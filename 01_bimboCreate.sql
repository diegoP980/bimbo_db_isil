USE master;
GO

IF DB_ID('Panaderia_Bimbo') IS NOT NULL
BEGIN
    ALTER DATABASE Panaderia_Bimbo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Panaderia_Bimbo;
END
GO

CREATE DATABASE Panaderia_Bimbo;
GO

USE Panaderia_Bimbo;
GO

-- ========================================
-- 1. TABLA CLIENTE
-- ========================================
CREATE TABLE CLIENTE (
    IdCliente INT IDENTITY(1,1) CONSTRAINT PK_CLIENTE PRIMARY KEY,
    RUC VARCHAR(11) NOT NULL,
    Direccion VARCHAR(50),
    Telefono VARCHAR(9),
    RazonSocial VARCHAR(100),
    Email VARCHAR(30) 
);
GO

-- ============================================================
-- 2. TABLA: PRODUCTOS
-- ============================================================
CREATE TABLE PRODUCTOS (
    IdProducto INT IDENTITY(1,1) CONSTRAINT PK_PRODUCTOS PRIMARY KEY,
    nomProducto VARCHAR(100),
    categoria VARCHAR(50),
    precioUnit DECIMAL(10,2),
    Stock INT
);
GO 

-- ============================================================
-- 3. TABLA: SUCURSALES
-- ============================================================
CREATE TABLE SUCURSALES (
    IdSucursal INT IDENTITY(1,1) CONSTRAINT PK_SUCURSALES PRIMARY KEY,
	codigoSucursal VARCHAR(10) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    ciudad VARCHAR(50) NOT NULL,
    telefono VARCHAR(9) NOT NULL,
    email VARCHAR(50) NOT NULL,
);
GO

-- ============================================================
-- 4. TABLA: EMPLEADOS
-- ============================================================
CREATE TABLE EMPLEADOS (
    IdEmpleado INT IDENTITY(1,1) CONSTRAINT PK_EMPLEADOS PRIMARY KEY,
	IdSucursal INT,
    Nombres VARCHAR(30),
    ApellidoPaterno VARCHAR(30),
	ApellidoMaterno VARCHAR(30),
    DNI CHAR(8),
    cargo VARCHAR(30),
    Salario DECIMAL(6,2)
	CONSTRAINT FK_EMPLEADOS_SUCURSALES FOREIGN KEY (IdSucursal) REFERENCES SUCURSALES(IdSucursal)
);
GO

-- ============================================================
-- 5. TABLA: MATERIA PRIMA
-- ============================================================
CREATE TABLE MATERIA_PRIMA (
    materia_ID INT IDENTITY(1,1) CONSTRAINT PK_MATERIA_PRIMA PRIMARY KEY,
    nomMatPrima VARCHAR(20),
    unidMedida VARCHAR(5),
    costoUnidMed DECIMAL(7,2)
);
GO

-- ============================================================
-- 6. TABLA: PROVEEDORES
-- ============================================================
CREATE TABLE PROVEEDORES (
    proveedor_ID INT IDENTITY(1,1) CONSTRAINT PK_PROVEEDORES PRIMARY KEY,
    razon_Social VARCHAR(100),
    RUC VARCHAR(11),
    telefono VARCHAR(9),
    email VARCHAR(30),
    direccion VARCHAR(50)
);
GO 

-- ============================================================
-- 7. TABLA: LOTES
-- ============================================================
CREATE TABLE LOTES (
    Lote_ID INT IDENTITY(1,1) CONSTRAINT PK_LOTES PRIMARY KEY,
    IdProducto INT NOT NULL,
    IdSucursal INT NOT NULL,
    fec_Lote DATE,
    estado VARCHAR(1),
    contenido VARCHAR(200),
    CONSTRAINT FK_LOTES_PRODUCTOS FOREIGN KEY (IdProducto) REFERENCES PRODUCTOS(IdProducto),
    CONSTRAINT FK_LOTES_SUCURSALES FOREIGN KEY (IdSucursal) REFERENCES SUCURSALES(IdSucursal)
);
GO 

