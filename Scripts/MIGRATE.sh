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
#Migra la información de mongo a mysql 

#https://stackoverflow.com/questions/20751352/suppress-warning-messages-using-mysql-from-within-terminal-but-password-written/22933056#22933056

user=$1
password=$2
config="./config.cnf"
pathCSV="../CSV/*"
pathJSON="../JSON/*"
db_name="ppl"

echo "[client]
user=$user
password=$password
host=localhost
" > $config

echo -e "\e[41mMigrando \"Profesores\"\e[49m"
./migrateProfesores.sh $config $db_name
echo -e "\e[41mMigrando \"Materias\"\e[49m"
./migrateMaterias.sh $config $db_name
echo -e "\e[41mMigrando \"Capitulos\"\e[49m"
./migrateCapitulos.sh $config $db_name
echo -e "\e[41mMigrando \"Semestres\"\e[49m"
./migrateSemestres.sh $config $db_name
echo -e "\e[41mMigrando \"Paralelos\"\e[49m"
./migrateParalelos.sh $config $db_name
echo -e "\e[41mMigrando \"Grupos\"\e[49m"
./migrateGrupos.sh $config $db_name
echo -e "\e[41mMigrando \"Lecciones\"\e[49m"
./migrateLecciones.sh $config $db_name
echo -e "\e[41mMigrando \"Estudiantes\"\e[49m"
./migrateEstudiantes.sh $config $db_name
echo -e "\e[41mMigrando \"Preguntas\"\e[49m"
./migratePreguntas.sh $config $db_name
echo -e "\e[41mMigrando \"Preguntas_Lecciones\"\e[49m"
./migratePreguntasLecciones.sh $config $db_name
echo -e "\e[41mMigrando \"Respuestas\"\e[49m"
#./migrateRespuestas.sh $config $db_name
echo -e "\e[41mMigrando \"ProfesoresParalelos\"\e[49m"
./migrateProfesoresParalelos.sh $config $db_name


rm $pathCSV
rm $config
rm $pathJSON

#Corregir problema: no se puede guardar datos desde subl
	#sudo chown -R boscoand Documents/Pasantias/ppl/MigrateMongoToMySql/*
#Restaurar base de datos en mongo
	#mongorestore --db ppl <rutadb>
#Error “Data too long for column” - why?
	#install awk: sudo apt-get install gawk
