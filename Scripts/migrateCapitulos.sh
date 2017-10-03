#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

collection="capitulos"
table="capitulos"

config=$1
db_name=$2

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,codigoMateria,nombre"

mongoexport --db $db_name --collection $collection --type=csv --fields $fields --out $pathCSV;

#Se crea procedimiento almacenado para actualizar el idMateria luego de ingresar los registros
mysql --defaults-extra-file=$config $db_name -e "delimiter //
												create procedure actualizarIdMateria(in idmateria varchar(50))
												begin
													update capitulos
													set materia_id = (select id from materias m where m.codigo = idmateria)
													ORDER BY id DESC
													LIMIT 1;
												end //
												delimiter ;"

#Se lee archivo .csv con información de mongo
# col1 = _id = idMongo
# col2 = codigoMateria = tmp
# col3 = nombre = nombre
cont=0
while IFS=, read -r col1 col2 col3
do	
	if [ $cont -gt 0 ]
	then
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO capitulos(idMongo,nombre)
	                      									values('$col1','$col3');"
	    mysql --defaults-extra-file=$config $db_name -e "call actualizarIdMateria('$col2');"
	fi
	let cont=cont+1
done < $pathCSV

#Se borra procedimiento almacenado
mysql --defaults-extra-file=$config $db_name -e "drop procedure actualizarIdMateria"
