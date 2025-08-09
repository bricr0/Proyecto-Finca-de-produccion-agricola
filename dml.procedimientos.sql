-- 1. **sp_ProcesarVenta**: Registra una venta y actualiza el inventario automáticamente.

DROP PROCEDURE ProcesarVenta;
DELIMITER //
CREATE PROCEDURE ProcesarVenta(in Iid_cliente int, Iid_empleado int, I_id_producto int, 
				 I_cantidad int, I_precio_unitario DECIMAL(10,2))
BEGIN
	DECLARE I_total_venta DECIMAL(10,2);
	
	SET  I_total_venta = I_precio_unitario * I_cantidad;
	
	INSERT INTO Venta (fecha, id_cliente, id_empleado, total_venta)
	VALUES (now(),Iid_cliente, Iid_empleado, I_total_venta);
	
	SET @I_id_venta = LAST_INSERT_ID();
	
	INSERT INTO Detalle_Venta (id_venta, id_producto, cantidad, precio_unitario)
	VALUES (@I_id_venta, I_id_producto, I_cantidad, I_precio_unitario);
	
	UPDATE Inventario i 
	SET cantidad = cantidad - I_cantidad,
	fecha_actualizacion = now()
	WHERE i.id_producto_fk = I_id_producto;
END
//
DELIMITER ;

CALL ProcesarVenta(4, 3, 10, 5, 25.50);
SELECT * FROM Inventario i ;
-- 2. **sp_RegistrarProveedor**: Inserta un nuevo proveedor validando que no exista.
DROP PROCEDURE RegistrarProveedo;
DELIMITER //
CREATE PROCEDURE RegistrarProveedo(I_nombre varchar(70), I_tipo_insumo varchar(50), I_telefono varchar(20), I_direccion varchar(100)) 
BEGIN
	DECLARE I_existe int;
	SELECT COUNT(*) INTO I_existe FROM Proveedor p WHERE p.nombre = I_nombre;
	
	IF I_existe = 0 THEN
		INSERT INTO Proveedor(nombre, tipo_insumo,  telefono, direccion)
		VALUES (I_nombre, I_tipo_insumo, I_telefono, I_direccion);
	ELSE
	    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El proveedor ya existe';
	END IF;
END
//
DELIMITER ;
CALL RegistrarProveedo(
    'Agroinsumos El Campo',
    'Fertilizantes orgánicos',
    '310-987-6543',
    'Carretera Central Km 8, Pueblo Nuevo'
);

SELECT * FROM Proveedor p;
-- 3. **sp_RegistrarEmpleado**: Inserta un empleado y asigna una tarea.
DROP PROCEDURE RegistrarEmpleado;
DELIMITER // 
CREATE PROCEDURE RegistrarEmpleado(in I_nombre_completo varchar(70), I_doc_identidad int, I_cargo varchar(50), I_fecha_ingreso DATE,
				 I_telefono VARCHAR(20), I_salario DECIMAL(10,2),
				 I_Tarea_Descipcion varchar(100), I_fecha_tarea DATE, I_estado ENUM('pendiente', 'en proceso', 'completada'))
BEGIN
	DECLARE E_existe int;
	DECLARE I_id_empleado int;
	DECLARE I_id_tarea int;

	SELECT COUNT(*) INTO E_existe FROM Empleado e WHERE e.doc_identidad = I_doc_identidad;
	
	IF I_estado NOT IN ('pendiente', 'en proceso', 'completada') THEN
	   SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT = 'Estado inválido';
	END IF;

	IF E_existe = 0 THEN 
		INSERT INTO Empleado (nombre_completo, doc_identidad, cargo, fecha_ingreso, telefono, salario)
		VALUES  (I_nombre_completo, I_doc_identidad, I_cargo, I_fecha_ingreso, I_telefono, I_salario);
		
		SET I_id_empleado = LAST_INSERT_ID();
		
		INSERT INTO Tarea (descripcion, fecha, estado)
		VALUES (I_Tarea_Descipcion, I_fecha_tarea, I_estado);
		
		SET I_id_tarea = LAST_INSERT_ID();
		
		INSERT INTO Asignacion_Tarea (id_empleado_fk, id_tarea_fk)
		VALUES (@I_id_empleado, @I_id_tarea);
	ELSE 
		signal SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El empleado ya esta registrado';
	END IF;
END
//
DELIMITER ;

