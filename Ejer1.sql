--3)
SELECT * from DBA_TABLESPACES WHERE TABLESPACE_NAME='ESPACIO1';
CREATE TABLESPACE ESPACIO1 DATAFILE 'espacio1.dbf' SIZE 10M AUTOEXTEND ON;
--4)
CREATE PROFILE PERF_USUARIO LIMIT
  FAILED_LOGIN_ATTEMPTS 3
  IDLE_TIME 5;
--5)
CREATE PROFILE PERF_PROGRAMADOR LIMIT
  SESSIONS_PER_USER 4
  PASSWORD_LIFE_TIME 30;
--6)
CREATE ROLE R_USUARIO;
GRANT CONNECT TO R_USUARIO;
GRANT CREATE TABLE TO R_USUARIO;
--7)
CREATE USER USUARIO1 IDENTIFIED BY usuario
  DEFAULT TABLESPACE ESPACIO1
  QUOTA 1M ON ESPACIO1
  PROFILE PERF_USUARIO;
GRANT R_USUARIO TO USUARIO1;
  
CREATE USER USUARIO2 IDENTIFIED BY usuario
  DEFAULT TABLESPACE ESPACIO1
  QUOTA 1M ON ESPACIO1
  PROFILE PERF_USUARIO;
GRANT R_USUARIO TO USUARIO2;
--8)
CREATE TABLE USUARIO1.TABLA2
 (  CODIGO NUMBER   ) ;
 
CREATE TABLE USUARIO2.TABLA2
 (  CODIGO NUMBER   ) ;
--9)
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2 (P_CODIGO IN NUMBER) AS BEGIN INSERT INTO TABLA2 VALUES (P_CODIGO);
END PR_INSERTA_TABLA2;
/
--10) Sí funciona
--11)
GRANT EXECUTE ON USUARIO1.PR_INSERTA_TABLA2 TO USUARIO2;
--12)Si funciona
--13)En la tabla del USUARIO1, ya que en ese usuario es donde se ejecuta el procedimiento.
--14)
CREATE OR REPLACE PROCEDURE USUARIO1.PR_INSERTA_TABLA2 (P_CODIGO IN NUMBER) AS BEGIN execute immediate 'INSERT INTO TABLA2 VALUES ('||P_CODIGO||')';
END PR_INSERTA_TABLA2;
/
--15)Si funciona
--16)Si funciona
--17)
CREATE OR REPLACE PROCEDURE USUARIO1.PR_CREA_TABLA (P_TABLA IN VARCHAR2, P_ATRIBUTO IN VARCHAR2) AS BEGIN EXECUTE IMMEDIATE 'CREATE TABLE '||P_TABLA||'('||P_ATRIBUTO||' NUMBER(9))';
END PR_CREA_TABLA;
/
--18)No funciona por problemas de privilegios.
--19)No funcionara
/* 20)Son cuentas predefinidas que crea Oracle al instalar. Si hacemos SELECT * FROM BDA_USER_WHIT_DEFPWD nos sale cuentas que son 
para ejemplos de cuenta de esquemas, que son meramentes cuentas que se utiliza de prueba para materiales de documentación o de instrucciones 
de la base de datos de Oracle; y Cuentas internas, las cuales son creadas paraq que las caracteristicas y componentes de la base de datos
de oracle tengan sus propios esquemas, las cuales no deben ser borradas, ni intertar entrar en ellas.*/
--21)
SELECT * FROM DBA_PROFILES;
/* Son COMPOSITE_LIMIT, SESSIONS_PER_USER, CPU_PER_SESSION, CPU_PER_CALL, LOGICAL_READS_PER_SESSION, LOGICAL_READS_PER_CALL, IDLE_TIME,
CONNECT_TIME, PRIVATE_SGA, FAILED_LOGIN_ATTEMPTS, PASSWORD_LIFE_TIME, PASSWORD_REUSE_TIME,PASSWORD_REUSE_MAX, PASSWORD_VERIFY_FUNCTION,
PASSWORD_LOCK_TIME, PASSWORD_GRACE_TIME.
*/
ALTER PROFILE DEFAULT LIMIT
  PASSWORD_GRACE_TIME 5
  FAILED_LOGIN_ATTEMPTS 3;

--Cuando se intenta ingresar por cuarta vez, nos sale que la cuanta esta bloqueada
ALTER USER USUARIO1 IDENTIFIED BY usuario ACCOUNT UNLOCK;

select value from v$parameter where name = 'sec_max_failed_login_attempts';
show PARAMETERS;

/*El failed_login_attempts sirve para bloquear una cuenta si algiuen intenta entrar en esa cuenta, 
mientras que el sec_max_failed_login_attempts sirve para que no se pueda enviar varias veces que te has
equivocadoal entrar. Sobretodo sirve para que no se haga un ataque DoS a la Base de Datos. */

/* Se puede eliminar con la intruccion DROP USER 'usuario' CASCADE;. Sin embargo no se puede borrar todos los
perfiles de oracle, ya que hay algunos predefinidos llamados "usuarios internos" que sirve para que funcione oracle perfectamente 
y no esta recomendado borrarlos. */

--La diferencia es que los dinámicos se van a cambiar casi constantemente sus valores, mientras que os estaticos es muy poco probable que se les cambie.