-- ============================================================
-- 8. TABLA: PEDIDOS
-- ============================================================
CREATE TABLE PEDIDOS (
    IdPedido INT IDENTITY(1,1) CONSTRAINT PK_PEDIDOS PRIMARY KEY,
    IdCliente INT NOT NULL,
    Lote_ID INT NOT NULL,
    fec_Pedido DATE,
    monto DECIMAL(7,2),
    estado VARCHAR(1),
    CONSTRAINT FK_PEDIDOS_CLIENTE FOREIGN KEY (IdCliente) REFERENCES CLIENTE(IdCliente),
    CONSTRAINT FK_PEDIDOS_LOTES FOREIGN KEY (Lote_ID) REFERENCES LOTES(Lote_ID)
);
GO

-- ============================================================
-- 9. TABLA: INVENTARIO_SUCURSAL
-- ============================================================
CREATE TABLE INVENTARIO_SUCURSAL (
    Inventario_ID INT IDENTITY(1,1) CONSTRAINT PK_INVENTARIO_SUCURSAL PRIMARY KEY,
    IdSucursal INT NOT NULL,
    IdMatPrima INT NOT NULL, 
    stock DECIMAL(10,2),
    punto_Reorden DECIMAL(10,2),
    fecha_Actualizacion DATETIME,
    CONSTRAINT FK_INVENTARIO_SUCURSAL FOREIGN KEY (IdSucursal) REFERENCES SUCURSALES(IdSucursal),
    CONSTRAINT FK_INVENTARIO_MATERIA FOREIGN KEY (IdMatPrima) REFERENCES MATERIA_PRIMA(materia_ID)
);
GO

-- ============================================================
-- 10. TABLA: DETALLE_PROVEEDOR
-- ============================================================
CREATE TABLE DETALLE_PROVEEDOR (
    Detalle_ProvMat_ID INT IDENTITY(1,1) CONSTRAINT PK_DETALLE_PROVEEDOR PRIMARY KEY,
    IdProveedor INT NOT NULL,
    IdMatPrima INT NOT NULL,
    precio_Compra DECIMAL(10,2),
    fecha_Suministro DATE,
    CONSTRAINT FK_PROVEEDOR_MATERIA FOREIGN KEY (IdProveedor) REFERENCES PROVEEDORES(proveedor_ID),
    CONSTRAINT FK_MATERIA_PROVEEDOR FOREIGN KEY (IdMatPrima) REFERENCES MATERIA_PRIMA(materia_ID)
);
GO

USE Panaderia_Bimbo;
GO

/* ============================================================
   CONSTRAINTS 
============================================================ */

ALTER TABLE PRODUCTOS
ADD CONSTRAINT DF_PRODUCTOS_precio DEFAULT 0 FOR precioUnit;
GO

ALTER TABLE EMPLEADOS
ADD CONSTRAINT CK_EMPLEADOS_Salario CHECK (Salario > 0);
GO

ALTER TABLE CLIENTE
ADD CONSTRAINT UQ_CLIENTE_RUC UNIQUE (RUC);
GO


/* ================================
   INSERTS (10+ registros por tabla)
================================ */

INSERT INTO CLIENTE (RUC, Direccion, Telefono, RazonSocial, Email) VALUES
('20111111111','Av. Arequipa 1234, Lima','987654321','Supermercados Andinos S.A.','contacto@andinos.com'),
('20111111112','Jr. Junín 456, Arequipa','987654322','Minimarket Sol E.I.R.L.','ventas@sol.com'),
('20111111113','Av. Grau 789, Trujillo','987654323','Distribuidora Norte S.A.C.','compras@norte.com'),
('20111111114','Calle Piura 321, Chiclayo','987654324','Bodega La Esquina','laesquina@correo.com'),
('20111111115','Av. Larco 555, Lima','987654325','Panadería San José','sanjo@correo.com'),
('20111111116','Av. Collique 741, Lima','987654326','Restaurante Buen Sabor','bsabor@correo.com'),
('20111111117','Jr. Puno 202, Cusco','987654327','Hotel Inti S.A.C.','reservas@inti.com'),
('20111111118','Av. La Marina 1000, Callao','987654328','Comercial Pacífico','pacifico@correo.com'),
('20111111119','Av. América Sur 400, Trujillo','987654329','Cafetería Aroma','aroma@correo.com'),
('20111111120','Av. Independencia 77, Arequipa','987654330','Colegio Santa María','admin@santamaria.edu');

