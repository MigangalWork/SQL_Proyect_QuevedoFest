# Memoria Quevedo FEST

## Introduccion
---
    En este proyecto vamos a crear una pequeña base de datos para un hipotético festival.

    Nos centraremos en el apartado de artistas musicales y sus actuaciones.


## Modelo Conceptual
---
    Para ello desarrollaremos una base de datos que incluya datos de los artista, sus grupos, sus fans, sus actuaciones, los asistentes a sus actuaciones asi como el lugar donde se realizan   y los patrocinadores de los grupos

Hemos decidido crear este esquema del modelo entidad relacion:

---
![CAT](BBDD(2).png)

---
### Modelo entidad-relacion

      Estos serian los datos que sacamos del anterior diagrama

      Grupo(id_grupo, nombre, experiencia)
      Artistas(nombre, apellido, dni)
      Estilo(epoca, nombre)
      Patrocinador(nombre, patrocinaDesde)
      Fans(id_fan, nombre, donacion)
      Actuacion(id_actuacion, nombre, fecha)
      Escenario(nombre, aforo)
      Asistente(numeroEntrada, nombre, butaca)

Normalizandolos,

- Ya estan en primera forma normal, pues ningun atributo puede tomar mas de un valor por fila

- Solo Patrocinador no esta en segunda forma normal

   - Aque al ser una relacion N-M lo que hacemos es crear una tabla intermedia nueva

- Todos estan en tercera forma normal ya que ningun atributo depende de otro, solo de la clave primaria


      Grupo(id_grupo, nombre, experiencia)
      Artistas(nombre, apellido, dni)
      Estilo(epoca, nombre)
      Patrocinador(nombre, patrocinaDesde)
      Fans(id_fan, nombre, donacion)
      Actuacion(id_actuacion, nombre, fecha)
      Escenario(nombre, aforo)
      Asistente(numeroEntrada, nombre, butaca)

      Grupo-patrocinador(grupo, patrocinador, patrocinaDesde)

Ahora que hemos normalizado seguiremos las reglas de transformacion para generar las tablas

## Modelo fisico
---
Obtendremos del apartado anterior los datos necesarios para crear este diagrama de clases.

---
![CAT](ClassDiagram(3).png)

---
Con esto, crearemos la base de datos “fest”.

Usando Postgres para crear la base de datos.

Expondremos aquí el codigo para crear la base de datos

```SQL
CREATE DATABASE fest;
```

Tras crear la base de datos , creamos las tablas

```SQL

CREATE TABLE estilo
(nombre VARCHAR(40) CONSTRAINT estilo_pk PRIMARY KEY,
epoca VARCHAR(40) NOT NULL
);

CREATE TABLE grupo
(id_grupo INT CONSTRAINT grupo_pk PRIMARY KEY,
nombre VARCHAR(40) UNIQUE NOT NULL,
experiencia DATE);

CREATE TABLE fan
(id_fan INT CONSTRAINT fan_pk PRIMARY KEY ,
nombre VARCHAR(40) NOT NULL,
donacion INT,
grupo INT,
CONSTRAINT fan_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo)
);

CREATE TABLE artista
(dni VARCHAR(40) CONSTRAINT artista_pk PRIMARY KEY ,
nombre VARCHAR(40) NOT NULL,
apellido VARCHAR(40) NOT NULL,
grupo INT,
estilo VARCHAR(40),

CONSTRAINT artista_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT artista_estilo_fk FOREIGN KEY (estilo) REFERENCES estilo(nombre)

);

CREATE TABLE escenario
(nombre VARCHAR CONSTRAINT escenario_pk PRIMARY KEY,
aforo INT
);

CREATE TABLE actuacion
(id_actuacion INT CONSTRAINT actuacion_pk PRIMARY KEY ,
nombre VARCHAR(40) NOT NULL,
fecha DATETIME NOT NULL,
grupo INT,
escenario VARCHAR(40),

CONSTRAINT actuacion_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT escenario_estilo_fk FOREIGN KEY (escenario) REFERENCES escenario(nombre)

);

CREATE TABLE asistente
(num_entrada INT CONSTRAINT entrada_pk PRIMARY KEY ,
nombre VARCHAR(40) NOT NULL,
butaca VARCHAR(40) UNIQUE,
actuacion INT,

CONSTRAINT asistente_grupo_fk FOREIGN KEY (actuacion) REFERENCES actuacion(id_actuacion)
);

CREATE TABLE patrocinador
(id_patrocinador VARCHAR(40) CONSTRAINT patrocinador_pk PRIMARY KEY,
nombre VARCHAR(40) NOT NULL
);

CREATE TABLE patrocinador_grupo
(
fecha_contrato DATE NOT NULL,
grupo INT CONSTRAINT patgrup_pk PRIMARY KEY,
patrocinador VARCHAR(40) UNIQUE NOT NULL,

CONSTRAINT patgrup_grupo_fk FOREIGN KEY (grupo) REFERENCES grupo(id_grupo),
CONSTRAINT patgrup_patrocinador_fk FOREIGN KEY (patrocinador) REFERENCES patrocinador(id_patrocinador)

);
```
Posteriormente introduciremos algunos datos ficticios en la base de datos

