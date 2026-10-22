#R2 - Creacion de las tblas de la base de datos ------------------------------------------------------------------------------------------------

drop database if exists DronAndes;
create database DronAndes;
use DronAndes;

create table bases(
id_base int auto_increment primary key,
nombre varchar(60) not null unique,
municipio varchar(60) not null,
departamento varchar(60)not null,
capacidad_drones int not null,
fecha_apertura date not null,
constraint chk_capacidad_positiva check (capacidad_drones > 0)
);

create table tipos_cargas(
id_tipo int auto_increment primary key,
nombre varchar(40) not null unique,
tarifa_kg decimal(10,2) not null,
requiere_frio boolean not null default FALSE,
constraint chk_tarifa check (tarifa_kg > 0)
);

create table drones(
id_dron int auto_increment primary key,
codigo_serie varchar(12) not null unique,
modelo varchar(40) not null,
carga_max_kg decimal(5,2) not null,
autonomia_km decimal(5,1) not null,
estado varchar(15) default 'ACTIVO' not null,
horas_vuelo decimal(7,1) not null default 0,
fecha_adquisicion date not null,
id_base int not null,
constraint chk_autonomia check (autonomia_km > 0),
constraint chk_horas check (horas_vuelo >= 0),
constraint chk_estado check (estado in ('ACTIVO', 'MANTENIMIENTO', 'RETIRADO')),

constraint fk_drones
foreign key (id_base)
references bases(id_base)
);

create table pilotos(
id_piloto int auto_increment primary key,
documento varchar(15) not null unique,
nombres varchar(50) not null,
apellidos varchar(50) not null,
email varchar(80) not null unique,
licencia char(1) not null,
fecha_ingreso date not null,
id_supervisor int null,
id_base int not null,
constraint chk_categoria_licencia check (licencia in  ('A', 'B', 'C')),

constraint fk_pilotos
foreign key (id_base)
references bases(id_base)
);

create table clientes(
id_cliente int auto_increment primary key,
tipo varchar(12) not null,
nombre varchar(80) not null,
nit_documento varchar(15) not null unique,
email varchar(80) null unique,
telefono varchar(15) null,
municipio varchar(60) not null,
fecha_registro date default (current_date()) not null,
constraint chk_tipo_cliente check (tipo in ('HOSPITAL', 'FARMACIA', 'COMERCIO', 'ONG', 'PERSONA'))
);

create table entregas(
id_entrega int primary key auto_increment,
codigo varchar(10) unique not null,
id_cliente int not null,
id_dron int not null,
id_piloto int not null,
fecha_programada datetime not null,
fecha_entrega datetime null,
municipio_destino varchar(60) not null,
distancia_km decimal(5,1) not null,
prioridad varchar(8) default 'NORMAL' not null,
estado varchar(12) default 'PROGRAMADA' not null,
calificacion smallint null,
constraint chk_distancia check (distancia_km > 0),
constraint chk_prioridad check (prioridad in ('NORMAL', 'URGENTE', 'VITAL')),
constraint chk_estado_entrega check (estado in ('PROGRAMADA', 'EN_VUELO', 'ENTREGADA', 'CANCELADA', 'FALLIDA')),
constraint chk_calificacion check (calificacion between 1 and 5),

constraint fk_entregas_cliente
foreign key (id_cliente)
references clientes(id_cliente),

constraint fk_entregas_dron
foreign key (id_dron)
references drones(id_dron),

constraint fk_entregas_piloto
foreign key (id_piloto)
references pilotos(id_piloto)
);

create table carga_entrega (
id_entrega int not null,
id_tipo int not null,
peso_kg decimal(6,2) not null,
unidades int default 1 not null,
primary key (id_entrega, id_tipo),
constraint chk_peso check (peso_kg > 0),
constraint chk_unidades check (unidades > 0),

constraint fk_carga_entrega
foreign key (id_entrega)
references entregas(id_entrega),

constraint fk_carga_entrega_tipo
foreign key (id_tipo)
references tipos_cargas(id_tipo)
);

create table mantenimientos (
id_mantenimiento int auto_increment primary key,
id_dron int not null,
fecha date not null,
tipo varchar(12)not null,
descripcion varchar(200) null,
costo decimal(10,2) not null,
constraint chk_costo check (costo >= 0),
constraint chk_tipo check (tipo in ('PREVENTIVO', 'CORRECTIVO')),

constraint fk_mantenimientos
foreign key (id_dron)
references drones(id_dron)
);