INSERT INTO PRODUCTOS (nomProducto, categoria, precioUnit, Stock) VALUES
('Pan Francés','Panadería',0.50,1200),
('Pan Integral','Panadería',0.80,800),
('Baguet','Panadería',1.50,600),
('Croissant','Pastelería',2.20,450),
('Queque vainilla','Pastelería',6.50,200),
('Torta chocolate (porción)','Pastelería',4.90,300),
('Empanada de pollo','Panadería',2.00,700),
('Pan de molde','Panadería',3.80,500),
('Muffin arándanos','Pastelería',3.20,350),
('Galletas de avena (pack)','Pastelería',5.50,250);

INSERT INTO SUCURSALES (codigoSucursal, direccion, ciudad, telefono, email) VALUES
('PB01','Av. Arequipa 1500','Lima','901111111','lima-centro@bimbo.pe'),
('PB02','Av. Dolores 200','Arequipa','901111112','arequipa@bimbo.pe'),
('PB03','Av. España 300','Trujillo','901111113','trujillo@bimbo.pe'),
('PB04','Av. Balta 400','Chiclayo','901111114','chiclayo@bimbo.pe'),
('PB05','Av. Universitaria 500','Lima','901111115','lima-norte@bimbo.pe'),
('PB06','Av. La Marina 600','Callao','901111116','callao@bimbo.pe'),
('PB07','Av. El Sol 700','Cusco','901111117','cusco@bimbo.pe'),
('PB08','Av. Primavera 800','Lima','901111118','lima-sur@bimbo.pe'),
('PB09','Av. Progreso 900','Piura','901111119','piura@bimbo.pe'),
('PB10','Av. Colonial 1000','Lima','901111120','lima-oeste@bimbo.pe');

INSERT INTO EMPLEADOS (IdSucursal, nombres, ApellidoPaterno, ApellidoMaterno, DNI, cargo, Salario) VALUES
(1, 'Juan','Pérez', 'Rueda', '12345670','Administrador',3500.00),
(2,'María','García', 'Padron', '12345671','Jefe de Sucursal',3200.00),
(3,'Luis','Rojas', 'Cornejo', '12345672','Panadero',1800.00),
(4,'Ana','Lopez', 'Alba', '12345673','Pastelera',1900.00),
(5,'Carlos','Diaz', 'Novoa', '12345674','Vendedor',1400.00),
(6,'Sofía','Vargas', 'Noguera', '12345675','Cajera',1350.00),
(7,'Pedro','Castro', 'Guirado', '12345676','Repartidor',1500.00),
(8,'Lucía','Salas', 'Catala', '12345677','Almacenero',1600.00),
(9,'Diego','Mendoza', 'Ortiz', '12345678','Panadero',1850.00),
(10,'Elena','Quispe', 'Romero', '12345679','Jefe de Producción',3600.00);

INSERT INTO MATERIA_PRIMA (nomMatPrima, unidMedida, costoUnidMed) VALUES
('Harina','kg',3.20),
('Azúcar','kg',3.00),
('Levadura','kg',15.00),
('Sal','kg',2.50),
('Mantequilla','kg',22.00),
('Huevos','ud',0.60),
('Leche','lt',4.50),
('Chocolate','kg',28.00),
('Vainilla','lt',35.00),
('Aceite','lt',8.50);

