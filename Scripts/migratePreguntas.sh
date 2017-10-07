#!/bin/bash

##############################
#Autor: Jaminson Riascos M   #
#	    riascos@espol.edu.ec #
##############################

collection="preguntas"
table="preguntas"

config=$1
db_name=$2



user="root"

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
#Campos que se obtendrán
fields="_id,nombre,creador,tipoLeccion,tipoPregunta,tiempoEstimado,puntaje,capitulo"


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
while IFS="☺" read -r _id nombre creador tipoLeccion tipoPregunta tiempoEstimado puntaje capitulo
do
	if [ $cont -gt 0 ] 
	then
		#Obtengo el id del capitulo
		resultado=$(mongo ppl --eval "db.capitulos.find({\"nombre\": \"$capitulo\"},{\"_id\":1});")  
		#La función cut, corta el string hasta el " y luego selecciona el cuarto campo del string.
		capitulo_id_mongo=$(echo $resultado | cut -d '"' -f4)
		
		temp=$(mysql --defaults-extra-file=$config $db_name -e "(select id from capitulos where idMongo = \"$capitulo_id_mongo\");") 
		capitulo_id_sql=$(echo $temp | cut -d ' ' -f2)


		#Obtengo el id del creador
		temp=$(mysql --defaults-extra-file=$config $db_name -e "(select id from profesores where idMongo = \"$creador\");") 
		creador_id_sql=$(echo $temp | cut -d ' ' -f2)
		
		#Obtengo la descripcion de la pregunta
		resultado=$(mongo ppl --eval "db.preguntas.find({\"_id\":\"$_id\"},{\"descripcion\":1});")
		#La función cut, corta el string hasta el " y luego selecciona el cuarto campo del string.
		descripcion=$(echo $resultado | cut -d '"' --complement -s -f1-7)
		#elimino los ultimos 3 caracteres del string
		descripcion=${descripcion::-3}
		

	
		#echo  -e "$_id"
		
		if [ "$capitulo_id_sql" = "" ]
		then
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,nombre,profesor_id,tipo_leccion,tipo_pregunta,capitulo_id,tiempo_estimado,descripcion,puntaje,pregunta_raiz)
			                  			  values('$_id','$nombre','$creador_id_sql','$tipoLeccion','$tipoPregunta',NULL,'$tiempoEstimado',\"$descripcion\",'$puntaje',NULL);"
		
		else
		
		mysql --defaults-extra-file=$config $db_name -e "INSERT INTO $table(idMongo,nombre,profesor_id,tipo_leccion,tipo_pregunta,capitulo_id,tiempo_estimado,descripcion,puntaje,pregunta_raiz)
			                  			  values('$_id','$nombre','$creador_id_sql','$tipoLeccion','$tipoPregunta','$capitulo_id_sql','$tiempoEstimado',\"$descripcion\",'$puntaje',NULL);"
		
		fi

	fi
	let cont=cont+1
done < tmp.txt


rm tmp.txt