create table historial_entregas (
id_historial int auto_increment primary key,
id_entrega int not null,
estado_anterior varchar(12) not null,
estado_nuevo varchar(12) not null,
fecha_cambio datetime default(current_timestamp()) not null,

constraint fk_historial_entregas
foreign key (id_entrega)
references entregas(id_entrega)
);

#infromacion para la base de datos 

-- ===================================================================== 
-- DATOS INICIALES — Proyecto Cóndor (DronAndes Express S.A.S.) 
-- Corte: 30 de septiembre de 2026, 18:00 
-- Script COMÚN para MySQL y PostgreSQL. Ejecutar DESPUÉS del DDL (R2). 
-- ===================================================================== 
 
INSERT INTO bases (id_base, nombre, municipio, departamento, capacidad_drones, fecha_apertura) VALUES 
(1, 'Base Cóndor',    'Rionegro', 'Antioquia', 6, '2024-02-15'), 
(2, 'Base Colibrí',   'Guatapé',  'Antioquia', 4, '2024-08-01'), 
(3, 'Base Frailejón', 'Tunja',    'Boyacá',    5, '2025-01-20'), 
(4, 'Base Guadua',    'Salento',  'Quindío',   3, '2026-07-01'); 

 
INSERT INTO tipos_cargas (id_tipo, nombre, tarifa_kg, requiere_frio) VALUES 
(1, 'Vacunas',                 12000, TRUE), 
(2, 'Muestras de laboratorio', 10000, TRUE), 
(3, 'Medicamentos',             8000, FALSE), 
(4, 'Documentos',               5000, FALSE), 
(5, 'Repuestos',                4500, FALSE), 
(6, 'Alimentos',                3500, FALSE); 
 
INSERT INTO drones (id_dron, codigo_serie, modelo, carga_max_kg, autonomia_km, estado, horas_vuelo, fecha_adquisicion, id_base) VALUES 
(1, 'DA-CX4-01', 'Cóndor X4',    8.00, 45.0, 'ACTIVO',        312.5, '2024-02-20', 1), 
(2, 'DA-CX4-02', 'Cóndor X4',    8.00, 45.0, 'ACTIVO',        468.0, '2024-03-10', 1), 
(3, 'DA-CX6-01', 'Cóndor X6',   15.00, 60.0, 'ACTIVO',        205.0, '2025-01-15', 1), 
(4, 'DA-COL-01', 'Colibrí Mini', 2.50, 25.0, 'ACTIVO',        520.5, '2024-08-05', 2), 
(5, 'DA-COL-02', 'Colibrí Mini', 2.50, 25.0, 'MANTENIMIENTO', 610.0, '2024-08-05', 2), 
(6, 'DA-ALB-01', 'Albatros H8', 25.00, 90.0, 'ACTIVO',         98.0, '2025-02-01', 3), 
(7, 'DA-CX6-02', 'Cóndor X6',   15.00, 60.0, 'ACTIVO',        150.5, '2025-03-12', 3), 
(8, 'DA-ALB-02', 'Albatros H8', 25.00, 90.0, 'RETIRADO',      890.0, '2024-05-01', 3); 
 
-- Los supervisores (id_supervisor NULL) se insertan primero. 
INSERT INTO pilotos (id_piloto, documento, nombres, apellidos, email, licencia, fecha_ingreso, id_supervisor, id_base) VALUES 
(1, '1036600111', 'Laura',    'Restrepo Gil',  'laura.restrepo@dronandes.co',  'C', '2024-02-01', NULL, 
1), 
(2, '1049600222', 'Camilo',   'Duarte Rojas',  'camilo.duarte@dronandes.co',   'C', '2025-01-10', NULL, 
3), 
(3, '1036600333', 'Mateo',    'Zapata Vélez',  'mateo.zapata@dronandes.co',    'B', '2024-04-15', 1,    1), 
(4, '1036600444', 'Sara',     'Montoya Ruiz',  'sara.montoya@dronandes.co',    'B', '2024-08-10', 1,    2), 
(5, '1036600555', 'Julián',   'Patiño Cruz',   'julian.patino@dronandes.co',   'A', '2025-06-01', 1,    2), 
(6, '1049600666', 'Daniela',  'Suárez León',   'daniela.suarez@dronandes.co',  'B', '2025-02-01', 2,    3), 
(7, '1049600777', 'Tomás',    'Becerra Niño',  'tomas.becerra@dronandes.co',   'A', '2026-06-15', 2,    3); 
 
