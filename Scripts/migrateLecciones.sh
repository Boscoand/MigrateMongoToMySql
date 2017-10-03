#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

collection="lecciones"
table="lecciones"

config=$1
db_name=$2

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
#Campos que se obtendrán
fields="_id,estado,tiempoEstimado,puntaje,tipo,codigo,creador,paralelo,fechaInicio,nombre"

# #Procedimiento para obtener profesor_id
mysql --defaults-extra-file=$config $db_name -e "delimiter //
													create procedure profesor_id(in idMongo1 varchar(50))
													begin
														update $table
														set profesor_id = (select id from profesores where idMongo = idMongo1)
														ORDER BY id DESC
														LIMIT 1;
													end //
													delimiter ;"

# #Procedimiento para obtener paralelo_id									
mysql --defaults-extra-file=$config $db_name -e "delimiter //
												create procedure paralelo_id(in idMongo1 varchar(50))
												begin
													update $table
													set paralelo_id = (select id from paralelos where idMongo = idMongo1)
													ORDER BY id DESC
													LIMIT 1;
												end //
												delimiter ;"

#Se exporta información de Mongo
mongoexport --db $db_name --collection $collection --type=csv --fields $fields --out $pathCSV;


# Fuente: https://stackoverflow.com/questions/8940352/how-to-handle-commas-within-a-csv-file-being-read-by-bash-script
# Otra forma de leer los csv, ahora respetando los string que se encuetran dentro de "" y las ','
# Básicamente lo que hice fue cambiar el separador (,) por ☺ para que no dieran problemas. Ej: "Capacitancia, corriente"
echo "$(awk '{ 	for (i = 0; ++i <= NF;) {
   					substr($i, 1, 1) == "\"" && 
    				$i = substr($i, 2, length($i) - 2)
   					printf "%s☺", $i
    		 	}   
    		 	printf("\n")
 			 }' FPAT='([^,]+)|("[^"]+")|()' $pathCSV)" > tmp.txt

cont=0
#Separador ☺ improvisado
while IFS="☺" read -r _id estado tiempoEstimado puntaje tipo codigo creador paralelo fechaInicio nombre
do
	if [ $cont -gt 0 ] 
	then
		#modificación en formato de date
		fechaInicio=$(echo $fechaInicio | cut -d 'T' -f1)
		#Debido a que hay campos de fechas vacios hay que hacer esta validación
		if [[ $fechaInicio = '' ]]; then
			fechaInicio="2000-01-01"
		fi
		#Copia de información en mysql
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,estado,tiempo_estimado,puntaje,tipo,codigo,fecha_evaluacion,nombre)
			                  			  values('$_id','$estado','$tiempoEstimado','$puntaje','$tipo','$codigo','$fechaInicio','$nombre');"
		mysql --defaults-extra-file=$config $db_name -e "call paralelo_id('$paralelo');"		                  			  
		mysql --defaults-extra-file=$config $db_name -e "call profesor_id('$creador');"
	fi
	let cont=cont+1
done < tmp.txt

mysql --defaults-extra-file=$config $db_name -e "drop procedure paralelo_id"
mysql --defaults-extra-file=$config $db_name -e "drop procedure profesor_id"

rm tmp.txt