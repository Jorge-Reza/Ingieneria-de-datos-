-- requisito #2 -----------------------------------------------------------------------------------------------------------------------------------------------
drop database if exists cicloverde;
create database cicloverde;
use cicloverde;

create table estaciones(
id_estacion int auto_increment primary key,
nombre varchar(50) not null unique,
barrio varchar(50) not null,
capacidad int not null,
activa boolean not null default TRUE,

constraint chk_capacidad_positiva check (capacidad > 0)
);

create table bicicletas(
id_bici int primary key auto_increment,
codigo varchar(10)unique not null,
modelo varchar(40) not null,
estado varchar(10) not null default 'ACTIVA',
km_recorridos decimal(7,1) not null default 0,
id_estacion int not null,

constraint chk_km_recorridos check (km_recorridos >= 0),
constraint chk_estado_bici check (estado in ('ACTIVA', 'TALLER', 'BAJA')),

constraint fk_estacion
foreign key (id_estacion)
references estaciones(id_estacion)
);

create table usuarios(
id_usuario int primary key auto_increment,
documento varchar(15) not null unique,
nombres varchar(50) not null,
apellidos varchar(50) not null,
email varchar(80) null unique,
telefono varchar(15) null,
plan varchar(10) not null default 'BASICO',
fehca_registro date not null,

constraint chk_plan check (plan in ('PREMIUM', 'BASICO'))
);

create table accesorios(
id_accesorios int primary key auto_increment,
nombre varchar(40) not null unique ,
precio decimal(8,2) not null,

constraint chk_precio_positivo check (precio >0)
);

create table viajes(
id_viaje int auto_increment primary key,
id_usuario int not null,
id_bici int not null,
id_estacion_origen int not null,
id_estacion_destino int not null,
fecha_inicio datetime not null,
km decimal(5,1) not null default 0,
estado varchar(12) not null default 'EN_CURSO',
calificacion smallint null,

constraint chk_recorrido check (km >= 0),
constraint chk_estado check (estado in ('EN_CURSO', 'FINALIZADO', 'CANCELADO')),
constraint chk_calificacion_positiva check (calificacion between 1 and 5),

constraint fk_usuarios
foreign key (id_usuario)
references usuarios(id_usuario),

constraint fk_bicis
foreign key (id_bici)
references bicicletas(id_bici),

constraint fk_origen
foreign key (id_estacion_origen)
references estaciones(id_estacion)
);

drop table viajes;

create table viajes_accesorios(
id_viaje int not null,
id_accesorio int not null,
cantidad int not null default 1,

constraint chk_cantidad check (cantidad >0),

constraint id_viaje
foreign key (id_viaje)
references viajes(id_viaje),

constraint id_accesorios
foreign key (id_accesorio)
references accesorios(id_accesorios)
);

create table historial_bicicletas(
id_historial int primary key auto_increment,
id_bici int not null,
estado_anterior varchar(10) not null,
estado_nuevo varchar(10) not null,
fecha_cambio datetime not null default(current_timestamp()),

constraint fk_bicicleta
foreign key (id_bici)
references bicicletas(id_bici)
);

show table usuarios;
show table bicicletas;
show table estaciones;
show table historial_biciletas;
show table accesorios;

