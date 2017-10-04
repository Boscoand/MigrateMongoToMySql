#!/bin/bash

#############################
#Autores: 					#
#->   Bosco Andrade Bravo   #
#		@boscoand     		#
#							#
#->   Jaminson Riascos M    #
#	  riascos@espol.edu.ec  #
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
												tiempo_estimado int,
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


mysql --defaults-extra-file=$config ppl -e "create table estudiantes(
												id int auto_increment,
												idMongo varchar(50),
												nombres varchar(100),
												apellidos varchar(100),
												correo varchar(50),
												matricula varchar(10),
												foto_url varchar(200), 
												grupo_id int,
												paralelo_id int,
												primary key (id),
												foreign key (grupo_id) references grupos(id),
												foreign key (paralelo_id) references paralelos(id)
											);"			



mysql --defaults-extra-file=$config ppl -e "create table preguntas(
												id int auto_increment,
												idMongo varchar(50),
												profesor_id int,
												nombre varchar(20),
												tipo_leccion varchar(20),
												tipo_pregunta varchar(20),
												capitulo_id int, 
												tiempo_estimado int,
												descripcion varchar(1000),
												puntaje double,
												pregunta_raiz int,
												primary key (id),
												foreign key (profesor_id) references profesores(id),
												foreign key (capitulo_id) references capitulos(id),
												foreign key (pregunta_raiz) references preguntas(id)
											);"	


mysql --defaults-extra-file=$config ppl -e "create table preguntas_lecciones(
												id int auto_increment,
												idMongo varchar(50),
												estudiante_id int,
												pregunta_id int,
												leccion_id int,
												primary key (id),
												foreign key (estudiante_id) references estudiantes(id),
												foreign key (pregunta_id) references preguntas(id),
												foreign key (leccion_id) references lecciones(id)
											);"	

mysql --defaults-extra-file=$config ppl -e "create table respuestas(
												id int auto_increment,
												idMongo varchar(50),
												estudiante_id int,
												pregunta_leccion_id int,
												respuesta varchar(500),
												calificacion double,
												feedback varchar(500), 
												imagen_url varchar(200),
												leccion_id int,
												primary key (id),
												foreign key (estudiante_id) references estudiantes(id),
												foreign key (leccion_id) references lecciones(id),
												foreign key (pregunta_leccion_id) references preguntas_lecciones(id)
											);"			

mysql --defaults-extra-file=$config ppl -e "create table profesor_paralelos(
												id int auto_increment,
												idMongo varchar(50),
												paralelo_id int,
												profesor_id int,
												grado_responsabilidad int,
												primary key (id),
												foreign key (paralelo_id) references paralelos(id),
												foreign key (profesor_id) references profesores(id)
											);"					

rm $config