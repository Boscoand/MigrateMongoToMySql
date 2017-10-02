#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

password=$1
pathCSV="../CSV/*"

./migrateProfesores.sh $password
./migrateMaterias.sh $password
./migrateCapitulos.sh $password
./migrateSemestres.sh $password
./migrateParalelos.sh $password
./migrateGrupos.sh $password
./migrateLecciones.sh $password

rm $pathCSV

#sudo chown -R boscoand Documents/Pasantias/ppl/MigrateMongoToMySql/*