```SQL
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
```


Despues de introducir esto datos de prueba vamos a modificar algunas cosas.

Primero, cambiaremos el nombre a la columna de `EXPERIENCIA` de la tabla `GRUPO` por `FUNDACION`, ya que es mas descriptiva.

```SQL
ALTER TABLE grupo RENAME COLUMN experiencia TO fundacion;
```

Despues, cambiaremos tambien la columna `Fecha`de la tabla `ACTUACION` que hemos definido como en un principio como tipo `DATE` y queremos que tambien incluya la hora de la actuacion.

Para esto primero borraremos la columna actual con

```SQL
ALTER TABLE actuacion DROP COLUMN fecha;
```

Y luego añadiremos una columna nuevo de tipo `TIMESTAMP` a la misma columna.

```SQL
ALTER TABLE actuacion ADD COLUMN fecha TIMESTAMP;
```

Por ultimo, reintroduciremos los datos de fecha en las entradas que ya estan en la base de datos.

```SQL
UPDATE actuacion SET fecha = '2021-11-2 20:00:00' WHERE id_actuacion = 1;

UPDATE actuacion SET fecha = '2021-11-1 20:00:00' WHERE id_actuacion = 0;
```

Para no tener que crear una gran cantidad de datos a mano, hemos programado un pequeño programa en Python donde a partir de unos archivos sacados de la red creamos filas en las tablas.

