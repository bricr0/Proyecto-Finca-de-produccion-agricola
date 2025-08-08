-- 11. Promedio de horas de uso de cada tipo de maquinaria
SELECT m.nombre, AVG(um.horas_uso) as horas_de_uso
FROM Maquinaria m 
JOIN Uso_Maquinaria um on m.id = um.id_maquinaria_fk
GROUP By m.nombre;

-- 12. Ranking de lotes por rendimiento
SELECT l.nombre, SUM(p.cantidad) / l.tamaño as rendimiento 
FROM Lote l
JOIN Produccion p on l.id = p.id_lote_fk
GROUP BY l.id, l.nombre, l.tamaño;

-- 13. Combinaciones de productos frecuentemente vendidos
SELECT dv.id_producto, dv2.id_producto , COUNT(*) as  veces_juntos
FROM Detalle_Venta dv 
JOIN Detalle_Venta dv2 on dv.id_venta = dv2.id_venta and dv.id_producto < dv2.id_producto
GROUP BY dv.id_producto, dv2.id_producto;

-- 14. Lotes con producción inferior al 70% de su potencial
SELECT l.nombre, SUM(p.cantidad) as produccion, l.tamaño * 1000 as produccion_potencial, ROUND((SUM(p.cantidad)/ (l.tamaño * 1000)) * 100, 2) as porcentaje_produccion
FROM Lote l
JOIN Produccion p on l.id = p.id_lote_fk
GROUP BY l.id, l.nombre, l.tamaño
HAVING SUM(p.cantidad) < (l.tamaño*1000* 0.7);
-- 16. Lotes cuya producción total supera el promedio histórico de producción de todos los lotes, usando HAVING.
SELECT p.id_lote_fk,  SUM(p.cantidad) as total_lote
FROM Produccion p 
GROUP BY p.id_lote_fk
HAVING total_lote > (
SELECT AVG(total_lote)
FROM(
SELECT SUM(p.cantidad) as total_lote
FROM Produccion p 
GROUP BY p.id_lote_fk
) as totales
);
-- 17. Maquinaria cuyo tiempo total de uso supera el promedio de uso de todas las máquinas.
SELECT *
FROM (
  SELECT 
    id_maquinaria_fk,
    SUM(horas_uso) AS total_horas
  FROM Uso_Maquinaria
  GROUP BY id_maquinaria_fk
) AS resumen
WHERE total_horas > (
  SELECT AVG(total_maquina)
  FROM (
    SELECT id_maquinaria_fk, SUM(horas_uso) AS total_maquina
    FROM Uso_Maquinaria
    GROUP BY id_maquinaria_fk
  ) AS promedio
);
-- 18. Producción y precio medio de cada producto filtrando por ingresos superiores a X.
SELECT dv.id_venta, AVG(dv.precio_unitario) as precio_medio, SUM(dv.cantidad * dv.precio_unitario) AS ingresos
FROM Detalle_Venta dv
GROUP BY dv.id_producto
HAVING SUM(dv.cantidad * dv.precio_unitario) > 1000;
-- 19. Actividades agrícolas agrupadas por tipo de actividad y lote.
SELECT aa.id_lote, GROUP_CONCAT(ta.nombre SEPARATOR ', ') AS tipos_actividades
FROM Actividad_Agricola aa 
JOIN Tipo_actividad ta on aa.id_tipo_actividad = ta.id
GROUP BY aa.id_tipo_actividad asc;
-- 20. 5 productos con mayor ingreso generado en el último año.
SELECT dv.id_producto,SUM(dv.cantidad *  dv.precio_unitario) as Ingreso
FROM Detalle_Venta dv 
JOIN Venta v ON dv.id_venta = v.id
WHERE v.fecha BETWEEN "2023-01-01" and "2023-12-31" 
GROUP BY dv.id_producto 
ORDER BY Ingreso DESC LIMIT 5;