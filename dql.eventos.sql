SET GLOBAL event_scheduler = ON;

-- 1. **ev_BackupDiario**: Copiar todas las tablas críticas a tablas de respaldo dentro de la BD. 
CREATE TABLE Actividad_Agricola_backup LIKE Actividad_Agricola;
CREATE TABLE Asignacion_Tarea_backup LIKE Asignacion_Tarea;
CREATE TABLE Cliente_bakup LIKE Cliente;
CREATE TABLE Compra_backup LIKE Compra;
CREATE TABLE Detalle_Compra_backup LIKE Detalle_Compra;
CREATE TABLE Detalle_Venta_backup LIKE Detalle_Venta;
CREATE TABLE Empleado_backup LIKE Empleado;
CREATE TABLE Entrada_Inventario_backup LIKE Entrada_Inventario;
CREATE TABLE Inventario_backup LIKE Inventario;
CREATE TABLE Lote_backup LIKE Lote;
CREATE TABLE Mantenimiento_backup LIKE Mantenimiento;
CREATE TABLE Maquinaria_backup LIKE Maquinaria;
CREATE TABLE Produccion_backup LIKE Produccion;
CREATE TABLE Producto_backup LIKE Producto;
CREATE TABLE Proveedor_backip LIKE Proveedor;
CREATE TABLE Salida_Inventario_backup LIKE Salida_Inventario;
CREATE TABLE Tarea_backup LIKE Tarea;
CREATE TABLE Tipo_actividad_backup LIKE Tipo_actividad;
CREATE TABLE Uso_Maquinaria_backup LIKE Uso_Maquinaria;
CREATE TABLE Venta_backup LIKE Venta;

DELIMITER //
CREATE EVENT BackupDiario 
ON SCHEDULE EVERY 1 DAY
STARTS '2025-08-09 00:00:00'
DO
BEGIN
	TRUNCATE TABLE Actividad_Agricola_backup;
	TRUNCATE TABLE Asignacion_Tarea_backup;
	TRUNCATE TABLE Cliente_bakup;
	TRUNCATE TABLE Compra_backup;
	TRUNCATE TABLE Detalle_Compra_backup;
	TRUNCATE TABLE Detalle_Venta_backup;
	TRUNCATE TABLE Empleado_backup;
	TRUNCATE TABLE Entrada_Inventario_backup;
	TRUNCATE TABLE Inventario_backup;
	TRUNCATE TABLE Lote_backup;
	TRUNCATE TABLE Mantenimiento_backup;
	TRUNCATE TABLE Maquinaria_backup;
	TRUNCATE TABLE Produccion_backup;
	TRUNCATE TABLE Producto_backup;
	TRUNCATE TABLE Proveedor_backip;
	TRUNCATE TABLE Salida_Inventario_backup;
	TRUNCATE TABLE Tarea_backup;
	TRUNCATE TABLE Tipo_actividad_backup;
	TRUNCATE TABLE Uso_Maquinaria_backup;
	TRUNCATE TABLE Venta_backup;
	
	INSERT INTO Actividad_Agricola_backup
	SELECT * FROM Actividad_Agricola;
	
	INSERT INTO Asignacion_Tarea_backup
	SELECT * FROM Asignacion_Tarea;
	
	INSERT INTO Cliente_bakup
	SELECT * FROM Cliente;
	
	INSERT INTO Compra_backup
	SELECT * FROM Compra;
	
	INSERT INTO Detalle_Compra_backup
	SELECT * FROM Detalle_Compra;
	
	INSERT INTO Detalle_Venta_backup
	SELECT * FROM Detalle_Venta;
	
	INSERT INTO Empleado_backup
	SELECT * FROM Empleado;
	
	INSERT INTO Entrada_Inventario_backup
	SELECT * FROM Entrada_Inventario;
	
	INSERT INTO Inventario_backup
	SELECT * FROM Inventario;
	
	INSERT INTO Lote_backup
	SELECT * FROM Lote;
	
	INSERT INTO Mantenimiento_backup
	SELECT * FROM Mantenimiento;
	
	INSERT INTO Maquinaria_backup
	SELECT * FROM Maquinaria;
	
	INSERT INTO Produccion_backup
	SELECT * FROM Produccion;
	
	INSERT INTO Producto_backup
	SELECT * FROM Producto;
	
	INSERT INTO Proveedor_backip
	SELECT * FROM Proveedor;
	
	INSERT INTO Salida_Inventario_backup
	SELECT * FROM Salida_Inventario;
	
	INSERT INTO Tarea_backup
	SELECT * FROM Tarea;
	
	INSERT INTO Tipo_actividad_backup
	SELECT * FROM Tipo_actividad;
	
	INSERT INTO Uso_Maquinaria_backup
	SELECT * FROM Uso_Maquinaria;
	
	INSERT INTO Venta_backup
	SELECT * FROM Venta;
