-- ==============================================
-- LOGIN
-- ==============================================
use master;

create login login_bimbo_DIEGO with password = '12345';
create login login_bimbo_PAMELA with password = '12345';
create login login_bimbo_CAMILLE with password = '12345';
create login login_bimbo_JUAN with password = '12345';
create login login_bimbo_gael with password = '!Has$F�I';
create login login_bimbo_yasmina with password = 'w$!tRp1@';
create login login_bimbo_izan with password = 'sr#21mg&';
create login login_bimbo_hanane with password = 'nDe3TQg&';
create login login_bimbo_jesus with password = 'kG!H5eeH';
create login login_bimbo_alejandro with password = 'VtPDJgY3';
create login login_bimbo_marc with password = '00o!mt#z';
create login login_bimbo_maria with password = 'dEZFUpQk';
create login login_bimbo_ana with password = 'GFQq4izA';
create login login_bimbo_adam with password = 'famr!ivq';

-- ==============================================
-- USERS
-- ==============================================
use Panaderia_Bimbo;

create user usuario_bimbo_DIEGO for login login_bimbo_DIEGO ;
create user usuario_bimbo_PAMELA for login login_bimbo_PAMELA;
create user usuario_bimbo_CAMILLE for login login_bimbo_CAMILLE;
create user usuario_bimbo_JUAN  for login login_bimbo_JUAN;
create user usuario_bimbo_gael for login login_bimbo_gael;
create user usuario_bimbo_yasmina for login login_bimbo_yasmina;
create user usuario_bimbo_izan for login login_bimbo_izan;
create user usuario_bimbo_hanane for login login_bimbo_hanane;
create user usuario_bimbo_jesus for login login_bimbo_jesus;
create user usuario_bimbo_alejandro for login login_bimbo_alejandro;
create user usuario_bimbo_marc for login login_bimbo_marc;
create user usuario_bimbo_maria for login login_bimbo_maria;
create user usuario_bimbo_ana for login login_bimbo_ana;
create user usuario_bimbo_adam for login login_bimbo_adam;

-- ==============================================
-- ROLES:
-- ==============================================
use Panaderia_Bimbo;

create role rol_lectura;
create role rol_ventas;
create role rol_almacen;
create role rol_supervisor;
create role rol_auditor;
create role rol_dbmanager;

    -- ==============================================
    -- PERMISOS:
    -- ==============================================

-- ----------------------------------------------------------
-- 1. LECTURA
-- ----------------------------------------------------------
-- tablas
grant select on dbo.CLIENTE to rol_lectura;
grant select on dbo.PRODUCTOS to rol_lectura;
grant select on dbo.EMPLEADOS to rol_lectura;
grant select on dbo.SUCURSALES to rol_lectura;
grant select on dbo.MATERIA_PRIMA to rol_lectura;
grant select on dbo.PROVEEDORES to rol_lectura;
grant select on dbo.LOTES to rol_lectura;
grant select on dbo.PEDIDOS to rol_lectura;
grant select on dbo.INVENTARIO_SUCURSAL to rol_lectura;
grant select on dbo.DETALLE_PROVEEDOR to rol_lectura;

-- vistas
select *
from sys.views;

grant select on dbo.PEDIDOS_DETALLE to rol_lectura;
grant select on dbo.INVENTARIO_DETALLE to rol_lectura;
grant select on dbo.PROVEEDOR_MATERIA to rol_lectura;

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_AuditarLotesInconsistentes to rol_lectura;
grant exec on dbo.sp_AuditarPedidosInconsistentes to rol_lectura;
grant exec on dbo.sp_AuditarStockNegativo to rol_lectura;
grant exec on dbo.sp_AuditarClientesDuplicados to rol_lectura;
grant exec on dbo.sp_ReportePedidosPorFecha to rol_lectura;
grant exec on dbo.sp_StockMateriasPrimaPorSucursal to rol_lectura;
grant exec on dbo.sp_ProveedoresPorMateriaPrima to rol_lectura;

-- ----------------------------------------------------------
-- 2. VENTAS
-- ----------------------------------------------------------
-- tablas
grant select on dbo.CLIENTE to rol_ventas;
grant select on dbo.PRODUCTOS to rol_ventas;
grant select on dbo.SUCURSALES to rol_ventas;
grant select on dbo.LOTES to rol_ventas;
grant select, insert, update on dbo.PEDIDOS to rol_ventas;
grant select on dbo.INVENTARIO_SUCURSAL to rol_ventas;

-- vistas
select *
from sys.views;

grant select on dbo.PEDIDOS_DETALLE to rol_ventas;

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_InsertarPedidoSeguro to rol_lectura;
grant exec on dbo.sp_ReportePedidosPorFecha to rol_lectura;
grant exec on dbo.sp_ProductosMasVendidos to rol_lectura;

-- ----------------------------------------------------------
-- 3. ALMACEN
-- ----------------------------------------------------------
-- tablas
grant select, insert, update on dbo.INVENTARIO_SUCURSAL to rol_almacen;
grant select on dbo.MATERIA_PRIMA to rol_almacen;
grant select, insert, update  on dbo.LOTES to rol_almacen;
grant select on dbo.PRODUCTOS to rol_almacen;
grant select on dbo.SUCURSALES to rol_almacen;

-- vistas
select *
from sys.views;

