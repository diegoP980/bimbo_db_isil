# BIMBO: Base de datos

Este repositorio contiene todo el codigo fuente correspondiente a la base de datos que se trabajó para nuestro cliente BIMBO S.A. como parte de nuestro proyecto final.

## Scripts:

### 01_bimboCreate

Este script se encarga de la creación de toda la base de datos, lo cual corresponde a:
* La base de datos en sí misma:
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
* Tablas de la base de datos:
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
* Constaints (restricciones):
  ```sql

...

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

...

ALTER TABLE EMPLEADOS
ADD CONSTRAINT CK_EMPLEADOS_Salario CHECK (Salario > 0);
GO

...
  ```
* Inserción de datos de prueba:
  ```sql
INSERT INTO EMPLEADOS (IdSucursal, nombres, ApellidoPaterno, ApellidoMaterno, DNI, cargo, Salario) VALUES
(1, 'Juan','Pérez', 'Rueda', '12345670','Administrador',3500.00),
(2,'María','García', 'Padron', '12345671','Jefe de Sucursal',3200.00),
(3,'Luis','Rojas', 'Cornejo', '12345672','Panadero',1800.00),
...
  ```