END;
//
DELIMITER ;
-- 2. **ev_ControlStockBajo**: Revisa inventario cada lunes 08:00 a.m. e inserta alertas si hay productos con menos de 100 unidades.
CREATE TABLE alertas_inventario (
	id INT PRIMARY KEY AUTO_INCREMENT,
	id_producto_fk int,
	nombre_producto_fk varchar(70),
	cantidad_actual int,
	fecha_alerta DATE 
);

DELIMITER //
CREATE EVENT ControlStockBajo
ON SCHEDULE EVERY 1 WEEK
STARTS '2025-08-11 08:00:00'
DO
BEGIN
	
	INSERT INTO alertas_inventario (id_producto_fk, nombre_producto_fk, cantidad_actual, fecha_alerta)
	SELECT p.id_producto, p.nombre, i.cantidad, NOW()
	FROM Producto p 
	JOIN Inventario i ON p.id_producto = i.id_producto_fk
	WHERE i.cantidad < 100;
END;
//
DELIMITER ;
SELECT * FROM alertas_inventario;
-- 3. **ev_ReporteVentasMensual**: Reporte ventas mensuales.

CREATE TABLE Reporte_Mensual_Ventas (
	id INT PRIMARY KEY AUTO_INCREMENT,
	nombre_producto varchar(70),
	cantidad int,
	total_ventas DECIMAL(10,2),
	fecha DATE
);
DROP EVENT ReporteVentasMensual;

DELIMITER //
CREATE EVENT ReporteVentasMensual
ON SCHEDULE EVERY 1 MONTH
STARTS NOW()
DO
BEGIN
	
	INSERT INTO Reporte_Mensual_Ventas(nombre_producto, cantidad, total_ventas, fecha)
	SELECT p.nombre, SUM(dv.cantidad) as Cantidad, SUM(v.total_venta) AS total, now()
	FROM Producto p
	JOIN Detalle_Venta dv ON p.id_producto = dv.id_producto
	JOIN Venta v ON dv.id_venta = v.id
	GROUP BY p.id_producto;
END;
// 
DELIMITER ;
SELECT * FROM Reporte_Mensual_Ventas;
-- 4. **ev_EliminarClientesInactivos**: Cada 1 de enero, eliminar de la base de datos a los clientes que no hayan realizado ninguna compra en los últimos 3 años.
DROP EVENT EliminarClientesInactivos;

DELIMITER // 
CREATE EVENT EliminarClientesInactivos 
ON SCHEDULE EVERY 1 YEAR
STARTS CURRENT_TIMESTAMP
DO
BEGIN

    DELETE
    FROM Cliente c
    WHERE NOT EXISTS ( 
        SELECT 1
        FROM Venta v
        WHERE v.id_cliente = c.id
        AND v.fecha >= DATE_SUB(CURDATE(), INTERVAL 3 YEAR)
    );
END;
//
DELIMITER ;

