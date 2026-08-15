USE Panaderia_Bimbo;
GO

/* ============================================================
   VISTAS 
============================================================ */

CREATE OR ALTER VIEW dbo.PEDIDOS_DETALLE
AS
SELECT 
    p.IdPedido,
    p.fec_Pedido,
    p.monto,
    p.estado AS EstadoPedido,
    c.IdCliente,
    c.RazonSocial AS Cliente,
    c.RUC,
    pr.IdProducto,
    pr.nomProducto AS Producto,
    pr.categoria,
    s.IdSucursal,
    s.ciudad AS Sucursal
FROM PEDIDOS p
JOIN CLIENTE c ON p.IdCliente = c.IdCliente
JOIN LOTES l ON p.Lote_ID = l.Lote_ID
JOIN PRODUCTOS pr ON l.IdProducto = pr.IdProducto
JOIN SUCURSALES s ON l.IdSucursal = s.IdSucursal;
GO

CREATE OR ALTER VIEW dbo.INVENTARIO_DETALLE
AS
SELECT 
    i.Inventario_ID,
    s.IdSucursal,
    s.ciudad,
    mp.materia_ID,
    mp.nomMatPrima,
    i.stock,
    i.punto_Reorden,
    i.fecha_Actualizacion,
    CASE 
        WHEN i.stock < i.punto_Reorden THEN 'REORDEN'
        ELSE 'OK'
    END AS EstadoStock
FROM INVENTARIO_SUCURSAL i
JOIN SUCURSALES s ON i.IdSucursal = s.IdSucursal
JOIN MATERIA_PRIMA mp ON i.IdMatPrima = mp.materia_ID;
GO

CREATE OR ALTER VIEW dbo.PROVEEDOR_MATERIA
AS
SELECT
    pv.proveedor_ID,
    pv.razon_Social AS Proveedor,
    mp.materia_ID,
    mp.nomMatPrima,
    dp.precio_Compra,
    dp.fecha_Suministro
FROM DETALLE_PROVEEDOR dp
JOIN PROVEEDORES pv ON dp.IdProveedor = pv.proveedor_ID
JOIN MATERIA_PRIMA mp ON dp.IdMatPrima = mp.materia_ID;
GO

-- Validaciones 
SELECT TOP 10
    IdPedido, fec_Pedido, Cliente, Producto, Sucursal, monto
FROM dbo.PEDIDOS_DETALLE
ORDER BY fec_Pedido DESC;
GO

SELECT TOP 10
    ciudad, nomMatPrima, stock, punto_Reorden, EstadoStock, fecha_Actualizacion
FROM dbo.INVENTARIO_DETALLE
ORDER BY EstadoStock DESC, ciudad, nomMatPrima;
GO

SELECT TOP 10
    Proveedor, nomMatPrima, precio_Compra, fecha_Suministro
FROM dbo.PROVEEDOR_MATERIA
ORDER BY fecha_Suministro DESC;
GO

-- ==================================================================
-- CINCO VISTAS ADICIONALES - DROP IF EXISTS y CREATE
-- ==================================================================

IF OBJECT_ID('dbo.VIEW_PRODUCTOS_STOCK_BAJO','V') IS NOT NULL
    DROP VIEW dbo.VIEW_PRODUCTOS_STOCK_BAJO;
GO
CREATE VIEW VIEW_PRODUCTOS_STOCK_BAJO AS
SELECT 
    IdProducto,
    nomProducto,
    Stock
FROM PRODUCTOS
WHERE Stock < 200;
GO

select*from VIEW_PRODUCTOS_STOCK_BAJO

IF OBJECT_ID('dbo.VIEW_CLIENTES_TOP_PEDIDOS','V') IS NOT NULL
    DROP VIEW dbo.VIEW_CLIENTES_TOP_PEDIDOS;
GO
CREATE VIEW VIEW_CLIENTES_TOP_PEDIDOS AS
SELECT 
    c.IdCliente,
    c.RazonSocial,
    COUNT(p.IdPedido) AS TotalPedidos
FROM CLIENTE c
LEFT JOIN PEDIDOS p ON p.IdCliente = c.IdCliente
GROUP BY c.IdCliente, c.RazonSocial;
GO

