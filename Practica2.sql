--------- CONEXIÓN DESDE SYS AS SYSDBA ---------
-- 3)
create or replace directory directorio_ext as 'c:\app\alumnos';
-- 4) Creamos los tablespaces y el usuario

create tablespace tp_user datafile 'tp_user.dbf' size 10M autoextend on;

create user User1 identified by user1
default tablespace tp_user
quota 100M on tp_user; 
  
-- 5) Le damos permiso al usuario User1

grant read, write on directory directorio_ext to User1;
grant connect, create table to User1;

--------- CONEXIÓN DESDE User1 ---------
 
-- 7) Crear la tabla
     create table empleado_externo
        ( empl_id varchar2(3),
          apellido varchar2(50),
          nombre varchar2(50),
          dni varchar2(9),
          usuario varchar2(20),
         email varchar2(100)
        )
        organization external
       ( default directory directorio_ext
         access parameters
         ( records delimited by newline
           fields terminated by ','
         )
         location ('empleados.txt')  
     );
     
-- 8)
SELECT * FROM EMPLEADO_EXTERNO;
-- Sí funciona cualquier operacion de insercción,busqueda... para EMPLEADOS_EXTERNO

-- 9)
--Creamos la tabla EMPLEADOS
create table empleados
        ( empl_id varchar2(3),
          apellido varchar2(50),
          nombre varchar2(50),
          dni varchar2(9),
          usuario varchar2(20),
         email varchar2(100)
        );
--Y utilizamos la instrucción
INSERT INTO EMPLEADOS SELECT * FROM EMPLEADO_EXTERNO; 

--Sin embargo es mejor ejecutar esta secuencia que hacer una tabla para luego insertar todo eso
create table empleado as select * from EMPLEADO_EXTERNO;

-- 10) 
SELECT * FROM USER_INDEXES;
-- La tabla no tiene ningun indice

--------- CONEXIÓN DESDE SYS AS SYSDBA ---------
--11)
alter table User1.EMPLEADO add primary key (empl_id);

create index uppercase_idx1 on User1.EMPLEADO (UPPER(Nombre),UPPER(Apellido));
create index upperemp_idx2 on User1.EMPLEADO (UPPER(Apellido),UPPER(Nombre));
create index emp_idx3 on User1.EMPLEADO (DNI,Nombre,Apellido);

--------- CONEXIÓN DESDE User1 ---------

create index nocase_idx1 on User1.EMPLEADO (Nombre,Apellido);
-- Ahora si salen los índices en la tabla USER_INDEXES.

-- 12) 
-- La tabla empleados en tp_user que es el tablespace que creé para que lo usara User1,
-- y los índices se han creado en el tablespace SYSTEM. Al darme cuenta de esto ahora mismo he probado a crear otro índice
-- desde User1, éste sí que se creó también en tp_user

