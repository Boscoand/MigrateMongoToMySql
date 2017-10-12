#!/bin/bash

##############################
#Autor: Jaminson Riascos M   #
#	    riascos@espol.edu.ec #
##############################

collection="respuestas"
table="respuestas"

config=$1
db_name=$2



user="root"

path="/var/lib/mysql-files/"
pathCSV="../JSON/$table.json"
#Campos que se obtendrán
fields="_id,estudiante,leccion,pregunta,respuesta,calificacion,feedback"


#Se exporta información de Mongo como un json
mongoexport --db $db_name --collection $collection --type=json --fields $fields --out $pathCSV;


#jq es un procesador de json para bash consultar ejemplos:http://www.compciv.org/recipes/cli/jq-for-parsing-json/

while IFS= read -r linea
do
  #Obtengo el id_mongo de una respuesta por iteracion
  respuesta_id_mongo=$(echo $linea | jq '._id')
  respuesta_id_mongo=$( echo $leccion_id_mongo | tr -d "\"")

  #Obtengo la respuesta del estudiante
  respuesta=$(echo $linea | jq '.respuesta')
  respuesta=$( echo $respuesta | tr -d "\"")

  #Obtengo la calificacion del estudiante
  calificacion=$(echo $linea | jq '.calificacion')
  calificacion=$( echo $calificacion | tr -d "\"")

  #Obtengo el feedback del estudiante
  feedback=$(echo $linea | jq '.feedback')
  feedback=$( echo $feedback | tr -d "\"")

  #Obtengo el id_mongo de una leccion por iteracion
  leccion_id_mongo=$(echo $linea | jq '.leccion')
  leccion_id_mongo=$( echo $leccion_id_mongo | tr -d "\"")
  
  #obtengo el id_sql de la leccion 
  leccion_id=$(mysql --defaults-extra-file=$config $db_name -e "(select id from lecciones where idMongo = \"$leccion_id_mongo\");") 
  leccion_id=$( echo $leccion_id  | cut -d ' ' -f2 )

  #obtengo los id mongo de la pregunta de la leccion
  pregunta=$(echo $linea | jq '.pregunta')
  pregunta=$(echo $preguntas  | tr -d "\"")

  
  #Obtener  mysql id de preguntas  de la leccion respectiva
	pregunta_sql_id=$(mysql --defaults-extra-file=$config $db_name -e "(select id from preguntas where idMongo = \"$pregunta\");") 
	pregunta_sql_id=$( echo $resultado | cut -d ' ' -f2 )

  #Obtengo el id_mongo del estudiante 
  estudiante_id_mongo=$(echo $linea | jq '.estudiante')
  estudiante_id_mongo=$( echo $estudiante_id_mongo | tr -d "\"")

  #Obtener  mysql id del estudiante respectivo
  estudiante_id_sql=$(mysql --defaults-extra-file=$config $db_name -e "(select id from estudiantes where idMongo = \"$estudiante_id_mongo\");") 
  estudiante_id_sql=$( echo $estudiante_id_sql | cut -d ' ' -f2 )
  #echo $estudiante_id_mongo
  #echo $estudiante_id_sql


  #obtengo el id_sql de la pregunta_respuesta 
  p_r_id=$(mysql --defaults-extra-file=$config $db_name -e "(select id from preguntas_lecciones where pregunta_id = \"$pregunta_sql_id\" and  leccion_id = \"$leccion_id\");") 
  p_r_id=$( echo $leccion_id  | cut -d ' ' -f2 )

  #Verificacion de respuestas vacias
  mysql --defaults-extra-file=$config ppl -e "INSERT INTO $table(idMongo,estudiante_id,pregunta_leccion_id,respuesta,calificacion,feedback,imagen_url)
                                      values('$respuesta_id_mongo','$estudiante_id_sql','$p_r_id','\"$respuesta\"','$calificacion','\"$feedback\"',NULL);"




	




  

done < "$pathCSV"



