#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

password=$1

mysql -u root -p$password ppl -e "delete from lecciones where id > 0"
mysql -u root -p$password ppl -e "delete from grupos where id > 0"
mysql -u root -p$password ppl -e "delete from paralelos where id > 0"
mysql -u root -p$password ppl -e "delete from semestres where id > 0"
mysql -u root -p$password ppl -e "delete from capitulos where id > 0"
mysql -u root -p$password ppl -e "delete from materias where id > 0"
mysql -u root -p$password ppl -e "delete from profesores where id > 0"