select*from VIEW_CLIENTES_TOP_PEDIDOS

IF OBJECT_ID('dbo.VIEW_LOTES_POR_SUCURSAL','V') IS NOT NULL
    DROP VIEW dbo.VIEW_LOTES_POR_SUCURSAL;
GO
CREATE VIEW VIEW_LOTES_POR_SUCURSAL AS
SELECT 
    s.IdSucursal,
    s.ciudad,
    COUNT(l.Lote_ID) AS TotalLotes
FROM SUCURSALES s
LEFT JOIN LOTES l ON l.IdSucursal = s.IdSucursal
GROUP BY s.IdSucursal, s.ciudad;
GO

select*from VIEW_LOTES_POR_SUCURSAL

IF OBJECT_ID('dbo.VIEW_COMPRAS_MATERIA_PRIMA','V') IS NOT NULL
    DROP VIEW dbo.VIEW_COMPRAS_MATERIA_PRIMA;
GO
CREATE VIEW VIEW_COMPRAS_MATERIA_PRIMA AS
SELECT 
    mp.nomMatPrima,
    dp.precio_Compra,
    dp.fecha_Suministro,
    pv.razon_Social AS Proveedor
FROM DETALLE_PROVEEDOR dp
JOIN MATERIA_PRIMA mp ON dp.IdMatPrima = mp.materia_ID
JOIN PROVEEDORES pv ON dp.IdProveedor = pv.proveedor_ID;
GO

select*from VIEW_COMPRAS_MATERIA_PRIMA


IF OBJECT_ID('dbo.VIEW_PEDIDOS_POR_PRODUCTO','V') IS NOT NULL
    DROP VIEW dbo.VIEW_PEDIDOS_POR_PRODUCTO;
GO
CREATE VIEW VIEW_PEDIDOS_POR_PRODUCTO AS
SELECT 
    pr.IdProducto,
    pr.nomProducto,
    COUNT(p.IdPedido) AS PedidosTotales
FROM PRODUCTOS pr
JOIN LOTES l ON pr.IdProducto = l.IdProducto
JOIN PEDIDOS p ON l.Lote_ID = p.Lote_ID
GROUP BY pr.IdProducto, pr.nomProducto;
GO

select*from VIEW_PEDIDOS_POR_PRODUCTO


/* ============================================================
   ÍNDICES 
============================================================ */

-- ============================================================
-- ÍNDICE OPTIMIZADO PARA LOTES
-- Prioriza búsquedas por producto y joins
-- ============================================================
CREATE NONCLUSTERED INDEX IX_LOTES_PRODUCTO_SUCURSAL
ON LOTES (IdProducto, IdSucursal);
GO

-- Indice NONCLUSTERED para acelerar busqueda de CLIENTE por RUC--
--  Util porque RUC es un campo consultado frecuentemente------------
CREATE UNIQUE NONCLUSTERED INDEX IX_CLIENTE_RUC
ON CLIENTE (RUC);
GO

-- ============================================================
-- ÍNDICE CUBRIENTE PARA PEDIDOS
-- Mejora reportes por rango de fechas
-- ============================================================
CREATE NONCLUSTERED INDEX IX_PEDIDOS_FECHA_CLIENTE
ON PEDIDOS (fec_Pedido)
INCLUDE (IdCliente, monto);
GO

-- Verificar índices actuales
SELECT 
    t.name AS Tabla,
    i.name AS Indice,
    i.type_desc
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('LOTES','PEDIDOS')
			AND i.is_primary_key = 0;
GO

-- Ver plan de ejecución 
SET SHOWPLAN_TEXT ON;
GO
SELECT IdCliente, RUC, RazonSocial, Email
FROM CLIENTE
WHERE RUC = '20111111111';
GO
SET SHOWPLAN_TEXT OFF;
GO

