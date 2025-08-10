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

-- 11 sp_RegistrarCompraProveedor: Registra compras y actualiza inventario.
DELIMITER //

CREATE PROCEDURE sp_RegistrarCompraProveedor(
    IN p_id_proveedor INT,
    IN p_fecha_compra DATE,
    IN p_total_compra DECIMAL(10,2),
    IN p_id_producto1 INT, IN p_cantidad1 INT,
    IN p_id_producto2 INT, IN p_cantidad2 INT,
    IN p_id_producto3 INT, IN p_cantidad3 INT,
    IN p_id_producto4 INT, IN p_cantidad4 INT,
    IN p_id_producto5 INT, IN p_cantidad5 INT
)
BEGIN
    DECLARE v_id_compra INT;
    
    START TRANSACTION;
    
    INSERT INTO Compra (fecha, id_proveedor_fk, total)
    VALUES (p_fecha_compra, p_id_proveedor, p_total_compra);
    
    SET v_id_compra = LAST_INSERT_ID();
    
    IF p_id_producto1 IS NOT NULL THEN
        CALL RegistrarDetalleCompra(v_id_compra, p_id_producto1, p_cantidad1, p_fecha_compra);
    END IF;
    
    IF p_id_producto2 IS NOT NULL THEN
        CALL RegistrarDetalleCompra(v_id_compra, p_id_producto2, p_cantidad2, p_fecha_compra);
    END IF;
    
    IF p_id_producto3 IS NOT NULL THEN
        CALL RegistrarDetalleCompra(v_id_compra, p_id_producto3, p_cantidad3, p_fecha_compra);
    END IF;
    
    IF p_id_producto4 IS NOT NULL THEN
        CALL RegistrarDetalleCompra(v_id_compra, p_id_producto4, p_cantidad4, p_fecha_compra);
    END IF;
    
    IF p_id_producto5 IS NOT NULL THEN
        CALL RegistrarDetalleCompra(v_id_compra, p_id_producto5, p_cantidad5, p_fecha_compra);
    END IF;
    
    COMMIT;
    
    SELECT CONCAT('Compra registrada correctamente. ID: ', v_id_compra) AS mensaje;
END //

CREATE PROCEDURE RegistrarDetalleCompra(
    IN p_id_compra INT,
    IN p_id_producto INT,
    IN p_cantidad INT,
    IN p_fecha DATE
)
BEGIN
    
    INSERT INTO Detalle_Compra (id_compra_fk, id_producto_fk, cantidad)
    VALUES (p_id_compra, p_id_producto, p_cantidad);
    
    INSERT INTO Entrada_Inventario (fecha, id_producto_fk, cantidad, origen)
    VALUES (p_fecha, p_id_producto, p_cantidad, 'compra');
    
    IF EXISTS (SELECT 1 FROM Inventario WHERE id_producto_fk = p_id_producto) THEN
        UPDATE Inventario 
        SET cantidad = cantidad + p_cantidad,
            fecha_actualizacion = CURRENT_DATE()
        WHERE id_producto_fk = p_id_producto;
    ELSE
        INSERT INTO Inventario (id_producto_fk, cantidad, fecha_actualizacion)
        VALUES (p_id_producto, p_cantidad, CURRENT_DATE());
    END IF;
END //

DELIMITER ;

CALL sp_RegistrarCompraProveedor(
    1,                         
    '2023-11-15',               
    1500.50,                    
    1, 10,                      
    3, 5,                       
    NULL, NULL,                 
    NULL, NULL,                 
    NULL, NULL                  
);


-- 12 sp_TransferirStockEntreLotes: Mueve cantidad de un lote a otro validando capacidad.
DELIMITER //

CREATE PROCEDURE sp_TransferirStockSimple(
    IN p_id_producto INT,
    IN p_id_lote_origen INT,
    IN p_id_lote_destino INT,
    IN p_cantidad DECIMAL(10,2),
    IN p_fecha_transferencia DATE
)
BEGIN
    DECLARE v_existencia DECIMAL(10,2);
    
    START TRANSACTION;
    

    SELECT IFNULL(SUM(cantidad), 0) INTO v_existencia
    FROM Produccion
    WHERE id_producto_fk = p_id_producto 
    AND id_lote_fk = p_id_lote_origen;
    
    IF v_existencia < p_cantidad THEN
        ROLLBACK;
        SELECT CONCAT('Error: Solo hay ', v_existencia, ' unidades disponibles') AS error;
    ELSE

        INSERT INTO Produccion (fecha_produccion, id_producto_fk, id_lote_fk, cantidad)
        VALUES (p_fecha_transferencia, p_id_producto, p_id_lote_origen, -p_cantidad);
        
        INSERT INTO Produccion (fecha_produccion, id_producto_fk, id_lote_fk, cantidad)
        VALUES (p_fecha_transferencia, p_id_producto, p_id_lote_destino, p_cantidad);
        
        COMMIT;
        SELECT 'Transferencia exitosa' AS resultado;
    END IF;