CALL RegistrarEmpleado(
    'María Martinez',
    1024567890,
    'Recolectora de Café',
    '2025-08-07',
    '3112345678',
    1200000.00,
    'Recolección de café maduro en el lote 3',
    '2025-08-08',
    'pendiente'
);
-- 4. **sp_ActualizarEstadoMaquinaria**: Cambia el estado de una máquina según informe de mantenimiento.
DELIMITER // 
CREATE PROCEDURE ActualizarEstadoMaquinaria(IN I_nombre varchar(70), I_estado varchar(25))
BEGIN 
	IF I_estado NOT IN ('operando', 'mantenimiento', 'descompuesta') THEN
	   SIGNAL SQLSTATE '45000'
	   		SET MESSAGE_TEXT = 'Estado inválido';
	END IF;
	
	UPDATE Maquinaria m 	
	SET estado = I_estado
	WHERE m.nombre = I_nombre;
END
//
DELIMITER ;
CALL ActualizarEstadoMaquinaria('Tractor John Deere 6125', 'mantenimiento');
SELECT * FROM Maquinaria m;
-- 5. **sp_CalcularNomina**: Calcula la nómina de un empleado en un período dado
DROP PROCEDURE CalcularNomina;
DELIMITER //
CREATE PROCEDURE CalcularNomina(I_doc_identidad int, I_fecha_inicial DATE, I_fecha_final DATE)
BEGIN 
	DECLARE sueldo_base DECIMAL(10,2);
	DECLARE E_existe int;
	DECLARE dias_mes int;
	DECLARE dias_trabajados int;
	DECLARE sueldo_diario DECIMAL(10,2);
	DECLARE nomina DECIMAL(10,2);
	
	SELECT COUNT(*) INTO E_existe FROM Empleado WHERE doc_identidad = I_doc_identidad;
	
	IF E_existe = 1 THEN
		SELECT salario INTO sueldo_base FROM Empleado WHERE doc_identidad = I_doc_identidad;
		SET dias_mes =  DAY(LAST_DAY(I_fecha_inicial));
		SET dias_trabajados = DATEDIFF(I_fecha_final, I_fecha_inicial) + 1;
		SET sueldo_diario = sueldo_base / dias_mes;
		SET nomina = sueldo_diario * dias_trabajados;
		SELECT nomina AS nomina_calculada;
	ELSE
	   SIGNAL SQLSTATE '45000'
   			SET MESSAGE_TEXT = 'Empleado no existe';
	END IF;
END
//
DELIMITER ;
CALL CalcularNomina(1024567890, '2025-08-10', '2025-08-25');
SELECT * FROM Empleado e ;
-- 6. **sp_AsignarActividad**: Asigna una tarea a un empleado.
DROP PROCEDURE AsignarActividad;
DELIMITER //
CREATE PROCEDURE AsignarActividad(IN I_doc_empleado int)
BEGIN
	DECLARE id_tarea_pendiente int;
	DECLARE id_empleado int;
	DECLARE E_existe int;
	
	SELECT COUNT(*) INTO E_existe
	FROM Empleado e 
	WHERE e.doc_identidad = I_doc_empleado;
	
	IF E_existe = 1 THEN
	
		SELECT t.id INTO id_tarea_pendiente
		FROM Tarea t
		WHERE t.estado = "pendiente"
		LIMIT 1;
		
		UPDATE Tarea t 
		SET	estado = "en proceso",
		fecha = now()
		WHERE id = id_tarea_pendiente;
		
		SELECT e.id INTO id_empleado
		FROM Empleado e 
		WHERE e.doc_identidad =  I_doc_empleado
		LIMIT 1;
		
		INSERT INTO Asignacion_Tarea (id_empleado_fk, id_tarea_fk )
		VALUES (id_empleado, id_tarea_pendiente);
	ELSE
	   SIGNAL SQLSTATE '45000'
   			SET MESSAGE_TEXT = 'Empleado no existe';
	END IF;