INSERT INTO clientes (id_cliente, tipo, nombre, nit_documento, email, telefono, municipio, fecha_registro) VALUES 
(1,  'HOSPITAL', 'Hospital San Juan de Dios de Rionegro', '890980000-1', 'compras@hsjdrionegro.org',      '6045310000', 'Rionegro',     '2024-03-01'), 
(2,  'FARMACIA', 'Droguería La Esperanza',                '71234567',    'esperanza.drogueria@gmail.com', '3104567890', 'Guatapé',      '2024-09-12'), 
(3,  'HOSPITAL', 'E.S.E. Hospital San Rafael de Tunja',   '891800231-6', 'Logistica@HSRTunja.gov.co',     '6087405050', 'Tunja',        '2025-01-25'), 
(4,  'ONG',      'Fundación Alas para el Campo',          '900456789-2', 'contacto@alasparaelcampo.org',  NULL,         'Marinilla',    '2024-11-03'), 
(5,  'COMERCIO', 'Repuestos Agrícolas El Arriero',        '900123456-7', NULL,                            '31245678',   'El Peñol',     '2025-04-18'), 
(6,  'PERSONA',  'Mariana Gómez Arango',                  '1040123456',  'mariana.gomez@hotmail.com',     '3157778899', 'Guarne',       '2025-07-07'), 

(7,  'FARMACIA', 'Farmacia Botica del Páramo',            '900777888-1', 'boticaparamo@gmail.com',        '3209998877', 'Ventaquemada', '2025-02-14'), 
(8,  'COMERCIO', 'Café de Altura Las Nubes',              '901222333-4', 'ventas@cafelasnubes.co',        '3001112233', 'Salento',      '2026-07-20'), 
(9,  'PERSONA',  'Jorge Iván Ríos',                       '79888777',    NULL,                            NULL,         'Rionegro',     
'2026-08-30'), 
(10, 'ONG',      'Corporación Montaña Viva',              '900999111-0', 'info@montanaviva.org',          
'310555444',  'Sáchica',      '2025-09-01'); 
 
INSERT INTO entregas (id_entrega, codigo, id_cliente, id_dron, id_piloto, fecha_programada, fecha_entrega, municipio_destino, distancia_km, prioridad, estado, calificacion) VALUES 
(1,  'ENT-0001', 1,  1, 3, '2026-08-03 08:00:00', '2026-08-03 08:42:00', 'San Vicente',          18.5, 'VITAL',   'ENTREGADA',  5), 
(2,  'ENT-0002', 1,  3, 1, '2026-08-05 09:30:00', '2026-08-05 10:20:00', 'Concepción',           32.0, 'VITAL',   'ENTREGADA',  4), 
(3,  'ENT-0003', 2,  4, 4, '2026-08-07 14:00:00', '2026-08-07 14:25:00', 'San Rafael',           12.0, 'NORMAL',  'ENTREGADA',  5), 
(4,  'ENT-0004', 4,  2, 3, '2026-08-10 07:45:00', '2026-08-10 08:30:00', 'El Carmen de Viboral', 22.4, 'URGENTE', 'ENTREGADA',  3), 
(5,  'ENT-0005', 5,  3, 1, '2026-08-12 11:00:00', NULL,                  'El Peñol',             15.0, 'NORMAL',  
'CANCELADA',  NULL), 
(6,  'ENT-0006', 3,  6, 2, '2026-08-14 06:30:00', '2026-08-14 07:40:00', 'Ramiriquí',            48.0, 'VITAL',   'ENTREGADA',  5), 
(7,  'ENT-0007', 10, 7, 6, '2026-08-18 10:00:00', '2026-08-18 10:35:00', 'Samacá',               20.5, 'NORMAL',  'ENTREGADA',  4), 
(8,  'ENT-0008', 3,  8, 6, '2026-08-20 08:15:00', NULL,                  'Chíquiza',             35.0, 'URGENTE', 
'FALLIDA',    NULL), 
(9,  'ENT-0009', 6,  4, 5, '2026-08-22 16:00:00', '2026-08-22 16:20:00', 'Guarne',                9.5, 'NORMAL',  'ENTREGADA',  2), 
(10, 'ENT-0010', 1,  1, 1, '2026-08-25 07:00:00', '2026-08-25 07:50:00', 'Sonsón',               41.0, 'VITAL',   'ENTREGADA',  5), 
(11, 'ENT-0011', 10, 6, 2, '2026-08-27 09:00:00', '2026-08-27 10:05:00', 'Sáchica',              52.5, 'URGENTE', 'ENTREGADA',  NULL), 
(12, 'ENT-0012', 2,  5, 4, '2026-08-29 13:00:00', NULL,                  'Alejandría',           14.0, 'NORMAL',  'CANCELADA',  NULL), 
(13, 'ENT-0013', 4,  2, 1, '2026-09-01 08:00:00', '2026-09-01 08:55:00', 'Granada',              38.0, 'URGENTE', 'ENTREGADA',  4), 
(14, 'ENT-0014', 1,  3, 1, '2026-09-03 10:30:00', '2026-09-03 11:15:00', 'Abejorral',            44.0, 'VITAL',   'ENTREGADA',  5), 
(15, 'ENT-0015', 7,  7, 6, '2026-09-08 15:00:00', '2026-09-08 15:30:00', 'Turmequé',             17.0, 'NORMAL',  'ENTREGADA',  3), 
(16, 'ENT-0016', 3,  6, 2, '2026-09-15 06:00:00', '2026-09-15 07:10:00', 'Miraflores',           58.0, 'VITAL',   'ENTREGADA',  4), 
(17, 'ENT-0017', 6,  2, 3, '2026-09-21 17:00:00', NULL,                  'Guarne',               10.0, 'NORMAL',  'CANCELADA',  NULL), 
(18, 'ENT-0018', 10, 7, 6, '2026-09-30 17:40:00', NULL,                  'Villa de Leyva',       26.0, 'NORMAL',  'EN_VUELO',   NULL), 
(19, 'ENT-0019', 1,  1, 1, '2026-10-01 07:30:00', NULL,                  'Nariño',               47.0, 'VITAL',   
'PROGRAMADA', NULL), 
(20, 'ENT-0020', 3,  6, 6, '2026-10-02 06:00:00', NULL,                  'Pesca',                39.0, 'VITAL',   
'PROGRAMADA', NULL); 
 
