CREATE DATABASE fest;

--Crear tablas

CREATE TABLE estilo
(nombre VARCHAR CONSTRAINT estilo_pk PRIMARY KEY,
epoca VARCHAR NOT NULL
);

CREATE TABLE grupo
(id_grupo INT CONSTRAINT grupo_pk PRIMARY KEY,
nombre VARCHAR UNIQUE NOT NULL,
experiencia DATE);

CREATE TABLE fan
(id_fan INT CONSTRAINT fan_pk PRIMARY KEY ,
nombre VARCHAR NOT NULL,
donacion INT,
grupo INT,
CONSTRAINT fan_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo)
);

CREATE TABLE artista
(dni VARCHAR CONSTRAINT artista_pk PRIMARY KEY ,
nombre VARCHAR NOT NULL,
apellido VARCHAR NOT NULL,
grupo INT,
estilo VARCHAR,

CONSTRAINT artista_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT artista_estilo_fk FOREIGN KEY (estilo) REFERENCES estilo(nombre)

);

CREATE TABLE escenario
(nombre VARCHAR CONSTRAINT escenario_pk PRIMARY KEY,
aforo INT
);

CREATE TABLE actuacion
(id_actuacion INT CONSTRAINT actuacion_pk PRIMARY KEY ,
nombre VARCHAR NOT NULL,
fecha DATE NOT NULL,
grupo INT,
escenario VARCHAR,

CONSTRAINT actuacion_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT escenario_estilo_fk FOREIGN KEY (escenario) REFERENCES escenario(nombre)

);

CREATE TABLE asistente
(num_entrada INT CONSTRAINT entrada_pk PRIMARY KEY ,
nombre VARCHAR NOT NULL,
butaca VARCHAR UNIQUE,
actuacion INT,

CONSTRAINT asistente_grupo_fk FOREIGN KEY (actuacion) REFERENCES actuacion(id_actuacion)
);

CREATE TABLE patrocinador
(id_patrocinador VARCHAR CONSTRAINT patrocinador_pk PRIMARY KEY,
nombre VARCHAR NOT NULL
);

CREATE TABLE patrocinador_grupo
(
fecha_contrato DATE NOT NULL,
grupo INT CONSTRAINT patgrup_pk PRIMARY KEY,
patrocinador VARCHAR UNIQUE NOT NULL,

CONSTRAINT patgrup_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT patgrup_patrocinador_fk FOREIGN KEY (patrocinador) REFERENCES patrocinador(id_patrocinador)

);

--Insert

INSERT INTO grupo (id_grupo, nombre, experiencia)
VALUES (0, 'asd', '1990-10-12');
INSERT INTO grupo (id_grupo, nombre, experiencia)
VALUES (1, 'ACDC', '1945-12-12');

INSERT INTO estilo (nombre, epoca)
VALUES ('Barroco', 'Edad moderna');

INSERT INTO estilo (nombre, epoca)
VALUES ('Rock', 'Años 70');

INSERT INTO artista (dni, nombre, apellido, grupo, estilo)
VALUES('8374487G', 'Marco', 'Fernandez', 0, 'Barroco');

INSERT INTO artista (dni, nombre, apellido, grupo, estilo)
VALUES('1232387H', 'Marina', 'Ortiz', 1, 'Rock');

INSERT INTO patrocinador (id_patrocinador, nombre)
VALUES(0, 'Cocacola');

INSERT INTO patrocinador (id_patrocinador, nombre)
VALUES(1, 'Pepsi');

INSERT INTO patrocinador_grupo (fecha_contrato, grupo, patrocinador)
VALUES ('2020-10-1', 0, 0);

INSERT INTO patrocinador_grupo (fecha_contrato, grupo, patrocinador)
VALUES ('2018-11-11', 1, 1);

INSERT INTO fan (id_fan, nombre, donacion, grupo)
VALUES(0,'Carlos',10,0);

INSERT INTO fan (id_fan, nombre, donacion, grupo)
VALUES(1,'Jose',10,0);

INSERT INTO escenario (nombre, aforo)
VALUES('Principal', 1000);

INSERT INTO escenario (nombre, aforo)
VALUES('Secundario', 100);

INSERT INTO actuacion (id_actuacion, nombre, fecha, grupo, escenario)
VALUES(1,'Conciertillo','2021-11-2', 1, 'Secundario');

INSERT INTO actuacion (id_actuacion, nombre, fecha, grupo, escenario)
VALUES(0,'Conciertazo','2021-11-1', 0, 'Principal');

INSERT INTO asistente (num_entrada, nombre, butaca, actuacion)
VALUES(0, 'Miguel', '10G', 1);

INSERT INTO asistente (num_entrada, nombre, butaca, actuacion)
VALUES(1, 'Manuel', '4G', 0);


ALTER TABLE grupo RENAME COLUMN experiencia TO fundacion;

ALTER TABLE actuacion DROP COLUMN fecha;

ALTER TABLE actuacion ADD COLUMN fecha TIMESTAMP;

ALTER TABLE patrocinador ADD COLUMN donacion INT;

INSERT INTO actuacion (id_actuacion, nombre, grupo, escenario, fecha)
VALUES(3,'PreConciertillo', 0, 'Secundario', '2021-11-2 16:00:00' );

UPDATE actuacion SET fecha = '2021-11-2 20:00:00' WHERE id_actuacion = 1;

UPDATE actuacion SET fecha = '2021-11-1 20:00:00' WHERE id_actuacion = 0;

--Consultas

SELECT * FROM asistente;

