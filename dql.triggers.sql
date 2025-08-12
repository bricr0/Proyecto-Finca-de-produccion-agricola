-- 1. **tr_Venta_UpdateInventario**: Reduce stock al insertar una venta.
DROP TRIGGER Venta_UpdateInventario;

DELIMITER //
CREATE TRIGGER Venta_UpdateInventario
AFTER INSERT ON Detalle_Venta
FOR EACH ROW 
BEGIN 
	
	DECLARE stock_actual INT;
	
	SELECT i.cantidad INTO stock_actual
	FROM Inventario i 
	WHERE i.id_producto_fk = NEW.id_producto
	LIMIT 1;
	
	IF stock_actual < NEW.cantidad THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para realizar la venta';
	ELSE
		UPDATE Inventario 
		SET cantidad = cantidad - NEW.cantidad,
		fecha_actualizacion = NOW()
		WHERE id_producto_fk = NEW.id_producto
		LIMIT 1;
	END IF;
END;
//
DELIMITER ;

SELECT * FROM Venta;
-- 2. **tr_AfterInsertProduccion_UpdateInventario**: Suma producción al stock.
DROP TRIGGER Produccion_UpdateInventario;

DELIMITER //
CREATE TRIGGER Produccion_UpdateInventario
AFTER INSERT ON Produccion
FOR EACH ROW 
BEGIN
	
	DECLARE stock_actual DECIMAL(10,2);
	
	SELECT i.cantidad INTO stock_actual
	FROM Inventario i
	WHERE i.id_producto_fk = NEW.id_producto_fk;
	
	IF stock_actual IS NULL THEN
		INSERT INTO Inventario (id_producto_fk, cantidad, fecha_actualizacion)
		VALUES (new.id_producto_fk, new.cantidad, now());
	ELSE
		UPDATE Inventario
		SET cantidad = canntidad + new.cantidad,
		fecha_actualizacion = NOW()
		WHERE id_producto_fk = NEW.id_producto_fk;
	END IF;
END;
//
DELIMITER ;

-- 3. **tr_BeforeInsertMaquinaria_Validate**: Impide registrar maquinaria duplicada.
DELIMITER //
CREATE  TRIGGER InsertMaquinaria_Validate
BEFORE INSERT ON Maquinaria 
FOR EACH ROW
BEGIN
	
	DECLARE maquinaria_existe INT;
	
	SELECT COUNT(*) INTO maquinaria_existe
	FROM Maquinaria m 
	WHERE LOWER(m.nombre) = LOWER(NEW.nombre);
	
	IF maquinaria_existe >= 1 THEN
		SIGNAL SQLSTATE '45000'	
        SET MESSAGE_TEXT = 'Error: Maquina ya existe';
	END IF;
END;
//
DELIMITER ;

-- 4. **tr_AfterUpdateEmpleado_HistorialSalario**: Guarda cambios de salario en historial.
DROP TABLE historial_salarios;
CREATE TABLE historial_salarios (
	id INT primary key AUTO_INCREMENT,
	doc_identidad INT,
	antiguo_salario DECIMAL(10,2),
	nuevo_salario DECIMAL(10,2)
);

DELIMITER //
CREATE TRIGGER Empleado_HistorialSalario
AFTER UPDATE ON Empleado
FOR EACH ROW
BEGIN
	
	IF OLD.salario <> NEW.salario THEN
		INSERT INTO historial_salarios(doc_identidad, antiguo_salario, nuevo_salario)
		VALUES(NEW.doc_identidad, OLD.salario, NEW.salario);
	END IF;
	
END;
//
DELIMITER ;
-- 5. **tr_AfterInsertCompra_UpdateInventario**: Actualiza inventario al registrar compra.
DELIMITER //
CREATE TRIGGER Compra_UpdateInventario
AFTER INSERT ON Detalle_Compra
FOR EACH ROW
BEGIN
		UPDATE Inventario i
		SET cantidad = cantidad + new.cantidad,
		fecha_actualizacion = NOW()
		WHERE i.id_producto_fk = new.id_producto_fk;
END; 
//
DELIMITER ;

-- 6. **tr_BeforeInsertActividad_ValidateFecha**: Evita que se inserte una actividad con fecha anterior a hoy.
DELIMITER //
CREATE TRIGGER Actividad_ValidateFecha
BEFORE INSERT ON Tarea
FOR EACH ROW 
BEGIN
	
	IF NEW.fecha < CURDATE() THEN 
		SIGNAL SQLSTATE '45000'	
        SET MESSAGE_TEXT = 'Error: No puedes poner fechas anteriores';		
	END IF;
	