INSERT INTO carga_entrega (id_entrega, id_tipo, peso_kg, unidades) VALUES 
(1, 1, 3.00, 60),  (1, 3, 2.00, 15), 
(2, 2, 1.50, 30),  (2, 3, 4.00, 40), 
(3, 3, 1.80, 12), 
(4, 3, 3.50, 25),  (4, 4, 0.50, 3), 
(5, 5, 6.00, 4), 
(6, 1, 5.00, 100), (6, 2, 2.00, 40), 
(7, 3, 6.00, 50), 
(8, 1, 8.00, 160), (8, 3, 4.00, 30), 
(9, 4, 0.80, 5), 
(10, 1, 4.00, 80), (10, 2, 1.00, 20), (10, 3, 2.50, 20), 
(11, 3, 7.00, 60), (11, 4, 1.00, 6), 
(13, 3, 5.00, 40), (13, 5, 2.00, 2), 
(14, 1, 6.00, 120), (14, 2, 3.00, 60), 
(15, 3, 3.00, 25), (15, 4, 0.30, 2), 
(16, 1, 10.00, 200), (16, 3, 8.00, 70), 
(18, 3, 4.00, 35), 
(19, 1, 3.50, 70), 
(20, 2, 2.50, 50), (20, 1, 6.00, 120); 
 
INSERT INTO mantenimientos (id_mantenimiento, id_dron, fecha, tipo, descripcion, costo) VALUES 
(1, 2, '2026-03-15', 'PREVENTIVO', 'Cambio de hélices',                          350000), 
(2, 4, '2026-04-02', 'PREVENTIVO', 'Calibración de GPS',                         180000), 
(3, 5, '2026-09-25', 'CORRECTIVO', 'Falla en motor 3',                          1250000), 
(4, 8, '2026-08-21', 'CORRECTIVO', 'Impacto en aterrizaje, evaluación de daños', 2800000), 
(5, 1, '2026-06-10', 'PREVENTIVO', 'Revisión general de 300 horas',              420000), 
(6, 6, '2026-07-05', 'PREVENTIVO', NULL,                                         260000), 
(7, 5, '2026-05-14', 'PREVENTIVO', 'Cambio de baterías',                         950000), 
(8, 2, '2026-09-12', 'CORRECTIVO', 'Sensor de altitud defectuoso',               610000); 


#R3 ajaustes esctrucutrales solicitados por calidad-----------------------------------------------------------------------------------------------

