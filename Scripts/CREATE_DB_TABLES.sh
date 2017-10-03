#!/bin/bash

#############################
#Autor: Bosco Andrade Bravo #
#		@boscoand           #
#############################

#FUNCIONALIDAD:
#Crea la base de datos ppl y sus respectivas tablas

user=$1
password=$2
config="./config.cnf"

echo "[client]
user=$user
password=$password
host=localhost
" > $config

echo -e "\e[41mCreando base de datos \"ppl\"\e[49m"

mysql --defaults-extra-file=$config -e "create database ppl;"

mysql --defaults-extra-file=$config ppl -e "create table profesores(
												id int auto_increment,
												idMongo varchar(50), 
												correo varchar(50) not null,
												nombres varchar(50) not null,
												apellidos varchar(50) not null,
												primary key (id)
											);"

mysql --defaults-extra-file=$config ppl -e "create table materias(
												id int auto_increment,
												codigo varchar(50) not null,
												nombre varchar(50) not null,
												profesor_id int,
												primary key (id),
												foreign key (profesor_id) references profesores(id)
											);"

mysql --defaults-extra-file=$config ppl -e "create table capitulos(
												id int auto_increment,
												idMongo varchar(50) not null,
												nombre varchar(100) not null,
												materia_id int,
												primary key (id),
												foreign key (materia_id) references materias(id)
											);"

mysql --defaults-extra-file=$config ppl -e "create table semestres(
												id int auto_increment,
												anio int not null, 
												termino int not null, 
												primary key (id)
											);"

mysql --defaults-extra-file=$config ppl -e "create table paralelos(
												id int auto_increment,
												idMongo varchar(50), 
												nombre varchar(50) not null,
												materia_id int,
												semestre_id int,
												primary key (id),
												foreign key (materia_id) references materias(id),
												foreign key (semestre_id) references semestres(id)
											);"

mysql --defaults-extra-file=$config ppl -e "create table grupos(
												id int auto_increment,
												idMongo varchar(50),
												nombre varchar(50) not null,
												paralelo_id int,
												primary key (id),
												foreign key (paralelo_id) references paralelos(id)
											);"								

mysql --defaults-extra-file=$config ppl -e "create table lecciones(
												id int auto_increment,
												idMongo varchar(50),
												nombre varchar(100),
												estado varchar(50),
												tiempo_estimado double,
												puntaje double, 
												tipo varchar(50),
												codigo varchar(50),
												profesor_id int,
												paralelo_id int,
												fecha_evaluacion date,
												primary key (id),
												foreign key (profesor_id) references profesores(id),
												foreign key (paralelo_id) references paralelos(id)
											);"								

rm $config