SELECT * FROM Venta;
SELECT * FROM Cliente c;
-- 5. **ev_ReporteActividadesTrimestral**: Resume actividades agrícolas trimestrales por tipo de uso de lote.
 SELECT * FROM Lote;
-- 6. **ev_ActualizarEstadoMaquinaria**: cambia a mantiniento las maquinas cada domingo si superaron las 20 horas de uso Y regresa las horas a 0
DROP EVENT ActualizarEstadoMaquinaria;
DELIMITER //
CREATE EVENT ActualizarEstadoMaquinaria
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
	
	UPDATE Maquinaria m
	JOIN Uso_Maquinaria um ON m.id = um.id_maquinaria_fk
	SET estado = "mantenimiento"
	WHERE um.horas_uso >= 20;
	
	UPDATE Uso_Maquinaria um 
	SET horas_uso = 0
	WHERE horas_uso >= 20;
	
END;
//
DELIMITER ;

SELECT * FROM Maquinaria m; 
-- 7. **ev_EnviarRecordatoriosTareasDiarias**: Marcar en una tabla las tareas pendientes cada semana iniciando el lunes.
CREATE TABLE RecordatoriosTareasDiarias(
	id INT PRIMARY KEY AUTO_INCREMENT,
	tareas VARCHAR(100),
	estado VARCHAR(25)
); 
DROP EVENT EnviarRecordatoriosTareasDiarias;

DELIMITER //
CREATE EVENT EnviarRecordatoriosTareasDiarias
ON SCHEDULE EVERY 1 WEEK
STARTS CURRENT_TIMESTAMP
DO
BEGIN
	
	TRUNCATE TABLE RecordatoriosTareasDiarias;
	
	INSERT INTO RecordatoriosTareasDiarias (tareas, estado)
	SELECT t.descripcion, t.estado
	FROM Tarea t
	WHERE t.estado = 'pendiente';
	
END;
//
DELIMITER ;

SELECT * FROM RecordatoriosTareasDiarias;
-- 8. **ev_LimpiarVentasAntiguas** Elimina ventas con tres anios de antiguedad.

DROP EVENT LimpiarVentasAntiguas;

DELIMITER //
CREATE EVENT LimpiarVentasAntiguas
ON SCHEDULE EVERY 1 YEAR
STARTS CURRENT_TIMESTAMP
DO
BEGIN
	
	DELETE FROM Venta WHERE fecha <  DATE_SUB(CURDATE(), INTERVAL 3 YEAR);
	
END;
//
DELIMITER ;

SELECT * FROM Venta;

-- 9. **ev_ProgramarMantenimientoSemanal**: Planifica mantenimientos cada lunes

DELIMITER //

-- 10. **ev_ActualizarInventarioDiario**: Actualiza el inventario diariamente con los movimientos de ventas y compras del día anterior.
DROP EVENT ActualizarInventarioDiario;
DELIMITER //
CREATE EVENT ActualizarInventarioDiario
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
BEGIN
	
	UPDATE Inventario i 
	LEFT JOIN (
	SELECT id_producto_fk, SUM(cantidad) as total_entradas
	FROM Entrada_Inventario
	WHERE fecha = CURDATE() - INTERVAL 1 DAY
	GROUP BY id_producto_fk
	) ei ON i.id_producto_fk = ei.id_producto_fk
	LEFT JOIN (
	SELECT id_producto_fk, SUM(cantidad) as total_salidas
	FROM Salida_Inventario si 
	WHERE fecha = CURDATE() - INTERVAL 1 DAY
	GROUP BY id_producto_fk
	) si ON i.id_producto_fk = si.id_producto_fk
	SET i.cantidad = i.cantidad + IFNULL(ei.total_entradas, 0) - IFNULL(si.total_salidas, 0);
	
END;
//
DELIMITER ;

