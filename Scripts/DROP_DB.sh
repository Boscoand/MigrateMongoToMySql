#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

user=$1
password=$2
config="./config.cnf"

echo "[client]
user=$user
password=$password
host=localhost
" > $config

echo -e "\e[41mBorrando base de datos \"ppl\"\e[49m"
mysql --defaults-extra-file=$config ppl -e "drop database ppl"

rm $config