-- a) =

alter table clientes
modify column nombre varchar(120) not null;

describe clientes; 

-- b) =

alter table drones
add constraint chk_dornes_carga check (carga_max_kg between 0.5 and 25.0);

show create table drones;

-- c) = 

alter table pilotos
add
constraint fk_pilotos_supervisor
foreign key (id_supervisor)
references pilotos(id_piloto);

show create table pilotos;

#R4 opereciones (DML) ---------------------------------------------------------------------------------------------------------------------------

-- a) = 

insert into clientes
(tipo, nombre, nit_documento, email, telefono, municipio, fecha_registro) values

('FARMACIA', 'Drogería Santa Ana', '900314159-2', 'santaana@gmail.com', '3112223344', 'Marinilla', '2026-09-28'),
('PERSONA', 'Esteban Mejía Toro', '1036987654', NULL, '3015556677', 'Rionegro', '2026-09-29'),
('COMERCIO', 'Tienda Naturista Frailejón', '901555666-3', 'tienda.frilejon@outlook.com', '3209871234', 'Tunja', '2026-09-30');

-- b) = 

update drones
set estado = 'MANTENIMIENTO'
where estado = 'ACTIVO' and horas_vuelo > 500;

	# se vieropn a fectadas una solo fila la cual cuenta con un dron que posee mas de 500 horas de vuelo el codigo de seria el doron es el siguiente "DA-COL-01".

-- c) = 

delete from entregas
where estado = 'CANCELADA'
and id_entrega not in (
select id_entrega from carga_entrega)
;

	# se vieron afectadas dos filas las cules teinie el estado de canceladas pero no poseian carga alguna

-- d) = 

select
(select count(*) from clientes) as total_clientes,
(select count(*) from entregas) as total_entregas,
(select count(*) from drones where estado = 'MANTENIMIENTO') as dornes_mantenimiento_total
;

#R5 tabalero de control operativo -------------------------------------------------------------------------------

-- a) = 

select codigo, municipio_destino, distancia_km, prioridad from entregas
where estado = 'ENTREGADA'
and distancia_km between 18 and 58
and prioridad in ('VITAL', 'URGENTE')
order by distancia_km desc;

-- b.1) =

select codigo, estado, fecha_programada from entregas
where estado not in ('ENTREGADA', 'PROGRAMADA', 'EN_VUELO')
and fecha_entrega is NULL
order by codigo asc;

-- b.2) = 

select codigo, fecha_entrega from entregas
where fecha_entrega is not null
and calificacion is null;

-- c) = 

select codigo_serie, modelo, carga_max_kg, horas_vuelo, autonomia_km, estado from drones
where estado not in ('RETIRADO')
and carga_max_kg >= 8
and horas_vuelo < 400
or autonomia_km > 80
order by codigo_serie asc;

-- d) =

select nombres, apellidos, licencia, fecha_ingreso from pilotos
where not licencia = 'A'
and fecha_ingreso <= '2025-02-01'
order by fecha_ingreso asc;


#R6 directorio comercial y calida de datos ------------------------------------------------------------------------------------------

-- a) = 

select 
upper(nombre) as cliente, 
municipio, 
coalesce(telefono, 'SIN TELEFONO') as telefono, 
coalesce(length(telefono), 0) as digitos
from clientes 
where telefono is null or length(telefono) <> 10
order by nombre asc;

-- b) = 

select 
nombre,
lower(email) as correo,
concat(nombre, ' <', lower(email), '>') as contacto
from clientes
where email is not null
and email not like '%@gmail.com'
and email not like '%@hotmail.com'
and email not like '%@outlook.com'
order by nombre asc;

-- c)=

select
codigo_serie,
upper(modelo) as modelo,
round(horas_vuelo / 1000 * 100, 1) as pct_vida_util
from drones
where codigo_serie like 'DA-CX_-__'
order by horas_vuelo desc;


#R7 indicadores de gestion ------------------------------------------------------------------------------

-- a) = 

select 
tc.nombre as tipo_carga,
count(distinct ce.id_entrega) as num_entregas,
sum(ce.peso_kg) as kg_totales,
round(avg(ce.peso_kg), 2) as kg_promedio,
min(ce.peso_kg) as kg_minimo,
max(ce.peso_kg) as kg_maximo
from tipos_cargas tc
inner join carga_entrega ce on ce.id_tipo = tc.id_tipo
inner join entregas e on e.id_entrega = ce.id_entrega
where e.estado = 'ENTREGADA'
group by tc.nombre
order by sum(ce.peso_kg) desc;

