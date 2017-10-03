#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

#http://www.thegeekstuff.com/2012/12/linux-tr-command																	#
#https://stackoverflow.com/questions/8949335/mongo-export-all-fields-data-from-collection-without-specifying-fields		#

#
config=$1
db_name=$2
table="profesores"
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="_id,correo,nombres,apellidos"

rm /var/lib/mysql-files/*

mongoexport --db $db_name --collection $table --type=csv --fields $fields --out $pathCSV;

cp $pathCSV $path

mysql --defaults-extra-file=$config $db_name -e "LOAD DATA INFILE '$path$table.csv' 
												INTO TABLE $table 
												CHARACTER SET UTF8 
												FIELDS TERMINATED BY ',' 
												ENCLOSED BY '\"' 
												LINES TERMINATED BY '\n' 
												IGNORE 1 ROWS 
												(@_id,correo,nombres,apellidos)
												SET idMongo = @_id";