/* ============================================================
   PROCEDIMIENTOS ALMACENADOS 
============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_ReportePedidosPorFecha
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdPedido, fec_Pedido, Cliente, RUC, Producto, categoria, Sucursal, monto, EstadoPedido
    FROM dbo.PEDIDOS_DETALLE
    WHERE fec_Pedido BETWEEN @FechaInicio AND @FechaFin
    ORDER BY fec_Pedido;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProductosMasVendidos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10
        pr.IdProducto,
        pr.nomProducto,
        pr.categoria,
        COUNT(p.IdPedido) AS TotalVentas,
        SUM(p.monto) AS MontoVendido
    FROM PEDIDOS p
    JOIN LOTES l ON p.Lote_ID = l.Lote_ID
    JOIN PRODUCTOS pr ON l.IdProducto = pr.IdProducto
    GROUP BY pr.IdProducto, pr.nomProducto, pr.categoria
    ORDER BY MontoVendido DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_StockMateriasPrimaPorSucursal
    @IdSucursal INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        IdSucursal, ciudad, nomMatPrima, stock, punto_Reorden, EstadoStock, fecha_Actualizacion
    FROM dbo.INVENTARIO_DETALLE
    WHERE IdSucursal = @IdSucursal
    ORDER BY EstadoStock DESC, nomMatPrima;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_ProveedoresPorMateriaPrima
    @IdMatPrima INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Proveedor, nomMatPrima, precio_Compra, fecha_Suministro
    FROM dbo.PROVEEDOR_MATERIA
    WHERE materia_ID = @IdMatPrima
    ORDER BY fecha_Suministro DESC;
END
GO


/* ============================================================
   AUDITORÍA 
============================================================ */

CREATE OR ALTER PROCEDURE dbo.sp_AuditarClientesDuplicados
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        RUC,
        COUNT(*) AS CantDuplicados
    FROM CLIENTE
    GROUP BY RUC
    HAVING COUNT(*) > 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AuditarStockNegativo
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        Inventario_ID,
        IdSucursal,
        IdMatPrima,
        stock,
        fecha_Actualizacion
    FROM INVENTARIO_SUCURSAL
    WHERE stock < 0;
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_AuditarPedidosInconsistentes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        p.IdPedido,
        p.IdCliente,
        p.Lote_ID,
        c.IdCliente AS ClienteExistente,
        l.Lote_ID AS LoteExistente
    FROM PEDIDOS p
    LEFT JOIN CLIENTE c ON p.IdCliente = c.IdCliente
    LEFT JOIN LOTES l ON p.Lote_ID = l.Lote_ID
    WHERE c.IdCliente IS NULL OR l.Lote_ID IS NULL;
END;
GO

-- procedimiento  para LOTES inconsistentes 
CREATE OR ALTER PROCEDURE dbo.sp_AuditarLotesInconsistentes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Lote_ID,
        l.IdProducto,
        l.IdSucursal,
        p.IdProducto AS ProductoExistente,
        s.IdSucursal AS SucursalExistente,
        l.fec_Lote,
        l.estado
    FROM LOTES l
    LEFT JOIN PRODUCTOS p ON l.IdProducto = p.IdProducto
    LEFT JOIN SUCURSALES s ON l.IdSucursal = s.IdSucursal
    WHERE p.IdProducto IS NULL OR s.IdSucursal IS NULL;
END;
GO


/* ============================================================
   MANTENIMIENTO 
============================================================ */

