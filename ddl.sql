CREATE TABLE Producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tipo_producto VARCHAR(255) NOT NULL,
    unidad_medida ENUM('kilogramos', 'litros', 'unidades') NOT NULL
);

CREATE TABLE Lote (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    tamaño DECIMAL(10,2) NOT NULL,
    tipo_uso VARCHAR(50) NOT NULL
);

CREATE TABLE Tipo_actividad (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL
);

CREATE TABLE Actividad_Agricola (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_tipo_actividad INT NOT NULL,
    fecha DATE NOT NULL,
    id_lote INT NOT NULL,
    observaciones VARCHAR(250) NOT NULL,
    FOREIGN KEY (id_tipo_actividad) REFERENCES Tipo_actividad(id),
    FOREIGN KEY (id_lote) REFERENCES Lote(id)
);

CREATE TABLE Produccion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha_produccion DATE NOT NULL,
    id_producto_fk INT NOT NULL,
    id_lote_fk INT NOT NULL,
    cantidad DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto),
    FOREIGN KEY (id_lote_fk) REFERENCES Lote(id)
);

CREATE TABLE Empleado (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre_completo VARCHAR(70) NOT NULL,
    doc_identidad INT NOT NULL,
    cargo VARCHAR(70) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    salario DECIMAL(10,2) NOT NULL
);

CREATE TABLE Tarea (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    estado ENUM('pendiente', 'en proceso', 'completada') NOT NULL
);

CREATE TABLE Asignacion_Tarea (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado_fk INT NOT NULL,
    id_tarea_fk INT NOT NULL,
    FOREIGN KEY (id_empleado_fk) REFERENCES Empleado(id),
    FOREIGN KEY (id_tarea_fk) REFERENCES Tarea(id)
);

CREATE TABLE Maquinaria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(70) NOT NULL,
    fecha_compra DATE NOT NULL,
    estado ENUM('operando', 'mantenimiento', 'descompuesta') NOT NULL
);

CREATE TABLE Uso_Maquinaria (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria_fk INT NOT NULL,
    fecha_uso DATE NOT NULL,
    id_lote_fk INT NOT NULL,
    horas_uso DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_maquinaria_fk) REFERENCES Maquinaria(id),
    FOREIGN KEY (id_lote_fk) REFERENCES Lote(id)
);

CREATE TABLE Mantenimiento (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_maquinaria_fk INT NOT NULL,
    fecha_mantenimiento DATE NOT NULL,
    descripción VARCHAR(200) NOT NULL,
    FOREIGN KEY (id_maquinaria_fk) REFERENCES Maquinaria(id)
);

CREATE TABLE Cliente (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(70) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    direccion VARCHAR(100) NOT NULL
);

CREATE TABLE Venta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    id_cliente INT NOT NULL,
    id_empleado INT NOT NULL,
    total_venta DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES Cliente(id),
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id)
);

CREATE TABLE Detalle_Venta (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_venta INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad DECIMAL(12,2) NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_venta) REFERENCES Venta(id),
    FOREIGN KEY (id_producto) REFERENCES Producto(id_producto)
);

CREATE TABLE Inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_producto_fk INT,
    cantidad INT,
    fecha_actualizacion DATE,
    FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
);

CREATE TABLE Entrada_Inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    id_producto_fk INT,
    cantidad INT,
    origen ENUM('produccion', 'compra'),
    FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
);

CREATE TABLE Salida_Inventario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    id_producto_fk INT,
    cantidad INT,
    destino ENUM('venta', 'perdida', 'consumo interno'),
    FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
);

CREATE TABLE Proveedor (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(70),
    tipo_insumo VARCHAR(50),
    telefono VARCHAR(20),
    direccion VARCHAR(100)
);

CREATE TABLE Compra (
    id INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    id_proveedor_fk INT,
    total DECIMAL(10,2),
    FOREIGN KEY (id_proveedor_fk) REFERENCES Proveedor(id)
);

CREATE TABLE Detalle_Compra (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_compra_fk INT,
    id_producto_fk INT,
    cantidad INT,
    FOREIGN KEY (id_compra_fk) REFERENCES Compra(id),
    FOREIGN KEY (id_producto_fk) REFERENCES Producto(id_producto)
);