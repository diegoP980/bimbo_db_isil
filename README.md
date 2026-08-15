# BIMBO: Base de datos

Este repositorio contiene todo el codigo fuente correspondiente a la base de datos que se trabajó para nuestro cliente BIMBO S.A. como parte de nuestro proyecto final.

## Scripts:

### 01_bimboCreate

Este script se encarga de la creación de toda la base de datos, lo cual incluye:
- La base de datos en sí misma:
  ```sql
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

  ...
  ```
- Tablas de la base de datos:
  ```sql
  CREATE TABLE CLIENTE (
      IdCliente INT IDENTITY(1,1) CONSTRAINT PK_CLIENTE PRIMARY KEY,
      RUC VARCHAR(11) NOT NULL,
      Direccion VARCHAR(50),
      ... 
  );
  GO

  CREATE TABLE PRODUCTOS (
      IdProducto INT IDENTITY(1,1) CONSTRAINT PK_PRODUCTOS PRIMARY KEY,
      nomProducto VARCHAR(100),
      categoria VARCHAR(50),
      ...
  );
  GO 

  ...
  ```
- Relaciones y constaints (restricciones):
  ```sql
  ...

  CREATE TABLE PEDIDOS (
      ...
      CONSTRAINT FK_PEDIDOS_CLIENTE FOREIGN KEY (IdCliente) REFERENCES CLIENTE(IdCliente),
      CONSTRAINT FK_PEDIDOS_LOTES FOREIGN KEY (Lote_ID) REFERENCES LOTES(Lote_ID)
  );
  GO

  ...

  ALTER TABLE EMPLEADOS
  ADD CONSTRAINT CK_EMPLEADOS_Salario CHECK (Salario > 0);
  GO

  ...
  ```
- Inserción de datos de prueba:
  ```sql
  INSERT INTO EMPLEADOS (IdSucursal, nombres, ApellidoPaterno, ApellidoMaterno, DNI, cargo, Salario) VALUES
  (1, 'Juan','Pérez', 'Rueda', '12345670','Administrador',3500.00),
  (2,'María','García', 'Padron', '12345671','Jefe de Sucursal',3200.00),
  (3,'Luis','Rojas', 'Cornejo', '12345672','Panadero',1800.00),
  ...
  ```

### 02_bimboScripts
EL presente script se encarga de la programación de la base de datos, que corresponde a:
- Vistas:
  ```sql
  ...
  
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

  ...
  ```
- Índices:
  ```sql
  ...

  CREATE NONCLUSTERED INDEX IX_PEDIDOS_FECHA_CLIENTE
  ON PEDIDOS (fec_Pedido)
  INCLUDE (IdCliente, monto);
  GO

  ...
  ```
- Procedimientos almacenados:
  ```sql
  ...

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

  ...
  ```
- Triggers:
  ```sql
  ...

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

  ...
  ```

Además, todos los objetos poseen categorías internas como mantenimiento, auditoria, entreo otros.

### 03_bimboQueries
Script encargado de ejecutar consultas de prueba a la base de datos
```sql
...

-- Conteo de empleados por sucursal
SELECT 
    e.IdSucursal, s.codigoSucursal, ciudad, count(e.IdEmpleado) as Empleados
FROM EMPLEADOS e
LEFT JOIN SUCURSALES s ON e.IdSucursal = s.IdSucursal
GROUP BY e.IdSucursal, s.codigoSucursal, ciudad;
GO

...

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

...


```

*Nota: Existe conocimiento de la ineficiencia (en términos de recursos del sistema) de las subconsultas. Están presentes por motivos académicos.*

### 04_bimboLogins
Este script es tan importante como los anteriores ya que es el encargado de construir el esquema de control de acceso en base a los roles de cada usuario dentro de la base de datos.

A continuación, se muestra arte del script en cuestión:

```sql
-- ==============================================
-- LOGIN
-- ==============================================
use master;

create login login_bimbo_DIEGO with password = '12345';
create login login_bimbo_PAMELA with password = '12345';
create login login_bimbo_CAMILLE with password = '12345';
create login login_bimbo_JUAN with password = '12345';
create login login_bimbo_gael with password = '!Has$F�I';
...

-- ==============================================
-- USERS
-- ==============================================
use Panaderia_Bimbo;
...
create user usuario_bimbo_marc for login login_bimbo_marc;
create user usuario_bimbo_maria for login login_bimbo_maria;
create user usuario_bimbo_ana for login login_bimbo_ana;
create user usuario_bimbo_adam for login login_bimbo_adam;
...

-- ==============================================
-- ROLES:
-- ==============================================
use Panaderia_Bimbo;
...
create role rol_supervisor;
create role rol_auditor;
create role rol_dbmanager;
...

-- ==============================================
-- PERMISOS:
-- ==============================================
-- ----------------------------------------------------------
-- 1. LECTURA
-- ----------------------------------------------------------
-- tablas
grant select on dbo.CLIENTE to rol_lectura;
grant select on dbo.PRODUCTOS to rol_lectura;
...

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_AuditarLotesInconsistentes to rol_lectura;
...

...
```