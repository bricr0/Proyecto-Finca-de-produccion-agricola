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
-- 11 fn_NivelReordenProducto(producto_id): Calcula el punto de reorden óptimo.
DELIMITER //

CREATE FUNCTION fn_NivelReordenProducto(p_producto_id INT)
RETURNS INT
DETERMINISTIC
BEGIN
	DECLARE v_consumo_promedio DECIMAL(10,2);
	DECLARE v_lead_time INT DEFAULT 7;
	DECLARE v_nivel_seguridad INT DEFAULT 2;

	SELECT COALESCE(AVG(cantidad), 0) INTO v_consumo_promedio
	FROM Detalle_Venta d 
	JOIN Venta v ON d.id_venta  = v.id
	WHERE d.id_producto  = p_producto_id
	AND v.fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY);
	
	RETURN CEILING(v_consumo_promedio * v_lead_time * v_nivel_seguridad);
END //

DELIMITER ;

SELECT fn_NivelReordenProducto(15) AS punto_reorden;

-- 12 fn_DepreciacionMaquinaria(maquina_id, fecha): Calcula depreciación.
DELIMITER // 

CREATE FUNCTION fn_DepreciacionMaquinaria(p_maquina_id INT, p_fecha DATE)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN 
	DECLARE v_valor_inicial DECIMAL(12,2);
	DECLARE v_vida_util INT DEFAULT 5;
	DECLARE v_fecha_compra DATE;
	DECLARE v_meses_transcurridos INT;
	DECLARE v_depreciacion_acumulada DECIMAL(12,2);

	SELECT m.id , fecha_compra
	INTO v_valor_inicial, v_fecha_compra
	FROM Maquinaria m 
	WHERE id = p_maquina_id;
	
	SET v_meses_transcurridos = TIMESTAMPDIFF(MONTH, v_fecha_compra, p_fecha);
	
	SET v_depreciacion_acumulada = (v_valor_inicial / (v_vida_util * 12)) * LEAST(v_meses_transcurridos, v_vida_util * 12);
	
	RETURN ROUND(v_depreciacion_acumulada, 2);
END //

DELIMITER ;

SELECT fn_DepreciacionMaquinaria(5, '2023-12-31') AS depreciacion_acumulada;
-- 13 fn_RequerimientoAguaPorCultivo(cultivo_id, area): Devuelve litros necesarios.
DELIMITER //

CREATE FUNCTION fn_RequerimientoAguaPorCultivo(p_lote_id INT, p_area DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN 
    DECLARE v_coeficiente_agua DECIMAL(10,2);
    
    SELECT 
        CASE
            WHEN tipo_uso LIKE '%Hortalizas%' THEN 5.0
            WHEN tipo_uso LIKE '%Frutales%' THEN 7.5
            WHEN tipo_uso LIKE '%Cereales%' THEN 3.5 
            ELSE 4.0
        END INTO v_coeficiente_agua
    FROM Lote 
    WHERE id = p_lote_id; 
    
    RETURN ROUND(v_coeficiente_agua * p_area, 2);
END //

DELIMITER ;
SELECT fn_RequerimientoAguaPorCultivo(10, 25) AS litros_agua_necesarios;
-- 14 fn_ProyeccionVentasMensual(producto_id, meses): Devuelve ventas previstas.
DELIMITER //

CREATE FUNCTION fn_ProyeccionVentasMensual(p_producto_id INT, p_meses INT) 
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE v_venta_promedio DECIMAL(12,2);
    DECLARE v_factor_crecimiento DECIMAL(5,2) DEFAULT 1.05; 
    DECLARE v_proyeccion DECIMAL(12,2) DEFAULT 0;
    DECLARE i INT DEFAULT 1;

    SELECT COALESCE(AVG(dv.cantidad * dv.precio_unitario), 0) INTO v_venta_promedio
    FROM Detalle_Venta dv
    JOIN Venta v ON dv.id_venta = v.id
    WHERE dv.id_producto = p_producto_id
    AND v.fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 6 MONTH);

    WHILE i <= p_meses DO
        SET v_proyeccion = v_proyeccion + (v_venta_promedio * POW(v_factor_crecimiento, i));
        SET i = i + 1;
    END WHILE;
    
    RETURN ROUND(v_proyeccion, 2);
END //

DELIMITER ;
SELECT fn_ProyeccionVentasMensual(15, 3) AS ventas_proyectadas;
-- 15 fn_DisponibilidadMaquinaria(maquina_id)
DELIMITER //

CREATE FUNCTION fn_DisponibilidadMaquinaria(p_maquina_id INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE v_total_dias INT DEFAULT 30;
    DECLARE v_dias_operativos INT;
    DECLARE v_disponibilidad DECIMAL(5,2);

    SELECT COUNT(DISTINCT DATE(fecha_uso)) INTO v_dias_operativos
    FROM Uso_Maquinaria
    WHERE id_maquinaria_fk = p_maquina_id
    AND fecha_uso >= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY);

    SET v_disponibilidad = (v_dias_operativos / v_total_dias) * 100;
    
    RETURN ROUND(v_disponibilidad, 2);
END //

DELIMITER ;
SELECT fn_DisponibilidadMaquinaria(8) AS disponibilidad_maquinaria;
-- 16 fn_EficienciaProduccion(lote_id)
DELIMITER //

