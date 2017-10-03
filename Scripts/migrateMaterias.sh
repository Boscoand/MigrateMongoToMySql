#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

#https://stackoverflow.com/questions/12891337/mysql-load-data-infile-ignore-duplicate-rows-autoincrement-as-primary-key
#http://www.mysqltutorial.org/mysql-delete-duplicate-rows/

collection="paralelos"
table="materias"
config=$1
db_name=$2
path="/var/lib/mysql-files/"
pathCSV="../CSV/$table.csv"
fields="codigo,nombreMateria"

rm /var/lib/mysql-files/*

mongoexport --db $db_name --collection $collection --type=csv --fields $fields --out $pathCSV;

cp $pathCSV $path

mysql --defaults-extra-file=$config $db_name -e "LOAD DATA INFILE '$path$table.csv' 
												IGNORE INTO TABLE $table 
												CHARACTER SET UTF8 
												FIELDS TERMINATED BY ',' 
												ENCLOSED BY '\"' 
												LINES TERMINATED BY '\n' 
												IGNORE 1 ROWS
												(codigo,@nombreMateria)
												set nombre=@nombreMateria";
#Eliminar materias repetidas. 
mysql --defaults-extra-file=$config $db_name -e "DELETE t1 FROM materias t1 INNER JOIN materias t2 
                       							WHERE t1.id < t2.id AND t1.codigo = t2.codigo"