INSERT INTO PROVEEDORES (razon_Social, RUC, telefono, email, direccion) VALUES
('Molinos Andinos S.A.','20444444001','902000001','ventas@molinosandinos.pe','Av. Industrial 123, Lima'),
('Azucarera del Norte S.A.','20444444002','902000002','comercial@azunor.pe','Av. Agro 456, Chiclayo'),
('Lacteos del Sur S.A.C.','20444444003','902000003','contacto@lactsur.pe','Av. Lechera 789, Arequipa'),
('Cacao Peru S.A.C.','20444444004','902000004','ventas@cacaoperu.pe','Av. Cacao 101, Lima'),
('Granja El Sol E.I.R.L.','20444444005','902000005','huevos@granjaelsol.pe','Av. Granjas 202, Ica'),
('Aceites Andinos S.A.','20444444006','902000006','comercial@aceitesandinos.pe','Av. Refinería 303, Callao'),
('Sabor y Aroma S.A.C.','20444444007','902000007','ventas@saboraroma.pe','Av. Esencias 404, Lima'),
('Luma Distribuidora','20444444008','902000008','luma@distribuidora.pe','Av. Central 505, Lima'),
('Salinera Pacífico','20444444009','902000009','ventas@salpacifico.pe','Av. Salinas 606, Piura'),
('Insumos Pan S.A.C.','20444444010','902000010','info@insumospan.pe','Av. Panificadora 707, Lima');

INSERT INTO LOTES (IdProducto, IdSucursal, fec_Lote, estado, contenido) VALUES
(1,1,'2025-10-01','A','Pan Francés — 500 unidades'),
(2,2,'2025-10-01','A','Pan Integral — 300 unidades'),
(3,3,'2025-10-02','A','Baguet — 200 unidades'),
(4,4,'2025-10-02','A','Croissant — 180 unidades'),
(5,5,'2025-10-03','A','Queque vainilla — 90 unidades'),
(6,6,'2025-10-03','A','Torta chocolate porción — 250 uds'),
(7,7,'2025-10-04','A','Empanada de pollo — 350 uds'),
(8,8,'2025-10-04','A','Pan de molde — 150 unidades'),
(9,9,'2025-10-05','A','Muffin arándanos — 200 uds'),
(10,10,'2025-10-05','A','Galletas de avena — 120 packs');

INSERT INTO PEDIDOS (IdCliente, Lote_ID, fec_Pedido, monto, estado) VALUES
(1,1,'2025-10-06',250.00,'A'),
(2,2,'2025-10-06',240.00,'A'),
(3,3,'2025-10-07',300.00,'A'),
(4,4,'2025-10-07',396.00,'A'),
(5,5,'2025-10-08',585.00,'A'),
(6,6,'2025-10-08',1225.00,'A'),
(7,7,'2025-10-09',700.00,'A'),
(8,8,'2025-10-09',570.00,'A'),
(9,9,'2025-10-10',640.00,'A'),
(10,10,'2025-10-10',660.00,'A');

INSERT INTO INVENTARIO_SUCURSAL (IdSucursal, IdMatPrima, stock, punto_Reorden, fecha_Actualizacion) VALUES
(1,1,500.00,200.00,'2025-10-10T08:00:00'),
(2,2,300.00,120.00,'2025-10-10T08:05:00'),
(3,3,80.00,30.00,'2025-10-10T08:10:00'),
(4,4,150.00,60.00,'2025-10-10T08:15:00'),
(5,5,90.00,40.00,'2025-10-10T08:20:00'),
(6,6,1200.00,600.00,'2025-10-10T08:25:00'),
(7,7,400.00,150.00,'2025-10-10T08:30:00'),
(8,8,70.00,30.00,'2025-10-10T08:35:00'),
(9,9,25.00,10.00,'2025-10-10T08:40:00'),
(10,10,200.00,80.00,'2025-10-10T08:45:00');

INSERT INTO DETALLE_PROVEEDOR (IdProveedor, IdMatPrima, precio_Compra, fecha_Suministro) VALUES
(1,1,3.10,'2025-09-28'),
(2,2,2.90,'2025-09-28'),
(3,7,4.30,'2025-09-29'),
(4,8,27.50,'2025-09-29'),
(5,6,0.55,'2025-09-30'),
(6,10,8.20,'2025-09-30'),
(7,9,34.50,'2025-10-01'),
(8,3,14.70,'2025-10-01'),
(9,4,2.40,'2025-10-02'),
(10,5,21.80,'2025-10-02');