-- b) =

select 
c.nombre as cliente,
count(*) as entregas_realizadas,
round(avg(e.calificacion), 2) as calificacion_promedio
from clientes c
inner join entregas e on e.id_cliente = c.id_cliente
where e.estado = 'ENTREGADA'
group by c.nombre, c.id_cliente
having count(*) >= 2
and avg(e.calificacion) >= 4
order by calificacion_promedio desc, cliente asc;


#R8 consultas multitabla--------------------------------------------------------------------------------

-- a) = 

select 
e.codigo as codigo,
c.nombre as cliente,
concat(p.nombres, ' ', p.apellidos) as piloto,
d.codigo_serie as dron,
b.nombre as base,
timestampdiff(minute, e.fecha_programada, e.fecha_entrega) as minutos_vuelo
from entregas e
inner join clientes c on c.id_cliente = e.id_cliente
inner join pilotos p on p.id_piloto = e.id_piloto
inner join drones d on d.id_dron = e.id_dron
inner join baseS b on b.id_base = d.id_base
where e.estado = 'ENTREGADA'
and e.prioridad = 'VITAL'
order by e.fecha_programada asc;

-- b) = 

select 
concat(p.nombres, ' ', p.apellidos) as piloto,
p.licencia as licencia,
count(e.id_entrega) as entregas_realizadas
from pilotos p
left join entregas e
on e.id_piloto = p.id_piloto
and e.estado = 'ENTREGADA'
group by p.id_piloto, p.nombres, p.apellidos, p.licencia
order by entregas_realizadas desc, piloto asc;

-- c) =

select
concat(p.nombres, ' ', p.apellidos) as piloto,
p.licencia as licencia,
coalesce(concat(s.nombres, ' ', s.apellidos), 'DIRECCION DE OPERACIONES') as supervisor
from pilotos p 
left join pilotos s on s.id_piloto = p.id_supervisor
order by supervisor, piloto;

-- d) = 

select 
e.codigo as codigo,
c.nombre as cliente,
d.codigo_serie as dron,
e.distancia_km as distancia,
d.autonomia_km as auntonomia,
(e.distancia_km - d.autonomia_km) as execeso_km
from entregas e
inner join clientes c on c.id_cliente = e.id_cliente
inner join drones d on d.id_dron = e.id_dron
where e.estado = 'PROGRAMADA'
and e.distancia_km > d.autonomia_km
order by execeso_km asc;


#R9 consultas multitabla--------------------------------------------------------------------------------

-- a) = 

select codigo, municipio_destino, distancia_km from entregas
where estado = 'ENTREGADA'
and distancia_km > (
	select avg(distancia_km) from entregas
	where estado = 'ENTREGADA'
	)
order by distancia_km desc;

-- b) =

select nombre, tipo, municipio, fecha_registro from clientes
where id_cliente not in (
	select id_cliente from entregas
	)
order by fecha_registro, nombre;

-- c) = 

select
d.codigo_serie as dron,
b.nombre as base,
d.horas_vuelo as horas_de_vuelo
from drones d 
inner join bases b on b.id_base = d.id_base
where d.horas_vuelo > (
	select avg(d2.horas_vuelo)
	from drones d2
	where d2.id_base = d.id_base
)
order by base;

-- d) = 

select 
d.codigo_serie as dron, 
d.modelo as modelo, 
d.estado as estado
from drones d
where d.estado <> 'RETIRADO' 
and not exists (
	select 1
	from mantenimientos m
	where m.id_dron = d.id_dron
)
order by d.codigo_serie;















#R10 vista de indices-----------------------------------------------------------------------------------------

-- a) = 

CREATE VIEW ww_tablero_entregas AS
SELECT
    e.codigo                                  AS codigo,
    e.fecha_programada                        AS fecha_programada,
    c.nombre                                  AS cliente,
    c.tipo                                    AS tipo_cliente,
    e.municipio_destino                       AS municipio_destino,
    d.codigo_serie                            AS dron,
    CONCAT(p.nombres, ' ', p.apellidos)       AS piloto,
    e.prioridad                               AS prioridad,
    e.estado                                  AS estado,
    COUNT(DISTINCT ce.id_tipo)                AS tipos_carga,
    COALESCE(SUM(ce.peso_kg), 0)              AS peso_total_kg
