#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

collection="paralelos"
table="paralelos"

config=$1
db_name=$2

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,nombre,codigo,anio,termino"

mongoexport --db $db_name --collection $collection --type=csv --fields $fields --out $pathCSV;

#Se crea procedimiento almacenado para actualizar el idMateria luego de ingresar los registros
mysql --defaults-extra-file=$config $db_name -e "delimiter //
												create procedure setIdSemestre(in anio1 int, in termino1 int)
												begin
													update $table
													set semestre_id = (select id from semestres where anio = anio1 and termino = termino1)
													ORDER BY id DESC
													LIMIT 1;
												end //
												delimiter ;"

mysql --defaults-extra-file=$config $db_name -e "delimiter //
												create procedure setIdMateria(in codigo1 varchar(50))
												begin
													update $table
													set materia_id = (select id from materias where codigo = codigo1)
													ORDER BY id DESC
													LIMIT 1;
												end //
												delimiter ;"

#Se lee archivo .csv con información de mongo
# col1 = _id
# col2 = nombre
# col3 = codigo
# col4 = anio
# col5 = termino

cont=0

while IFS=, read -r col1 col2 col3 col4 col5
do	
	if [ $cont -gt 0 ]
	then
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,nombre)
	                      								values('$col1','$col2');"
	    mysql --defaults-extra-file=$config $db_name -e "call setIdSemestre($col4,$col5);"
	    mysql --defaults-extra-file=$config $db_name -e "call setIdMateria('$col3');"
	fi
	let cont=cont+1
done < $pathCSV

#Se borra procedimiento almacenado
mysql --defaults-extra-file=$config $db_name -e "drop procedure setIdMateria"
mysql --defaults-extra-file=$config $db_name -e "drop procedure setIdSemestre"