SELECT * FROM Entrada_Inventario ei;
SELECT * FROM Salida_Inventario si ;
SELECT * FROM Inventario i;
-- 11 ev_GenerarOrdenesCompraSemanal: Genera compras semanales.
DELIMITER //

CREATE EVENT ev_GenerarOrdenesCompraSemanal
ON SCHEDULE EVERY 1 WEEK STARTS '2023-12-04 06:00:00'
DO
BEGIN
    DECLARE v_umbral INT DEFAULT 10;

    CALL sp_GenerarOrdenCompraAutomatica(v_umbral, 50); 

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_GenerarOrdenesCompraSemanal', 
            CONCAT('Generadas órdenes para productos bajo ', v_umbral, ' unidades'), 
            NOW());
END //

DELIMITER ;
-- 12 ev_OptimizarIndicesSemanal: Reorganiza índices de bases de datos.
DELIMITER //

CREATE EVENT ev_OptimizarIndicesSemanal
ON SCHEDULE EVERY 1 WEEK STARTS '2023-12-03 02:00:00'
DO
BEGIN
  
    ANALYZE TABLE Actividad_Agricola, Produccion, Venta, Compra;
    
    OPTIMIZE TABLE Lote, Producto, Inventario;

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_OptimizarIndicesSemanal', 'Optimización de índices completada', NOW());
END //

DELIMITER ;
-- 13 ev_EnviarAlertasStockBajoDiario: Notifica stock bajo cada día.
DELIMITER //

CREATE EVENT ev_EnviarAlertasStockBajoDiario
ON SCHEDULE EVERY 1 DAY STARTS '2023-12-01 08:00:00'
DO
BEGIN
    DECLARE v_umbral INT DEFAULT 15; 

    CALL sp_EnviarNotificacionStockBajo(v_umbral);

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_EnviarAlertasStockBajoDiario', 
            CONCAT('Notificaciones enviadas para productos bajo ', v_umbral, ' unidades'), 
            NOW());
END //

DELIMITER ;
-- 14 ev_GenerarReporteCostosMensual: Consolida costos operativos.
DELIMITER //

CREATE EVENT ev_GenerarReporteCostosMensual
ON SCHEDULE EVERY 1 MONTH STARTS '2023-12-01 00:00:00'
DO
BEGIN
    DECLARE v_fecha_inicio DATE;
    DECLARE v_fecha_fin DATE;
    
    SET v_fecha_inicio = DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01');
    SET v_fecha_fin = LAST_DAY(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));

    CALL sp_GenerarReporteCostos(v_fecha_inicio, v_fecha_fin);

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_GenerarReporteCostosMensual', 
            CONCAT('Reporte de costos generado del ', v_fecha_inicio, ' al ', v_fecha_fin), 
            NOW());
END //

DELIMITER ;
-- 15 ev_ActualizarSalariosTrimestral: Ajusta salarios por inflación.
DELIMITER //

CREATE EVENT ev_ActualizarSalariosTrimestral
ON SCHEDULE EVERY 3 MONTH STARTS '2024-01-01 00:00:00'
DO
BEGIN
    DECLARE v_inflacion DECIMAL(5,2) DEFAULT 5.0; 

    UPDATE Empleado
    SET salario = salario * (1 + (v_inflacion/100))
    WHERE activo = TRUE;

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_ActualizarSalariosTrimestral', 
            CONCAT('Ajuste salarial aplicado: ', v_inflacion, '%'), 
            NOW());
END //

DELIMITER ;
-- 16 ev_RealizarCheckIntegridadMensual: Verifica integridad referencial.
DELIMITER //

CREATE EVENT ev_RealizarCheckIntegridadMensual
ON SCHEDULE EVERY 1 MONTH STARTS '2023-12-01 03:00:00'
DO
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM Produccion p
        LEFT JOIN Lote l ON p.id_lote_fk = l.id
        WHERE l.id IS NULL
    ) THEN
        INSERT INTO LogErrores (evento, descripcion, severidad, fecha)
        VALUES ('ev_RealizarCheckIntegridadMensual', 
                'Error de integridad: Producciones sin lote asociado', 
                'ALTA', NOW());
    END IF;
    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_RealizarCheckIntegridadMensual', 
            'Verificación de integridad completada', 
            NOW());
