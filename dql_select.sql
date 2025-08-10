-- 1
-- Producción total por producto en el mes actual
SELECT p.nombre, SUM(pr.cantidad) AS produccion_total
FROM Produccion pr
JOIN Producto p ON pr.id_producto_fk = p.id_producto
WHERE MONTH(pr.fecha_produccion) = MONTH(CURRENT_DATE())
GROUP BY p.nombre;
-- 2
-- Productos que no se han producido en los últimos 6 meses
SELECT p.nombre
FROM Producto p
WHERE p.id_producto NOT IN (
    SELECT DISTINCT pr.id_producto_fk
    FROM Produccion pr
    WHERE pr.fecha_produccion >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH)
);
-- 3
-- 5 lotes con mayor rendimiento anual
SELECT l.nombre, SUM(pr.cantidad) AS rendimiento_anual
FROM Produccion pr
JOIN Lote l ON pr.id_lote_fk = l.id
GROUP BY l.nombre
ORDER BY rendimiento_anual DESC
LIMIT 5;

-- 4
--  Lote con mayor producción total
SELECT l.nombre
FROM Lote l
JOIN Produccion p ON l.id = p.id_lote_fk
GROUP BY l.nombre
HAVING SUM(p.cantidad) = (
    SELECT MAX(total_produccion)
    FROM (
        SELECT SUM(cantidad) AS total_produccion
        FROM Produccion
        GROUP BY id_lote_fk
    ) AS subreque	rimiento
);

-- 5
-- Ventas mensuales por producto (superiores al promedio)
SELECT p.nombre, MONTH(v.fecha) AS mes, SUM(dv.cantidad) AS cantidad_vendida
FROM Detalle_Venta dv
JOIN Venta v ON dv.id_venta = v.id
JOIN Producto p ON dv.id_producto = p.id_producto
GROUP BY p.nombre, MONTH(v.fecha)
HAVING cantidad_vendida > (
    SELECT AVG(cantidad)
    FROM Detalle_Venta
);

-- 6
-- Clientes con más de 3 compras en el último año
SELECT c.nombre, COUNT(v.id) AS total_compras
FROM Cliente c
JOIN Venta v ON c.id = v.id_cliente
WHERE v.fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
GROUP BY c.nombre
HAVING COUNT(v.id) > 3;

-- 7
-- Promedio de producción por tipo de cultivo
SELECT l.tipo_uso AS tipo_cultivo, AVG(p.cantidad) AS produccion_promedio
FROM Produccion p
JOIN Lote l ON p.id_lote_fk = l.id
GROUP BY l.tipo_uso;


-- 8
-- Empleados con tareas pendientes 
SELECT e.nombre_completo, COUNT(at.id) AS tareas_pendientes
FROM Empleado e
JOIN Asignacion_Tarea at ON e.id = at.id_empleado_fk
JOIN Tarea t ON at.id_tarea_fk = t.id
WHERE t.estado = 'pendiente'
GROUP BY e.nombre_completo;

-- 9
-- Stock actual vs stock promedio histórico
SELECT p.nombre, 
       i.cantidad AS stock_actual,
       (SELECT AVG(ei.cantidad) 
        FROM Entrada_Inventario ei 
        WHERE ei.id_producto_fk = p.id_producto) AS promedio_historico
FROM Inventario i
JOIN Producto p ON i.id_producto_fk = p.id_producto;

-- 10
-- Lotes con costo operativo superior al promedio
SELECT l.nombre, SUM(um.horas_uso) AS total_horas_uso
FROM Uso_Maquinaria um
JOIN Lote l ON um.id_lote_fk = l.id
GROUP BY l.nombre
HAVING total_horas_uso > (
    SELECT AVG(total_horas)
    FROM (
        SELECT SUM(horas_uso) AS total_horas
        FROM Uso_Maquinaria
        GROUP BY id_lote_fk
    ) AS subrequerimiento
);
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