#requisisto funcional 38

create view vw_tablero_indicador
select 
ti.nombre as indicador,
ti.periocidad,
p.descripcion as periodo,
p.anio,
p.mes,
s.nombre as sexo,
re.descripcion as rango_edad,
t.nombre as terriotorio, 
t.nivel as nivel_territorio,
ra.nombre as rama actividad,
i.valor,
i.confiable,
i.fecha_calculo

from indicador i
join tipo_indicador ti on ti.id_tipo_indicador = i.id_tipo_indicador
join periodo p