grant select on dbo.INVENTARIO_DETALLE to rol_almacen;
grant select on dbo.PROVEEDOR_MATERIA to rol_almacen;

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_StockMateriasPrimaPorSucursal to rol_almacen;
grant exec on dbo.sp_ActualizarStockProducto to rol_almacen;
grant exec on dbo.sp_ProveedoresPorMateriaPrima to rol_almacen;

-- ----------------------------------------------------------
-- 4. SUPERVISOR
-- ----------------------------------------------------------
-- tablas
grant select, insert, update on dbo.CLIENTE to rol_supervisor;
grant select, insert, update on dbo.PEDIDOS to rol_supervisor;
grant select, insert, update on dbo.PRODUCTOS to rol_supervisor;
grant select, insert, update on dbo.LOTES to rol_supervisor;
grant select, insert, update on dbo.INVENTARIO_SUCURSAL to rol_supervisor;
grant select, insert, update on dbo.DETALLE_PROVEEDOR to rol_supervisor;

-- vistas
select *
from sys.views;

grant select on dbo.PEDIDOS_DETALLE to rol_supervisor;
grant select on dbo.INVENTARIO_DETALLE to rol_supervisor;
grant select on dbo.PROVEEDOR_MATERIA to rol_supervisor;

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_InsertarPedidoSeguro to rol_almacen;
grant exec on dbo.sp_ActualizarStockProducto to rol_almacen;
grant exec on dbo.sp_ProveedoresPorMateriaPrima to rol_almacen;
grant exec on dbo.sp_StockMateriasPrimaPorSucursal to rol_almacen;
grant exec on dbo.sp_ProductosMasVendidos to rol_almacen;
grant exec on dbo.sp_ReportePedidosPorFecha to rol_almacen;

-- ----------------------------------------------------------
-- 5. AUDITOR (INTERNO/EXTERNO)
-- ----------------------------------------------------------
-- tablas
grant select on dbo.CLIENTE to rol_auditor;
grant select on dbo.PRODUCTOS to rol_auditor;
grant select on dbo.EMPLEADOS to rol_auditor;
grant select on dbo.SUCURSALES to rol_auditor;
grant select on dbo.MATERIA_PRIMA to rol_auditor;
grant select on dbo.PROVEEDORES to rol_auditor;
grant select on dbo.LOTES to rol_auditor;
grant select on dbo.PEDIDOS to rol_auditor;
grant select on dbo.INVENTARIO_SUCURSAL to rol_auditor;
grant select on dbo.DETALLE_PROVEEDOR to rol_auditor;

-- vistas
select *
from sys.views;

grant select on dbo.PEDIDOS_DETALLE to rol_auditor;
grant select on dbo.INVENTARIO_DETALLE to rol_auditor;
grant select on dbo.PROVEEDOR_MATERIA to rol_auditor;

-- procedimientos almacenados
select object_id, name, create_date, modify_date
from sys.objects
where type = 'P'
order by create_date desc;

grant exec on dbo.sp_AuditarClientesDuplicados to rol_auditor;
grant exec on dbo.sp_AuditarStockNegativo to rol_auditor;
grant exec on dbo.sp_AuditarPedidosInconsistentes to rol_auditor;
grant exec on dbo.sp_AuditarLotesInconsistentes to rol_auditor;

-- ----------------------------------------------------------
-- 6. DBMANAGER
-- ----------------------------------------------------------
-- permisos de CRUD sobre tablas y lectura de vistas, ejecucion de sp's y modificaciones de vistas e indices
grant select, insert, update, delete on schema::dbo to rol_dbmanager;
grant exec on schema::dbo to rol_dbmanager;
grant alter on schema::dbo to rol_dbmanager;

-- permisos de creacion de objetos en la base de datos
grant create view to rol_dbmanager;
grant create procedure to rol_dbmanager;
grant create table to rol_dbmanager;
grant create function to rol_dbmanager;

-- ==============================================
-- ASIGNACION DE ROLES A USUARIOS:
-- ==============================================
use Panaderia_Bimbo;

-- ----------------------------------------------------------
-- LECTURA (analistas, contabilidad, facturacion, finanzas)
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_gael;
alter role rol_lectura add member usuario_bimbo_yasmina;

-- ----------------------------------------------------------
-- VENTAS
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_izan;
alter role rol_lectura add member usuario_bimbo_hanane;

-- ----------------------------------------------------------
-- ALMACEN
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_jesus;
alter role rol_lectura add member usuario_bimbo_alejandro;

-- ----------------------------------------------------------
-- SUPERVISOR
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_marc;

-- ----------------------------------------------------------
-- AUDITOR
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_maria;

-- ----------------------------------------------------------
-- DBMANAGER
-- ----------------------------------------------------------
alter role rol_lectura add member usuario_bimbo_ana;

-- ----------------------------------------------------------
-- DBADMIN
-- ----------------------------------------------------------
alter role db_owner add member usuario_bimbo_adam;
alter role db_owner add member usuario_bimbo_DIEGO;
alter role db_owner add member usuario_bimbo_PAMELA;
alter role db_owner add member usuario_bimbo_CAMILLE;
alter role db_owner add member usuario_bimbo_JUAN;

-- ----------------------------------------------------------
-- OWNER
-- ----------------------------------------------------------
alter server role sysadmin add member login_bimbo_DIEGO;
alter server role sysadmin add member login_bimbo_PAMELA;
alter server role sysadmin add member login_bimbo_CAMILLE;
alter server role sysadmin add member login_bimbo_JUAN;
