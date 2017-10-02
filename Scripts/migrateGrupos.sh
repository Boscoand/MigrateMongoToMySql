#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

#https://stackoverflow.com/questions/10586153/split-string-into-an-array-in-bash
#https://stackoverflow.com/questions/428109/extract-substring-in-bash
#http://tldp.org/LDP/abs/html/comparison-ops.html

collection="paralelos"
table="grupos"

dbname=ppl
user="root"
password=$1
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,grupos"

mongoexport --db $dbname --collection $collection --type=csv --fields $fields --out $pathCSV;

#Se crea procedimiento almacenado para actualizar el paralelo_id
mysql -u root -p$password ppl -e "delimiter //
									create procedure paralelo_id(in paralelo_id varchar(50))
									begin
										update $table
										set paralelo_id = (select id from paralelos where idMongo = paralelo_id)
										ORDER BY id DESC
										LIMIT 1;
									end //
									delimiter ;"

#Función exclusiva para manejar formato que devuelve mongoexport en "grupos"
#col1 = _id (id de paralelo al que pertenecen los grupos)
#col2 = grupos (json con los id de los grupos)
while IFS=, read -r col1 col2
do
	#Obtener id de todos los grupos de paralelo respectivo
	var=$( echo $col2 | tr -d "\n\"[]")
	IFS=, read -r -a array <<< $var
	
	#Obtener nombres de grupos almancenados en $var
	for grupo_idMongo in "${array[@]}"
	do
	    #Obtener nombre
		resultado=`mongo ppl --eval "db.grupos.find({\"_id\":\"$grupo_idMongo\"},{\"nombre\":1});"`
		nombreGrupo=$( echo $resultado | cut -d '"' -f8 )
		
		#Se valida que el grupo sea válido y tenga información
		if [[ $nombreGrupo != Mongo* ]]; then
			#Se ingresa registro en mysql
			mysql -u root -p$password ppl -e "INSERT INTO $table(idMongo,nombre)
		                  						values('$grupo_idMongo','$nombreGrupo');"
			mysql -u root -p$password ppl -e "call paralelo_id('$col1');"
		fi

	done
done < $pathCSV

mysql -u root -p$password ppl -e "drop procedure paralelo_id"
