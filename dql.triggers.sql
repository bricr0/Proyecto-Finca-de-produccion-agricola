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

