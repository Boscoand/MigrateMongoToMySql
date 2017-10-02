# MigrateMongoToMySql
Scripts para migrar una base de datos en mongo a mysql

#Funcionamiento
-Ubicarse en la carpeta de scripts: cd Scripts/
-Ejecutar lo siguiente como usuario root (sudo -s):
    * ./CREATE_DB_TABLES.sh <passwordDataBaseMySql>
    * ./MIGRATE.sh <passwordDataBaseMySql>
-Asegurarse que no exista una base de datos llamada ppl en su base de datos. Si existe, ejecutar:
    * ./DROP_DB.sh <passwordDataBaseMySql>
    
#Funcionalidad
Protecto PPL.
Migra base de datos no relacional creada en mongo a mysql.
