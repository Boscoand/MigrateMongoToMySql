#!/bin/bash

##############################
#Autor: Jaminson Riascos M   #
#	    riascos@espol.edu.ec #
##############################

collection="estudiantes"
table="estudiantes"

config=$1
db_name=$2



user="root"

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
#Campos que se obtendrán
fields="_id,nombres,apellidos,correo,matricula"


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
while IFS="☺" read -r _id nombres apellidos correo matricula
do
	if [ $cont -gt 0 ] 
	then
		#Obtengo el id del grupo
		resultado=$(mongo ppl --eval "db.grupos.find({\"estudiantes\":{ \"\$all\": [\"$_id\"]}},{\"_id\":1});")
		#La función cut, corta el string hasta el " y luego selecciona el cuarto campo del string.
		grupo_id_mongo=$(echo $resultado | cut -d '"' -f4)
		
		temp=$(mysql --defaults-extra-file=$config $db_name -e "(select id from grupos where idMongo = \"$grupo_id_mongo\");") 
		grupo_id_sql=$(echo $temp | cut -d ' ' -f2)


		#obtengo el id del paralelo
		resultado=$(mongo ppl --eval "db.paralelos.find({\"grupos\":{ \"\$all\": [\"$grupo_id_mongo\"]}},{\"_id\":1});")
		
		paralelo_id_mongo=$(echo $resultado | cut -d '"' -f4)



		temp=$(mysql --defaults-extra-file=$config $db_name -e "(select id from paralelos where idMongo = \"$paralelo_id_mongo\");") 
		paralelo_id_sql=$(echo $temp | cut -d ' ' -f2)
		
		#echo  -e "$paralelo_id_sql"


		#guardo en base de datos sql
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,nombres,apellidos,correo,matricula,foto_url,grupo_id,paralelo_id)
			                  			  values('$_id','$nombres','$apellidos','$correo','$matricula',NULL,'$grupo_id_sql','$paralelo_id_sql');"

	fi
	let cont=cont+1
done < tmp.txt


rm tmp.txt