```python
import random
import datetime
import yaml

consultas = ''

ngrupos = 10 # max 30
nfans = 2000
max_artistas_grupo = 5
npatrocinadores = 50 # max 100
max_patrocinadores_por_grupo = 5
first_date_patrocinador = datetime.datetime(2016, 1, 1)
max_days_patrocinador = 1000
first_date_grupo = datetime.datetime(1980, 1, 1)
max_days_grupo = 40*356
escenarios = {'Principal': 2500, 'Secundario': 1000, 'Cubierto': 400}
# https://thestoryshack.com/tools/event-name-generator/
actuaciones = list(map(lambda x: x.strip(), open('actuaciones.dat', 'r').readlines()))
# https://thestoryshack.com/tools/band-name-generator/
grupos = list(map(lambda x: x.strip(), open('grupos.dat', 'r').readlines()))[:ngrupos]
# 10000 nombres mas frecuentes de hombre y 10000 mas frecuentes de mujer INE
nombres = list(map(lambda x: x.strip(), open('nombres.dat', 'r').readlines()))
# 10000 apellidos mas frecuentes INE
apellidos = list(map(lambda x: x.strip(), open('apellidos.dat', 'r').readlines()))
# https://www.duns100000.com/distribucion_empresas_ibericas/top100Espana
patrocinadores = list(map(lambda x: x.strip(), open('patrocinadores.dat', 'r').readlines()))[:npatrocinadores]

estilos = yaml.safe_load(open('estilos.yaml', 'r'))

for id_grupo, nombre in enumerate(grupos):
    fecha = (first_date_grupo + datetime.timedelta(days=random.randint(0, max_days_grupo))).strftime('%Y-%m-%d')
    consultas += f"INSERT INTO grupo (id_grupo,nombre,fundacion)\nVALUES('{id_grupo}','{nombre}','{fecha}');\n"


for nombre, aforo in escenarios.items():
    consultas += f"INSERT INTO escenario (nombre, aforo)\nVALUES('{nombre}', {aforo});\n"

grupos_aleatorio = []
aforos_actuacion = []
while set(grupos_aleatorio) != set(range(ngrupos)):
    grupos_aleatorio = random.choices(range(ngrupos), k=len(actuaciones))

for id_actuacion, nombre in enumerate(actuaciones):
    escenario = random.choice(list(escenarios.keys()))
    aforos_actuacion.append(escenarios.get(escenario))
    fecha = f'2021-11-{random.randint(1,5)} {random.randint(0, 23)}:{random.choice(["00",15,30,45])}:00'
    consultas += f"INSERT INTO actuacion (id_actuacion,nombre,grupo,escenario,fecha)\nVALUES({id_actuacion},'{nombre}',{grupos_aleatorio[id_actuacion]},'{escenario}','{fecha}');\n"

num_entrada = 0
maxbutaca = 350
for actuacion, aforo in enumerate(aforos_actuacion):
    for i in range(aforo):
        consultas += f"INSERT INTO asistente (num_entrada,nombre,butaca,actuacion)\nVALUES({num_entrada},'{random.choice(nombres)}','{i%maxbutaca+1}{chr(65+i//maxbutaca)}',{actuacion});\n"
        num_entrada += 1


for id_patrocinador, nombre in enumerate(patrocinadores):
    consultas += f"INSERT INTO patrocinador (id_patrocinador,nombre)\nVALUES({id_patrocinador},'{nombre}');\n"

for grupo in range(ngrupos):
    nipatrocinadores = random.choices(range(len(patrocinadores)), k=random.randint(1, max_patrocinadores_por_grupo))
    for patrocinador in nipatrocinadores:
        fecha = (first_date_patrocinador + datetime.timedelta(days=random.randint(0, max_days_patrocinador))).strftime('%Y-%m-%d')
        consultas += f"INSERT INTO patrocinador_grupo (fecha_contrato,grupo,patrocinador)\nVALUES('{fecha}','{grupo}','{patrocinador}');\n"


for nombre, epoca in estilos.items():
    consultas += f"INSERT INTO estilo (nombre,epoca)\nVALUES('{nombre}','{epoca}');\n"


for id_fan in range(nfans):
    consultas += f"INSERT INTO fan (id_fan,nombre,donacion,grupo)\nVALUES({id_fan},'{random.choice(nombres)}',{random.randint(5, 500)},{random.randint(0, ngrupos-1)});\n"


for grupo in range(ngrupos):
    nartistas = random.randint(1, max_artistas_grupo)
    for _ in range(nartistas):
        rn = lambda: random.randint(0,9)
        dni = f'{rn()}{rn()}{rn()}{rn()}{rn()}{rn()}{rn()}{rn()}{chr(65+random.randint(0, 25))}'
        consultas += f"INSERT INTO artista (dni,nombre,apellido,grupo,estilo)\nVALUES('{dni}','{random.choice(nombres)}','{random.choice(apellidos)}',{grupo},'{random.choice(list(estilos.keys()))}');\n"


open('consulta.txt', 'w').write(consultas)
```
Gracias a este pequeño codigo generamos un txt donde estan todos los `inserts` de los datos.

Intentaremos conectar directamente con la base de datos si nos sobra tiempo para hacer directamente la insercion de datos.

Hemos introducido de esta forma 30.000 datos aproximadamente.

## Consultas
---
Con estos datos ya podemos hacer consultas a la base de datos,

Dividiremos esta seccion en pequeñas consultas explicando su funcion en el proyecto y porque consideramos que serian utiles.

Con esta consulta podriamos ver a todos los asistentes a cualquier evento,

```SQL
SELECT * FROM asistente;
```
Es una consulta sencilla que devolveria una gran cantidad de datos pero puede usarse para posteriormente filtrar los datos de otra forma, en vez de hacerlo directamente con la base de datos.

Con esta consulta veriamos los fans que han aportado mas de 100 euros a su grupo.

```SQL
SELECT nombre FROM fan WHERE donacion > 100;
```
Tal vez podria ser util para organizar algun tipo de sorte entre los fans que mas han contribuido a la banda