IF OBJECT_ID('dbo.sp_ActualizarStockProducto', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_ActualizarStockProducto;
GO

CREATE PROCEDURE dbo.sp_ActualizarStockProducto
    @IdProducto INT,
    @NuevoStock INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE PRODUCTOS
    SET Stock = @NuevoStock
    WHERE IdProducto = @IdProducto;
END;
GO

IF OBJECT_ID('dbo.sp_InsertarPedidoSeguro', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_InsertarPedidoSeguro;
GO

CREATE PROCEDURE dbo.sp_InsertarPedidoSeguro
    @IdCliente INT,
    @Lote_ID INT,
    @fec_Pedido DATE,
    @monto DECIMAL(7,2),
    @estado CHAR(1) = 'A'
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM CLIENTE WHERE IdCliente = @IdCliente)
       AND EXISTS (SELECT 1 FROM LOTES WHERE Lote_ID = @Lote_ID)
    BEGIN
        INSERT INTO PEDIDOS (IdCliente, Lote_ID, fec_Pedido, monto, estado)
        VALUES (@IdCliente, @Lote_ID, @fec_Pedido, @monto, @estado);
    END
    ELSE
    BEGIN
        SELECT 'Cliente o lote no válidos' AS Mensaje;
    END
END;
GO

-- Inserción de pedido con TRANSACCIÓN EXPLÍCITA 
CREATE OR ALTER PROCEDURE dbo.sp_InsertarPedidoConTransaccion
    @IdCliente INT,
    @Lote_ID INT,
    @fec_Pedido DATE,
    @monto DECIMAL(7,2),
    @estado CHAR(1) = 'A'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN;

    IF EXISTS (SELECT 1 FROM CLIENTE WHERE IdCliente = @IdCliente)
       AND EXISTS (SELECT 1 FROM LOTES WHERE Lote_ID = @Lote_ID)
    BEGIN
        INSERT INTO PEDIDOS (IdCliente, Lote_ID, fec_Pedido, monto, estado)
        VALUES (@IdCliente, @Lote_ID, @fec_Pedido, @monto, @estado);

        COMMIT;
        SELECT 'Pedido insertado correctamente (TRANSACCIÓN EXPLÍCITA)' AS Resultado;
    END
    ELSE
    BEGIN
        ROLLBACK;
        SELECT 'Cliente o lote no válido. Se hizo ROLLBACK y no se insertó.' AS Resultado;
    END
END;
GO

/* ============================================================
   TRIGGERS 
============================================================ */

-- ==================================================================
-- SECCIÓN: AUDITORÍA / TABLAS AUXILIARES
-- ==================================================================
IF OBJECT_ID('dbo.AUD_CLIENTE', 'U') IS NOT NULL
    DROP TABLE dbo.AUD_CLIENTE;
GO

CREATE TABLE AUD_CLIENTE(
    IdAud INT IDENTITY PRIMARY KEY,
    IdCliente INT,
    RUC VARCHAR(11),
    FechaRegistro DATETIME DEFAULT GETDATE()
);
GO

-- ==================================================================
-- SECCIÓN: TRIGGERS (5) - DROP IF EXISTS y CREATE
-- ==================================================================

-- 1) TRG_ValidarStockPositivo
IF OBJECT_ID('TRG_ValidarStockPositivo','TR') IS NOT NULL
    DROP TRIGGER TRG_ValidarStockPositivo;
GO
CREATE TRIGGER TRG_ValidarStockPositivo
ON INVENTARIO_SUCURSAL
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM INSERTED WHERE stock < 0)
    BEGIN
        RAISERROR('El stock no puede ser negativo.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- 2) TRG_ActualizarStockProductoDesdeLote
IF OBJECT_ID('TRG_ActualizarStockProductoDesdeLote','TR') IS NOT NULL
    DROP TRIGGER TRG_ActualizarStockProductoDesdeLote;
GO

CREATE TRIGGER TRG_ActualizarStockProductoDesdeLote
ON LOTES
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ajusta el stock sumando 100 unidades por cada lote insertado
    UPDATE PRODUCTOS
    SET Stock = Stock + 100
    FROM PRODUCTOS pr
    JOIN INSERTED i ON pr.IdProducto = i.IdProducto;
END;
GO



-- 3) TRG_AuditarNuevoCliente
IF OBJECT_ID('TRG_AuditarNuevoCliente','TR') IS NOT NULL
    DROP TRIGGER TRG_AuditarNuevoCliente;
GO
CREATE TRIGGER TRG_AuditarNuevoCliente
ON CLIENTE
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO AUD_CLIENTE(IdCliente, RUC, FechaRegistro)
    SELECT IdCliente, RUC, GETDATE()
    FROM INSERTED;
END;
GO

-- 4) TRG_ValidarPrecioProducto
IF OBJECT_ID('TRG_ValidarPrecioProducto','TR') IS NOT NULL
    DROP TRIGGER TRG_ValidarPrecioProducto;