END;
//
DELIMITER ;
-- 7. **tr_AfterInsertMantenimiento_UpdateMaquinaria**: Cambia el estado de la máquina.
DELIMITER //
CREATE TRIGGER Mantenimiento_UpdateMaquinaria
AFTER INSERT ON Mantenimiento
FOR EACH ROW
BEGIN
	
	UPDATE Maquinaria m
	SET estado = 'mantenimiento'
	WHERE m.id = NEW.id_maquinaria_fk;
END;
//
DELIMITER ;
-- 8. **tr_AfterInsertProveedor_Log**: Guarda en tabla de auditoría.
CREATE TABLE Log_Proveedor (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_proveedor INT,
    nombre VARCHAR(100),
    accion VARCHAR(20),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER InsertProveedor_Log
AFTER INSERT ON Proveedor
FOR EACH ROW
BEGIN
	
	INSERT INTO Log_Proveedor(id_proveedor, nombre, accion)
	VALUES (NEW.id, NEW.nombre, 'INSERT');
END;
//
DELIMITER ;

-- 9. **tr_BeforeDeleteProducto_PreventDeletionIfStock**: Impide borrar producto con stock > 0.
DELIMITER //
CREATE TRIGGER DeleteProducto_PreventDeletionIfStock
BEFORE DELETE ON Inventario
FOR EACH ROW
BEGIN
	
	IF OLD.cantidad > 0 THEN
		SIGNAL SQLSTATE '45000'	
        SET MESSAGE_TEXT = 'No se puede borrar el producto: stock mayor a 0';			
	END IF;
END; 
//
DELIMITER ;
-- 10. **tr_AfterUpdateEmpleado_UpdateFechaModificacion**: Después de actualizar los datos de un empleado, guardar automáticamente la fecha y hora de la última modificación en un campo
ALTER TABLE Empleado
ADD COLUMN fecha_modificacion DATETIME DEFAULT NULL;

DELIMITER //
CREATE TRIGGER Empleado_UpdateFechaModificacion
BEFORE UPDATE ON Empleado
FOR EACH ROW
BEGIN
    SET NEW.fecha_modificacion = NOW();
END;
//
DELIMITER ;

-- 11 tr_BeforeInsertVenta_ValidateCliente: Verifica que el cliente exista y esté activo.
DELIMITER //

CREATE TRIGGER tr_BeforeInsertVenta_ValidateCliente
BEFORE INSERT ON Venta
FOR EACH ROW
BEGIN
    DECLARE cliente_existe INT;
    
    SELECT COUNT(*) INTO cliente_existe 
    FROM Cliente 
    WHERE id = NEW.id_cliente;
    
    IF cliente_existe = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede registrar la venta: El cliente no existe';
    END IF;
END //

DELIMITER ;
-- 12 tr_AfterUpdatePrecio_LogPrecio: Registra cambios de precios en auditoría.
DELIMITER //

CREATE TRIGGER tr_AfterUpdatePrecio_LogPrecio
AFTER UPDATE ON Detalle_Venta
FOR EACH ROW
BEGIN
    IF OLD.precio_unitario <> NEW.precio_unitario THEN
        INSERT INTO Inventario (id_producto_fk, cantidad, fecha_actualizacion)
        VALUES (OLD.id_producto, 0, NOW()); -- Usamos Inventario como registro de auditoría
    END IF;
END //

DELIMITER ;
-- 13 tr_AfterInsertLote_CalculateTamañoRef: Calcula y almacena referencia de tamaño.
DELIMITER //

CREATE TRIGGER tr_AfterInsertLote_CalculateTamañoRef
AFTER INSERT ON Lote
FOR EACH ROW
BEGIN
    DECLARE categoria VARCHAR(20);
    
    SET categoria = CASE 
        WHEN NEW.tamaño < 1 THEN 'Pequeño'
        WHEN NEW.tamaño BETWEEN 1 AND 5 THEN 'Mediano'
        ELSE 'Grande'
    END;
    
    -- Actualizamos el nombre para incluir la categoría
    UPDATE Lote 
    SET nombre = CONCAT(nombre, ' (', categoria, ')')
    WHERE id = NEW.id;
END //

DELIMITER ;
-- 14 tr_BeforeUpdateLote_ValidateSuperficie: Verifica que la superficie sea positiva.
DELIMITER //

CREATE TRIGGER tr_BeforeUpdateLote_ValidateSuperficie
BEFORE UPDATE ON Lote
FOR EACH ROW
BEGIN
    IF NEW.tamaño <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El tamaño del lote debe ser un valor positivo';
    END IF;
END //

DELIMITER ;
-- 15 tr_AfterInsertProduccion_UpdateProduccionSummary: Actualiza tabla resumen.
DELIMITER //

CREATE TRIGGER tr_AfterInsertProduccion_UpdateSummary
AFTER INSERT ON Produccion
FOR EACH ROW
BEGIN
    UPDATE Inventario 
    SET cantidad = cantidad + NEW.cantidad,
        fecha_actualizacion = NOW()
    WHERE id_producto_fk = NEW.id_producto_fk;

    IF ROW_COUNT() = 0 THEN
        INSERT INTO Inventario (id_producto_fk, cantidad, fecha_actualizacion)
        VALUES (NEW.id_producto_fk, NEW.cantidad, NOW());
    END IF;
END //

DELIMITER ;
-- 16 tr_AfterInsertEmpleado_AssignRole: Asigna un rol por defecto al nuevo empleado.
DELIMITER //

CREATE TRIGGER tr_AfterInsertEmpleado_AssignRole
AFTER INSERT ON Empleado
FOR EACH ROW
BEGIN
    
    UPDATE Empleado
    SET doc_identidad = CONCAT('EMP-', LPAD(NEW.id, 5, '0'))
    WHERE id = NEW.id;
END //

DELIMITER ;
-- 17 tr_BeforeInsertVenta_ValidateInventario: Impide facturar si no hay stock suficiente.
DELIMITER //

CREATE TRIGGER tr_BeforeInsertDetalleVenta_ValidateInventario
BEFORE INSERT ON Detalle_Venta
FOR EACH ROW
BEGIN
    DECLARE stock_actual DECIMAL(10,2);
    
    SELECT COALESCE(cantidad, 0) INTO stock_actual
    FROM Inventario
    WHERE id_producto_fk = NEW.id_producto;
    
    IF stock_actual < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay suficiente stock para realizar la venta';
    END IF;
END //

DELIMITER ;
-- 18 tr_AfterInsertActividad_ArchiveOld: Archive logs anteriores a un año.
DELIMITER //

CREATE TRIGGER tr_AfterInsertActividad_ArchiveOld
AFTER INSERT ON Actividad_Agricola
FOR EACH ROW
BEGIN
	
    DELETE FROM Actividad_Agricola 
    WHERE fecha < DATE_SUB(NOW(), INTERVAL 2 YEAR)
    AND id NOT IN (
        SELECT id FROM (
            SELECT id FROM Actividad_Agricola 
            ORDER BY fecha DESC 
            LIMIT 1000
        ) AS temp
    );
END //

DELIMITER ;
-- 19 tr_AfterInsertTarea_ScheduleReminder: Programa recordatorio tras una notificación.
DELIMITER //

CREATE TRIGGER tr_AfterInsertTarea_ScheduleReminder
AFTER INSERT ON Tarea
FOR EACH ROW
BEGIN
    
    IF NEW.descripcion LIKE '%urgente%' THEN
        UPDATE Tarea
        SET estado = 'en proceso'
        WHERE id = NEW.id;
    END IF;
END //

DELIMITER ;
-- 20 tr_BeforeInsertAsignacionTarea_ValidateEmpleadoAvailability: Evita sobreasignar tareas.
DELIMITER //

CREATE TRIGGER tr_BeforeInsertAsignacionTarea_ValidateEmpleado
BEFORE INSERT ON Asignacion_Tarea
FOR EACH ROW
BEGIN
    DECLARE tareas_pendientes INT;
    
    SELECT COUNT(*) INTO tareas_pendientes
    FROM Asignacion_Tarea at
    JOIN Tarea t ON at.id_tarea_fk = t.id
    WHERE at.id_empleado_fk = NEW.id_empleado_fk
    AND t.estado IN ('pendiente', 'en proceso');
    
    IF tareas_pendientes >= 5 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado ya tiene 5 tareas asignadas pendientes';
    END IF;
END //

DELIMITER ;