END //

DELIMITER ;
CALL sp_TransferirStockSimple(1, 5, 8, 100.0, CURDATE());
-- 13 sp_ActualizarCostoOperativo: Reprocesa los costos de actividades en un rango de fechas.
DELIMITER //

CREATE PROCEDURE sp_ActualizarCostoOperativo(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_reprocesar_todo BOOLEAN
)
BEGIN
    DECLARE v_total_costos DECIMAL(12,2) DEFAULT 0;
    DECLARE v_lotes_procesados INT DEFAULT 0;
    DECLARE v_error_msg TEXT;

    DROP TEMPORARY TABLE IF EXISTS temp_costos_lotes;
    CREATE TEMPORARY TABLE temp_costos_lotes (
        id_lote INT,
        nombre_lote VARCHAR(50),
        costo_operativo DECIMAL(12,2),
        PRIMARY KEY (id_lote)
    );

    START TRANSACTION;

    INSERT INTO temp_costos_lotes (id_lote, nombre_lote, costo_operativo)
    SELECT 
        aa.id_lote,
        l.nombre,
        SUM(e.salario * 
            CASE 
                WHEN ta.nombre LIKE '%Siembra%' THEN 8
                WHEN ta.nombre LIKE '%Cosecha%' THEN 6
                WHEN ta.nombre LIKE '%Fertiliz%' THEN 4
                ELSE 5
            END / 160) AS costo
    FROM Actividad_Agricola aa
    JOIN Tipo_actividad ta ON aa.id_tipo_actividad = ta.id
    JOIN Empleado e ON EXISTS (
        SELECT 1 FROM Asignacion_Tarea at
        JOIN Tarea t ON at.id_tarea_fk = t.id
        WHERE at.id_empleado_fk = e.id
        AND t.descripcion LIKE CONCAT('%', ta.nombre, '%')
        AND t.fecha BETWEEN aa.fecha AND DATE_ADD(aa.fecha, INTERVAL 1 DAY)
    )
    JOIN Lote l ON aa.id_lote = l.id
    WHERE aa.fecha BETWEEN p_fecha_inicio AND p_fecha_fin
    AND (p_reprocesar_todo OR aa.fecha >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
    GROUP BY aa.id_lote, l.nombre;

    INSERT INTO temp_costos_lotes (id_lote, nombre_lote, costo_operativo)
    SELECT 
        um.id_lote_fk,
        l.nombre,
        SUM(m.costo_hora * um.horas_uso) AS costo_maquinaria
    FROM Uso_Maquinaria um
    JOIN Maquinaria m ON um.id_maquinaria_fk = m.id
    JOIN Lote l ON um.id_lote_fk = l.id
    WHERE um.fecha_uso BETWEEN p_fecha_inicio AND p_fecha_fin
    AND (p_reprocesar_todo OR um.fecha_uso >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
    ON DUPLICATE KEY UPDATE 
        costo_operativo = temp_costos_lotes.costo_operativo + VALUES(costo_operativo);
 
    UPDATE Lote l
    JOIN temp_costos_lotes tcl ON l.id = tcl.id_lote
    SET l.costo_operativo = tcl.costo_operativo,
        l.fecha_actualizacion_costos = CURRENT_TIMESTAMP;

    SELECT SUM(costo_operativo), COUNT(*) INTO v_total_costos, v_lotes_procesados
    FROM temp_costos_lotes;

    COMMIT;

    SELECT 
        CONCAT('Costos operativos actualizados para ', v_lotes_procesados, ' lotes') AS mensaje,
        v_total_costos AS total_costos,
        v_lotes_procesados AS lotes_afectados,
        p_fecha_inicio AS periodo_desde,
        p_fecha_fin AS periodo_hasta;
END //

DELIMITER ;
CALL sp_ActualizarCostoOperativo(
    '2023-01-01',  
    '2023-12-31',  
    TRUE       
);

-- 14 sp_RotarCultivosPorLote: Programa rotación según calendario agrícola.
DELIMITER //

CREATE PROCEDURE sp_RotarCultivosPorLote(
    IN p_id_lote INT,
    IN p_fecha_rotacion DATE
)
BEGIN
    DECLARE v_ultimo_cultivo VARCHAR(100);
    DECLARE v_proximo_cultivo VARCHAR(100);
    DECLARE v_temporada VARCHAR(50);
    DECLARE v_rotacion_valida BOOLEAN DEFAULT FALSE;
    DECLARE v_error_msg VARCHAR(1000);

    IF p_id_lote IS NULL OR p_fecha_rotacion IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ID de lote y fecha de rotación son requeridos';
    END IF;

    SET v_temporada = CASE 
        WHEN MONTH(p_fecha_rotacion) BETWEEN 3 AND 5 THEN 'Primavera'
        WHEN MONTH(p_fecha_rotacion) BETWEEN 6 AND 8 THEN 'Verano'
        WHEN MONTH(p_fecha_rotacion) BETWEEN 9 AND 11 THEN 'Otoño'
        ELSE 'Invierno'
    END;

    START TRANSACTION;

    SELECT tipo_uso INTO v_ultimo_cultivo
    FROM Lote
    WHERE id = p_id_lote;

    IF v_ultimo_cultivo IS NOT NULL THEN
 
        SET v_proximo_cultivo = CASE 
            WHEN v_ultimo_cultivo LIKE '%Leguminosa%' THEN 
                CASE 
                    WHEN v_temporada IN ('Primavera', 'Verano') THEN 'Cereal'
                    ELSE 'Hortaliza'
                END
            WHEN v_ultimo_cultivo LIKE '%Cereal%' THEN 
                CASE 
                    WHEN v_temporada IN ('Otoño', 'Invierno') THEN 'Leguminosa'
                    ELSE 'Raíz'
                END
            WHEN v_ultimo_cultivo LIKE '%Hortaliza%' THEN 'Leguminosa'
            ELSE 
                CASE 
                    WHEN v_temporada IN ('Primavera', 'Verano') THEN 'Leguminosa'
                    ELSE 'Cereal'
                END
        END;
        
        SET v_rotacion_valida = TRUE;
    ELSE

        SET v_proximo_cultivo = CASE 
            WHEN v_temporada IN ('Primavera', 'Verano') THEN 'Leguminosa'
            ELSE 'Cereal'
        END;
        SET v_rotacion_valida = TRUE;
    END IF;

    IF v_rotacion_valida THEN
        INSERT INTO Actividad_Agricola (
            id_tipo_actividad, 
            fecha, 
            id_lote, 
            observaciones
        )
        SELECT 
            ta.id, 
            p_fecha_rotacion, 
            p_id_lote, 
            CONCAT('Rotación de cultivos: De ', 
                   COALESCE(v_ultimo_cultivo, 'Ninguno'), 
                   ' a ', v_proximo_cultivo)
        FROM Tipo_actividad ta
        WHERE ta.nombre LIKE '%Rotación%' LIMIT 1;

        IF EXISTS (
            SELECT 1 FROM information_schema.COLUMNS 
            WHERE TABLE_NAME = 'Lote' AND COLUMN_NAME = 'fecha_ultima_rotacion'
        ) THEN
            UPDATE Lote
            SET tipo_uso = v_proximo_cultivo,
                fecha_ultima_rotacion = p_fecha_rotacion
            WHERE id = p_id_lote;
        ELSE
            UPDATE Lote
            SET tipo_uso = v_proximo_cultivo
            WHERE id = p_id_lote;
        END IF;
        
        COMMIT;

        SELECT 
            CONCAT('Rotación completada: Lote ', p_id_lote) AS mensaje,
            v_ultimo_cultivo AS cultivo_anterior,
            v_proximo_cultivo AS nuevo_cultivo,
            v_temporada AS temporada,
            p_fecha_rotacion AS fecha_rotacion;
    ELSE
        ROLLBACK;
        SELECT 'No se pudo determinar la rotación adecuada' AS error_message;
    END IF;
END //

DELIMITER ;
CALL sp_RotarCultivosPorLote(5, CURDATE());
-- 15 sp_CalcularComisionEmpleado: Calcula la comisión de ventas para un empleado.
DELIMITER //

CREATE PROCEDURE sp_CalcularComisionEmpleado(
    IN p_id_empleado INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    OUT p_comision_total DECIMAL(12,2),
    OUT p_ventas_totales DECIMAL(12,2)
)
BEGIN
    DECLARE v_porcentaje_comision DECIMAL(5,2) DEFAULT 0.05; -- 5% comisión base
    DECLARE v_ventas_periodo DECIMAL(12,2) DEFAULT 0;
    DECLARE v_meta_ventas DECIMAL(12,2) DEFAULT 10000.00; -- Meta de ventas
    DECLARE v_bono_adicional DECIMAL(10,2) DEFAULT 0;


    IF p_id_empleado IS NULL OR p_fecha_inicio IS NULL OR p_fecha_fin IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ID empleado y rango de fechas son requeridos';
    END IF;
    
    IF p_fecha_inicio > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Fecha inicio debe ser menor o igual a fecha fin';
    END IF;

    START TRANSACTION;

    SELECT COALESCE(SUM(v.total_venta), 0) INTO v_ventas_periodo
    FROM Venta v
    WHERE v.id_empleado = p_id_empleado
    AND v.fecha BETWEEN p_fecha_inicio AND p_fecha_fin;

    IF v_ventas_periodo > v_meta_ventas THEN
        SET v_porcentaje_comision = 0.07; 
        SET v_bono_adicional = 500.00; 
    END IF;

    SET p_comision_total = (v_ventas_periodo * v_porcentaje_comision) + v_bono_adicional;
    SET p_ventas_totales = v_ventas_periodo;

    IF EXISTS (SELECT 1 FROM information_schema.TABLES 
              WHERE TABLE_NAME = 'Comisiones_Empleados') THEN
        INSERT INTO Comisiones_Empleados (
            id_empleado,
            fecha_inicio,
            fecha_fin,
            ventas_totales,
            porcentaje_comision,
            bono_adicional,
            comision_total,
            fecha_calculo
        )
        VALUES (
            p_id_empleado,
            p_fecha_inicio,
            p_fecha_fin,
            v_ventas_periodo,
            v_porcentaje_comision,
            v_bono_adicional,
            p_comision_total,
            CURRENT_DATE()
        );
    END IF;

    COMMIT;

    SELECT 
        CONCAT('Comisión calculada para empleado #', p_id_empleado) AS mensaje,
        p_fecha_inicio AS periodo_inicio,
        p_fecha_fin AS periodo_fin,
        p_ventas_totales AS ventas_totales,
        (v_porcentaje_comision * 100) AS porcentaje_comision,
        v_bono_adicional AS bono_adicional,
        p_comision_total AS comision_total;
END //

DELIMITER ;
CALL sp_CalcularComisionEmpleado(5, '2023-01-01', '2023-01-31', @comision, @ventas);
-- 16 sp_GenerarOrdenCompraAutomatica: Crea órdenes de compra al cruzar un umbral de stock.
DELIMITER //

CREATE PROCEDURE sp_GenerarOrdenCompraAutomatica(
    IN p_umbral_minimo INT,
    IN p_cantidad_orden INT
)
BEGIN
    DECLARE v_id_producto INT;
    DECLARE v_nombre_producto VARCHAR(50);
    DECLARE v_cantidad_actual INT;
    DECLARE v_id_proveedor INT;
    DECLARE v_nombre_proveedor VARCHAR(70);
    DECLARE v_precio_unitario DECIMAL(10,2);
    DECLARE v_fecha_actual DATE;
    DECLARE v_id_orden INT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_error_msg TEXT;
    
    DECLARE cur_productos CURSOR FOR
        SELECT p.id_producto, p.nombre, i.cantidad
        FROM Producto p
        JOIN Inventario i ON p.id_producto = i.id_producto_fk
        WHERE i.cantidad <= p_umbral_minimo;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;
    
    SET v_fecha_actual = CURDATE();

    IF p_umbral_minimo IS NULL OR p_cantidad_orden IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Umbral mínimo y cantidad de orden son requeridos';
    END IF;
    
    IF p_cantidad_orden <= 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La cantidad a ordenar debe ser mayor que cero';
    END IF;

    START TRANSACTION;

    DROP TEMPORARY TABLE IF EXISTS tmp_ordenes_generadas;
    CREATE TEMPORARY TABLE tmp_ordenes_generadas (
        id_orden INT,
        producto VARCHAR(50),
        cantidad INT,
        proveedor VARCHAR(70),
        total DECIMAL(12,2)
    );
    
    OPEN cur_productos;
    
    read_loop: LOOP
        FETCH cur_productos INTO v_id_producto, v_nombre_producto, v_cantidad_actual;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        SELECT pr.id, pr.nombre, dp.precio_unitario
        INTO v_id_proveedor, v_nombre_proveedor, v_precio_unitario
        FROM Proveedor pr
        JOIN Detalle_Proveedor dp ON pr.id = dp.id_proveedor_fk
        WHERE dp.id_producto_fk = v_id_producto
        ORDER BY dp.prioridad ASC
        LIMIT 1;

        IF v_id_proveedor IS NOT NULL THEN

            INSERT INTO OrdenCompra (
                fecha_orden,
                id_proveedor_fk,
                estado,
                total
            ) VALUES (
                v_fecha_actual,
                v_id_proveedor,
                'PENDIENTE',
                p_cantidad_orden * v_precio_unitario
            );
            
            SET v_id_orden = LAST_INSERT_ID();

            INSERT INTO Detalle_OrdenCompra (
                id_orden_fk,
                id_producto_fk,
                cantidad,
                precio_unitario
            ) VALUES (
                v_id_orden,
                v_id_producto,
                p_cantidad_orden,
                v_precio_unitario
            );

            INSERT INTO tmp_ordenes_generadas
            VALUES (v_id_orden, v_nombre_producto, p_cantidad_orden, v_nombre_proveedor, 
                   p_cantidad_orden * v_precio_unitario);
        END IF;
    END LOOP;
    
    CLOSE cur_productos;

    COMMIT;

    IF EXISTS (SELECT 1 FROM tmp_ordenes_generadas LIMIT 1) THEN
        SELECT * FROM tmp_ordenes_generadas;
    ELSE
        SELECT 'No se generaron órdenes de compra: ningún producto bajo el umbral' AS mensaje;
    END IF;
END //

DELIMITER ;
CALL sp_GenerarOrdenCompraAutomatica(10, 50);
-- 17 sp_ActualizarKPIProduccion: Recalcula indicadores clave de producción.
DELIMITER //

CREATE PROCEDURE sp_ActualizarKPIProduccion(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    DECLARE v_total_lotes INT;
    DECLARE v_total_productos INT;
    DECLARE v_produccion_total DECIMAL(12,2);
    DECLARE v_rendimiento_promedio DECIMAL(10,2);
    DECLARE v_lote_mas_productivo INT;
    DECLARE v_producto_mas_producido INT;
    

    IF p_fecha_inicio IS NULL OR p_fecha_fin IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Las fechas de inicio y fin son requeridas';
    END IF;
    
    IF p_fecha_inicio > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de inicio debe ser menor o igual a la fecha fin';
    END IF;

    START TRANSACTION;

    SELECT COUNT(*) INTO v_total_lotes
    FROM Lote
    WHERE id IN (
        SELECT DISTINCT id_lote_fk 
        FROM Produccion 
        WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin
    );

    SELECT COUNT(DISTINCT id_producto_fk) INTO v_total_productos
    FROM Produccion
    WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin;

    SELECT COALESCE(SUM(cantidad), 0) INTO v_produccion_total
    FROM Produccion
    WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin;

    SELECT COALESCE(AVG(total_produccion), 0) INTO v_rendimiento_promedio
    FROM (
        SELECT id_lote_fk, SUM(cantidad) AS total_produccion
        FROM Produccion
        WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY id_lote_fk
    ) AS produccion_por_lote;
    
    SELECT id_lote_fk INTO v_lote_mas_productivo
    FROM (
        SELECT id_lote_fk, SUM(cantidad) AS total_produccion
        FROM Produccion
        WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY id_lote_fk
        ORDER BY total_produccion DESC
        LIMIT 1
    ) AS lotes_ordenados;

    SELECT id_producto_fk INTO v_producto_mas_producido
    FROM (
        SELECT id_producto_fk, SUM(cantidad) AS total_produccion
        FROM Produccion
        WHERE fecha_produccion BETWEEN p_fecha_inicio AND p_fecha_fin
        GROUP BY id_producto_fk
        ORDER BY total_produccion DESC
        LIMIT 1
    ) AS productos_ordenados;

    IF EXISTS (
        SELECT 1 FROM KPI_Produccion 
        WHERE fecha_inicio = p_fecha_inicio AND fecha_fin = p_fecha_fin
    ) THEN
        UPDATE KPI_Produccion
        SET 
            total_lotes = v_total_lotes,
            total_productos = v_total_productos,
            produccion_total = v_produccion_total,
            rendimiento_promedio = v_rendimiento_promedio,
            lote_mas_productivo = v_lote_mas_productivo,
            producto_mas_producido = v_producto_mas_producido,
            fecha_actualizacion = NOW()
        WHERE fecha_inicio = p_fecha_inicio AND fecha_fin = p_fecha_fin;
    ELSE
        INSERT INTO KPI_Produccion (
            fecha_inicio,
            fecha_fin,
            total_lotes,
            total_productos,
            produccion_total,
            rendimiento_promedio,
            lote_mas_productivo,
            producto_mas_producido,
            fecha_actualizacion
        ) VALUES (
            p_fecha_inicio,
            p_fecha_fin,
            v_total_lotes,
            v_total_productos,
            v_produccion_total,
            v_rendimiento_promedio,
            v_lote_mas_productivo,
            v_producto_mas_producido,
            NOW()
        );
    END IF;

    COMMIT;
    
    SELECT 
        CONCAT('KPIs actualizados para el período ', 
              DATE_FORMAT(p_fecha_inicio, '%d/%m/%Y'), ' al ', 
              DATE_FORMAT(p_fecha_fin, '%d/%m/%Y')) AS mensaje,
        v_total_lotes AS total_lotes_activos,
        v_total_productos AS total_productos_producidos,
        v_produccion_total AS produccion_total,
        v_rendimiento_promedio AS rendimiento_promedio,
        v_lote_mas_productivo AS lote_mas_productivo_id,
        v_producto_mas_producido AS producto_mas_producido_id;
END //

DELIMITER ;
CALL sp_ActualizarKPIProduccion('2023-01-01', '2023-12-31');

-- 18 sp_EnviarNotificacionStockBajo: Envía alerta vía correo a responsables.
DELIMITER //

CREATE PROCEDURE sp_EnviarNotificacionStockBajo(
    IN p_umbral_minimo INT
)
BEGIN
    DECLARE v_id_producto INT;
    DECLARE v_nombre_producto VARCHAR(50);
    DECLARE v_cantidad_actual INT;
    DECLARE v_unidad_medida VARCHAR(20);
    DECLARE v_responsable_email VARCHAR(100);
    DECLARE v_asunto VARCHAR(100);
    DECLARE v_cuerpo TEXT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_productos_bajo_stock TEXT DEFAULT '';
    DECLARE v_total_productos INT DEFAULT 0;

    DECLARE cur_stock_bajo CURSOR FOR
        SELECT p.id_producto, p.nombre, i.cantidad, p.unidad_medida
        FROM Producto p
        JOIN Inventario i ON p.id_producto = i.id_producto_fk
        WHERE i.cantidad <= p_umbral_minimo;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    IF p_umbral_minimo IS NULL OR p_umbral_minimo < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El umbral mínimo debe ser un número positivo';
    END IF;

    DROP TEMPORARY TABLE IF EXISTS tmp_notificaciones;
    CREATE TEMPORARY TABLE tmp_notificaciones (
        id_producto INT,
        producto VARCHAR(50),
        cantidad INT,
        unidad_medida VARCHAR(20),
        enviado BOOLEAN DEFAULT FALSE
    );

    OPEN cur_stock_bajo;
    
    read_loop: LOOP
        FETCH cur_stock_bajo INTO v_id_producto, v_nombre_producto, v_cantidad_actual, v_unidad_medida;
        IF v_done THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO tmp_notificaciones (id_producto, producto, cantidad, unidad_medida)
        VALUES (v_id_producto, v_nombre_producto, v_cantidad_actual, v_unidad_medida);

        SET v_productos_bajo_stock = CONCAT(v_productos_bajo_stock, 
                                          '- ', v_nombre_producto, ': ', 
                                          v_cantidad_actual, ' ', v_unidad_medida, '\n');
        SET v_total_productos = v_total_productos + 1;
    END LOOP;
    
    CLOSE cur_stock_bajo;

    IF v_total_productos > 0 THEN
        SELECT valor INTO v_responsable_email
        FROM Configuracion
        WHERE clave = 'EMAIL_RESPONSABLE_INVENTARIO';

        SET v_asunto = CONCAT('[Alerta] Stock bajo para ', v_total_productos, ' productos');
        SET v_cuerpo = CONCAT('Los siguientes productos están por debajo del nivel mínimo (', 
                             p_umbral_minimo, ' unidades):\n\n',
                             v_productos_bajo_stock,
                             '\nFecha: ', NOW(), '\n',
                             'Por favor, realice una nueva orden de compra.');

        INSERT INTO Notificaciones (
            tipo,
            asunto,
            mensaje,
            destinatario,
            fecha_creacion,
            estado
        ) VALUES (
            'STOCK_BAJO',
            v_asunto,
            v_cuerpo,
            v_responsable_email,
            NOW(),
            'PENDIENTE'
        );

        UPDATE tmp_notificaciones SET enviado = TRUE;

        SELECT 
            CONCAT('Notificación generada para ', v_total_productos, ' productos') AS mensaje,
            v_asunto AS asunto_email,
            v_responsable_email AS destinatario;
    ELSE
        SELECT 'No hay productos por debajo del nivel de stock mínimo' AS mensaje;
    END IF;

    SELECT * FROM tmp_notificaciones;
END //

DELIMITER ;
CALL sp_EnviarNotificacionStockBajo(10);
-- 19 sp_RegistrarActividadAgricola: Inserta una actividad y movimiento de inventario asociado.
DELIMITER //

CREATE PROCEDURE sp_RegistrarActividadAgricola(
    IN p_id_tipo_actividad INT,
    IN p_id_lote INT,
    IN p_fecha_actividad DATE,
    IN p_observaciones VARCHAR(250),
    IN p_id_producto_usado INT,
    IN p_cantidad_usada DECIMAL(10,2),
    IN p_id_producto_generado INT,
    IN p_cantidad_generada DECIMAL(10,2)
)
BEGIN
    DECLARE v_id_actividad INT;
    DECLARE v_error_msg VARCHAR(255);
    

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT CONCAT('Error: ', COALESCE(v_error_msg, 'Error desconocido')) AS mensaje_error;
    END;
    

    IF p_id_tipo_actividad IS NULL OR p_id_lote IS NULL OR p_fecha_actividad IS NULL THEN
        SET v_error_msg = 'Datos básicos son requeridos (tipo, lote, fecha)';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
    END IF;

    START TRANSACTION;

    INSERT INTO Actividad_Agricola (
        id_tipo_actividad,
        fecha,
        id_lote,
        observaciones
    ) VALUES (
        p_id_tipo_actividad,
        p_fecha_actividad,
        p_id_lote,
        p_observaciones
    );
    
    SET v_id_actividad = LAST_INSERT_ID();

    IF p_id_producto_usado IS NOT NULL AND p_cantidad_usada > 0 THEN
      
        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id_producto = p_id_producto_usado) THEN
            SET v_error_msg = CONCAT('Producto usado no existe: ', p_id_producto_usado);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;

        INSERT INTO Salida_Inventario (
            fecha,
            id_producto_fk,
            cantidad,
            destino,
            id_actividad_relacionada
        ) VALUES (
            p_fecha_actividad,
            p_id_producto_usado,
            p_cantidad_usada,
            'consumo interno',
            v_id_actividad
        );

        IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_NAME = 'Inventario') THEN
            UPDATE Inventario 
            SET cantidad = cantidad - p_cantidad_usada
            WHERE id_producto_fk = p_id_producto_usado;
        END IF;
    END IF;

    IF p_id_producto_generado IS NOT NULL AND p_cantidad_generada > 0 THEN

        IF NOT EXISTS (SELECT 1 FROM Producto WHERE id_producto = p_id_producto_generado) THEN
            SET v_error_msg = CONCAT('Producto generado no existe: ', p_id_producto_generado);
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_error_msg;
        END IF;

        INSERT INTO Produccion (
            fecha_produccion,
            id_producto_fk,
            id_lote_fk,
            cantidad,
            id_actividad_relacionada
        ) VALUES (
            p_fecha_actividad,
            p_id_producto_generado,
            p_id_lote,
            p_cantidad_generada,
            v_id_actividad
        );

        INSERT INTO Entrada_Inventario (
            fecha,
            id_producto_fk,
            cantidad,
            origen,
            id_actividad_relacionada
        ) VALUES (
            p_fecha_actividad,
            p_id_producto_generado,
            p_cantidad_generada,
            'produccion',
            v_id_actividad
        );

        IF EXISTS (SELECT 1 FROM information_schema.TABLES WHERE TABLE_NAME = 'Inventario') THEN
            IF EXISTS (SELECT 1 FROM Inventario WHERE id_producto_fk = p_id_producto_generado) THEN
                UPDATE Inventario 
                SET cantidad = cantidad + p_cantidad_generada
                WHERE id_producto_fk = p_id_producto_generado;
            ELSE
                INSERT INTO Inventario (
                    id_producto_fk,
                    cantidad
                ) VALUES (
                    p_id_producto_generado,
                    p_cantidad_generada
                );
            END IF;
        END IF;
    END IF;

    COMMIT;

    SELECT CONCAT('Actividad registrada correctamente. ID: ', v_id_actividad) AS resultado;
END //

DELIMITER ;
CALL sp_RegistrarActividadAgricola(1, 5, '2023-11-20', 'Preparación de terreno', NULL, NULL, NULL, NULL);
-- 20 sp_OptimizarRiegoPorLote: Calcula y programa riegos basado en datos históricos.
DELIMITER //

CREATE PROCEDURE sp_OptimizarRiegoPorLote(
    IN p_id_lote INT,
    IN p_fecha_inicio DATE
)
BEGIN
    DECLARE v_tipo_cultivo VARCHAR(50);
    DECLARE v_area DECIMAL(10,2);
    DECLARE v_historial_riego INT;
    DECLARE v_ultima_humedad DECIMAL(5,2);
    DECLARE v_precipitacion_7d DECIMAL(5,2);
    DECLARE v_temperatura_promedio DECIMAL(5,2);
    DECLARE v_dias_ultimo_riego INT;
    DECLARE v_cantidad_agua DECIMAL(6,2);
    DECLARE v_frecuencia_riego INT;
    DECLARE v_proxima_fecha DATE;
    DECLARE v_hora_optima TIME;
    

    IF p_id_lote IS NULL OR p_fecha_inicio IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'ID de lote y fecha de inicio son requeridos';
    END IF;
    
    IF p_fecha_inicio < CURDATE() THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La fecha de inicio no puede ser en el pasado';
    END IF;

    START TRANSACTION;

    SELECT 
        l.tipo_uso,
        l.tamaño
    INTO 
        v_tipo_cultivo,
        v_area
    FROM Lote l
    WHERE l.id = p_id_lote;

    SELECT 
        COUNT(*) AS total_riegos,
        DATEDIFF(p_fecha_inicio, MAX(fecha)) AS dias_desde_ultimo
    INTO 
        v_historial_riego,
        v_dias_ultimo_riego
    FROM Registro_Riego
    WHERE id_lote = p_id_lote
    AND fecha >= DATE_SUB(p_fecha_inicio, INTERVAL 30 DAY);

    SELECT 
        AVG(humedad) AS humedad_promedio,
        SUM(precipitacion) AS lluvia_acumulada,
        AVG(temperatura) AS temp_promedio
    INTO 
        v_ultima_humedad,
        v_precipitacion_7d,
        v_temperatura_promedio
    FROM Sensores
    WHERE id_lote = p_id_lote
    AND fecha >= DATE_SUB(p_fecha_inicio, INTERVAL 7 DAY);

    CASE v_tipo_cultivo
        WHEN 'Hortalizas' THEN
            SET v_cantidad_agua = 20.00; 
            SET v_frecuencia_riego = CASE 
                WHEN v_precipitacion_7d > 50 THEN 4
                WHEN v_precipitacion_7d > 20 THEN 3
                ELSE 2
            END;
            SET v_hora_optima = '06:00:00';
            
        WHEN 'Frutales' THEN
            SET v_cantidad_agua = 35.00; 
            SET v_frecuencia_riego = CASE 
                WHEN v_temperatura_promedio > 28 THEN 5
                WHEN v_temperatura_promedio > 22 THEN 7
                ELSE 10
            END;
            SET v_hora_optima = '05:00:00';
            
        WHEN 'Cereales' THEN
            SET v_cantidad_agua = 15.00; 
            SET v_frecuencia_riego = CASE 
                WHEN v_ultima_humedad < 40 THEN 3
                WHEN v_ultima_humedad < 60 THEN 5
                ELSE 7
            END;
            SET v_hora_optima = '04:00:00';
            
        ELSE 
            SET v_cantidad_agua = 25.00;
            SET v_frecuencia_riego = 5;
            SET v_hora_optima = '06:30:00';
    END CASE;

    IF v_precipitacion_7d > 30 THEN
        SET v_cantidad_agua = v_cantidad_agha * 0.7;
        SET v_frecuencia_riego = v_frecuencia_riego + 1;
    END IF;
    
    IF v_temperatura_promedio > 30 THEN
        SET v_cantidad_agua = v_cantidad_agha * 1.2;
        SET v_frecuencia_riego = v_frecuencia_riego - 1;
    END IF;

    SET v_proxima_fecha = p_fecha_inicio;
    
    WHILE v_proxima_fecha <= DATE_ADD(p_fecha_inicio, INTERVAL 7 DAY) DO

        INSERT INTO Programacion_Riego (
            id_lote,
            fecha_programada,
            hora_programada,
            cantidad_agua,
            estado,
            metodo_riego
        ) VALUES (
            p_id_lote,
            v_proxima_fecha,
            v_hora_optima,
            ROUND(v_cantidad_agha * v_area, 2), -- Cantidad total para el área
            'PENDIENTE',
            CASE 
                WHEN v_tipo_cultivo = 'Hortalizas' THEN 'Goteo'
                WHEN v_tipo_cultivo = 'Frutales' THEN 'Aspersión'
                ELSE 'Gravedad'
            END
        );

        SET v_proxima_fecha = DATE_ADD(v_proxima_fecha, INTERVAL v_frecuencia_riego DAY);
    END WHILE;

    COMMIT;

    SELECT 
        CONCAT('Programación de riego optimizada para lote #', p_id_lote) AS mensaje,
        v_tipo_cultivo AS cultivo,
        v_area AS area_m2,
        v_frecuencia_riego AS frecuencia_dias,
        ROUND(v_cantidad_agha * v_area, 2) AS cantidad_agua_total,
        v_hora_optima AS hora_recomendada,
        DATE_ADD(p_fecha_inicio, INTERVAL v_frecuencia_riego DAY) AS proximo_riego;
END //

DELIMITER ;
CALL sp_OptimizarRiegoPorLote(8, '2023-12-01');