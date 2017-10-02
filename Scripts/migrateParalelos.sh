#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

collection="paralelos"
table="paralelos"

dbname=ppl
user="root"
password=$1
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,nombre,codigo,anio,termino"

mongoexport --db $dbname --collection $collection --type=csv --fields $fields --out $pathCSV;

#Se crea procedimiento almacenado para actualizar el idMateria luego de ingresar los registros
mysql -u root -p$password ppl -e "delimiter //
									create procedure setIdSemestre(in anio1 int, in termino1 int)
									begin
										update $table
										set semestre_id = (select id from semestres where anio = anio1 and termino = termino1)
										ORDER BY id DESC
										LIMIT 1;
									end //
									delimiter ;"

mysql -u root -p$password ppl -e "delimiter //
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
		mysql -u root -p$password ppl -e "INSERT INTO $table(idMongo,nombre)
	                      						values('$col1','$col2');"
	    mysql -u root -p$password ppl -e "call setIdSemestre($col4,$col5);"
	    mysql -u root -p$password ppl -e "call setIdMateria('$col3');"
	fi
	let cont=cont+1
done < $pathCSV

#Se borra procedimiento almacenado
mysql -u root -p$password ppl -e "drop procedure setIdMateria"
mysql -u root -p$password ppl -e "drop procedure setIdSemestre"
