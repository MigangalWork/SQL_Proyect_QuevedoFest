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