Esta consulta ya es un poco mas compleja, ya que tiene una subconsulta. En ella bucamos el nombre de los grupos que tienen mas de un artista y que han recivido mas de 10000 euros en donaciones por sus fans
```SQL
SELECT nombre FROM grupo AS gr WHERE (select count(*) from artista) > 1 AND (select sum(donacion) from fan where grupo = gr.id_grupo) > 10000;
```
Puede ser una consulta util para ver, entre los grupos de mas de un cantante, cuales ganan mas dinero de sus fans


Esta consulta tambien sencilla, veriamos cuantos asistentes tiene cada una de las actuaciones
```SQL
SELECT actuacion, count(*) FROM asistente GROUP BY actuacion;
```
Puede ser util para comprobar que actuaciones son mas reclamadas y cuales menos

Con esta consulta comprobariamos que un grupo tenga una fundacion mas actual que el año 2000. Usamos `DATE_PART` para sacar el año de la fecha y lo comparamos.

```SQL
SELECT * FROM grupo WHERE DATE_PART('year', fundacion) > 2000;
```
Util para buscar los grupos mas modernos.

Aqui ya hariamos consultas multitabla. En este caso consultariamos las tablas grupo y actuacion para relacionar el nombre de un grupo con la fecha en la que actua.
```SQL
SELECT grupo.nombre, actuacion.fecha FROM grupo JOIN actuacion ON grupo.id_grupo=actuacion.grupo;
```
Seria interesante para sacar un calendario de fechas

En esta otra consulta multitabla relacionamos el nombre de un grupo con el total de donaciones de sus fans.

```SQL
SELECT grupo.nombre, sum(fan.donacion) FROM grupo JOIN fan ON grupo.id_grupo=fan.grupo GROUP BY grupo.nombre;
```
Similar a una consulta anterior serviria para sacar los grupos con mas ingresos

Con esta consulta de agrupacion, veremos que estilos son mas o menos populares.
```SQL
SELECT estilo, count(*) from artista GROUP BY estilo HAVING count(*) = 5;
```
Puede ser util para ver la tendencia musical actual.
Aun que tal vez seria mas util de esta forma,

```SQL
SELECT estilo, count(*) from artista GROUP BY estilo ORDER BY count(*);
```

Es consulta, relaciona el nombre de un patrocinador de un grupo con el nombre del escenario donde tocaria ese grupo en cada una de sus actuaciones. Seria una consulta multitabla con varios `JOIN`.
```SQL
SELECT patrocinador.nombre, escenario.nombre FROM patrocinador 
JOIN patrocinador_grupo  ON patrocinador.id_patrocinador = patrocinador_grupo.patrocinador 
JOIN grupo ON patrocinador_grupo.grupo = grupo.id_grupo
JOIN actuacion ON grupo.id_grupo = actuacion.grupo
JOIN escenario ON actuacion.escenario = escenario.nombre;
```
Podria usarse para poder poner publicidad de ese patrocinador en el escenario en el que toque su grupo.

## Vistas
---
Las vistas son utiles usadas para consultas frecuentes, ya que nos ahorran tiempo al hacer estas consultas.

Debido a esto aqui proponemos algunas vistas que consideramos utiles

Esta primera vista nos relacionaria el nombre de cada grupo con sus artistas, una busqueda bastante util en festivales donde no se conozca mucho a los artistas.
```SQL
CREATE or replace VIEW artistas AS 
   SELECT grupo.nombre, artista.nombre FROM grupo 
   JOIN artista ON grupo.id_grupo = artista.grupo ;
```
## Scripts
---
hemos generado tambien algunos scripts para hacer algunas funciones.

El primero es un script que sacaria por consola una lista de cada uno de los donantes.

Es muy sencillo por eso es el primero.
```SQL
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

donacionText := 'Estas han sido las donaciones de fans para el grupo con id %: ', _grupo;
   
   LOOP

    FETCH _donacion INTO donado;

    exit when not found;

    donacionText := donacionText || donado ;


   end loop;
  

   CLOSE _donacion;

   RETURN donacionText;

END;

 $$

language plpgsql;

```
Este segundo Script comprobaria si se ha superado el aforo maximo en algun evento para un escenario dado.

Para ello recorre cada uno de los eventos asociados a ese escenario y lo commpara con la suma de los asistentes.

En caso de superarse, lanzaria un mensaje informando del problema.
Si no, lanzaria otro mensaje confirmando que aun quedan plazas.

```SQL

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

```