SELECT nombre FROM fan WHERE donacion > 10;

SELECT nombre FROM grupo AS gr WHERE (select count(*) from artista) > 1 AND (select sum(donacion) from fan where grupo = gr.id_grupo) > 10;

SELECT actuacion, count(*) FROM asistente GROUP BY actuacion;

SELECT * FROM grupo WHERE DATE_PART('year', fundacion) > 1989;

SELECT grupo.nombre, actuacion.fecha FROM grupo JOIN actuacion ON grupo.id_grupo=actuacion.grupo;

SELECT grupo.nombre, sum(fan.donacion) FROM grupo JOIN fan ON grupo.id_grupo=fan.grupo GROUP BY grupo.nombre;

SELECT estilo, count(*) from artista GROUP BY estilo HAVING count(*) > 2;

SELECT estilo, count(*) from artista GROUP BY estilo HAVING count(*) = 5;

SELECT patrocinador.nombre, escenario.nombre FROM patrocinador 
JOIN patrocinador_grupo  ON patrocinador.id_patrocinador = patrocinador_grupo.patrocinador 
JOIN grupo ON patrocinador_grupo.grupo = grupo.id_grupo
JOIN actuacion ON grupo.id_grupo = actuacion.grupo
JOIN escenario ON actuacion.escenario = escenario.nombre;

--Vistas

CREATE or replace VIEW artistas AS 
   SELECT grupo.nombre, artista.nombre FROM grupo 
   JOIN artista ON grupo.id_grupo = artista.grupo ;

CREATE or replace VIEW calendarioGrupo AS 
   SELECT grupo.nombre, actuacion.fecha FROM grupo 
   JOIN actuacion ON grupo.id_grupo=actuacion.grupo ORDER BY grupo.nombre;

CREATE or replace VIEW calendarioFechas AS 
   SELECT DATE_PART('day', actuacion.fecha) || '-' || DATE_PART('month', actuacion.fecha) || '-' || DATE_PART('year', actuacion.fecha), count(grupo.*) FROM grupo 
   JOIN actuacion ON grupo.id_grupo=actuacion.grupo 
   GROUP BY DATE_PART('day', actuacion.fecha), DATE_PART('month', actuacion.fecha), DATE_PART('year', actuacion.fecha)
   ORDER BY DATE_PART('day', actuacion.fecha);

--Indices

CREATE INDEX numEntrada ON asistente

CREATE INDEX indexNombre ON fan

--Scripts

CREATE or replace FUNCTION donaciones(_grupo integer)
   RETURN text AS $$
declare 
    donado int;
  


	_donacion CURSOR(_grupo integer) 
		 for SELECT donacion
		 FROM fan
         WHERE grupo = _grupo;
		 
    donacionText text;

BEGIN

OPEN _donacion(_grupo);

donacionText := 'Estas han sido las donaciones de fans para el grupo: ';
   
   LOOP

    FETCH _donacion INTO donado;

    exit when not found;

    donacionText := donacionText || donado || ', ' ;


   end loop;
  

   CLOSE _donacion;

   RETURN donacionText;

END;

 $$

language plpgsql;

CREATE or replace FUNCTION aforo_maximo(_escenario VARCHAR)
   RETURNS VOID
   
   AS $$

declare 
    v_actuacion RECORD;
    v_aforo escenario.aforo%type;
  
	_actuaciones CURSOR(_escenario VARCHAR)
		for SELECT actuacion.id_actuacion AS id_ac, count(asistente.*) AS Asistentes
		   FROM actuacion
         JOIN asistente ON actuacion.id_actuacion = asistente.actuacion
         GROUP BY actuacion.id_actuacion
         HAVING actuacion.escenario LIKE _escenario;
         

  

   

BEGIN

OPEN _actuaciones(_escenario);

SELECT aforo INTO v_aforo FROM escenario WHERE nombre = _escenario;


   LOOP

      FETCH _actuaciones INTO v_actuacion;

      exit when not found;

      IF (v_actuacion.Asistentes > v_aforo) then
         
         RAISE NOTICE 'Para la sesion % el aforo ha sido superado', v_actuacion.id_ac;
      
      ELSE RAISE NOTICE 'Para la sesion % el aforo aun no ha sido superado', v_actuacion.id_ac;
   
      END IF;

   END LOOP;
  
   CLOSE _actuaciones;

   

END;

 $$

language plpgsql;


CREATE or replace FUNCTION Sorteo(_grupo integer, _dinero integer)
   RETURNS VARCHAR
   
   AS $$

declare 
    v_distancia integer;
    v_distancia_anterior integer;
    ganador VARCHAR;
    num_participantes integer;
    numGanador integer;
    num integer;
   
  
	_participantes CURSOR(_dinero integer, _grupo integer)
		for SELECT nombre from fan where grupo = _grupo AND donacion > _dinero;
         

  

   

BEGIN

   SELECT count(*) INTO num_participantes from fan where grupo = _grupo AND donacion > _dinero;
   
   v_distancia_anterior := num_participantes;

   SELECT FLOOR(RANDOM()*num_participantes) INTO numGanador;

   FOR concursante IN _participantes(_dinero, _grupo) LOOP

      SELECT FLOOR(RANDOM()*num_participantes) INTO num;

      v_distancia := abs(num - numGanador);

      IF (v_distancia < v_distancia_anterior) THEN ganador := concursante; END IF;

      v_distancia_anterior := v_distancia;

   END LOOP;

  
   RETURN ganador;

   

END;

 $$

language plpgsql;

