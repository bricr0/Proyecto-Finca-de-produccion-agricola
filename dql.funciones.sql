-- 1. **fn_CalcularRendimientoPorHectarea(lote_id)**: Devuelve kg/ha promedio.
 
DELIMITER //
CREATE FUNCTION CalcularRendimientoPorHectarea(lote_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC 
BEGIN
	
	DECLARE v_total INT;
	DECLARE v_hectareas DECIMAL(10,2);
	
	SELECT SUM(p.cantidad) INTO v_total
	FROM Produccion p 
	WHERE p.id_producto_fk = lote_id;
	
	SELECT l.tamaño INTO v_hectareas
	FROM Lote l 
	WHERE l.id = lote_id;
	
	RETURN IFNULL(v_total / v_hectareas, 0);
END
//
DELIMITER ;
SELECT CalcularRendimientoPorHectarea(1) AS rendimiento_kg_ha;

-- 2. **fn_CalcularProduccionTotal**(periodo_inicio, periodo_fin): Devuelve la producción total (en kilos) de todos los lotes en un rango de fechas. 
DELIMITER // 
CREATE FUNCTION CalcularProduccionTotal(periodo_inicio DATE, periodo_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE produccion_total DECIMAL(10,2);

	SELECT SUM(p.cantidad) INTO produccion_total
	FROM Produccion p
	WHERE p.fecha_produccion BETWEEN periodo_inicio AND periodo_fin;
	
	RETURN IFNULL(produccion_total, 0);
END
//
DELIMITER ;	

SELECT * FROM Produccion p;
SELECT CalcularProduccionTotal('2023-08-01', '2023-09-20') As produccion_total;

-- 3. **fn_EdadMaquinaria(maquina_id)**: Devuelve la antigüedad en años.
DROP FUNCTION EdadMaquinaria;
DELIMITER //
CREATE FUNCTION EdadMaquinaria(maquina_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	DECLARE edad_maquina DECIMAL(10,2);
	
	SELECT TIMESTAMPDIFF(YEAR, m.fecha_compra, CURDATE()) INTO edad_maquina
	FROM Maquinaria m  
	WHERE m.id = maquina_id;
	
	RETURN IFNULL(edad_maquina, 0);
	
END
//
DELIMITER ;

SELECT EdadMaquinaria(1) AS Edad_maquinaria;
-- 4. **fn_EstimarProduccionFutura(cultivo_id, meses)**: Devuelve un pronóstico simple.
DELIMITER //
CREATE FUNCTION EstimarProduccionFutura(nombre_producto varchar(50), meses INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	
	DECLARE produccion_futura DECIMAL(10,2);
	DECLARE produccion_mensual DECIMAL(10,2);
	DECLARE producto_id INT;
	
	SELECT p.id_producto INTO producto_id
	FROM Producto p  
	WHERE LOWER(p.nombre) = LOWER(nombre_producto);
	
	SELECT AVG(p.cantidad) INTO produccion_mensual
	FROM Produccion p 
	WHERE p.id_producto_fk = producto_id;
	
	SET produccion_futura = produccion_mensual * meses;
	
	RETURN IFNULL(produccion_futura, 0);
END
//
DELIMITER ;

SELECT EstimarProduccionFutura("maiz blanco", 6) as produccion_futura;
-- 5. **fn_CalcularDiasDesdeUltimaCosecha(lote_id)**: Devuelve el número de días transcurridos desde la última cosecha registrada para un lote específico.
DELIMITER //
CREATE FUNCTION CalcularDiasDesdeUltimaCosecha(nombre_lote VARCHAR(100))
RETURNS DECIMAL(10,2)
DETERMINISTIC 
BEGIN
	
	DECLARE ultima_cosecha INT;
	
	SELECT DATEDIFF(CURDATE(), MAX(aa.fecha)) INTO ultima_cosecha
	FROM Lote l
	JOIN Actividad_Agricola aa ON l.id = aa.id_lote
	WHERE LOWER(l.nombre) = LOWER(nombre_lote);
	
	RETURN  IFNULL(ultima_cosecha, 0);
END
//
DELIMITER ;

SELECT CalcularDiasDesdeUltimaCosecha('LOTE NORTE A') AS 'Ultima Cosecha';

-- 6. **fn_TiempoEntreActividades(act1_id, act2_id)**: Retorna el número de días transcurridos entre la fecha de 
-- finalización de la primera actividad y la fecha de inicio de la segunda, 
DELIMITER //
CREATE FUNCTION TiempoEntreActividades(tarea_1 VARCHAR(50), tarea_2 VARCHAR(50))
RETURNS INT
DETERMINISTIC
BEGIN
	
	DECLARE tarea_fecha_1 DATE;
	DECLARE tarea_fecha_2 DATE;
	DECLARE dias_entre_fechas INT;
	
	SELECT t.fecha INTO tarea_fecha_1
	FROM Empleado e 
	JOIN Asignacion_Tarea at2 ON e.id = at2.id_empleado_fk
	JOIN Tarea t ON at2.id_tarea_fk = t.id
	WHERE LOWER(t.descripcion)  = LOWER(tarea_1)
	LIMIT 1;
	
	SELECT t.fecha INTO tarea_fecha_2
	FROM Empleado e 
	JOIN Asignacion_Tarea at2 ON e.id = at2.id_empleado_fk
	JOIN Tarea t ON at2.id_tarea_fk = t.id
	WHERE LOWER(t.descripcion)  = LOWER(tarea_2)
	LIMIT 1;
	
	SET dias_entre_fechas = ABS(DATEDIFF(tarea_fecha_1, tarea_fecha_2));
	
	RETURN IFNULL(dias_entre_fechas, 0);
	
END;
//
DELIMITER ;
SELECT TiempoEntreActividades('Siembra maíz Lote Norte', 'Preparación terreno Lote 1') AS dias;
SELECT * from Tarea t;

-- 7. **fn_DiasEmpleadoTrabajando(nombre_empleado)**: Devuelve la cantidad de dias que lleva un empleado trabajando.
DELIMITER //
CREATE FUNCTION DiasEmpleadoTrabajando(doc_identidad int) 
RETURNS INT
DETERMINISTIC
BEGIN
	
	DECLARE tiempo_empleado INT;
	
	SELECT DATEDIFF(CURDATE(), e.fecha_ingreso) INTO tiempo_empleado
	FROM Empleado e
	WHERE e.doc_identidad = doc_identidad;
	
	RETURN IFNULL(tiempo_empleado, 0);
END;
DELIMITER ;
SELECT * FROM Empleado e; 
SELECT DiasEmpleadoTrabajando(67890123) AS dias_en_la_empresa;
-- 8. **fn_DisponibilidadMaquinaria(maquina_id, periodo)**: Devuelve porcentaje de uso libre.

DROP FUNCTION DisponibilidadMaquinaria;
DELIMITER //
CREATE FUNCTION DisponibilidadMaquinaria(nombre_maquina VARCHAR(50), fecha_inicio DATE, fecha_fin DATE)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
	
	DECLARE porcentaje_uso DECIMAL(10,2);
	DECLARE total_dias INT;
	DECLARE hora_disponible DECIMAL(10,2);
	DECLARE horas_usadas DECIMAL(10,2);
	
	SELECT DATEDIFF(fecha_fin, fecha_inicio) + 1 INTO total_dias;
	
	SET hora_disponible = total_dias * 24;
	
	SELECT SUM(um.horas_uso) INTO horas_usadas
	FROM Uso_Maquinaria um 
	JOIN Maquinaria m ON um.id_maquinaria_fk = m.id
	WHERE LOWER(m.nombre) = LOWER(nombre_maquina) 
	AND um.fecha_uso BETWEEN fecha_inicio AND fecha_fin;
	
	SET porcentaje_uso = ((hora_disponible - horas_usadas) / hora_disponible) * 100;
	
	RETURN IFNUL(porcentaje_uso, 0);
END;
//
DELIMITER ;

SELECT * FROM Uso_Maquinaria um ;
SELECT DisponibilidadMaquinaria("Tractor John Deere 6125", '2020-01-15', '2025-01-10') AS porcentaje;

-- 9. fn_TotalHorasUso(maquina_id, fecha_inicio, fecha_fin): Devuelve la suma total de horas que una máquina estuvo en uso en el rango de fechas indicado.
DROP FUNCTION TotalHorasUso;

DELIMITER //
CREATE FUNCTION TotalHorasUso(nombre_maquina VARCHAR(50), fecha_inicio DATE , fecha_fin DATE )
RETURNS DECIMAL(10,2)
DETERMINISTIC 
BEGIN
	
	DECLARE horas_uso DECIMAL(10,2);
	
	SELECT SUM(um.horas_uso) INTO horas_uso 
	FROM Maquinaria m 
	JOIN Uso_Maquinaria um ON m.id = um.id_maquinaria_fk
	WHERE LOWER(m.nombre) = LOWER(nombre_maquina)
	AND um.fecha_uso BETWEEN fecha_inicio AND fecha_fin;
	
	RETURN IFNULL(horas_uso, 0);
	
END;
//
DELIMITER ; 

SELECT * FROM Maquinaria m;
SELECT TotalHorasUso("Tractor John Deere 6125", '2020-01-15', '2025-01-10') AS horas_uso;

-- 10. **fn_CantidadStockProducto(producto_id)**: Devuelve el stock actual disponible.
DROP FUNCTION CantidadStockProducto;

DELIMITER //
CREATE FUNCTION CantidadStockProducto(nombre_producto VARCHAR(50))
RETURNS INT
DETERMINISTIC 
BEGIN
	
	DECLARE cantidad_stock INT;
	
	SELECT SUM(i.cantidad) INTO cantidad_stock
	FROM Inventario i 
	JOIN Producto p ON i.id_producto_fk = p.id_producto
	WHERE LOWER(p.nombre) = LOWER(nombre_producto);
	
	RETURN IFNULL(cantidad_stock, 0);
	
END;
//
DELIMITER ;

SELECT * FROM Producto;
SELECT CantidadStockProducto('maiZ amarillo') as cantidad_stock;