FROM entregas e
INNER JOIN clientes c ON c.id_cliente = e.id_cliente
INNER JOIN drones   d ON d.id_dron    = e.id_dron
INNER JOIN pilotos  p ON p.id_piloto  = e.id_piloto
LEFT JOIN  carga_entrega ce ON ce.id_entrega = e.id_entrega
GROUP BY e.id_entrega, e.codigo, e.fecha_programada,
         c.nombre, c.tipo, e.municipio_destino,
         d.codigo_serie, p.nombres, p.apellidos,
         e.prioridad, e.estado;

-- Prueba de la vista (entregas PROGRAMADA o EN_VUELO)
SELECT *
FROM ww_tablero_entregas
WHERE estado IN ('PROGRAMADA', 'EN_VUELO')
ORDER BY fecha_programada ASC;

-- R10.b Índice 1
-- Optimiza la búsqueda de entregas por estado dentro de un rango
-- de fechas programadas: estado (igualdad) + fecha (rango).
CREATE INDEX idx_entregas_estado_fecha ON entregas (estado, fecha_programada);

-- R10.b Índice 2
-- Optimiza la búsqueda de clientes por tipo y municipio, usada
-- por el área comercial para segmentar clientes geográficamente.
CREATE INDEX idx_clientes_tipo_municipio ON clientes (tipo, municipio);

-- Demostración de que existen
SHOW INDEX FROM entregas;
SHOW INDEX FROM clientes;

-- ============================================================
-- R11. FUNCIÓN ALMACENADA
-- ============================================================

-- R11.a Función fn_valor_entrega
DROP FUNCTION IF EXISTS fn_valor_entrega;

DELIMITER //

