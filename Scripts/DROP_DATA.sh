#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

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

rm $config