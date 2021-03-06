#!/bin/bash

#############################
#Autores: 					#
#->   Bosco Andrade Bravo   #
#		@boscoand     		#
#							#
#->   Jaminson Riascos M    #
#	  riascos@espol.edu.ec  #
#############################

#FUNCIONALIDAD:
#Borra los registros de todas las tablas de la base de datos ppl

user=$1
password=$2
config="./config.cnf"
db_name="ppl"

echo "[client]
user=$user
password=$password
host=localhost
" > $config

echo -e "\e[41mBorrando registros de base de datos \"ppl\"\e[49m"
mysql --defaults-extra-file=$config $db_name -e "delete from lecciones where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from grupos where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from paralelos where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from semestres where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from capitulos where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from materias where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from profesores where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from estudiantes where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from preguntas where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from preguntas_lecciones where id > 0"
mysql --defaults-extra-file=$config $db_name -e "delete from profesores_paralelos where id > 0"

rm $config