GO
CREATE TRIGGER TRG_ValidarPrecioProducto
ON PRODUCTOS
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM INSERTED WHERE precioUnit IS NULL OR precioUnit < 0)
    BEGIN
        RAISERROR('El precio del producto no puede ser nulo o negativo.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- 5) TRG_ControlarEstadoPedido
IF OBJECT_ID('TRG_ControlarEstadoPedido','TR') IS NOT NULL
    DROP TRIGGER TRG_ControlarEstadoPedido;
GO
CREATE TRIGGER TRG_ControlarEstadoPedido
ON PEDIDOS
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE i.monto = 0 AND i.estado <> 'A'
    )
    BEGIN
        RAISERROR('No se puede cambiar el estado si el monto es 0.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO

-- ==================================================================
-- TRANSACCIONES (3) - PROCEDIMIENTOS PARA PRUEBAS
-- ==================================================================
-- 1) TX_RegistrarPedidoCompleto (Procedimiento que engloba la transacción)
IF OBJECT_ID('dbo.sp_TX_RegistrarPedidoCompleto','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TX_RegistrarPedidoCompleto;
GO
CREATE PROCEDURE sp_TX_RegistrarPedidoCompleto
    @IdCliente INT,
    @Lote_ID INT,
    @Cantidad INT,
    @monto DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    DECLARE @IdProducto INT;

    SELECT @IdProducto = IdProducto FROM LOTES WHERE Lote_ID = @Lote_ID;

    IF @IdProducto IS NULL
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Lote no válido. Transacción cancelada.';
        RETURN;
    END

    INSERT INTO PEDIDOS (IdCliente, Lote_ID, fec_Pedido, monto, estado)
    VALUES (@IdCliente, @Lote_ID, GETDATE(), @monto, 'A');

    UPDATE PRODUCTOS
    SET Stock = Stock - @Cantidad
    WHERE IdProducto = @IdProducto;

    IF EXISTS (SELECT 1 FROM PRODUCTOS WHERE IdProducto = @IdProducto AND Stock < 0)
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Stock insuficiente. Transacción revertida.';
        RETURN;
    END

    COMMIT TRANSACTION;
    PRINT 'Pedido registrado correctamente.';
END;
GO

-- 2) TX_ActualizarInventario (Procedimiento)
IF OBJECT_ID('dbo.sp_TX_ActualizarInventario','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TX_ActualizarInventario;
GO
CREATE PROCEDURE sp_TX_ActualizarInventario
    @Inventario_ID INT,
    @CantidadMov DECIMAL(10,2) -- positivo = entrada, negativo = salida
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    UPDATE INVENTARIO_SUCURSAL
    SET stock = stock + @CantidadMov, fecha_Actualizacion = GETDATE()
    WHERE Inventario_ID = @Inventario_ID;

    IF EXISTS (SELECT 1 FROM INVENTARIO_SUCURSAL WHERE Inventario_ID = @Inventario_ID AND stock < 0)
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Movimiento inválido: stock negativo. Revertido.';
        RETURN;
    END

    COMMIT TRANSACTION;
    PRINT 'Inventario actualizado correctamente.';
END;
GO

-- 3) TX_RegistrarCompraMateriaPrima (Procedimiento)
IF OBJECT_ID('dbo.sp_TX_RegistrarCompraMateriaPrima','P') IS NOT NULL
    DROP PROCEDURE dbo.sp_TX_RegistrarCompraMateriaPrima;
GO
CREATE PROCEDURE sp_TX_RegistrarCompraMateriaPrima
    @IdProveedor INT,
    @IdMatPrima INT,
    @Precio DECIMAL(10,2),
    @Cantidad DECIMAL(10,2),
    @IdSucursal INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;

    INSERT INTO DETALLE_PROVEEDOR (IdProveedor, IdMatPrima, precio_Compra, fecha_Suministro)
    VALUES (@IdProveedor, @IdMatPrima, @Precio, GETDATE());

    UPDATE INVENTARIO_SUCURSAL
    SET stock = stock + @Cantidad, fecha_Actualizacion = GETDATE()
    WHERE IdMatPrima = @IdMatPrima AND IdSucursal = @IdSucursal;

    IF @@ERROR <> 0
    BEGIN
        ROLLBACK TRANSACTION;
        PRINT 'Error al registrar compra. Revertido.';
        RETURN;
    END

    COMMIT TRANSACTION;
    PRINT 'Compra registrada y stock actualizado.';
END;
GO