END
//
DELIMITER ;
CALL AsignarActividad(32333435);
SELECT e.nombre_completo, t.descripcion, t.descripcion
FROM Tarea t
JOIN Asignacion_Tarea at2 ON t.id = at2.id_tarea_fk
JOIN Empleado e ON at2.id_empleado_fk = e.id
WHERE e.doc_identidad = 32333435;
-- 7. sp_ActualizarStock: Procedimiento para actualizar el stock restando la cantidad vendida, validando que no quede stock negativo.
SELECT * FROM Inventario i ;
SELECT * FROM Producto p ;
DROP PROCEDURE ActualizarStock;
DELIMITER //
CREATE PROCEDURE ActualizarStock(IN I_nombre_producto VARCHAR(50), I_cantidad int)
BEGIN
	DECLARE P_existe int;
	DECLARE I_id_producto int;
	DECLARE stock_actual int;
	
	START TRANSACTION;	
		
	SELECT COUNT(*) INTO P_existe
	FROM Producto p 
	WHERE p.nombre = I_nombre_producto;
	
	IF P_existe >= 1 THEN 
	
		SELECT id_producto INTO I_id_producto
		FROM Producto p 
		WHERE p.nombre = I_nombre_producto;
	
		UPDATE Inventario
		set cantidad = cantidad - I_cantidad,
		fecha_actualizacion = NOW()
		WHERE id_producto_fk = I_id_producto;
		
		SELECT cantidad INTO stock_actual
		FROM Inventario i 
		WHERE id_producto_fk = I_id_producto;
		
		IF stock_actual < 0 THEN
			ROLLBACK;	
			SIGNAL SQLSTATE '45000'
   				SET MESSAGE_TEXT = 'El stock del producto no puede quedar negativo';
		ELSE
			COMMIT;
		END IF;
	ELSE
		ROLLBACK;
	   SIGNAL SQLSTATE '45000'
   			SET MESSAGE_TEXT = 'Empleado no existe';
	END IF;
END
 //
DELIMITER ;
CALL ActualizarStock("Brócoli", 600);
-- 8. **sp_GenerarReporteMensualVentas**: Reporte las ventas mensuales por producto.
SELECT * FROM Venta v ;

DROP PROCEDURE ReporteMensualVentas;

DELIMITER //
CREATE PROCEDURE ReporteMensualVentas(IN mes INT, anio INT)
BEGIN

		SELECT p.nombre, SUM(dv.cantidad) as Cantidad, SUM(v.total_venta) AS total, v.fecha
		FROM Producto p
		JOIN Detalle_Venta dv ON p.id_producto = dv.id_producto
		JOIN Venta v ON dv.id_venta = v.id
		WHERE MONTH(v.fecha) = mes AND YEAR(v.fecha) = anio
		GROUP BY p.id_producto
		ORDER BY v.total_venta DESC;
END
// 
DELIMITER ;

CALL ReporteMensualVentas(4, 2023);
-- 9. **sp_ProgramarMantenimiento**: cambia a mantenimiento una maquina según horas de uso acumuladas.
DROP PROCEDURE ProgramarMantenimiento;
DELIMITER //
CREATE PROCEDURE ProgramarMantenimiento(IN I_horas int)
BEGIN
	UPDATE Maquinaria m 
	JOIN Uso_Maquinaria um  ON m.id = um.id_maquinaria_fk
	SET m.estado = 'mantenimiento'
	WHERE m.estado <> 'mantenimiento' AND um.horas_uso >= I_horas;
END
//
DELIMITER ;
CALL ProgramarMantenimiento(8);
SELECT * FROM Maquinaria m ;
-- 10. **sp_ActualizarInventarioPorProduccion**: Suma la producción al stock disponible.  
SELECT * FROM Produccion p;
DROP PROCEDURE ActualizarInventarioPorProduccion;
DELIMITER //
CREATE PROCEDURE ActualizarInventarioPorProduccion(IN I_nombre_producto VARCHAR(70),  I_cantidad INT)
BEGIN
	DECLARE P_existe INT;
	
	SELECT COUNT(*) INTO  P_existe
	FROM Producto p  
	WHERE p.nombre = I_nombre_producto;
	
	IF P_existe > 0 THEN

		UPDATE Inventario i
		JOIN Producto p ON id_producto_fk = p.id_producto 
		SET cantidad = cantidad + I_cantidad,
		fecha_actualizacion = NOW()
		WHERE LOWER(p.nombre) = LOWER(I_nombre_producto);
	ELSE 
	   SIGNAL SQLSTATE '45000'
   			SET MESSAGE_TEXT = 'Empleado no existe';
	END IF;
END
//
DELIMITER ;
CALL ActualizarInventarioPorProduccion("Maíz blanco", 20);
SELECT * FROM Inventario i;