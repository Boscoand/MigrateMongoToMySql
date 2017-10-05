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
		#Copia de información en mysql
		
		#Obtengo el id del grupo
		resultado=`mongo ppl --eval "db.grupos.find({\"estudiantes\":{ \"\$all\": [\"$_id\"]}},{"_id":1});"`
		grupo_id=$( echo $resultado | cut -d '"' -f8 )
		echo -e "\e[41m$grupo_id"
		
		
		#mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,nombres,apellidos,correo,matricula,foto_url,grupo_id)
		#	                  			  values('$_id','$nombres','$apellidos','$correo','$matricula',NULL,'$grupo_id');"

	fi
	let cont=cont+1
done < tmp.txt

mysql --defaults-extra-file=$config $db_name -e "drop procedure paralelo_id"
mysql --defaults-extra-file=$config $db_name -e "drop procedure profesor_id"

rm tmp.txt