END //

DELIMITER ;
-- 17 ev_ArchivarDatosAnuales: Mueve datos antiguos a tablas históricas.
DELIMITER //

CREATE EVENT ev_ArchivarDatosAnuales
ON SCHEDULE EVERY 1 YEAR STARTS '2024-01-01 04:00:00'
DO
BEGIN

    INSERT INTO Produccion_Historico
    SELECT * FROM Produccion
    WHERE fecha_produccion < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
    
  
    DELETE FROM Produccion
    WHERE fecha_produccion < DATE_SUB(CURDATE(), INTERVAL 2 YEAR);
    

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_ArchivarDatosAnuales', 
            'Archivado anual de datos históricos completado', 
            NOW());
END //

DELIMITER ;
-- 18 ev_ActualizarRegionClimaticaAnual: Recalcula zonas climáticas por lote.
DELIMITER //

CREATE EVENT ev_ActualizarRegionClimaticaAnual
ON SCHEDULE EVERY 1 YEAR STARTS '2024-01-15 00:00:00'
DO
BEGIN

    UPDATE Lote l
    JOIN (
        SELECT id_lote, AVG(temperatura) AS temp_promedio, AVG(precipitacion) AS prec_promedio
        FROM Sensores
        WHERE fecha >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
        GROUP BY id_lote
    ) s ON l.id = s.id_lote
    SET l.zona_climatica = CASE
        WHEN temp_promedio > 25 AND prec_promedio > 100 THEN 'Tropical'
        WHEN temp_promedio > 20 AND prec_promedio > 50 THEN 'Subtropical'
        ELSE 'Templado'
    END;

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_ActualizarRegionClimaticaAnual', 
            'Actualización anual de zonas climáticas completada', 
            NOW());
END //

DELIMITER ;
-- 19 ev_SincronizacionMovilDiario: Envía datos a la app móvil.
DELIMITER //

CREATE EVENT ev_SincronizacionMovilDiario
ON SCHEDULE EVERY 1 DAY STARTS '2023-12-01 23:30:00'
DO
BEGIN

    SELECT * INTO OUTFILE '/tmp/datos_sincronizacion.csv'
    FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    FROM (
        SELECT id, nombre, tipo_uso, tamaño 
        FROM Lote 
        WHERE fecha_modificacion >= DATE_SUB(NOW(), INTERVAL 1 DAY)
        UNION ALL
        SELECT id_producto, nombre, tipo_producto, NULL
        FROM Producto
        WHERE fecha_modificacion >= DATE_SUB(NOW(), INTERVAL 1 DAY)
    ) AS datos_actualizados;

    INSERT INTO LogEventos (evento, descripcion, fecha)
    VALUES ('ev_SincronizacionMovilDiario', 
            'Archivo de sincronización generado', 
            NOW());
END //

DELIMITER ;
-- 20 ev_ArchivadoLogOperacional: Archive logs de operación cada noche.
DELIMITER //

CREATE EVENT ev_ArchivadoLogOperacional
ON SCHEDULE EVERY 1 DAY STARTS '2023-12-01 23:45:00'
DO
BEGIN
    INSERT INTO LogOperacional_Historico
    SELECT * FROM LogOperacional
    WHERE fecha < CURDATE();

    DELETE FROM LogOperacional
    WHERE fecha < CURDATE();

    INSERT INTO LogOperacional_Historico (evento, descripcion, fecha)
    VALUES ('ev_ArchivadoLogOperacional', 
            'Archivado diario de logs operacionales completado', 
            NOW());
END //

DELIMITER ;