CREATE FUNCTION fn_EficienciaProduccion(p_lote_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_produccion DECIMAL(10,2);
    DECLARE v_actividades INT;
    DECLARE v_eficiencia DECIMAL(10,2);

    SELECT COALESCE(SUM(cantidad), 0) INTO v_produccion
    FROM Produccion
    WHERE id_lote_fk = p_lote_id;

    SELECT COUNT(*) INTO v_actividades
    FROM Actividad_Agricola
    WHERE id_lote = p_lote_id;

    IF v_actividades > 0 THEN
        SET v_eficiencia = v_produccion / v_actividades;
    ELSE
        SET v_eficiencia = 0;
    END IF;
    
    RETURN ROUND(v_eficiencia, 2);
END //

DELIMITER ;
SELECT fn_EficienciaProduccion(1) AS eficicencia_produccion;
-- 17 fn_ProductividadPorLote(lote_id, perido)
DELIMITER //

CREATE FUNCTION fn_ProductividadPorLote(p_lote_id INT, p_periodo VARCHAR(10)) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_produccion_total DECIMAL(12,2);
    DECLARE v_ventas_total DECIMAL(12,2);
    DECLARE v_productividad DECIMAL(10,2);
    DECLARE v_fecha_inicio DATE;

    SET v_fecha_inicio = CASE p_periodo
        WHEN 'mensual' THEN DATE_SUB(CURRENT_DATE(), INTERVAL 1 MONTH)
        WHEN 'trimestral' THEN DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH)
        ELSE DATE_SUB(CURRENT_DATE(), INTERVAL 1 YEAR)
    END;

    SELECT COALESCE(SUM(cantidad), 0) INTO v_produccion_total
    FROM Produccion
    WHERE id_lote_fk = p_lote_id
    AND fecha_produccion >= v_fecha_inicio;

    SELECT COALESCE(SUM(dv.cantidad), 0) INTO v_ventas_total
    FROM Detalle_Venta dv
    JOIN Venta v ON dv.id_venta = v.id
    JOIN Produccion p ON dv.id_producto = p.id_producto_fk
    WHERE p.id_lote_fk = p_lote_id
    AND v.fecha >= v_fecha_inicio;

    IF v_produccion_total > 0 THEN
        SET v_productividad = (v_ventas_total / v_produccion_total) * 100;
    ELSE
        SET v_productividad = 0;
    END IF;
    
    RETURN ROUND(v_productividad, 2);
END //

DELIMITER ;
SELECT fn_ProductividadPorLote(1, 'mensual') AS productividad_mensual;
-- 18 fn_RiesgoClimaticoPorMes(mes): Devuelve factor de riesgo (tabla auxiliar).
DELIMITER //

CREATE FUNCTION fn_RiesgoClimaticoPorMes(p_mes INT) 
RETURNS DECIMAL(3,2)
DETERMINISTIC
BEGIN
    DECLARE v_riesgo DECIMAL(3,2);

    SET v_riesgo = CASE p_mes
        WHEN 1 THEN 0.75 
        WHEN 2 THEN 0.80 
        WHEN 3 THEN 0.65 
        WHEN 4 THEN 0.45 
        WHEN 5 THEN 0.30 
        WHEN 6 THEN 0.25 
        WHEN 7 THEN 0.20 
        WHEN 8 THEN 0.25 
        WHEN 9 THEN 0.40 
        WHEN 10 THEN 0.60 
        WHEN 11 THEN 0.70 
        WHEN 12 THEN 0.78 
        ELSE 0.50 
    END;
    
    RETURN v_riesgo;
END //

DELIMITER ;
SELECT fn_RiesgoClimaticoPorMes(5) AS riesgo_mayo;
-- 19 fn_UsoMaquinariaLote(lote_id)
DELIMITER //

CREATE FUNCTION fn_UsoMaquinariaLote(p_lote_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_horas_uso DECIMAL(10,2);
    DECLARE v_tamano_lote DECIMAL(10,2);
    DECLARE v_uso_por_hectarea DECIMAL(10,2);

    SELECT COALESCE(SUM(horas_uso), 0) INTO v_horas_uso
    FROM Uso_Maquinaria
    WHERE id_lote_fk = p_lote_id;

    SELECT tamaño INTO v_tamano_lote
    FROM Lote
    WHERE id = p_lote_id;

    IF v_tamano_lote > 0 THEN
        SET v_uso_por_hectarea = v_horas_uso / v_tamano_lote;
    ELSE
        SET v_uso_por_hectarea = 0;
    END IF;
    
    RETURN ROUND(v_uso_por_hectarea, 2);
END //

DELIMITER ;
SELECT fn_UsoMaquinariaLote(1) AS uso_maquinaria;
-- 20 fn_RotacionInventario(producto_id)
DELIMITER //

CREATE FUNCTION fn_RotacionInventario(p_producto_id INT) 
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_ventas_promedio DECIMAL(10,2);
    DECLARE v_inventario_promedio DECIMAL(10,2);
    DECLARE v_rotacion DECIMAL(10,2);

    SELECT COALESCE(SUM(dv.cantidad)/3, 0) INTO v_ventas_promedio
    FROM Detalle_Venta dv
    JOIN Venta v ON dv.id_venta = v.id
    WHERE dv.id_producto = p_producto_id
    AND v.fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 3 MONTH);

    SELECT COALESCE(AVG(cantidad), 0) INTO v_inventario_promedio
    FROM Inventario
    WHERE id_producto_fk = p_producto_id;

    IF v_inventario_promedio > 0 THEN
        SET v_rotacion = v_ventas_promedio / v_inventario_promedio;
    ELSE
        SET v_rotacion = 0;
    END IF;
    
    RETURN ROUND(v_rotacion, 2);
END //

DELIMITER ;

SELECT fn_RotacionInventario(12) AS rotacion_inventario;
