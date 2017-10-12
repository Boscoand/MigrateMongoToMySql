#!/bin/bash

##############################
#Autor: Jaminson Riascos M   #
#	    riascos@espol.edu.ec #
##############################

collection="profesores"
table="profesor_paralelos"

config=$1
db_name=$2



user="root"

path="/var/lib/mysql-files/"
pathCSV="../JSON/$table.json"
#Campos que se obtendrán
fields="_id,nivelPeer"


#Se exporta información de Mongo como un json
mongoexport --db $db_name --collection $collection --type=json --fields $fields --out $pathCSV;


#jq es un procesador de json para bash consultar ejemplos:http://www.compciv.org/recipes/cli/jq-for-parsing-json/


while IFS= read -r linea
do
  #Obtengo el id_mongo de un profesor
  profesor_id_mongo=$(echo $linea | jq '._id')
  profesor_id_mongo=$( echo $profesor_id_mongo | tr -d "\"")
  
  #obtengo el id_sql del profesor 
  profesor_id_sql=$(mysql --defaults-extra-file=$config $db_name -e "(select id from profesores where idMongo = \"$profesor_id_mongo\");") 
  profesor_id_sql=$( echo $profesor_id_sql  | cut -d ' ' -f2 )
  #echo $profesor_id_mongo

  #obtengo los id mongo de los paralelos
  paralelos_id_mongo=$(echo $linea | jq '.nivelPeer[].paralelo' )
  paralelos_id_mongo=$(echo $paralelos_id_mongo  | tr -d "\"")
  


  #obtengo los id mongo de los paralelos
  niveles=$(echo $linea | jq '.nivelPeer[].nivel' )
  niveles=$(echo $niveles  | tr -d "\"")

  #convierto la lista de id de paralelos en un arreglo
  IFS=" "  read -r -a arrayP <<< $paralelos_id_mongo

   #convierto la lista de id de paralelos en un arreglo
  IFS=" "  read -r -a arrayN <<< $niveles

  for ((i=0; i<${#arrayP[*]}; i++))      #for paralelo_id_mongo in "${arrayP[@]}"
  do
    #Obtener  mysql id del paralelo  
  	resultado=$(mysql --defaults-extra-file=$config $db_name -e "(select id from paralelos where idMongo = \"${arrayP[i]}\");") 
  	paralelo_sql_id=$( echo $resultado | cut -d ' ' -f2 )

    
    #Obtener  nivel del paralelo respectivo 
    g_r=${arrayN[$i]}
    g_r=$( echo $g_r | tr -d "\"")
    

  if [[ $paralelo_sql_id != "" ]]; then
   
    #Se ingresa registro en mysql
      mysql --defaults-extra-file=$config ppl -e "INSERT INTO $table(paralelo_id,profesor_id,grado_responsabilidad)
                                        values('$paralelo_sql_id','$profesor_id_sql','$g_r');"
    fi



  done

done < "$pathCSV"



