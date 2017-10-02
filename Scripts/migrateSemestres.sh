#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

collection="paralelos"
table="semestres"

dbname=ppl
user="root"
password=$1
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="anio,termino"

rm /var/lib/mysql-files/*

mongoexport --db $dbname --collection $collection --type=csv --fields $fields --out $pathCSV;

cp $pathCSV $path

mysql -u $user -p$password $dbname -e "LOAD DATA INFILE '$path$table.csv' 
										INTO TABLE $table 
										CHARACTER SET UTF8 
										FIELDS TERMINATED BY ',' 
										ENCLOSED BY '\"' 
										LINES TERMINATED BY '\n' 
										IGNORE 1 ROWS
										($fields)"

#Eliminar registros repetidos
mysql -u $user -p$password $dbname -e "DELETE t1 FROM $table t1 INNER JOIN $table t2 
                       					WHERE t1.id < t2.id AND t1.termino = t2.termino AND t1.anio = t2.anio"



