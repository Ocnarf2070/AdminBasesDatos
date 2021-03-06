GRANT CREATE procedure to PRACTICA2-- 1
CREATE TABLE DATOS 
(
  CODIGO NUMBER(9) 
, NOMBRE VARCHAR2(15) 
, FECHA DATE 
);

-- 2
CREATE SEQUENCE SECUENCIA_DATOS INCREMENT BY 3 START WITH 100;

--3 
CREATE OR REPLACE FUNCTION NUM_ALEATORIO 
(
  NUM IN NUMBER 
) RETURN NUMBER AS 
  LIMS NUMBER;
  LIMINF NUMBER;
  RETORNO NUMBER;
BEGIN
  LIMS := POWER(10,NUM);
  LIMINF:= POWER(10,NUM-1);
  RETORNO := TRUNC(DBMS_RANDOM.VALUE(LIMINF,LIMS));
  RETURN RETORNO;
END NUM_ALEATORIO;

-- 4
CREATE OR REPLACE FUNCTION CADENA_ALEATORIA 
(
  NUM IN NUMBER 
) RETURN VARCHAR2 AS 
RETORNO VARCHAR2(5000);
BEGIN
RETORNO := DBMS_RANDOM.STRING('U',NUM);
  RETURN RETORNO;
END CADENA_ALEATORIA;

-- 5
CREATE OR REPLACE FUNCTION CALCULAR_FECHA 
(
  FECHA IN DATE 
, DIA_SEM IN VARCHAR2 
, NUMERO IN NUMBER 
) RETURN DATE AS 
NEWDATE DATE;
BEGIN
  NEWDATE:= NEXT_DAY(FECHA+NUMERO, DIA_SEM);
  RETURN NEWDATE;
END CALCULAR_FECHA;

-- 6
CREATE OR REPLACE PROCEDURE RELLENAR 
(
  NUM IN NUMBER 
) AS 
NUMAUX NUMBER;
CODIGO NUMBER;
NOMBRE VARCHAR(15);
FECHA DATE;
BEGIN

--COMPROBACI�N N�MERO
    IF NUM < 100 THEN
      NUMAUX := 100;
    ELSE
      NUMAUX := NUM;
    END IF;
  
-- INSERCI�N EN TABLA
    FOR i IN 1..NUMAUX LOOP
      CODIGO := SECUENCIA_DATOS.NEXTVAL;
      NOMBRE := CADENA_ALEATORIA(15);
      FECHA := CALCULAR_FECHA(SYSDATE,'JUEVES', NUMAUX);
      INSERT INTO DATOS VALUES (CODIGO,NOMBRE,FECHA);
      END LOOP;

END RELLENAR;

-- 7

CREATE TABLE TB_OBJETOS 
(
  NOMBRE VARCHAR2(30) 
, CODIGO NUMBER 
, FECHA_CREACION DATE
, FECHA_MODIFICACION DATE
, TIPO VARCHAR2(19) 
, ESQUEMA_ORIGINAL VARCHAR2(30) 
);

DECLARE
  CURSOR C_ALLOBJECTS IS SELECT OBJECT_NAME, OBJECT_ID,CREATED,LAST_DDL_TIME,OBJECT_TYPE,OWNER FROM ALL_OBJECTS;
BEGIN
  FOR OBJECT_NAME IN C_ALLOBJECTS LOOP
  insert INTO TB_OBJETOS VALUES OBJECT_NAME;
  END LOOP;
END;

-- 8
CREATE TABLE TB_ESTILO 
(
  TIPO_OBJETO VARCHAR2(19) 
, PREFIJO VARCHAR(15)  
);

-- 9
ALTER TABLE TB_OBJETOS 
ADD (ESTADO VARCHAR2(30) );

ALTER TABLE TB_OBJETOS 
ADD (NOMBRE_CORRECTO VARCHAR2(30) );

create or replace PROCEDURE PR_COMPROBAR 
(
  ESQUEMA IN VARCHAR2 
) AS 
aux varchar2(500);
BEGIN

    IF (ESQUEMA IS NULL) -- CUANDO EL ESQUEMA NO EST� DEFINIDO
    THEN 
