#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

#http://www.thegeekstuff.com/2012/12/linux-tr-command																	#
#https://stackoverflow.com/questions/8949335/mongo-export-all-fields-data-from-collection-without-specifying-fields		#

#datos
table="profesores"
dbname=ppl
user="root"
password=$1
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,correo,nombres,apellidos"

rm /var/lib/mysql-files/*

mongoexport --db $dbname --collection $table --type=csv --fields $fields --out $pathCSV;

cp $pathCSV $path

mysql -u $user -p$password $dbname -e "LOAD DATA INFILE '$path$table.csv' 
										INTO TABLE $table 
										CHARACTER SET UTF8 
										FIELDS TERMINATED BY ',' 
										ENCLOSED BY '\"' 
										LINES TERMINATED BY '\n' 
										IGNORE 1 ROWS 
										(@_id,correo,nombres,apellidos)
										SET idMongo = @_id";

