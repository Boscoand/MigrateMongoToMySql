#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

password=$1

mysql -u root -p$password ppl -e "drop database ppl"

#DROP_DB.sh
#CREATE_DB_TABLES.sh
#MIGRATE.sh