CREATE FUNCTION fn_valor_entrega(p_id_entrega INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
BEGIN
    DECLARE v_existe       INT;
    DECLARE v_carga        DECIMAL(12,2);
    DECLARE v_distancia    DECIMAL(12,2);
    DECLARE v_prioridad    VARCHAR(8);
    DECLARE v_total        DECIMAL(12,2);

    SELECT COUNT(*) INTO v_existe
    FROM entregas
    WHERE id_entrega = p_id_entrega;

    IF v_existe = 0 THEN
        RETURN NULL;
    END IF;

    SELECT COALESCE(SUM(ce.peso_kg * tc.tarifa_kg), 0) INTO v_carga
    FROM carga_entrega ce
    INNER JOIN tipos_cargas tc ON tc.id_tipo = ce.id_tipo
    WHERE ce.id_entrega = p_id_entrega;

    SELECT distancia_km * 1200 INTO v_distancia
    FROM entregas
    WHERE id_entrega = p_id_entrega;

    SET v_total = v_carga + v_distancia;

    SELECT prioridad INTO v_prioridad
    FROM entregas
    WHERE id_entrega = p_id_entrega;

    IF v_prioridad = 'URGENTE' THEN
        SET v_total = v_total * 1.20;
    END IF;

    RETURN ROUND(v_total, 2);
END //

DELIMITER ;

-- R11.b.1 Listar ENTREGADA URGENTE con su valor
SELECT
    codigo,
    prioridad,
    fn_valor_entrega(id_entrega) AS valor_cop
FROM entregas
WHERE estado = 'ENTREGADA'
  AND prioridad = 'URGENTE'
ORDER BY valor_cop DESC;

-- R11.b.2 Probar con id inexistente
SELECT fn_valor_entrega(999) AS valor_cop;


-- r12

DELIMITER //

DROP TRIGGER IF EXISTS trg_entregas_estado //

CREATE TRIGGER trg_entregas_estado
BEFORE UPDATE ON entregas
FOR EACH ROW
BEGIN
    -- 1. Solo actuar si el estado realmente cambió
    IF OLD.estado <> NEW.estado THEN
        
        -- 2. Si el nuevo estado es ENTREGADA y no tiene fecha, asignarle la actual
        IF NEW.estado = 'ENTREGADA' AND NEW.fecha_entrega IS NULL THEN
            SET NEW.fecha_entrega = NOW();
        END IF;
        
        -- 3. Insertar en el historial de auditoría
        INSERT INTO historial_entregas (id_entrega, estado_anterior, estado_nuevo, fecha_cambio)
        VALUES (OLD.id_entrega, OLD.estado, NEW.estado, NOW());
        
    END IF;
END //

DELIMITER ;

-- Sentencia 1: ENT-0018 pasa a ENTREGADA y le ponen calificación 5
UPDATE entregas SET estado = 'ENTREGADA', calificacion = 5 WHERE codigo = 'ENT-0018';

-- Sentencia 2: ENT-0019 se cancela
UPDATE entregas SET estado = 'CANCELADA' WHERE codigo = 'ENT-0019';

-- Sentencia 3: ENT-0011 solo cambia la calificación (el estado no cambia)
UPDATE entregas SET calificacion = 4 WHERE codigo = 'ENT-0011';

DELIMITER //

DROP PROCEDURE IF EXISTS sp_programar_entrega //

CREATE PROCEDURE sp_programar_entrega(
    IN p_codigo        VARCHAR(10),
    IN p_id_cliente    INT,
    IN p_id_dron       INT,
    IN p_id_piloto     INT,
    IN p_fecha_prog    DATETIME,
    IN p_municipio     VARCHAR(60),
    IN p_distancia_km  DECIMAL(5,1),
    IN p_prioridad     VARCHAR(8)
)
BEGIN
    DECLARE v_existe_dron    INT DEFAULT 0;
    DECLARE v_existe_piloto  INT DEFAULT 0;
    DECLARE v_estado_dron    VARCHAR(15);
    DECLARE v_autonomia      DECIMAL(5,1);
    DECLARE v_licencia       CHAR(1);
    DECLARE v_id_generado    INT;

    -- =========================================================
    -- Validación 1: El dron y el piloto existen
    -- =========================================================
    SELECT COUNT(*) INTO v_existe_dron
    FROM drones WHERE id_dron = p_id_dron;

    IF v_existe_dron = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El dron especificado no existe.';
    END IF;

    SELECT COUNT(*) INTO v_existe_piloto
    FROM pilotos WHERE id_piloto = p_id_piloto;

    IF v_existe_piloto = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El piloto especificado no existe.';
    END IF;

    -- =========================================================
    -- Validación 2: El dron está ACTIVO (RN-06)
    -- =========================================================
    SELECT estado INTO v_estado_dron
    FROM drones WHERE id_dron = p_id_dron;

    IF v_estado_dron <> 'ACTIVO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El dron no está en estado ACTIVO y no puede recibir entregas.';
    END IF;

    -- =========================================================
    -- Validación 3: La distancia no supera la autonomía (RN-05)
    -- =========================================================
    SELECT autonomia_km INTO v_autonomia
    FROM drones WHERE id_dron = p_id_dron;

    IF p_distancia_km > v_autonomia THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La distancia de la entrega supera la autonomía del dron.';
    END IF;

    -- =========================================================
    -- Validación 4: La licencia permite la distancia (RN-03)
    -- =========================================================
    SELECT licencia INTO v_licencia
    FROM pilotos WHERE id_piloto = p_id_piloto;

    IF (v_licencia = 'A' AND p_distancia_km > 20)
       OR (v_licencia = 'B' AND p_distancia_km > 40) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La licencia del piloto no permite operar esa distancia.';
    END IF;

    -- =========================================================
    -- Si todo es válido: INSERTAR la entrega
    -- =========================================================
    INSERT INTO entregas (
        codigo, id_cliente, id_dron, id_piloto,
        fecha_programada, municipio_destino, distancia_km, prioridad
        -- Ojo: el estado NO se pone, porque tiene DEFAULT 'PROGRAMADA'
    ) VALUES (
        p_codigo, p_id_cliente, p_id_dron, p_id_piloto,
        p_fecha_prog, p_municipio, p_distancia_km, p_prioridad
    );

    -- Obtener el id generado
    SET v_id_generado = LAST_INSERT_ID();

    -- Mostrar el mensaje
    SELECT CONCAT('Entrega ', p_codigo, ' programada exitosamente con id: ', v_id_generado)
           AS mensaje;

END //

DELIMITER ;

CALL sp_programar_entrega('ENT-0021', 11, 3, 3, '2026-10-03 10:00:00', 'Marinilla', 16.0, 'URGENTE');
CALL sp_programar_entrega('ENT-0022', 6, 4, 4, '2026-10-03 11:00:00', 'Guarne', 9.0, 'NORMAL');
CALL sp_programar_entrega('ENT-0023', 2, 7, 7, '2026-10-04 08:00:00', 'Arcabuco', 28.0, 'NORMAL');

SELECT *
FROM ww_tablero_entregas
WHERE codigo = 'ENT-0021';









