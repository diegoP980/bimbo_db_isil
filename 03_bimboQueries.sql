USE Panaderia_Bimbo;
GO

/* ============================================================
   VALIDACIONES 
============================================================ */

-- Tablas relacionadas con SUCURSALES (catálogo)
SELECT name AS Tabla
FROM sys.tables
WHERE name LIKE '%SUCUR%';
GO

-- Conteo de empleados por sucursal
SELECT 
    e.IdSucursal, s.codigoSucursal, ciudad, count(e.IdEmpleado) as Empleados
FROM EMPLEADOS e
LEFT JOIN SUCURSALES s ON e.IdSucursal = s.IdSucursal
GROUP BY e.IdSucursal, s.codigoSucursal, ciudad;
GO

-- Lotes sin producto o sucursal válida
SELECT
    l.Lote_ID, l.IdProducto, l.IdSucursal, l.fec_Lote, l.estado
FROM LOTES l
LEFT JOIN PRODUCTOS p ON l.IdProducto = p.IdProducto
LEFT JOIN SUCURSALES s ON l.IdSucursal = s.IdSucursal
WHERE p.IdProducto IS NULL OR s.IdSucursal IS NULL;
GO

-- Conteo de registros por tabla (resumen)
SELECT 'CLIENTE' AS Tabla, COUNT(*) AS Registros FROM CLIENTE
UNION ALL SELECT 'PRODUCTOS', COUNT(*) FROM PRODUCTOS
UNION ALL SELECT 'EMPLEADOS', COUNT(*) FROM EMPLEADOS
UNION ALL SELECT 'SUCURSALES', COUNT(*) FROM SUCURSALES
UNION ALL SELECT 'MATERIA_PRIMA', COUNT(*) FROM MATERIA_PRIMA
UNION ALL SELECT 'PROVEEDORES', COUNT(*) FROM PROVEEDORES
UNION ALL SELECT 'LOTES', COUNT(*) FROM LOTES
UNION ALL SELECT 'PEDIDOS', COUNT(*) FROM PEDIDOS
UNION ALL SELECT 'INVENTARIO_SUCURSAL', COUNT(*) FROM INVENTARIO_SUCURSAL
UNION ALL SELECT 'DETALLE_PROVEEDOR', COUNT(*) FROM DETALLE_PROVEEDOR;
GO

-- Pedidos con cliente o lote inexistente
SELECT
    p.IdPedido, p.IdCliente, p.Lote_ID, p.fec_Pedido, p.monto
FROM PEDIDOS p
LEFT JOIN CLIENTE c ON p.IdCliente = c.IdCliente
LEFT JOIN LOTES l ON p.Lote_ID = l.Lote_ID
WHERE c.IdCliente IS NULL OR l.Lote_ID IS NULL;
GO

-- Stock negativo (debe ser 0 resultados)
SELECT
    Inventario_ID, IdSucursal, IdMatPrima, stock, fecha_Actualizacion
FROM INVENTARIO_SUCURSAL
WHERE stock < 0;
GO

-- Empleados duplicados por DNI (debe ser 0 resultados)
SELECT DNI, COUNT(*) AS duplicados
FROM EMPLEADOS
GROUP BY DNI
HAVING COUNT(*) > 1;
GO

/* ============================================================
   SUBCONSULTAS 
============================================================ */

-- Clientes con cantidad de pedidos y monto total (subconsulta + suma)
SELECT 
    c.IdCliente,
    c.RazonSocial,
    (SELECT COUNT(*) FROM PEDIDOS p WHERE p.IdCliente = c.IdCliente) AS TotalPedidos,
    (SELECT ISNULL(SUM(p.monto),0) FROM PEDIDOS p WHERE p.IdCliente = c.IdCliente) AS MontoTotal
FROM CLIENTE c
ORDER BY MontoTotal DESC;
GO

-- Productos con total de lotes disponibles (subconsulta)
SELECT 
    p.IdProducto,
    p.nomProducto,
    (SELECT COUNT(*) FROM LOTES l WHERE l.IdProducto = p.IdProducto) AS TotalLotes
FROM PRODUCTOS p
ORDER BY TotalLotes DESC;
GO

-- Sucursales y cantidad de inventario registrado (subconsulta)
SELECT 
    s.IdSucursal,
    s.ciudad,
    (SELECT COUNT(*) FROM INVENTARIO_SUCURSAL i WHERE i.IdSucursal = s.IdSucursal) AS ItemsInventario
FROM SUCURSALES s
ORDER BY ItemsInventario DESC;
GO

-- Pedidos con nombre de producto (subconsulta + JOIN interno)
SELECT 
    p.IdPedido,
    p.fec_Pedido,
    (SELECT pr.nomProducto
     FROM PRODUCTOS pr
     JOIN LOTES l ON pr.IdProducto = l.IdProducto
     WHERE l.Lote_ID = p.Lote_ID) AS Producto
FROM PEDIDOS p
ORDER BY p.fec_Pedido, p.IdPedido;
GO

/* ============================================================
   CONSULTAS ADICIONALES 
============================================================ */

-- 1) Top 5 clientes por ventas (JOIN + GROUP BY)
SELECT TOP 5
    c.RazonSocial,
    COUNT(p.IdPedido) AS CantPedidos,
    SUM(p.monto) AS MontoTotal,
    AVG(p.monto) AS TicketPromedio
FROM PEDIDOS p
JOIN CLIENTE c ON p.IdCliente = c.IdCliente
GROUP BY c.RazonSocial
ORDER BY MontoTotal DESC;
GO

-- 2) Ventas por sucursal (JOIN + GROUP BY)
SELECT
    s.ciudad AS Sucursal,
    COUNT(p.IdPedido) AS TotalPedidos,
    SUM(p.monto) AS TotalVentas
FROM PEDIDOS p
JOIN LOTES l ON p.Lote_ID = l.Lote_ID
JOIN SUCURSALES s ON l.IdSucursal = s.IdSucursal
GROUP BY s.ciudad
ORDER BY TotalVentas DESC;
GO

-- 3) Productos más vendidos (cantidad + monto)
SELECT TOP 10
    pr.nomProducto AS Producto,
    pr.categoria,
    COUNT(p.IdPedido) AS CantVentas,
    SUM(p.monto) AS MontoVendido
FROM PEDIDOS p
JOIN LOTES l ON p.Lote_ID = l.Lote_ID
JOIN PRODUCTOS pr ON l.IdProducto = pr.IdProducto
GROUP BY pr.nomProducto, pr.categoria
ORDER BY MontoVendido DESC;
GO

-- 4) Inventario en reorden (vista + CASE)
SELECT
    ciudad, nomMatPrima, stock, punto_Reorden, EstadoStock, fecha_Actualizacion
FROM dbo.INVENTARIO_DETALLE
WHERE EstadoStock = 'REORDEN'
ORDER BY (stock - punto_Reorden);
GO

-- 5) Clientes por encima del promedio (HAVING + subconsulta)
SELECT
    c.RazonSocial,
    SUM(p.monto) AS TotalComprado
FROM PEDIDOS p
JOIN CLIENTE c ON p.IdCliente = c.IdCliente
GROUP BY c.RazonSocial
HAVING SUM(p.monto) > (SELECT AVG(monto) FROM PEDIDOS)
ORDER BY TotalComprado DESC;
GO
