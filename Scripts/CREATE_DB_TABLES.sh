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

mysql --defaults-extra-file=$config -e "create database ppl DEFAULT CHARACTER SET utf8mb4;"

#mysql --defaults-extra-file=$config ppl -e "ALTER DATABASE ppl CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

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
											);ALTER TABLE materias AUTO_INCREMENT = 1;"


mysql --defaults-extra-file=$config ppl -e "create table capitulos(
												id int auto_increment,
												idMongo varchar(50) not null,
												nombre varchar(100) not null,
												materia_id int,
												primary key (id),
												foreign key (materia_id) references materias(id)
											);ALTER TABLE capitulos AUTO_INCREMENT = 1;"

mysql --defaults-extra-file=$config ppl -e "create table semestres(
												id int auto_increment,
												anio int not null, 
												termino int not null, 
												primary key (id)
											);ALTER TABLE semestres AUTO_INCREMENT = 1;"

mysql --defaults-extra-file=$config ppl -e "create table paralelos(
												id int auto_increment,
												idMongo varchar(50), 
												nombre varchar(50) not null,
												materia_id int,
												semestre_id int,
												primary key (id),
												foreign key (materia_id) references materias(id),
												foreign key (semestre_id) references semestres(id)
											);ALTER TABLE paralelos AUTO_INCREMENT = 1;"

mysql --defaults-extra-file=$config ppl -e "create table grupos(
												id int auto_increment,
												idMongo varchar(50),
												nombre varchar(50) not null,
												paralelo_id int,
												primary key (id),
												foreign key (paralelo_id) references paralelos(id)
											);ALTER TABLE grupos AUTO_INCREMENT = 1;"								

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
											);ALTER TABLE lecciones AUTO_INCREMENT = 1;"	


mysql --defaults-extra-file=$config ppl -e "create table estudiantes(
												id int auto_increment,
												idMongo varchar(50) not null,
												nombres varchar(100) not null,
												apellidos varchar(100) not null,
												correo varchar(50) not null,
												matricula varchar(10) not null,
												foto_url text, 
												grupo_id int,
												paralelo_id int not null,
												primary key (id),
												foreign key (grupo_id) references grupos(id),
												foreign key (paralelo_id) references paralelos(id)
											);ALTER TABLE estudiantes AUTO_INCREMENT = 1;"			



mysql --defaults-extra-file=$config ppl -e "create table preguntas(
												id int auto_increment,
												idMongo varchar(50) not null,
												profesor_id int not null,
												nombre varchar(100),
												tipo_leccion varchar(20),
												tipo_pregunta varchar(20),
												capitulo_id int, 
												tiempo_estimado int not null,
												descripcion  MEDIUMTEXT not null,
												puntaje double not null,
												pregunta_raiz int,
												primary key (id),
												foreign key (profesor_id) references profesores(id),
												foreign key (capitulo_id) references capitulos(id),
												foreign key (pregunta_raiz) references preguntas(id)
											);ALTER TABLE preguntas AUTO_INCREMENT = 1;"	


mysql --defaults-extra-file=$config ppl -e "create table preguntas_lecciones(
												id int auto_increment,
												pregunta_id int not null,
												leccion_id int not null,
												primary key (id),
												foreign key (pregunta_id) references preguntas(id),
												foreign key (leccion_id) references lecciones(id)
											);ALTER TABLE preguntas_lecciones AUTO_INCREMENT = 1;"	

mysql --defaults-extra-file=$config ppl -e "create table respuestas(
												id int auto_increment,
												idMongo varchar(50) not null,
												estudiante_id int not null,
												pregunta_leccion_id int not null,
												respuesta  MEDIUMTEXT,
												calificacion double,
												feedback  MEDIUMTEXT, 
												imagen_url text,
												leccion_id int,
												primary key (id),
												foreign key (estudiante_id) references estudiantes(id),
												foreign key (leccion_id) references lecciones(id),
												foreign key (pregunta_leccion_id) references preguntas_lecciones(id)
											);ALTER TABLE respuestas AUTO_INCREMENT = 1;"			

mysql --defaults-extra-file=$config ppl -e "create table profesor_paralelos(
												id int auto_increment,
												paralelo_id int not null,
												profesor_id int not null,
												grado_responsabilidad int,
												primary key (id),
												foreign key (paralelo_id) references paralelos(id),
												foreign key (profesor_id) references profesores(id)
											);ALTER TABLE profesor_paralelos AUTO_INCREMENT = 1;"	

				

rm $config