-- AQU� USAMOS EL CURSOR PARA RECORRER, Y SINO LE LANZAMOS UNA EXCEPCI�N DE QUE NO EXISTE EL ESQUEMA
      DECLARE CURSOR C_TBOBJETOS IS (SELECT NOMBRE,ESQUEMA_ORIGINAL,TIPO,ESTADO,NOMBRE_CORRECTO FROM TB_OBJETOS)
                     FOR UPDATE OF ESTADO,NOMBRE_CORRECTO;
              CURSOR C_TBESTILO  IS (SELECT * FROM TB_ESTILO);
-- AQU� COMIENZA EL BUCLE
      BEGIN
        FOR ACTESTILO IN C_TBESTILO LOOP
          FOR ACTOBJETOS IN C_TBOBJETOS LOOP
           IF ACTOBJETOS.TIPO = ACTESTILO.TIPO_OBJETO 
           THEN
                           aux:= ACTESTILO.PREFIJO || '%';
                dbms_output.put_line(AUX);
              IF ACTOBJETOS.NOMBRE = ACTESTILO.PREFIJO || '%'
              THEN

                UPDATE TB_OBJETOS SET ESTADO = 'CORRECTO';
              ELSE
                UPDATE TB_OBJETOS SET ESTADO = 'INCORRECTO', NOMBRE_CORRECTO = ACTESTILO.PREFIJO || ACTOBJETOS.NOMBRE;
           END IF;
              
           ELSE
              NULL;
              --DBMS_OUTPUT.PUT_LINE('TIPO NO ESPECIFICADO');
           END IF;
           
          END LOOP;

        END LOOP;
      END;
-- CUANDO EL ESQUEMA EST� DEFINIDO      
    ELSE
    DECLARE CURSOR C_TBOBJETOS IS (SELECT NOMBRE,ESQUEMA_ORIGINAL,TIPO,ESTADO,NOMBRE_CORRECTO FROM TB_OBJETOS WHERE ESQUEMA_ORIGINAL = ESQUEMA)
                     FOR UPDATE OF ESTADO,NOMBRE_CORRECTO;
              CURSOR C_TBESTILO  IS (SELECT * FROM TB_ESTILO);
       BEGIN
              FOR ACTESTILO IN C_TBESTILO LOOP
          FOR ACTOBJETOS IN C_TBOBJETOS LOOP
           IF ACTOBJETOS.TIPO = ACTESTILO.TIPO_OBJETO 
           THEN
              IF ACTOBJETOS.NOMBRE = ACTESTILO.PREFIJO || '%'
              THEN
                UPDATE TB_OBJETOS SET ESTADO = 'CORRECTO';
              ELSE
                UPDATE TB_OBJETOS SET ESTADO = 'INCORRECTO', NOMBRE_CORRECTO = ACTESTILO.PREFIJO || ACTOBJETOS.NOMBRE;
           END IF;
              
           ELSE
              DBMS_OUTPUT.PUT_LINE('TIPO NO ESPECIFICADO');
           END IF;
           
          END LOOP;

        END LOOP;
      END;
    END IF;
    
END PR_COMPROBAR;

-- 10

CREATE TABLE TB_ERRORES 
(
  FECHA DATE 
, RUTINA VARCHAR2(2000) 
, CODIGO VARCHAR2(2000) 
, MENSAJE VARCHAR2(2000) 
);

create or replace PROCEDURE PR_SELECT_MAS_UNA_FILA AS
VAR_FILA ALL_TABLES%ROWTYPE;
VSQLERR VARCHAR2(200);
VSQLCODE VARCHAR(5);
BEGIN
SELECT * INTO VAR_FILA
FROM ALL_TABLES;
EXCEPTION
  WHEN OTHERS THEN
 vSqlErr  := SUBSTR(sqlerrm, 1, 200) ;
 vSqlCode := SUBSTR(SQLCODE, 1, 5) ;
  Dbms_output.put_line('Error ' || VSQLCODE || ' EN PROCEDIMIENTO PR_SELECT_MAS_UNA_FILA');  
  INSERT INTO TB_ERRORES VALUES (SYSDATE,'PR_SELECT_MAS_UNA_FILA',vSqlCode,vSqlErr);
END PR_SELECT_MAS_UNA_FILA;


