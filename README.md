
# Funcionalidad
```sh
> Protecto PPL.
> Migra base de datos no relacional creada en mongo a mysql.
```
# Dependencias
```sh
> MySql
> Mongo (Con base de datos ppl cargada)
    > mongorestore --db ppl <rutadb>
> AWK
    > sudo apt-get install gawk
```

# Ejecución
```sh
> Ubicarse en la carpeta de scripts: cd Scripts/

> Ejecutar lo siguiente como usuario root (sudo -s):
    > ./CREATE_DB_TABLES.sh <userMySql> <passwordDataBaseMySql>   #Crea base de datos y tablas respectivas
    > ./MIGRATE.sh <userMySql> <passwordDataBaseMySql>            #Migra la información de mongo a mysql
    
> Asegurarse que no exista una base de datos llamada ppl en su base de datos. Si existe, ejecutar:
    >  ./DROP_DB.sh <userMySql> <passwordDataBaseMySql>           #Borra base de datos ppl
```
   
