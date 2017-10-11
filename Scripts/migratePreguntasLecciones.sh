#!/bin/bash

##############################
#Autor: Jaminson Riascos M   #
#	    riascos@espol.edu.ec #
##############################

collection="lecciones"
table="preguntas_lecciones"

config=$1
db_name=$2



user="root"

path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.json"
#Campos que se obtendrán
fields="_id,preguntas"


#Se exporta información de Mongo como un json
mongoexport --db $db_name --collection $collection --type=json --fields $fields --out $pathCSV;


#jq es un procesador de json para bash consultar ejemplos:http://www.compciv.org/recipes/cli/jq-for-parsing-json/


while IFS= read -r linea
do
  #Obtengo el id_mongo de una leccion por iteracion
  leccion_id_mongo=$(echo $linea | jq '._id')
  leccion_id_mongo=$( echo $leccion_id_mongo | tr -d "\"")
  
  #obtengo el id_sql de la leccion 
  leccion_id=$(mysql --defaults-extra-file=$config $db_name -e "(select id from lecciones where idMongo = \"$leccion_id_mongo\");") 
  leccion_id=$( echo $leccion_id  | cut -d ' ' -f2 )

  #obtengo los id mongo de las preguntas de la leccion
  preguntas=$(echo $linea | jq '.preguntas[].pregunta')
  preguntas=$(echo $preguntas  | tr -d "\"")

  #convierto la lista de id de preguntas en un arreglo
  IFS=" "  read -r -a array <<< $preguntas
  for pregunta_id_mongo in "${array[@]}"
  do
  	#Obtener  mysql id de preguntas  de la leccion respectiva
	resultado=$(mysql --defaults-extra-file=$config $db_name -e "(select id from preguntas where idMongo = \"$pregunta_id_mongo\");") 
	pregunta_sql_id=$( echo $resultado | cut -d ' ' -f2 )

	#Se ingresa registro en mysql
		mysql --defaults-extra-file=$config ppl -e "INSERT INTO $table(pregunta_id,leccion_id)
		                 									values('$pregunta_sql_id','$leccion_id');"




  done

done < "$pathCSV"



