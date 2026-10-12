/* =========================================================================
   DB_Bomberos - 3. Stored Procedures
   -------------------------------------------------------------------------
   Sistema de Gestión de Cuartel de Bomberos Voluntarios
   Stored Procedures usados por la capa de acceso a datos (DAL) de la
   aplicación web ASP.NET Web Forms.

   Orden de ejecución de scripts:
     1. Set-up.sql                       (estructura de la base)
     2. Initial Data.sql                 (datos iniciales)
     3. Stored Procedures.sql            (este script)
     4. Datos de ejemplo adicionales.sql (opcional, datos "del día")

   Requisitos: SQL Server 2017 o superior (usa CREATE OR ALTER, THROW,
   STRING_AGG y funciones de ventana).

   Convenciones:
     - sp_<Entidad>_Listar      : consulta con filtros opcionales (NULL = sin filtro)
     - sp_<Entidad>_Obtener     : un registro por ID
     - sp_<Entidad>_Insertar    : alta, devuelve el ID generado (columna ID)
     - sp_<Entidad>_Actualizar  : modificación
     - sp_<Entidad>_Eliminar    : baja física (o lógica cuando corresponde)
     - sp_Rpt_<Reporte>         : reportes / consultas
     - Errores de negocio: THROW 50001..50099 con mensaje para el usuario.
       La DAL muestra el mensaje tal cual al usuario final.
   ========================================================================= */

USE DB_Bomberos;
GO

-- Las opciones deben estar activas al crear los SP porque existen
-- índices filtrados (ver sección siguiente).
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =========================================================================
   REGLAS DE INTEGRIDAD ADICIONALES
   Refuerzan a nivel de base las reglas de negocio documentadas en el DER.
   ========================================================================= */

-- Un voluntario solo puede tener un rango vigente (FechaHasta IS NULL) a la vez
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HistorialRangos_Vigente')
    CREATE UNIQUE NONCLUSTERED INDEX UX_HistorialRangos_Vigente
        ON dbo.HistorialRangos (IDVoluntario)
        WHERE FechaHasta IS NULL;
GO

-- Un voluntario puede tener varios roles a la vez, pero no el mismo rol vigente dos veces
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HistorialRoles_Vigente')
    CREATE UNIQUE NONCLUSTERED INDEX UX_HistorialRoles_Vigente
        ON dbo.HistorialRoles (IDVoluntario, IDRol)
        WHERE FechaHasta IS NULL;
GO

/* =====================================================================
   CATÁLOGOS (tablas ID + Nombre)
   Todos los catálogos exponen el mismo contrato de columnas:
   ID, Nombre, Descripcion (NULL si la tabla no la tiene) y CantidadRegistros
   (cantidad de filas que lo referencian) para que la capa de datos
   pueda reutilizar un único mapeo.
   ===================================================================== */

-- ---------------------------------------------------------------------
-- Rangos
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rangos_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDRango AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.HistorialRangos r WHERE r.IDRango = c.IDRango) AS CantidadRegistros
    FROM dbo.Rangos c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rangos_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDRango AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.HistorialRangos r WHERE r.IDRango = c.IDRango) AS CantidadRegistros
    FROM dbo.Rangos c
    WHERE c.IDRango = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rangos_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Rangos WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de rango con ese nombre.', 1;
    INSERT INTO dbo.Rangos (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rangos_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Rangos WHERE IDRango = @ID)
        THROW 50004, N'El registro de rango no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Rangos WHERE Nombre = @Nombre AND IDRango <> @ID)
        THROW 50001, N'Ya existe un registro de rango con ese nombre.', 1;
    UPDATE dbo.Rangos SET Nombre = @Nombre WHERE IDRango = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rangos_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.HistorialRangos WHERE IDRango = @ID)
        THROW 50002, N'No se puede eliminar: el registro de rango está siendo utilizado en historial de rangos.', 1;
    DELETE FROM dbo.Rangos WHERE IDRango = @ID;
END
GO

-- ---------------------------------------------------------------------
-- Roles
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Roles_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDRol AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.HistorialRoles r WHERE r.IDRol = c.IDRol) AS CantidadRegistros
    FROM dbo.Roles c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDRol AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.HistorialRoles r WHERE r.IDRol = c.IDRol) AS CantidadRegistros
    FROM dbo.Roles c
    WHERE c.IDRol = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de rol con ese nombre.', 1;
    INSERT INTO dbo.Roles (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE IDRol = @ID)
        THROW 50004, N'El registro de rol no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Roles WHERE Nombre = @Nombre AND IDRol <> @ID)
        THROW 50001, N'Ya existe un registro de rol con ese nombre.', 1;
    UPDATE dbo.Roles SET Nombre = @Nombre WHERE IDRol = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Roles_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.HistorialRoles WHERE IDRol = @ID)
        THROW 50002, N'No se puede eliminar: el registro de rol está siendo utilizado en historial de roles.', 1;
    DELETE FROM dbo.Roles WHERE IDRol = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoVehiculo
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoVehiculo_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoVehiculo AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Vehiculos r WHERE r.IDTipoVehiculo = c.IDTipoVehiculo) AS CantidadRegistros
    FROM dbo.TipoVehiculo c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoVehiculo_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoVehiculo AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Vehiculos r WHERE r.IDTipoVehiculo = c.IDTipoVehiculo) AS CantidadRegistros
    FROM dbo.TipoVehiculo c
    WHERE c.IDTipoVehiculo = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoVehiculo_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoVehiculo WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de vehículo con ese nombre.', 1;
    INSERT INTO dbo.TipoVehiculo (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoVehiculo_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoVehiculo WHERE IDTipoVehiculo = @ID)
        THROW 50004, N'El registro de tipo de vehículo no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoVehiculo WHERE Nombre = @Nombre AND IDTipoVehiculo <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de vehículo con ese nombre.', 1;
    UPDATE dbo.TipoVehiculo SET Nombre = @Nombre WHERE IDTipoVehiculo = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoVehiculo_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Vehiculos WHERE IDTipoVehiculo = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de vehículo está siendo utilizado en vehículos.', 1;
    DELETE FROM dbo.TipoVehiculo WHERE IDTipoVehiculo = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoEquipamiento
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoEquipamiento_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoEquipamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Equipamiento r WHERE r.IDTipoEquipamiento = c.IDTipoEquipamiento) AS CantidadRegistros
    FROM dbo.TipoEquipamiento c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEquipamiento_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoEquipamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Equipamiento r WHERE r.IDTipoEquipamiento = c.IDTipoEquipamiento) AS CantidadRegistros
    FROM dbo.TipoEquipamiento c
    WHERE c.IDTipoEquipamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEquipamiento_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoEquipamiento WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de equipamiento con ese nombre.', 1;
    INSERT INTO dbo.TipoEquipamiento (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEquipamiento_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoEquipamiento WHERE IDTipoEquipamiento = @ID)
        THROW 50004, N'El registro de tipo de equipamiento no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoEquipamiento WHERE Nombre = @Nombre AND IDTipoEquipamiento <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de equipamiento con ese nombre.', 1;
    UPDATE dbo.TipoEquipamiento SET Nombre = @Nombre WHERE IDTipoEquipamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEquipamiento_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE IDTipoEquipamiento = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de equipamiento está siendo utilizado en equipamiento.', 1;
    DELETE FROM dbo.TipoEquipamiento WHERE IDTipoEquipamiento = @ID;
END
GO

-- ---------------------------------------------------------------------
-- CategoriaEquipamiento
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_CategoriaEquipamiento_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDCategoriaEquipamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Equipamiento r WHERE r.IDCategoriaEquipamiento = c.IDCategoriaEquipamiento) AS CantidadRegistros
    FROM dbo.CategoriaEquipamiento c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CategoriaEquipamiento_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDCategoriaEquipamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Equipamiento r WHERE r.IDCategoriaEquipamiento = c.IDCategoriaEquipamiento) AS CantidadRegistros
    FROM dbo.CategoriaEquipamiento c
    WHERE c.IDCategoriaEquipamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CategoriaEquipamiento_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.CategoriaEquipamiento WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de categoría de equipamiento con ese nombre.', 1;
    INSERT INTO dbo.CategoriaEquipamiento (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CategoriaEquipamiento_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.CategoriaEquipamiento WHERE IDCategoriaEquipamiento = @ID)
        THROW 50004, N'El registro de categoría de equipamiento no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.CategoriaEquipamiento WHERE Nombre = @Nombre AND IDCategoriaEquipamiento <> @ID)
        THROW 50001, N'Ya existe un registro de categoría de equipamiento con ese nombre.', 1;
    UPDATE dbo.CategoriaEquipamiento SET Nombre = @Nombre WHERE IDCategoriaEquipamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_CategoriaEquipamiento_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE IDCategoriaEquipamiento = @ID)
        THROW 50002, N'No se puede eliminar: el registro de categoría de equipamiento está siendo utilizado en equipamiento.', 1;
    DELETE FROM dbo.CategoriaEquipamiento WHERE IDCategoriaEquipamiento = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoMision
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoMision_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoMision AS ID, c.Nombre, c.Descripcion AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Misiones r WHERE r.IDTipoMision = c.IDTipoMision) AS CantidadRegistros
    FROM dbo.TipoMision c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoMision_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoMision AS ID, c.Nombre, c.Descripcion AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Misiones r WHERE r.IDTipoMision = c.IDTipoMision) AS CantidadRegistros
    FROM dbo.TipoMision c
    WHERE c.IDTipoMision = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoMision_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoMision WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de misión con ese nombre.', 1;
    INSERT INTO dbo.TipoMision (Nombre, Descripcion) VALUES (@Nombre, @Descripcion);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoMision_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoMision WHERE IDTipoMision = @ID)
        THROW 50004, N'El registro de tipo de misión no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoMision WHERE Nombre = @Nombre AND IDTipoMision <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de misión con ese nombre.', 1;
    UPDATE dbo.TipoMision SET Nombre = @Nombre, Descripcion = @Descripcion WHERE IDTipoMision = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoMision_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Misiones WHERE IDTipoMision = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de misión está siendo utilizado en misiones.', 1;
    DELETE FROM dbo.TipoMision WHERE IDTipoMision = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoEntrenamiento
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoEntrenamiento_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoEntrenamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Entrenamientos r WHERE r.IDTipoEntrenamiento = c.IDTipoEntrenamiento) AS CantidadRegistros
    FROM dbo.TipoEntrenamiento c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEntrenamiento_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoEntrenamiento AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Entrenamientos r WHERE r.IDTipoEntrenamiento = c.IDTipoEntrenamiento) AS CantidadRegistros
    FROM dbo.TipoEntrenamiento c
    WHERE c.IDTipoEntrenamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEntrenamiento_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoEntrenamiento WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de entrenamiento con ese nombre.', 1;
    INSERT INTO dbo.TipoEntrenamiento (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEntrenamiento_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoEntrenamiento WHERE IDTipoEntrenamiento = @ID)
        THROW 50004, N'El registro de tipo de entrenamiento no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoEntrenamiento WHERE Nombre = @Nombre AND IDTipoEntrenamiento <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de entrenamiento con ese nombre.', 1;
    UPDATE dbo.TipoEntrenamiento SET Nombre = @Nombre WHERE IDTipoEntrenamiento = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoEntrenamiento_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Entrenamientos WHERE IDTipoEntrenamiento = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de entrenamiento está siendo utilizado en entrenamientos.', 1;
    DELETE FROM dbo.TipoEntrenamiento WHERE IDTipoEntrenamiento = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoAporte
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoAporte_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoAporte AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Aportes r WHERE r.IDTipoAporte = c.IDTipoAporte) AS CantidadRegistros
    FROM dbo.TipoAporte c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoAporte_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoAporte AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Aportes r WHERE r.IDTipoAporte = c.IDTipoAporte) AS CantidadRegistros
    FROM dbo.TipoAporte c
    WHERE c.IDTipoAporte = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoAporte_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoAporte WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de aporte con ese nombre.', 1;
    INSERT INTO dbo.TipoAporte (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoAporte_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoAporte WHERE IDTipoAporte = @ID)
        THROW 50004, N'El registro de tipo de aporte no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoAporte WHERE Nombre = @Nombre AND IDTipoAporte <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de aporte con ese nombre.', 1;
    UPDATE dbo.TipoAporte SET Nombre = @Nombre WHERE IDTipoAporte = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoAporte_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Aportes WHERE IDTipoAporte = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de aporte está siendo utilizado en aportes.', 1;
    DELETE FROM dbo.TipoAporte WHERE IDTipoAporte = @ID;
END
GO

-- ---------------------------------------------------------------------
-- TipoGasto
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_TipoGasto_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoGasto AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Gastos r WHERE r.IDTipoGasto = c.IDTipoGasto) AS CantidadRegistros
    FROM dbo.TipoGasto c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoGasto_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDTipoGasto AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.Gastos r WHERE r.IDTipoGasto = c.IDTipoGasto) AS CantidadRegistros
    FROM dbo.TipoGasto c
    WHERE c.IDTipoGasto = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoGasto_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.TipoGasto WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de tipo de gasto con ese nombre.', 1;
    INSERT INTO dbo.TipoGasto (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoGasto_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.TipoGasto WHERE IDTipoGasto = @ID)
        THROW 50004, N'El registro de tipo de gasto no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.TipoGasto WHERE Nombre = @Nombre AND IDTipoGasto <> @ID)
        THROW 50001, N'Ya existe un registro de tipo de gasto con ese nombre.', 1;
    UPDATE dbo.TipoGasto SET Nombre = @Nombre WHERE IDTipoGasto = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_TipoGasto_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Gastos WHERE IDTipoGasto = @ID)
        THROW 50002, N'No se puede eliminar: el registro de tipo de gasto está siendo utilizado en gastos.', 1;
    DELETE FROM dbo.TipoGasto WHERE IDTipoGasto = @ID;
END
GO

-- ---------------------------------------------------------------------
-- Caja
-- ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Caja_Listar
    @Texto NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDCaja AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.MovimientoCaja r WHERE r.IDCaja = c.IDCaja) AS CantidadRegistros
    FROM dbo.Caja c
    WHERE @Texto IS NULL OR c.Nombre LIKE N'%' + @Texto + N'%'
    ORDER BY c.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Caja_Obtener
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDCaja AS ID, c.Nombre, CAST(NULL AS NVARCHAR(250)) AS Descripcion,
           (SELECT COUNT(*) FROM dbo.MovimientoCaja r WHERE r.IDCaja = c.IDCaja) AS CantidadRegistros
    FROM dbo.Caja c
    WHERE c.IDCaja = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Caja_Insertar
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Caja WHERE Nombre = @Nombre)
        THROW 50001, N'Ya existe un registro de caja con ese nombre.', 1;
    INSERT INTO dbo.Caja (Nombre) VALUES (@Nombre);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Caja_Actualizar
    @ID INT,
    @Nombre NVARCHAR(50),
    @Descripcion NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Caja WHERE IDCaja = @ID)
        THROW 50004, N'El registro de caja no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Caja WHERE Nombre = @Nombre AND IDCaja <> @ID)
        THROW 50001, N'Ya existe un registro de caja con ese nombre.', 1;
    UPDATE dbo.Caja SET Nombre = @Nombre WHERE IDCaja = @ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Caja_Eliminar
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.MovimientoCaja WHERE IDCaja = @ID)
        THROW 50002, N'No se puede eliminar: el registro de caja está siendo utilizado en movimientos de caja.', 1;
    DELETE FROM dbo.Caja WHERE IDCaja = @ID;
END
GO

/* =========================================================================
   MÓDULO PERSONAL
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Voluntarios
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Listar
    @Texto  NVARCHAR(100) = NULL,   -- busca en Nombre, Apellido, DNI y Email
    @Estado NVARCHAR(30)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVoluntario, v.Nombre, v.Apellido, v.DNI, v.FechaNacimiento, v.Telefono,
           v.Email, v.Direccion, v.FechaIngreso, v.Estado,
           ra.Nombre AS RangoActual
    FROM dbo.Voluntarios v
    OUTER APPLY (SELECT TOP 1 r.Nombre
                 FROM dbo.HistorialRangos hr
                 INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
                 WHERE hr.IDVoluntario = v.IDVoluntario AND hr.FechaHasta IS NULL
                 ORDER BY hr.FechaDesde DESC) ra
    WHERE (@Texto IS NULL
           OR v.Nombre   LIKE N'%' + @Texto + N'%'
           OR v.Apellido LIKE N'%' + @Texto + N'%'
           OR v.DNI      LIKE N'%' + @Texto + N'%'
           OR v.Email    LIKE N'%' + @Texto + N'%')
      AND (@Estado IS NULL OR v.Estado = @Estado)
    ORDER BY v.Apellido, v.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Obtener
    @IDVoluntario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVoluntario, v.Nombre, v.Apellido, v.DNI, v.FechaNacimiento, v.Telefono,
           v.Email, v.Direccion, v.FechaIngreso, v.Estado,
           ra.Nombre AS RangoActual
    FROM dbo.Voluntarios v
    OUTER APPLY (SELECT TOP 1 r.Nombre
                 FROM dbo.HistorialRangos hr
                 INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
                 WHERE hr.IDVoluntario = v.IDVoluntario AND hr.FechaHasta IS NULL) ra
    WHERE v.IDVoluntario = @IDVoluntario;
END
GO

-- Ficha completa del voluntario (usada por el DetailsView)
CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Ficha
    @IDVoluntario INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVoluntario,
           v.Apellido + N', ' + v.Nombre AS [Voluntario],
           v.DNI,
           v.FechaNacimiento AS [Fecha de nacimiento],
           DATEDIFF(YEAR, v.FechaNacimiento, GETDATE())
             - CASE WHEN DATEADD(YEAR, DATEDIFF(YEAR, v.FechaNacimiento, GETDATE()), v.FechaNacimiento) > GETDATE() THEN 1 ELSE 0 END AS [Edad],
           v.Telefono AS [Teléfono],
           v.Email,
           v.Direccion AS [Dirección],
           v.FechaIngreso AS [Fecha de ingreso],
           DATEDIFF(YEAR, v.FechaIngreso, GETDATE()) AS [Años de servicio],
           v.Estado,
           ISNULL(ra.Nombre, N'(sin rango)') AS [Rango actual],
           ISNULL((SELECT STRING_AGG(ro.Nombre, N', ')
                   FROM dbo.HistorialRoles hro
                   INNER JOIN dbo.Roles ro ON ro.IDRol = hro.IDRol
                   WHERE hro.IDVoluntario = v.IDVoluntario AND hro.FechaHasta IS NULL), N'(sin roles)') AS [Roles vigentes],
           (SELECT COUNT(*) FROM dbo.MisionVoluntario mv WHERE mv.IDVoluntario = v.IDVoluntario) AS [Misiones],
           (SELECT COUNT(*) FROM dbo.Entrenamientos e WHERE e.IDVoluntario = v.IDVoluntario) AS [Entrenamientos],
           (SELECT COUNT(*) FROM dbo.Guardias g WHERE g.IDVoluntario = v.IDVoluntario) AS [Guardias]
    FROM dbo.Voluntarios v
    OUTER APPLY (SELECT TOP 1 r.Nombre
                 FROM dbo.HistorialRangos hr
                 INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
                 WHERE hr.IDVoluntario = v.IDVoluntario AND hr.FechaHasta IS NULL) ra
    WHERE v.IDVoluntario = @IDVoluntario;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Insertar
    @Nombre          NVARCHAR(100),
    @Apellido        NVARCHAR(100),
    @DNI             NVARCHAR(10),
    @FechaNacimiento DATE,
    @Telefono        NVARCHAR(30)  = NULL,
    @Email           NVARCHAR(100) = NULL,
    @Direccion       NVARCHAR(200) = NULL,
    @FechaIngreso    DATE,
    @Estado          NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE DNI = @DNI)
        THROW 50001, N'Ya existe un voluntario registrado con ese DNI.', 1;
    IF @FechaIngreso < @FechaNacimiento
        THROW 50003, N'La fecha de ingreso no puede ser anterior a la fecha de nacimiento.', 1;

    INSERT INTO dbo.Voluntarios (Nombre, Apellido, DNI, FechaNacimiento, Telefono, Email, Direccion, FechaIngreso, Estado)
    VALUES (@Nombre, @Apellido, @DNI, @FechaNacimiento, @Telefono, @Email, @Direccion, @FechaIngreso, @Estado);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Actualizar
    @IDVoluntario    INT,
    @Nombre          NVARCHAR(100),
    @Apellido        NVARCHAR(100),
    @DNI             NVARCHAR(10),
    @FechaNacimiento DATE,
    @Telefono        NVARCHAR(30)  = NULL,
    @Email           NVARCHAR(100) = NULL,
    @Direccion       NVARCHAR(200) = NULL,
    @FechaIngreso    DATE,
    @Estado          NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE IDVoluntario = @IDVoluntario)
        THROW 50004, N'El voluntario no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE DNI = @DNI AND IDVoluntario <> @IDVoluntario)
        THROW 50001, N'Ya existe otro voluntario registrado con ese DNI.', 1;
    IF @FechaIngreso < @FechaNacimiento
        THROW 50003, N'La fecha de ingreso no puede ser anterior a la fecha de nacimiento.', 1;

    UPDATE dbo.Voluntarios
    SET Nombre = @Nombre, Apellido = @Apellido, DNI = @DNI, FechaNacimiento = @FechaNacimiento,
        Telefono = @Telefono, Email = @Email, Direccion = @Direccion,
        FechaIngreso = @FechaIngreso, Estado = @Estado
    WHERE IDVoluntario = @IDVoluntario;
END
GO

-- Baja lógica: el voluntario no se borra (conserva su historial), pasa a estado 'Baja'
CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_BajaLogica
    @IDVoluntario INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE IDVoluntario = @IDVoluntario)
        THROW 50004, N'El voluntario no existe.', 1;
    UPDATE dbo.Voluntarios SET Estado = N'Baja' WHERE IDVoluntario = @IDVoluntario;
END
GO

-- Lista para combos (DropDownList). @SoloActivos = 1 devuelve solo voluntarios en estado 'Activo';
-- con 0 devuelve todos excepto los dados de baja.
CREATE OR ALTER PROCEDURE dbo.sp_Voluntarios_Combo
    @SoloActivos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVoluntario AS Valor,
           v.Apellido + N', ' + v.Nombre + N' (DNI ' + v.DNI + N')' AS Texto
    FROM dbo.Voluntarios v
    WHERE (@SoloActivos = 1 AND v.Estado = N'Activo')
       OR (@SoloActivos = 0 AND v.Estado <> N'Baja')
    ORDER BY v.Apellido, v.Nombre;
END
GO

-- -------------------------------------------------------------------------
-- Historial de Rangos
-- Regla: un voluntario no puede tener más de un rango vigente al mismo
-- tiempo, ni períodos de rango superpuestos.
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Listar
    @IDVoluntario INT = NULL,
    @SoloVigentes BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT hr.IDHistorialRango, hr.IDVoluntario, hr.IDRango, hr.FechaDesde, hr.FechaHasta,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           r.Nombre AS RangoNombre
    FROM dbo.HistorialRangos hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
    WHERE (@IDVoluntario IS NULL OR hr.IDVoluntario = @IDVoluntario)
      AND (@SoloVigentes = 0 OR hr.FechaHasta IS NULL)
    ORDER BY v.Apellido, v.Nombre, hr.FechaDesde DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Obtener
    @IDHistorialRango INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT hr.IDHistorialRango, hr.IDVoluntario, hr.IDRango, hr.FechaDesde, hr.FechaHasta,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           r.Nombre AS RangoNombre
    FROM dbo.HistorialRangos hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
    WHERE hr.IDHistorialRango = @IDHistorialRango;
END
GO

-- Validación compartida por Insertar y Actualizar
CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Validar
    @IDHistorialRango INT = NULL,   -- NULL en altas
    @IDVoluntario     INT,
    @FechaDesde       DATE,
    @FechaHasta       DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaHasta IS NOT NULL AND @FechaHasta < @FechaDesde
        THROW 50003, N'La fecha hasta no puede ser anterior a la fecha desde.', 1;

    IF @FechaHasta IS NULL AND EXISTS (SELECT 1 FROM dbo.HistorialRangos
                                       WHERE IDVoluntario = @IDVoluntario AND FechaHasta IS NULL
                                         AND IDHistorialRango <> ISNULL(@IDHistorialRango, 0))
        THROW 50010, N'El voluntario ya posee un rango vigente. Finalice el rango actual o utilice "Registrar ascenso".', 1;

    -- Superposición de períodos (se permite que un período termine el mismo día que empieza el siguiente)
    IF EXISTS (SELECT 1 FROM dbo.HistorialRangos
               WHERE IDVoluntario = @IDVoluntario
                 AND IDHistorialRango <> ISNULL(@IDHistorialRango, 0)
                 AND FechaDesde < ISNULL(@FechaHasta, '99991231')
                 AND ISNULL(FechaHasta, '99991231') > @FechaDesde)
        THROW 50011, N'El período indicado se superpone con otro rango del voluntario. Un voluntario no puede tener dos rangos al mismo tiempo.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Insertar
    @IDVoluntario INT,
    @IDRango      INT,
    @FechaDesde   DATE,
    @FechaHasta   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_HistorialRangos_Validar NULL, @IDVoluntario, @FechaDesde, @FechaHasta;

    INSERT INTO dbo.HistorialRangos (IDVoluntario, IDRango, FechaDesde, FechaHasta)
    VALUES (@IDVoluntario, @IDRango, @FechaDesde, @FechaHasta);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Actualizar
    @IDHistorialRango INT,
    @IDVoluntario     INT,
    @IDRango          INT,
    @FechaDesde       DATE,
    @FechaHasta       DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.HistorialRangos WHERE IDHistorialRango = @IDHistorialRango)
        THROW 50004, N'El registro de historial no existe.', 1;
    EXEC dbo.sp_HistorialRangos_Validar @IDHistorialRango, @IDVoluntario, @FechaDesde, @FechaHasta;

    UPDATE dbo.HistorialRangos
    SET IDVoluntario = @IDVoluntario, IDRango = @IDRango, FechaDesde = @FechaDesde, FechaHasta = @FechaHasta
    WHERE IDHistorialRango = @IDHistorialRango;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Eliminar
    @IDHistorialRango INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.HistorialRangos WHERE IDHistorialRango = @IDHistorialRango;
END
GO

-- Registra un ascenso: cierra el rango vigente en @Fecha y abre el nuevo rango desde @Fecha.
-- Se ejecuta dentro de una transacción.
CREATE OR ALTER PROCEDURE dbo.sp_HistorialRangos_Ascender
    @IDVoluntario INT,
    @IDRango      INT,
    @Fecha        DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IDActual INT, @RangoActual INT, @DesdeActual DATE;

    SELECT @IDActual = IDHistorialRango, @RangoActual = IDRango, @DesdeActual = FechaDesde
    FROM dbo.HistorialRangos
    WHERE IDVoluntario = @IDVoluntario AND FechaHasta IS NULL;

    IF @RangoActual = @IDRango
        THROW 50012, N'El voluntario ya posee ese rango como rango vigente.', 1;
    IF @DesdeActual IS NOT NULL AND @Fecha < @DesdeActual
        THROW 50013, N'La fecha del ascenso no puede ser anterior al inicio del rango vigente.', 1;
    IF EXISTS (SELECT 1 FROM dbo.HistorialRangos
               WHERE IDVoluntario = @IDVoluntario AND FechaHasta IS NOT NULL AND FechaHasta > @Fecha)
        THROW 50011, N'La fecha del ascenso se superpone con períodos de rango ya registrados.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @IDActual IS NOT NULL
            UPDATE dbo.HistorialRangos SET FechaHasta = @Fecha WHERE IDHistorialRango = @IDActual;

        INSERT INTO dbo.HistorialRangos (IDVoluntario, IDRango, FechaDesde, FechaHasta)
        VALUES (@IDVoluntario, @IDRango, @Fecha, NULL);

        COMMIT TRANSACTION;
        SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- -------------------------------------------------------------------------
-- Historial de Roles
-- Regla: un voluntario puede tener varios roles a la vez, pero no el mismo
-- rol vigente dos veces ni períodos superpuestos del mismo rol.
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Listar
    @IDVoluntario INT = NULL,
    @SoloVigentes BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT hr.IDHistorialRol, hr.IDVoluntario, hr.IDRol, hr.FechaDesde, hr.FechaHasta,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           r.Nombre AS RolNombre
    FROM dbo.HistorialRoles hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Roles r ON r.IDRol = hr.IDRol
    WHERE (@IDVoluntario IS NULL OR hr.IDVoluntario = @IDVoluntario)
      AND (@SoloVigentes = 0 OR hr.FechaHasta IS NULL)
    ORDER BY v.Apellido, v.Nombre, hr.FechaDesde DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Obtener
    @IDHistorialRol INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT hr.IDHistorialRol, hr.IDVoluntario, hr.IDRol, hr.FechaDesde, hr.FechaHasta,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           r.Nombre AS RolNombre
    FROM dbo.HistorialRoles hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Roles r ON r.IDRol = hr.IDRol
    WHERE hr.IDHistorialRol = @IDHistorialRol;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Validar
    @IDHistorialRol INT = NULL,
    @IDVoluntario   INT,
    @IDRol          INT,
    @FechaDesde     DATE,
    @FechaHasta     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaHasta IS NOT NULL AND @FechaHasta < @FechaDesde
        THROW 50003, N'La fecha hasta no puede ser anterior a la fecha desde.', 1;

    IF EXISTS (SELECT 1 FROM dbo.HistorialRoles
               WHERE IDVoluntario = @IDVoluntario AND IDRol = @IDRol
                 AND IDHistorialRol <> ISNULL(@IDHistorialRol, 0)
                 AND FechaDesde < ISNULL(@FechaHasta, '99991231')
                 AND ISNULL(FechaHasta, '99991231') > @FechaDesde)
        THROW 50014, N'El voluntario ya tiene asignado ese rol en un período que se superpone (no puede tener el mismo rol vigente dos veces).', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Insertar
    @IDVoluntario INT,
    @IDRol        INT,
    @FechaDesde   DATE,
    @FechaHasta   DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_HistorialRoles_Validar NULL, @IDVoluntario, @IDRol, @FechaDesde, @FechaHasta;

    INSERT INTO dbo.HistorialRoles (IDVoluntario, IDRol, FechaDesde, FechaHasta)
    VALUES (@IDVoluntario, @IDRol, @FechaDesde, @FechaHasta);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Actualizar
    @IDHistorialRol INT,
    @IDVoluntario   INT,
    @IDRol          INT,
    @FechaDesde     DATE,
    @FechaHasta     DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.HistorialRoles WHERE IDHistorialRol = @IDHistorialRol)
        THROW 50004, N'El registro de historial no existe.', 1;
    EXEC dbo.sp_HistorialRoles_Validar @IDHistorialRol, @IDVoluntario, @IDRol, @FechaDesde, @FechaHasta;

    UPDATE dbo.HistorialRoles
    SET IDVoluntario = @IDVoluntario, IDRol = @IDRol, FechaDesde = @FechaDesde, FechaHasta = @FechaHasta
    WHERE IDHistorialRol = @IDHistorialRol;
END
GO

-- Finaliza la vigencia de un rol (asigna FechaHasta)
CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Finalizar
    @IDHistorialRol INT,
    @FechaHasta     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Desde DATE, @Hasta DATE;
    SELECT @Desde = FechaDesde, @Hasta = FechaHasta FROM dbo.HistorialRoles WHERE IDHistorialRol = @IDHistorialRol;

    IF @Desde IS NULL
        THROW 50004, N'El registro de historial no existe.', 1;
    IF @Hasta IS NOT NULL
        THROW 50015, N'La vigencia de este rol ya fue finalizada.', 1;
    IF @FechaHasta < @Desde
        THROW 50003, N'La fecha de finalización no puede ser anterior a la fecha desde.', 1;

    UPDATE dbo.HistorialRoles SET FechaHasta = @FechaHasta WHERE IDHistorialRol = @IDHistorialRol;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_HistorialRoles_Eliminar
    @IDHistorialRol INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.HistorialRoles WHERE IDHistorialRol = @IDHistorialRol;
END
GO

/* =========================================================================
   MÓDULO VEHÍCULOS
   Nota: la columna de la tabla se llama [Año]; se expone como "Anio" para
   evitar caracteres especiales en el código .NET.
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Listar
    @Patente        NVARCHAR(10) = NULL,
    @Estado         NVARCHAR(30) = NULL,
    @IDTipoVehiculo INT          = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVehiculo, v.Nombre, v.[Año] AS Anio, v.Patente, v.Estado, v.IDTipoVehiculo,
           t.Nombre AS TipoNombre,
           (SELECT COUNT(*) FROM dbo.DocumentacionVehiculo d
             WHERE d.IDVehiculo = v.IDVehiculo AND d.FechaVencimiento < CAST(GETDATE() AS DATE)) AS DocumentosVencidos
    FROM dbo.Vehiculos v
    INNER JOIN dbo.TipoVehiculo t ON t.IDTipoVehiculo = v.IDTipoVehiculo
    WHERE (@Patente IS NULL OR v.Patente LIKE N'%' + @Patente + N'%')
      AND (@Estado IS NULL OR v.Estado = @Estado)
      AND (@IDTipoVehiculo IS NULL OR v.IDTipoVehiculo = @IDTipoVehiculo)
    ORDER BY v.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Obtener
    @IDVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVehiculo, v.Nombre, v.[Año] AS Anio, v.Patente, v.Estado, v.IDTipoVehiculo,
           t.Nombre AS TipoNombre,
           (SELECT COUNT(*) FROM dbo.DocumentacionVehiculo d
             WHERE d.IDVehiculo = v.IDVehiculo AND d.FechaVencimiento < CAST(GETDATE() AS DATE)) AS DocumentosVencidos
    FROM dbo.Vehiculos v
    INNER JOIN dbo.TipoVehiculo t ON t.IDTipoVehiculo = v.IDTipoVehiculo
    WHERE v.IDVehiculo = @IDVehiculo;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Insertar
    @Nombre         NVARCHAR(100),
    @Anio           INT,
    @Patente        NVARCHAR(10),
    @Estado         NVARCHAR(30),
    @IDTipoVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Vehiculos WHERE Patente = @Patente)
        THROW 50001, N'Ya existe un vehículo con esa patente.', 1;

    INSERT INTO dbo.Vehiculos (Nombre, [Año], Patente, Estado, IDTipoVehiculo)
    VALUES (@Nombre, @Anio, @Patente, @Estado, @IDTipoVehiculo);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Actualizar
    @IDVehiculo     INT,
    @Nombre         NVARCHAR(100),
    @Anio           INT,
    @Patente        NVARCHAR(10),
    @Estado         NVARCHAR(30),
    @IDTipoVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Vehiculos WHERE IDVehiculo = @IDVehiculo)
        THROW 50004, N'El vehículo no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Vehiculos WHERE Patente = @Patente AND IDVehiculo <> @IDVehiculo)
        THROW 50001, N'Ya existe otro vehículo con esa patente.', 1;

    UPDATE dbo.Vehiculos
    SET Nombre = @Nombre, [Año] = @Anio, Patente = @Patente, Estado = @Estado, IDTipoVehiculo = @IDTipoVehiculo
    WHERE IDVehiculo = @IDVehiculo;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Eliminar
    @IDVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.MisionVehiculo WHERE IDVehiculo = @IDVehiculo)
        THROW 50002, N'No se puede eliminar: el vehículo participó en misiones. Cambie su estado a "Fuera de servicio".', 1;

    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM dbo.DocumentacionVehiculo WHERE IDVehiculo = @IDVehiculo;
        DELETE FROM dbo.Vehiculos WHERE IDVehiculo = @IDVehiculo;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Vehiculos_Combo
    @SoloOperativos BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVehiculo AS Valor,
           v.Nombre + N' - ' + v.Patente + N' (' + v.Estado + N')' AS Texto
    FROM dbo.Vehiculos v
    WHERE @SoloOperativos = 0 OR v.Estado = N'Operativo'
    ORDER BY v.Nombre;
END
GO

-- -------------------------------------------------------------------------
-- Documentación de vehículos
-- Situacion (calculada): 'Vencido' | 'Próximo a vencer' | 'Vigente'
-- @Situacion de filtro: 'Vencido' | 'Proximo' | 'Vigente' | NULL (todos)
-- -------------------------------------------------------------------------

-- Sincroniza la columna Estado almacenada con la fecha actual
CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_ActualizarEstados
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.DocumentacionVehiculo
    SET Estado = CASE WHEN FechaVencimiento < CAST(GETDATE() AS DATE) THEN N'Vencido' ELSE N'Vigente' END
    WHERE Estado <> CASE WHEN FechaVencimiento < CAST(GETDATE() AS DATE) THEN N'Vencido' ELSE N'Vigente' END;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_Listar
    @IDVehiculo INT          = NULL,
    @Situacion  NVARCHAR(20) = NULL,
    @DiasAviso  INT          = 30
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);

    SELECT * FROM (
        SELECT d.IDDocumento, d.IDVehiculo, d.TipoDocumento, d.FechaEmision, d.FechaVencimiento, d.Estado,
               v.Nombre AS VehiculoNombre, v.Patente,
               DATEDIFF(DAY, @Hoy, d.FechaVencimiento) AS DiasParaVencer,
               CASE WHEN d.FechaVencimiento < @Hoy THEN N'Vencido'
                    WHEN d.FechaVencimiento <= DATEADD(DAY, @DiasAviso, @Hoy) THEN N'Próximo a vencer'
                    ELSE N'Vigente' END AS Situacion
        FROM dbo.DocumentacionVehiculo d
        INNER JOIN dbo.Vehiculos v ON v.IDVehiculo = d.IDVehiculo
        WHERE (@IDVehiculo IS NULL OR d.IDVehiculo = @IDVehiculo)
    ) x
    WHERE @Situacion IS NULL
       OR (@Situacion = N'Vencido' AND x.Situacion = N'Vencido')
       OR (@Situacion = N'Proximo' AND x.Situacion = N'Próximo a vencer')
       OR (@Situacion = N'Vigente' AND x.Situacion = N'Vigente')
    ORDER BY x.FechaVencimiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_Obtener
    @IDDocumento INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    SELECT d.IDDocumento, d.IDVehiculo, d.TipoDocumento, d.FechaEmision, d.FechaVencimiento, d.Estado,
           v.Nombre AS VehiculoNombre, v.Patente,
           DATEDIFF(DAY, @Hoy, d.FechaVencimiento) AS DiasParaVencer,
           CASE WHEN d.FechaVencimiento < @Hoy THEN N'Vencido'
                WHEN d.FechaVencimiento <= DATEADD(DAY, 30, @Hoy) THEN N'Próximo a vencer'
                ELSE N'Vigente' END AS Situacion
    FROM dbo.DocumentacionVehiculo d
    INNER JOIN dbo.Vehiculos v ON v.IDVehiculo = d.IDVehiculo
    WHERE d.IDDocumento = @IDDocumento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_Insertar
    @IDVehiculo       INT,
    @TipoDocumento    NVARCHAR(50),
    @FechaEmision     DATE,
    @FechaVencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaVencimiento <= @FechaEmision
        THROW 50003, N'La fecha de vencimiento debe ser posterior a la fecha de emisión.', 1;

    INSERT INTO dbo.DocumentacionVehiculo (IDVehiculo, TipoDocumento, FechaEmision, FechaVencimiento, Estado)
    VALUES (@IDVehiculo, @TipoDocumento, @FechaEmision, @FechaVencimiento,
            CASE WHEN @FechaVencimiento < CAST(GETDATE() AS DATE) THEN N'Vencido' ELSE N'Vigente' END);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_Actualizar
    @IDDocumento      INT,
    @IDVehiculo       INT,
    @TipoDocumento    NVARCHAR(50),
    @FechaEmision     DATE,
    @FechaVencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.DocumentacionVehiculo WHERE IDDocumento = @IDDocumento)
        THROW 50004, N'El documento no existe.', 1;
    IF @FechaVencimiento <= @FechaEmision
        THROW 50003, N'La fecha de vencimiento debe ser posterior a la fecha de emisión.', 1;

    UPDATE dbo.DocumentacionVehiculo
    SET IDVehiculo = @IDVehiculo, TipoDocumento = @TipoDocumento,
        FechaEmision = @FechaEmision, FechaVencimiento = @FechaVencimiento,
        Estado = CASE WHEN @FechaVencimiento < CAST(GETDATE() AS DATE) THEN N'Vencido' ELSE N'Vigente' END
    WHERE IDDocumento = @IDDocumento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_DocumentacionVehiculo_Eliminar
    @IDDocumento INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.DocumentacionVehiculo WHERE IDDocumento = @IDDocumento;
END
GO

/* =========================================================================
   MÓDULO EQUIPAMIENTO
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Listar
    @Texto                   NVARCHAR(100) = NULL,  -- código interno o nombre
    @Estado                  NVARCHAR(30)  = NULL,
    @IDTipoEquipamiento      INT           = NULL,
    @IDCategoriaEquipamiento INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEquipamiento, e.CodigoInterno, e.Nombre, e.Estado, e.FechaCompra,
           e.FechaUltimoMantenimiento, e.FechaProximoMantenimiento,
           e.IDTipoEquipamiento, e.IDCategoriaEquipamiento,
           t.Nombre AS TipoNombre, c.Nombre AS CategoriaNombre
    FROM dbo.Equipamiento e
    INNER JOIN dbo.TipoEquipamiento t ON t.IDTipoEquipamiento = e.IDTipoEquipamiento
    INNER JOIN dbo.CategoriaEquipamiento c ON c.IDCategoriaEquipamiento = e.IDCategoriaEquipamiento
    WHERE (@Texto IS NULL OR e.CodigoInterno LIKE N'%' + @Texto + N'%' OR e.Nombre LIKE N'%' + @Texto + N'%')
      AND (@Estado IS NULL OR e.Estado = @Estado)
      AND (@IDTipoEquipamiento IS NULL OR e.IDTipoEquipamiento = @IDTipoEquipamiento)
      AND (@IDCategoriaEquipamiento IS NULL OR e.IDCategoriaEquipamiento = @IDCategoriaEquipamiento)
    ORDER BY e.CodigoInterno;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Obtener
    @IDEquipamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEquipamiento, e.CodigoInterno, e.Nombre, e.Estado, e.FechaCompra,
           e.FechaUltimoMantenimiento, e.FechaProximoMantenimiento,
           e.IDTipoEquipamiento, e.IDCategoriaEquipamiento,
           t.Nombre AS TipoNombre, c.Nombre AS CategoriaNombre
    FROM dbo.Equipamiento e
    INNER JOIN dbo.TipoEquipamiento t ON t.IDTipoEquipamiento = e.IDTipoEquipamiento
    INNER JOIN dbo.CategoriaEquipamiento c ON c.IDCategoriaEquipamiento = e.IDCategoriaEquipamiento
    WHERE e.IDEquipamiento = @IDEquipamiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Insertar
    @CodigoInterno             NVARCHAR(20),
    @Nombre                    NVARCHAR(100),
    @Estado                    NVARCHAR(30),
    @FechaCompra               DATE = NULL,
    @FechaUltimoMantenimiento  DATE = NULL,
    @FechaProximoMantenimiento DATE = NULL,
    @IDTipoEquipamiento        INT,
    @IDCategoriaEquipamiento   INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE CodigoInterno = @CodigoInterno)
        THROW 50001, N'Ya existe un equipo con ese código interno.', 1;
    IF @FechaUltimoMantenimiento IS NOT NULL AND @FechaProximoMantenimiento IS NOT NULL
       AND @FechaProximoMantenimiento < @FechaUltimoMantenimiento
        THROW 50003, N'El próximo mantenimiento no puede ser anterior al último mantenimiento.', 1;

    INSERT INTO dbo.Equipamiento (CodigoInterno, Nombre, Estado, FechaCompra, FechaUltimoMantenimiento,
                                  FechaProximoMantenimiento, IDTipoEquipamiento, IDCategoriaEquipamiento)
    VALUES (@CodigoInterno, @Nombre, @Estado, @FechaCompra, @FechaUltimoMantenimiento,
            @FechaProximoMantenimiento, @IDTipoEquipamiento, @IDCategoriaEquipamiento);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Actualizar
    @IDEquipamiento            INT,
    @CodigoInterno             NVARCHAR(20),
    @Nombre                    NVARCHAR(100),
    @Estado                    NVARCHAR(30),
    @FechaCompra               DATE = NULL,
    @FechaUltimoMantenimiento  DATE = NULL,
    @FechaProximoMantenimiento DATE = NULL,
    @IDTipoEquipamiento        INT,
    @IDCategoriaEquipamiento   INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE IDEquipamiento = @IDEquipamiento)
        THROW 50004, N'El equipo no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE CodigoInterno = @CodigoInterno AND IDEquipamiento <> @IDEquipamiento)
        THROW 50001, N'Ya existe otro equipo con ese código interno.', 1;
    IF @FechaUltimoMantenimiento IS NOT NULL AND @FechaProximoMantenimiento IS NOT NULL
       AND @FechaProximoMantenimiento < @FechaUltimoMantenimiento
        THROW 50003, N'El próximo mantenimiento no puede ser anterior al último mantenimiento.', 1;

    UPDATE dbo.Equipamiento
    SET CodigoInterno = @CodigoInterno, Nombre = @Nombre, Estado = @Estado, FechaCompra = @FechaCompra,
        FechaUltimoMantenimiento = @FechaUltimoMantenimiento, FechaProximoMantenimiento = @FechaProximoMantenimiento,
        IDTipoEquipamiento = @IDTipoEquipamiento, IDCategoriaEquipamiento = @IDCategoriaEquipamiento
    WHERE IDEquipamiento = @IDEquipamiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Eliminar
    @IDEquipamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.MisionEquipamiento WHERE IDEquipamiento = @IDEquipamiento)
        THROW 50002, N'No se puede eliminar: el equipo fue utilizado en misiones. Cambie su estado a "Baja".', 1;
    DELETE FROM dbo.Equipamiento WHERE IDEquipamiento = @IDEquipamiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Equipamiento_Combo
    @SoloDisponibles BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEquipamiento AS Valor,
           e.CodigoInterno + N' - ' + e.Nombre + N' (' + e.Estado + N')' AS Texto
    FROM dbo.Equipamiento e
    WHERE (@SoloDisponibles = 1 AND e.Estado = N'Disponible')
       OR (@SoloDisponibles = 0 AND e.Estado <> N'Baja')
    ORDER BY e.CodigoInterno;
END
GO

/* =========================================================================
   MÓDULO OPERACIONES
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Incidentes
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Listar
    @Desde     DATE          = NULL,
    @Hasta     DATE          = NULL,
    @Severidad NVARCHAR(20)  = NULL,
    @Texto     NVARCHAR(100) = NULL   -- dirección o descripción
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.IDIncidente, i.FechaHora, i.Direccion, i.Descripcion, i.Severidad,
           (SELECT COUNT(*) FROM dbo.Misiones m WHERE m.IDIncidente = i.IDIncidente) AS CantidadMisiones
    FROM dbo.Incidentes i
    WHERE (@Desde IS NULL OR i.FechaHora >= @Desde)
      AND (@Hasta IS NULL OR i.FechaHora < DATEADD(DAY, 1, CAST(@Hasta AS DATETIME)))
      AND (@Severidad IS NULL OR i.Severidad = @Severidad)
      AND (@Texto IS NULL OR i.Direccion LIKE N'%' + @Texto + N'%' OR i.Descripcion LIKE N'%' + @Texto + N'%')
    ORDER BY i.FechaHora DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Obtener
    @IDIncidente INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.IDIncidente, i.FechaHora, i.Direccion, i.Descripcion, i.Severidad,
           (SELECT COUNT(*) FROM dbo.Misiones m WHERE m.IDIncidente = i.IDIncidente) AS CantidadMisiones
    FROM dbo.Incidentes i
    WHERE i.IDIncidente = @IDIncidente;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Insertar
    @FechaHora   DATETIME,
    @Direccion   NVARCHAR(200),
    @Descripcion NVARCHAR(500) = NULL,
    @Severidad   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Incidentes (FechaHora, Direccion, Descripcion, Severidad)
    VALUES (@FechaHora, @Direccion, @Descripcion, @Severidad);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Actualizar
    @IDIncidente INT,
    @FechaHora   DATETIME,
    @Direccion   NVARCHAR(200),
    @Descripcion NVARCHAR(500) = NULL,
    @Severidad   NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Incidentes WHERE IDIncidente = @IDIncidente)
        THROW 50004, N'El incidente no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Misiones WHERE IDIncidente = @IDIncidente AND FechaInicio < @FechaHora)
        THROW 50003, N'La fecha del incidente no puede ser posterior al inicio de sus misiones.', 1;

    UPDATE dbo.Incidentes
    SET FechaHora = @FechaHora, Direccion = @Direccion, Descripcion = @Descripcion, Severidad = @Severidad
    WHERE IDIncidente = @IDIncidente;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Eliminar
    @IDIncidente INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Misiones WHERE IDIncidente = @IDIncidente)
        THROW 50002, N'No se puede eliminar: el incidente tiene misiones asociadas. Elimine primero las misiones.', 1;
    DELETE FROM dbo.Incidentes WHERE IDIncidente = @IDIncidente;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Incidentes_Combo
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.IDIncidente AS Valor,
           N'#' + CAST(i.IDIncidente AS NVARCHAR(10)) + N' - ' + CONVERT(NVARCHAR(16), i.FechaHora, 103) + N' '
             + CONVERT(NVARCHAR(5), i.FechaHora, 108) + N' - ' + i.Direccion AS Texto
    FROM dbo.Incidentes i
    ORDER BY i.FechaHora DESC;
END
GO

-- -------------------------------------------------------------------------
-- Misiones
-- Estados válidos: 'En curso' | 'Finalizada' | 'Cancelada'
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Listar
    @Estado       NVARCHAR(30)  = NULL,
    @IDIncidente  INT           = NULL,
    @IDTipoMision INT           = NULL,
    @Texto        NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.IDMision, m.IDIncidente, m.IDTipoMision, m.Nombre, m.FechaInicio, m.FechaFin, m.Estado,
           i.Direccion AS IncidenteDireccion, i.FechaHora AS IncidenteFechaHora, i.Severidad AS IncidenteSeveridad,
           t.Nombre AS TipoMisionNombre,
           (SELECT COUNT(*) FROM dbo.MisionVoluntario x WHERE x.IDMision = m.IDMision) AS CantidadVoluntarios,
           (SELECT COUNT(*) FROM dbo.MisionVehiculo x WHERE x.IDMision = m.IDMision) AS CantidadVehiculos,
           (SELECT COUNT(*) FROM dbo.MisionEquipamiento x WHERE x.IDMision = m.IDMision) AS CantidadEquipamiento
    FROM dbo.Misiones m
    INNER JOIN dbo.Incidentes i ON i.IDIncidente = m.IDIncidente
    INNER JOIN dbo.TipoMision t ON t.IDTipoMision = m.IDTipoMision
    WHERE (@Estado IS NULL OR m.Estado = @Estado)
      AND (@IDIncidente IS NULL OR m.IDIncidente = @IDIncidente)
      AND (@IDTipoMision IS NULL OR m.IDTipoMision = @IDTipoMision)
      AND (@Texto IS NULL OR m.Nombre LIKE N'%' + @Texto + N'%' OR i.Direccion LIKE N'%' + @Texto + N'%')
    ORDER BY m.FechaInicio DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Obtener
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.IDMision, m.IDIncidente, m.IDTipoMision, m.Nombre, m.FechaInicio, m.FechaFin, m.Estado,
           i.Direccion AS IncidenteDireccion, i.FechaHora AS IncidenteFechaHora, i.Severidad AS IncidenteSeveridad,
           t.Nombre AS TipoMisionNombre,
           (SELECT COUNT(*) FROM dbo.MisionVoluntario x WHERE x.IDMision = m.IDMision) AS CantidadVoluntarios,
           (SELECT COUNT(*) FROM dbo.MisionVehiculo x WHERE x.IDMision = m.IDMision) AS CantidadVehiculos,
           (SELECT COUNT(*) FROM dbo.MisionEquipamiento x WHERE x.IDMision = m.IDMision) AS CantidadEquipamiento
    FROM dbo.Misiones m
    INNER JOIN dbo.Incidentes i ON i.IDIncidente = m.IDIncidente
    INNER JOIN dbo.TipoMision t ON t.IDTipoMision = m.IDTipoMision
    WHERE m.IDMision = @IDMision;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Validar
    @IDIncidente INT,
    @FechaInicio DATETIME,
    @FechaFin    DATETIME = NULL,
    @Estado      NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    IF @Estado NOT IN (N'En curso', N'Finalizada', N'Cancelada')
        THROW 50020, N'Estado de misión inválido. Valores permitidos: En curso, Finalizada, Cancelada.', 1;
    IF @FechaFin IS NOT NULL AND @FechaFin < @FechaInicio
        THROW 50003, N'La fecha de fin no puede ser anterior a la fecha de inicio.', 1;
    IF @Estado = N'Finalizada' AND @FechaFin IS NULL
        THROW 50021, N'Una misión finalizada debe tener fecha de fin.', 1;
    IF @Estado = N'En curso' AND @FechaFin IS NOT NULL
        THROW 50022, N'Una misión en curso no puede tener fecha de fin. Cambie el estado a "Finalizada".', 1;
    IF EXISTS (SELECT 1 FROM dbo.Incidentes WHERE IDIncidente = @IDIncidente AND FechaHora > @FechaInicio)
        THROW 50023, N'La misión no puede iniciar antes de la fecha y hora del incidente.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Insertar
    @IDIncidente  INT,
    @IDTipoMision INT,
    @Nombre       NVARCHAR(100),
    @FechaInicio  DATETIME,
    @FechaFin     DATETIME = NULL,
    @Estado       NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Misiones_Validar @IDIncidente, @FechaInicio, @FechaFin, @Estado;

    INSERT INTO dbo.Misiones (IDIncidente, IDTipoMision, Nombre, FechaInicio, FechaFin, Estado)
    VALUES (@IDIncidente, @IDTipoMision, @Nombre, @FechaInicio, @FechaFin, @Estado);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Actualizar
    @IDMision     INT,
    @IDIncidente  INT,
    @IDTipoMision INT,
    @Nombre       NVARCHAR(100),
    @FechaInicio  DATETIME,
    @FechaFin     DATETIME = NULL,
    @Estado       NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Misiones WHERE IDMision = @IDMision)
        THROW 50004, N'La misión no existe.', 1;
    EXEC dbo.sp_Misiones_Validar @IDIncidente, @FechaInicio, @FechaFin, @Estado;

    UPDATE dbo.Misiones
    SET IDIncidente = @IDIncidente, IDTipoMision = @IDTipoMision, Nombre = @Nombre,
        FechaInicio = @FechaInicio, FechaFin = @FechaFin, Estado = @Estado
    WHERE IDMision = @IDMision;
END
GO

-- Elimina la misión junto con sus asignaciones (transacción)
CREATE OR ALTER PROCEDURE dbo.sp_Misiones_Eliminar
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        DELETE FROM dbo.MisionVoluntario   WHERE IDMision = @IDMision;
        DELETE FROM dbo.MisionVehiculo     WHERE IDMision = @IDMision;
        DELETE FROM dbo.MisionEquipamiento WHERE IDMision = @IDMision;
        DELETE FROM dbo.Misiones           WHERE IDMision = @IDMision;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

-- -------------------------------------------------------------------------
-- Asignaciones de recursos a misiones
-- Todas las consultas devuelven: ID, Descripcion, Detalle, Estado
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Misiones_ValidarAsignacion
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Estado NVARCHAR(30) = (SELECT Estado FROM dbo.Misiones WHERE IDMision = @IDMision);
    IF @Estado IS NULL
        THROW 50004, N'La misión no existe.', 1;
    IF @Estado = N'Cancelada'
        THROW 50030, N'No se pueden asignar recursos a una misión cancelada.', 1;
END
GO

-- Voluntarios ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_MisionVoluntario_Listar
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVoluntario AS ID,
           v.Apellido + N', ' + v.Nombre AS Descripcion,
           N'DNI ' + v.DNI + ISNULL(N' - ' + ra.Nombre, N'') AS Detalle,
           v.Estado
    FROM dbo.MisionVoluntario mv
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = mv.IDVoluntario
    OUTER APPLY (SELECT TOP 1 r.Nombre FROM dbo.HistorialRangos hr
                 INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
                 WHERE hr.IDVoluntario = v.IDVoluntario AND hr.FechaHasta IS NULL) ra
    WHERE mv.IDMision = @IDMision
    ORDER BY v.Apellido, v.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionVoluntario_Agregar
    @IDMision     INT,
    @IDVoluntario INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Misiones_ValidarAsignacion @IDMision;
    IF EXISTS (SELECT 1 FROM dbo.MisionVoluntario WHERE IDMision = @IDMision AND IDVoluntario = @IDVoluntario)
        THROW 50031, N'El voluntario ya está asignado a esta misión.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE IDVoluntario = @IDVoluntario AND Estado = N'Activo')
        THROW 50032, N'Solo se pueden asignar voluntarios en estado "Activo".', 1;

    INSERT INTO dbo.MisionVoluntario (IDMision, IDVoluntario) VALUES (@IDMision, @IDVoluntario);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionVoluntario_Quitar
    @IDMision     INT,
    @IDVoluntario INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.MisionVoluntario WHERE IDMision = @IDMision AND IDVoluntario = @IDVoluntario;
END
GO

-- Vehículos ------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_MisionVehiculo_Listar
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IDVehiculo AS ID,
           v.Nombre AS Descripcion,
           N'Patente ' + v.Patente + N' - ' + t.Nombre AS Detalle,
           v.Estado
    FROM dbo.MisionVehiculo mv
    INNER JOIN dbo.Vehiculos v ON v.IDVehiculo = mv.IDVehiculo
    INNER JOIN dbo.TipoVehiculo t ON t.IDTipoVehiculo = v.IDTipoVehiculo
    WHERE mv.IDMision = @IDMision
    ORDER BY v.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionVehiculo_Agregar
    @IDMision   INT,
    @IDVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Misiones_ValidarAsignacion @IDMision;
    IF EXISTS (SELECT 1 FROM dbo.MisionVehiculo WHERE IDMision = @IDMision AND IDVehiculo = @IDVehiculo)
        THROW 50031, N'El vehículo ya está asignado a esta misión.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Vehiculos WHERE IDVehiculo = @IDVehiculo AND Estado = N'Operativo')
        THROW 50033, N'Solo se pueden asignar vehículos en estado "Operativo".', 1;

    INSERT INTO dbo.MisionVehiculo (IDMision, IDVehiculo) VALUES (@IDMision, @IDVehiculo);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionVehiculo_Quitar
    @IDMision   INT,
    @IDVehiculo INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.MisionVehiculo WHERE IDMision = @IDMision AND IDVehiculo = @IDVehiculo;
END
GO

-- Equipamiento ---------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_MisionEquipamiento_Listar
    @IDMision INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEquipamiento AS ID,
           e.CodigoInterno + N' - ' + e.Nombre AS Descripcion,
           t.Nombre + N' / ' + c.Nombre AS Detalle,
           e.Estado
    FROM dbo.MisionEquipamiento me
    INNER JOIN dbo.Equipamiento e ON e.IDEquipamiento = me.IDEquipamiento
    INNER JOIN dbo.TipoEquipamiento t ON t.IDTipoEquipamiento = e.IDTipoEquipamiento
    INNER JOIN dbo.CategoriaEquipamiento c ON c.IDCategoriaEquipamiento = e.IDCategoriaEquipamiento
    WHERE me.IDMision = @IDMision
    ORDER BY e.CodigoInterno;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionEquipamiento_Agregar
    @IDMision       INT,
    @IDEquipamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Misiones_ValidarAsignacion @IDMision;
    IF EXISTS (SELECT 1 FROM dbo.MisionEquipamiento WHERE IDMision = @IDMision AND IDEquipamiento = @IDEquipamiento)
        THROW 50031, N'El equipo ya está asignado a esta misión.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Equipamiento WHERE IDEquipamiento = @IDEquipamiento AND Estado IN (N'Disponible', N'En uso'))
        THROW 50034, N'Solo se puede asignar equipamiento en estado "Disponible" o "En uso".', 1;

    INSERT INTO dbo.MisionEquipamiento (IDMision, IDEquipamiento) VALUES (@IDMision, @IDEquipamiento);
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MisionEquipamiento_Quitar
    @IDMision       INT,
    @IDEquipamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.MisionEquipamiento WHERE IDMision = @IDMision AND IDEquipamiento = @IDEquipamiento;
END
GO

/* =========================================================================
   MÓDULO CAPACITACIÓN
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Entrenamientos_Listar
    @IDVoluntario        INT  = NULL,
    @IDTipoEntrenamiento INT  = NULL,
    @Desde               DATE = NULL,
    @Hasta               DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEntrenamiento, e.IDTipoEntrenamiento, e.IDVoluntario, e.Fecha, e.Observaciones,
           t.Nombre AS TipoNombre,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre
    FROM dbo.Entrenamientos e
    INNER JOIN dbo.TipoEntrenamiento t ON t.IDTipoEntrenamiento = e.IDTipoEntrenamiento
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = e.IDVoluntario
    WHERE (@IDVoluntario IS NULL OR e.IDVoluntario = @IDVoluntario)
      AND (@IDTipoEntrenamiento IS NULL OR e.IDTipoEntrenamiento = @IDTipoEntrenamiento)
      AND (@Desde IS NULL OR e.Fecha >= @Desde)
      AND (@Hasta IS NULL OR e.Fecha <= @Hasta)
    ORDER BY e.Fecha DESC, v.Apellido;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Entrenamientos_Obtener
    @IDEntrenamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.IDEntrenamiento, e.IDTipoEntrenamiento, e.IDVoluntario, e.Fecha, e.Observaciones,
           t.Nombre AS TipoNombre,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre
    FROM dbo.Entrenamientos e
    INNER JOIN dbo.TipoEntrenamiento t ON t.IDTipoEntrenamiento = e.IDTipoEntrenamiento
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = e.IDVoluntario
    WHERE e.IDEntrenamiento = @IDEntrenamiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Entrenamientos_Insertar
    @IDTipoEntrenamiento INT,
    @IDVoluntario        INT,
    @Fecha               DATE,
    @Observaciones       NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM dbo.Entrenamientos
               WHERE IDVoluntario = @IDVoluntario AND IDTipoEntrenamiento = @IDTipoEntrenamiento AND Fecha = @Fecha)
        THROW 50001, N'El voluntario ya tiene registrado ese tipo de entrenamiento en esa fecha.', 1;

    INSERT INTO dbo.Entrenamientos (IDTipoEntrenamiento, IDVoluntario, Fecha, Observaciones)
    VALUES (@IDTipoEntrenamiento, @IDVoluntario, @Fecha, @Observaciones);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Entrenamientos_Actualizar
    @IDEntrenamiento     INT,
    @IDTipoEntrenamiento INT,
    @IDVoluntario        INT,
    @Fecha               DATE,
    @Observaciones       NVARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Entrenamientos WHERE IDEntrenamiento = @IDEntrenamiento)
        THROW 50004, N'El entrenamiento no existe.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Entrenamientos
               WHERE IDVoluntario = @IDVoluntario AND IDTipoEntrenamiento = @IDTipoEntrenamiento AND Fecha = @Fecha
                 AND IDEntrenamiento <> @IDEntrenamiento)
        THROW 50001, N'El voluntario ya tiene registrado ese tipo de entrenamiento en esa fecha.', 1;

    UPDATE dbo.Entrenamientos
    SET IDTipoEntrenamiento = @IDTipoEntrenamiento, IDVoluntario = @IDVoluntario,
        Fecha = @Fecha, Observaciones = @Observaciones
    WHERE IDEntrenamiento = @IDEntrenamiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Entrenamientos_Eliminar
    @IDEntrenamiento INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Entrenamientos WHERE IDEntrenamiento = @IDEntrenamiento;
END
GO

/* =========================================================================
   MÓDULO GUARDIAS
   Una guardia cuyo HoraFin es menor o igual a HoraInicio termina al día
   siguiente (ej.: 20:00 a 08:00).
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Listar
    @IDVoluntario INT  = NULL,
    @Desde        DATE = NULL,
    @Hasta        DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ahora DATETIME = GETDATE();
    SELECT g.IDGuardia, g.IDVoluntario, g.Fecha, g.HoraInicio, g.HoraFin,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           CAST(CASE WHEN @Ahora >= x.Inicio AND @Ahora < x.Fin THEN 1 ELSE 0 END AS BIT) AS EnCurso
    FROM dbo.Guardias g
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = g.IDVoluntario
    CROSS APPLY (SELECT CAST(g.Fecha AS DATETIME) + CAST(g.HoraInicio AS DATETIME) AS Inicio,
                        CAST(g.Fecha AS DATETIME) + CAST(g.HoraFin AS DATETIME)
                          + CASE WHEN g.HoraFin <= g.HoraInicio THEN 1 ELSE 0 END AS Fin) x
    WHERE (@IDVoluntario IS NULL OR g.IDVoluntario = @IDVoluntario)
      AND (@Desde IS NULL OR g.Fecha >= @Desde)
      AND (@Hasta IS NULL OR g.Fecha <= @Hasta)
    ORDER BY g.Fecha DESC, g.HoraInicio, v.Apellido;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Obtener
    @IDGuardia INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ahora DATETIME = GETDATE();
    SELECT g.IDGuardia, g.IDVoluntario, g.Fecha, g.HoraInicio, g.HoraFin,
           v.Apellido + N', ' + v.Nombre AS VoluntarioNombre,
           CAST(CASE WHEN @Ahora >= x.Inicio AND @Ahora < x.Fin THEN 1 ELSE 0 END AS BIT) AS EnCurso
    FROM dbo.Guardias g
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = g.IDVoluntario
    CROSS APPLY (SELECT CAST(g.Fecha AS DATETIME) + CAST(g.HoraInicio AS DATETIME) AS Inicio,
                        CAST(g.Fecha AS DATETIME) + CAST(g.HoraFin AS DATETIME)
                          + CASE WHEN g.HoraFin <= g.HoraInicio THEN 1 ELSE 0 END AS Fin) x
    WHERE g.IDGuardia = @IDGuardia;
END
GO

-- Verifica que el voluntario no tenga otra guardia que se superponga en el tiempo
CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Validar
    @IDGuardia    INT = NULL,
    @IDVoluntario INT,
    @Fecha        DATE,
    @HoraInicio   TIME,
    @HoraFin      TIME
AS
BEGIN
    SET NOCOUNT ON;
    IF @HoraInicio = @HoraFin
        THROW 50040, N'La hora de inicio y la hora de fin no pueden ser iguales.', 1;

    DECLARE @Inicio DATETIME = CAST(@Fecha AS DATETIME) + CAST(@HoraInicio AS DATETIME);
    DECLARE @Fin    DATETIME = CAST(@Fecha AS DATETIME) + CAST(@HoraFin AS DATETIME)
                               + CASE WHEN @HoraFin <= @HoraInicio THEN 1 ELSE 0 END;

    IF EXISTS (SELECT 1
               FROM dbo.Guardias g
               CROSS APPLY (SELECT CAST(g.Fecha AS DATETIME) + CAST(g.HoraInicio AS DATETIME) AS Inicio,
                                   CAST(g.Fecha AS DATETIME) + CAST(g.HoraFin AS DATETIME)
                                     + CASE WHEN g.HoraFin <= g.HoraInicio THEN 1 ELSE 0 END AS Fin) x
               WHERE g.IDVoluntario = @IDVoluntario
                 AND g.IDGuardia <> ISNULL(@IDGuardia, 0)
                 AND g.Fecha BETWEEN DATEADD(DAY, -1, @Fecha) AND DATEADD(DAY, 1, @Fecha)
                 AND x.Inicio < @Fin AND x.Fin > @Inicio)
        THROW 50041, N'El voluntario ya tiene una guardia asignada que se superpone con ese horario.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Insertar
    @IDVoluntario INT,
    @Fecha        DATE,
    @HoraInicio   TIME,
    @HoraFin      TIME
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Guardias_Validar NULL, @IDVoluntario, @Fecha, @HoraInicio, @HoraFin;

    INSERT INTO dbo.Guardias (IDVoluntario, Fecha, HoraInicio, HoraFin)
    VALUES (@IDVoluntario, @Fecha, @HoraInicio, @HoraFin);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Actualizar
    @IDGuardia    INT,
    @IDVoluntario INT,
    @Fecha        DATE,
    @HoraInicio   TIME,
    @HoraFin      TIME
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Guardias WHERE IDGuardia = @IDGuardia)
        THROW 50004, N'La guardia no existe.', 1;
    EXEC dbo.sp_Guardias_Validar @IDGuardia, @IDVoluntario, @Fecha, @HoraInicio, @HoraFin;

    UPDATE dbo.Guardias
    SET IDVoluntario = @IDVoluntario, Fecha = @Fecha, HoraInicio = @HoraInicio, HoraFin = @HoraFin
    WHERE IDGuardia = @IDGuardia;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Guardias_Eliminar
    @IDGuardia INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Guardias WHERE IDGuardia = @IDGuardia;
END
GO

/* =========================================================================
   MÓDULO FINANZAS
   ========================================================================= */

-- -------------------------------------------------------------------------
-- Aportes
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Aportes_Listar
    @Desde        DATE = NULL,
    @Hasta        DATE = NULL,
    @IDTipoAporte INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.IDAporte, a.IDTipoAporte, a.Fecha, a.Monto, a.Descripcion, t.Nombre AS TipoNombre
    FROM dbo.Aportes a
    INNER JOIN dbo.TipoAporte t ON t.IDTipoAporte = a.IDTipoAporte
    WHERE (@Desde IS NULL OR a.Fecha >= @Desde)
      AND (@Hasta IS NULL OR a.Fecha <= @Hasta)
      AND (@IDTipoAporte IS NULL OR a.IDTipoAporte = @IDTipoAporte)
    ORDER BY a.Fecha DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Aportes_Obtener
    @IDAporte INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.IDAporte, a.IDTipoAporte, a.Fecha, a.Monto, a.Descripcion, t.Nombre AS TipoNombre
    FROM dbo.Aportes a
    INNER JOIN dbo.TipoAporte t ON t.IDTipoAporte = a.IDTipoAporte
    WHERE a.IDAporte = @IDAporte;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Aportes_Insertar
    @IDTipoAporte INT,
    @Fecha        DATE,
    @Monto        DECIMAL(12,2),
    @Descripcion  NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @Monto <= 0
        THROW 50050, N'El monto debe ser mayor a cero.', 1;

    INSERT INTO dbo.Aportes (IDTipoAporte, Fecha, Monto, Descripcion)
    VALUES (@IDTipoAporte, @Fecha, @Monto, @Descripcion);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Aportes_Actualizar
    @IDAporte     INT,
    @IDTipoAporte INT,
    @Fecha        DATE,
    @Monto        DECIMAL(12,2),
    @Descripcion  NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Aportes WHERE IDAporte = @IDAporte)
        THROW 50004, N'El aporte no existe.', 1;
    IF @Monto <= 0
        THROW 50050, N'El monto debe ser mayor a cero.', 1;

    UPDATE dbo.Aportes
    SET IDTipoAporte = @IDTipoAporte, Fecha = @Fecha, Monto = @Monto, Descripcion = @Descripcion
    WHERE IDAporte = @IDAporte;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Aportes_Eliminar
    @IDAporte INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Aportes WHERE IDAporte = @IDAporte;
END
GO

-- -------------------------------------------------------------------------
-- Gastos
-- Regla: debe indicarse un voluntario autorizador existente (y no dado de baja).
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Listar
    @Desde        DATE = NULL,
    @Hasta        DATE = NULL,
    @IDTipoGasto  INT  = NULL,
    @IDVoluntario INT  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT g.IDGasto, g.Fecha, g.Monto, g.Descripcion, g.IDTipoGasto, g.IDVoluntarioAutorizador,
           t.Nombre AS TipoNombre,
           v.Apellido + N', ' + v.Nombre AS AutorizadorNombre
    FROM dbo.Gastos g
    INNER JOIN dbo.TipoGasto t ON t.IDTipoGasto = g.IDTipoGasto
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = g.IDVoluntarioAutorizador
    WHERE (@Desde IS NULL OR g.Fecha >= @Desde)
      AND (@Hasta IS NULL OR g.Fecha <= @Hasta)
      AND (@IDTipoGasto IS NULL OR g.IDTipoGasto = @IDTipoGasto)
      AND (@IDVoluntario IS NULL OR g.IDVoluntarioAutorizador = @IDVoluntario)
    ORDER BY g.Fecha DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Obtener
    @IDGasto INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT g.IDGasto, g.Fecha, g.Monto, g.Descripcion, g.IDTipoGasto, g.IDVoluntarioAutorizador,
           t.Nombre AS TipoNombre,
           v.Apellido + N', ' + v.Nombre AS AutorizadorNombre
    FROM dbo.Gastos g
    INNER JOIN dbo.TipoGasto t ON t.IDTipoGasto = g.IDTipoGasto
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = g.IDVoluntarioAutorizador
    WHERE g.IDGasto = @IDGasto;
END
GO

-- @IDGasto: NULL en altas. En modificaciones se permite conservar un autorizador
-- que fue dado de baja después de autorizar el gasto.
CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Validar
    @IDGasto                 INT = NULL,
    @Monto                   DECIMAL(12,2),
    @IDVoluntarioAutorizador INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @Monto <= 0
        THROW 50050, N'El monto debe ser mayor a cero.', 1;
    IF NOT EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE IDVoluntario = @IDVoluntarioAutorizador)
        THROW 50051, N'Debe seleccionar un voluntario autorizador existente.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Voluntarios WHERE IDVoluntario = @IDVoluntarioAutorizador AND Estado = N'Baja')
       AND NOT EXISTS (SELECT 1 FROM dbo.Gastos WHERE IDGasto = @IDGasto AND IDVoluntarioAutorizador = @IDVoluntarioAutorizador)
        THROW 50052, N'El voluntario autorizador está dado de baja.', 1;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Insertar
    @Fecha                   DATE,
    @Monto                   DECIMAL(12,2),
    @Descripcion             NVARCHAR(250) = NULL,
    @IDTipoGasto             INT,
    @IDVoluntarioAutorizador INT
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_Gastos_Validar NULL, @Monto, @IDVoluntarioAutorizador;

    INSERT INTO dbo.Gastos (Fecha, Monto, Descripcion, IDTipoGasto, IDVoluntarioAutorizador)
    VALUES (@Fecha, @Monto, @Descripcion, @IDTipoGasto, @IDVoluntarioAutorizador);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Actualizar
    @IDGasto                 INT,
    @Fecha                   DATE,
    @Monto                   DECIMAL(12,2),
    @Descripcion             NVARCHAR(250) = NULL,
    @IDTipoGasto             INT,
    @IDVoluntarioAutorizador INT
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.Gastos WHERE IDGasto = @IDGasto)
        THROW 50004, N'El gasto no existe.', 1;
    EXEC dbo.sp_Gastos_Validar @IDGasto, @Monto, @IDVoluntarioAutorizador;

    UPDATE dbo.Gastos
    SET Fecha = @Fecha, Monto = @Monto, Descripcion = @Descripcion,
        IDTipoGasto = @IDTipoGasto, IDVoluntarioAutorizador = @IDVoluntarioAutorizador
    WHERE IDGasto = @IDGasto;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Gastos_Eliminar
    @IDGasto INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM dbo.Gastos WHERE IDGasto = @IDGasto;
END
GO

-- -------------------------------------------------------------------------
-- Movimientos de caja
-- TipoMovimiento: únicamente 'Ingreso' o 'Egreso' (además hay CHECK en la tabla)
-- Regla: un egreso no puede dejar la caja con saldo negativo.
-- -------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Listar
    @IDCaja         INT          = NULL,
    @Desde          DATE         = NULL,
    @Hasta          DATE         = NULL,
    @TipoMovimiento NVARCHAR(10) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.IDMovimiento, m.IDCaja, m.Fecha, m.TipoMovimiento, m.Monto, m.Concepto, c.Nombre AS CajaNombre
    FROM dbo.MovimientoCaja m
    INNER JOIN dbo.Caja c ON c.IDCaja = m.IDCaja
    WHERE (@IDCaja IS NULL OR m.IDCaja = @IDCaja)
      AND (@Desde IS NULL OR m.Fecha >= @Desde)
      AND (@Hasta IS NULL OR m.Fecha < DATEADD(DAY, 1, CAST(@Hasta AS DATETIME)))
      AND (@TipoMovimiento IS NULL OR m.TipoMovimiento = @TipoMovimiento)
    ORDER BY m.Fecha DESC, m.IDMovimiento DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Obtener
    @IDMovimiento INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.IDMovimiento, m.IDCaja, m.Fecha, m.TipoMovimiento, m.Monto, m.Concepto, c.Nombre AS CajaNombre
    FROM dbo.MovimientoCaja m
    INNER JOIN dbo.Caja c ON c.IDCaja = m.IDCaja
    WHERE m.IDMovimiento = @IDMovimiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Validar
    @IDMovimiento   INT = NULL,
    @IDCaja         INT,
    @TipoMovimiento NVARCHAR(10),
    @Monto          DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF @TipoMovimiento NOT IN (N'Ingreso', N'Egreso')
        THROW 50060, N'El tipo de movimiento solo puede ser "Ingreso" o "Egreso".', 1;
    IF @Monto <= 0
        THROW 50050, N'El monto debe ser mayor a cero.', 1;

    -- Saldo de la caja sin contar el movimiento que se está editando
    DECLARE @Saldo DECIMAL(14,2) =
        ISNULL((SELECT SUM(CASE WHEN TipoMovimiento = N'Ingreso' THEN Monto ELSE -Monto END)
                FROM dbo.MovimientoCaja
                WHERE IDCaja = @IDCaja AND IDMovimiento <> ISNULL(@IDMovimiento, 0)), 0);

    IF @TipoMovimiento = N'Egreso' AND @Saldo - @Monto < 0
    BEGIN
        DECLARE @Msg NVARCHAR(300) = N'Saldo insuficiente: el egreso deja la caja con saldo negativo. Saldo disponible: $ '
                                   + FORMAT(@Saldo, N'N2', N'es-AR') + N'.';
        THROW 50061, @Msg, 1;
    END
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Insertar
    @IDCaja         INT,
    @Fecha          DATETIME,
    @TipoMovimiento NVARCHAR(10),
    @Monto          DECIMAL(12,2),
    @Concepto       NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    EXEC dbo.sp_MovimientoCaja_Validar NULL, @IDCaja, @TipoMovimiento, @Monto;

    INSERT INTO dbo.MovimientoCaja (IDCaja, Fecha, TipoMovimiento, Monto, Concepto)
    VALUES (@IDCaja, @Fecha, @TipoMovimiento, @Monto, @Concepto);
    SELECT CAST(SCOPE_IDENTITY() AS INT) AS ID;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Actualizar
    @IDMovimiento   INT,
    @IDCaja         INT,
    @Fecha          DATETIME,
    @TipoMovimiento NVARCHAR(10),
    @Monto          DECIMAL(12,2),
    @Concepto       NVARCHAR(250) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS (SELECT 1 FROM dbo.MovimientoCaja WHERE IDMovimiento = @IDMovimiento)
        THROW 50004, N'El movimiento no existe.', 1;
    EXEC dbo.sp_MovimientoCaja_Validar @IDMovimiento, @IDCaja, @TipoMovimiento, @Monto;

    UPDATE dbo.MovimientoCaja
    SET IDCaja = @IDCaja, Fecha = @Fecha, TipoMovimiento = @TipoMovimiento, Monto = @Monto, Concepto = @Concepto
    WHERE IDMovimiento = @IDMovimiento;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_MovimientoCaja_Eliminar
    @IDMovimiento INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IDCaja INT, @Tipo NVARCHAR(10), @Monto DECIMAL(12,2);
    SELECT @IDCaja = IDCaja, @Tipo = TipoMovimiento, @Monto = Monto
    FROM dbo.MovimientoCaja WHERE IDMovimiento = @IDMovimiento;

    -- Quitar un ingreso no puede dejar la caja en negativo
    IF @Tipo = N'Ingreso'
       AND ISNULL((SELECT SUM(CASE WHEN TipoMovimiento = N'Ingreso' THEN Monto ELSE -Monto END)
                   FROM dbo.MovimientoCaja WHERE IDCaja = @IDCaja), 0) - @Monto < 0
        THROW 50062, N'No se puede eliminar el ingreso: la caja quedaría con saldo negativo.', 1;

    DELETE FROM dbo.MovimientoCaja WHERE IDMovimiento = @IDMovimiento;
END
GO

-- Saldo actual de cada caja
CREATE OR ALTER PROCEDURE dbo.sp_Caja_Saldos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.IDCaja, c.Nombre,
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto END), 0) AS TotalIngresos,
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Egreso'  THEN m.Monto END), 0) AS TotalEgresos,
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto ELSE -m.Monto END), 0) AS Saldo,
           COUNT(m.IDMovimiento) AS CantidadMovimientos
    FROM dbo.Caja c
    LEFT JOIN dbo.MovimientoCaja m ON m.IDCaja = c.IDCaja
    GROUP BY c.IDCaja, c.Nombre
    ORDER BY c.Nombre;
END
GO

/* =========================================================================
   DASHBOARD
   ========================================================================= */
CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_Indicadores
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    DECLARE @Ahora DATETIME = GETDATE();
    DECLARE @InicioMes DATE = DATEFROMPARTS(YEAR(@Hoy), MONTH(@Hoy), 1);
    DECLARE @InicioMesSig DATE = DATEADD(MONTH, 1, @InicioMes);

    SELECT
        (SELECT COUNT(*) FROM dbo.Voluntarios WHERE Estado = N'Activo') AS VoluntariosActivos,
        (SELECT COUNT(*) FROM dbo.Voluntarios WHERE Estado <> N'Baja') AS VoluntariosTotales,
        (SELECT COUNT(*) FROM dbo.Vehiculos WHERE Estado = N'Operativo') AS VehiculosOperativos,
        (SELECT COUNT(*) FROM dbo.Vehiculos) AS VehiculosTotales,
        (SELECT COUNT(*) FROM dbo.Equipamiento WHERE Estado = N'Disponible') AS EquipamientoDisponible,
        (SELECT COUNT(*) FROM dbo.Equipamiento WHERE Estado <> N'Baja') AS EquipamientoTotal,
        (SELECT COUNT(*) FROM dbo.Misiones WHERE Estado = N'En curso') AS MisionesEnCurso,
        (SELECT COUNT(*)
           FROM dbo.Guardias g
           CROSS APPLY (SELECT CAST(g.Fecha AS DATETIME) + CAST(g.HoraInicio AS DATETIME) AS Inicio,
                               CAST(g.Fecha AS DATETIME) + CAST(g.HoraFin AS DATETIME)
                                 + CASE WHEN g.HoraFin <= g.HoraInicio THEN 1 ELSE 0 END AS Fin) x
           WHERE g.Fecha BETWEEN DATEADD(DAY, -1, @Hoy) AND @Hoy
             AND @Ahora >= x.Inicio AND @Ahora < x.Fin) AS GuardiasActivas,
        (SELECT COUNT(*) FROM dbo.Guardias WHERE Fecha = @Hoy) AS GuardiasHoy,
        ISNULL((SELECT SUM(CASE WHEN TipoMovimiento = N'Ingreso' THEN Monto ELSE -Monto END)
                FROM dbo.MovimientoCaja), 0) AS SaldoTotalCajas,
        ISNULL((SELECT SUM(Monto) FROM dbo.Gastos  WHERE Fecha >= @InicioMes AND Fecha < @InicioMesSig), 0) AS GastosMes,
        ISNULL((SELECT SUM(Monto) FROM dbo.Aportes WHERE Fecha >= @InicioMes AND Fecha < @InicioMesSig), 0) AS AportesMes,
        (SELECT COUNT(*) FROM dbo.DocumentacionVehiculo WHERE FechaVencimiento < @Hoy) AS DocumentosVencidos,
        (SELECT COUNT(*) FROM dbo.DocumentacionVehiculo
          WHERE FechaVencimiento >= @Hoy AND FechaVencimiento <= DATEADD(DAY, 30, @Hoy)) AS DocumentosPorVencer,
        (SELECT COUNT(*) FROM dbo.Equipamiento
          WHERE Estado <> N'Baja' AND FechaProximoMantenimiento <= DATEADD(DAY, 30, @Hoy)) AS MantenimientosProximos;
END
GO

-- Aportes vs. gastos de los últimos @Meses meses (incluye el actual)
CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_FinanzasMensuales
    @Meses INT = 12
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Inicio DATE = DATEADD(MONTH, -(@Meses - 1), DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1));

    WITH Meses AS (
        SELECT 0 AS N, @Inicio AS Mes
        UNION ALL
        SELECT N + 1, DATEADD(MONTH, 1, Mes) FROM Meses WHERE N + 1 < @Meses
    )
    SELECT FORMAT(m.Mes, N'MM/yyyy') AS Periodo,
           ISNULL((SELECT SUM(a.Monto) FROM dbo.Aportes a
                   WHERE a.Fecha >= m.Mes AND a.Fecha < DATEADD(MONTH, 1, m.Mes)), 0) AS Aportes,
           ISNULL((SELECT SUM(g.Monto) FROM dbo.Gastos g
                   WHERE g.Fecha >= m.Mes AND g.Fecha < DATEADD(MONTH, 1, m.Mes)), 0) AS Gastos
    FROM Meses m
    ORDER BY m.Mes
    OPTION (MAXRECURSION 120);
END
GO

-- Serie genérica Etiqueta/Valor para gráficos de torta/barras
CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_MisionesPorTipo
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Nombre AS Etiqueta, COUNT(m.IDMision) AS Valor
    FROM dbo.TipoMision t
    LEFT JOIN dbo.Misiones m ON m.IDTipoMision = t.IDTipoMision
    GROUP BY t.Nombre
    ORDER BY t.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_EquipamientoPorEstado
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Estado AS Etiqueta, COUNT(*) AS Valor
    FROM dbo.Equipamiento
    GROUP BY Estado
    ORDER BY Estado;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_VehiculosPorEstado
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Estado AS Etiqueta, COUNT(*) AS Valor
    FROM dbo.Vehiculos
    GROUP BY Estado
    ORDER BY Estado;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Dashboard_IncidentesPorSeveridad
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Severidad AS Etiqueta, COUNT(*) AS Valor
    FROM dbo.Incidentes
    GROUP BY Severidad
    ORDER BY CASE Severidad WHEN N'Baja' THEN 1 WHEN N'Media' THEN 2 WHEN N'Alta' THEN 3 ELSE 4 END;
END
GO

/* =========================================================================
   REPORTES
   Las columnas se devuelven con nombres "amigables" porque la grilla de
   reportes genera las columnas automáticamente.
   ========================================================================= */

-- PERSONAL ---------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_VoluntariosActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.Apellido + N', ' + v.Nombre AS [Voluntario],
           v.DNI,
           v.Telefono AS [Teléfono],
           v.Email,
           v.FechaIngreso AS [Fecha de ingreso],
           DATEDIFF(YEAR, v.FechaIngreso, GETDATE()) AS [Años de servicio],
           ISNULL(ra.Nombre, N'-') AS [Rango actual],
           ISNULL((SELECT STRING_AGG(ro.Nombre, N', ')
                   FROM dbo.HistorialRoles h
                   INNER JOIN dbo.Roles ro ON ro.IDRol = h.IDRol
                   WHERE h.IDVoluntario = v.IDVoluntario AND h.FechaHasta IS NULL), N'-') AS [Roles vigentes]
    FROM dbo.Voluntarios v
    OUTER APPLY (SELECT TOP 1 r.Nombre FROM dbo.HistorialRangos hr
                 INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
                 WHERE hr.IDVoluntario = v.IDVoluntario AND hr.FechaHasta IS NULL) ra
    WHERE v.Estado = N'Activo'
    ORDER BY v.Apellido, v.Nombre;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_HistorialRangos
    @IDVoluntario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.Apellido + N', ' + v.Nombre AS [Voluntario],
           r.Nombre AS [Rango],
           hr.FechaDesde AS [Desde],
           hr.FechaHasta AS [Hasta],
           DATEDIFF(DAY, hr.FechaDesde, ISNULL(hr.FechaHasta, CAST(GETDATE() AS DATE))) AS [Días en el rango],
           CASE WHEN hr.FechaHasta IS NULL THEN N'Vigente' ELSE N'Finalizado' END AS [Situación]
    FROM dbo.HistorialRangos hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Rangos r ON r.IDRango = hr.IDRango
    WHERE @IDVoluntario IS NULL OR hr.IDVoluntario = @IDVoluntario
    ORDER BY v.Apellido, v.Nombre, hr.FechaDesde;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_HistorialRoles
    @IDVoluntario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.Apellido + N', ' + v.Nombre AS [Voluntario],
           r.Nombre AS [Rol],
           hr.FechaDesde AS [Desde],
           hr.FechaHasta AS [Hasta],
           DATEDIFF(DAY, hr.FechaDesde, ISNULL(hr.FechaHasta, CAST(GETDATE() AS DATE))) AS [Días en el rol],
           CASE WHEN hr.FechaHasta IS NULL THEN N'Vigente' ELSE N'Finalizado' END AS [Situación]
    FROM dbo.HistorialRoles hr
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = hr.IDVoluntario
    INNER JOIN dbo.Roles r ON r.IDRol = hr.IDRol
    WHERE @IDVoluntario IS NULL OR hr.IDVoluntario = @IDVoluntario
    ORDER BY v.Apellido, v.Nombre, hr.FechaDesde;
END
GO

-- OPERACIONES -----------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_IncidentesPorPeriodo
    @Desde DATE = NULL,
    @Hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT i.IDIncidente AS [N°],
           i.FechaHora AS [Fecha y hora],
           i.Direccion AS [Dirección],
           i.Descripcion AS [Descripción],
           i.Severidad,
           (SELECT COUNT(*) FROM dbo.Misiones m WHERE m.IDIncidente = i.IDIncidente) AS [Misiones],
           (SELECT COUNT(DISTINCT mv.IDVoluntario) FROM dbo.Misiones m
              INNER JOIN dbo.MisionVoluntario mv ON mv.IDMision = m.IDMision
             WHERE m.IDIncidente = i.IDIncidente) AS [Voluntarios intervinientes]
    FROM dbo.Incidentes i
    WHERE (@Desde IS NULL OR i.FechaHora >= @Desde)
      AND (@Hasta IS NULL OR i.FechaHora < DATEADD(DAY, 1, CAST(@Hasta AS DATETIME)))
    ORDER BY i.FechaHora;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_MisionesPorEstado
    @Estado NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT m.Estado,
           m.Nombre AS [Misión],
           t.Nombre AS [Tipo],
           i.Direccion AS [Incidente],
           m.FechaInicio AS [Inicio],
           m.FechaFin AS [Fin],
           DATEDIFF(MINUTE, m.FechaInicio, ISNULL(m.FechaFin, GETDATE())) AS [Duración (min)],
           (SELECT COUNT(*) FROM dbo.MisionVoluntario x WHERE x.IDMision = m.IDMision) AS [Voluntarios],
           (SELECT COUNT(*) FROM dbo.MisionVehiculo x WHERE x.IDMision = m.IDMision) AS [Vehículos]
    FROM dbo.Misiones m
    INNER JOIN dbo.TipoMision t ON t.IDTipoMision = m.IDTipoMision
    INNER JOIN dbo.Incidentes i ON i.IDIncidente = m.IDIncidente
    WHERE @Estado IS NULL OR m.Estado = @Estado
    ORDER BY m.Estado, m.FechaInicio DESC;
END
GO

-- Sin voluntario: resumen por voluntario. Con voluntario: detalle de sus misiones.
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_MisionesPorVoluntario
    @IDVoluntario INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @IDVoluntario IS NULL
        SELECT v.Apellido + N', ' + v.Nombre AS [Voluntario],
               COUNT(mv.IDMision) AS [Misiones],
               SUM(CASE WHEN m.Estado = N'Finalizada' THEN 1 ELSE 0 END) AS [Finalizadas],
               SUM(CASE WHEN m.Estado = N'En curso' THEN 1 ELSE 0 END) AS [En curso],
               MAX(m.FechaInicio) AS [Última misión]
        FROM dbo.Voluntarios v
        LEFT JOIN dbo.MisionVoluntario mv ON mv.IDVoluntario = v.IDVoluntario
        LEFT JOIN dbo.Misiones m ON m.IDMision = mv.IDMision
        GROUP BY v.IDVoluntario, v.Apellido, v.Nombre
        ORDER BY COUNT(mv.IDMision) DESC, v.Apellido;
    ELSE
        SELECT m.Nombre AS [Misión],
               t.Nombre AS [Tipo],
               i.Direccion AS [Incidente],
               i.Severidad,
               m.FechaInicio AS [Inicio],
               m.FechaFin AS [Fin],
               m.Estado
        FROM dbo.MisionVoluntario mv
        INNER JOIN dbo.Misiones m ON m.IDMision = mv.IDMision
        INNER JOIN dbo.TipoMision t ON t.IDTipoMision = m.IDTipoMision
        INNER JOIN dbo.Incidentes i ON i.IDIncidente = m.IDIncidente
        WHERE mv.IDVoluntario = @IDVoluntario
        ORDER BY m.FechaInicio DESC;
END
GO

-- VEHÍCULOS -------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_VehiculosOperativos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.Nombre AS [Vehículo],
           t.Nombre AS [Tipo],
           v.Patente,
           v.[Año],
           (SELECT COUNT(*) FROM dbo.MisionVehiculo mv WHERE mv.IDVehiculo = v.IDVehiculo) AS [Misiones],
           (SELECT COUNT(*) FROM dbo.DocumentacionVehiculo d
             WHERE d.IDVehiculo = v.IDVehiculo AND d.FechaVencimiento < CAST(GETDATE() AS DATE)) AS [Documentos vencidos],
           (SELECT MIN(d.FechaVencimiento) FROM dbo.DocumentacionVehiculo d
             WHERE d.IDVehiculo = v.IDVehiculo AND d.FechaVencimiento >= CAST(GETDATE() AS DATE)) AS [Próximo vencimiento]
    FROM dbo.Vehiculos v
    INNER JOIN dbo.TipoVehiculo t ON t.IDTipoVehiculo = v.IDTipoVehiculo
    WHERE v.Estado = N'Operativo'
    ORDER BY v.Nombre;
END
GO

-- Documentación vencida y próxima a vencer (dentro de @DiasAviso días)
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_DocumentacionVencida
    @Dias INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    SELECT CASE WHEN d.FechaVencimiento < @Hoy THEN N'Vencido' ELSE N'Próximo a vencer' END AS [Situación],
           v.Nombre AS [Vehículo],
           v.Patente,
           d.TipoDocumento AS [Documento],
           d.FechaEmision AS [Emisión],
           d.FechaVencimiento AS [Vencimiento],
           DATEDIFF(DAY, @Hoy, d.FechaVencimiento) AS [Días para vencer]
    FROM dbo.DocumentacionVehiculo d
    INNER JOIN dbo.Vehiculos v ON v.IDVehiculo = d.IDVehiculo
    WHERE d.FechaVencimiento <= DATEADD(DAY, @Dias, @Hoy)
    ORDER BY d.FechaVencimiento;
END
GO

-- EQUIPAMIENTO ----------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_EquipamientoPorEstado
    @Estado NVARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Estado,
           e.CodigoInterno AS [Código],
           e.Nombre AS [Equipo],
           t.Nombre AS [Tipo],
           c.Nombre AS [Categoría],
           e.FechaCompra AS [Compra],
           e.FechaUltimoMantenimiento AS [Último mantenimiento],
           e.FechaProximoMantenimiento AS [Próximo mantenimiento]
    FROM dbo.Equipamiento e
    INNER JOIN dbo.TipoEquipamiento t ON t.IDTipoEquipamiento = e.IDTipoEquipamiento
    INNER JOIN dbo.CategoriaEquipamiento c ON c.IDCategoriaEquipamiento = e.IDCategoriaEquipamiento
    WHERE @Estado IS NULL OR e.Estado = @Estado
    ORDER BY e.Estado, e.CodigoInterno;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_ProximosMantenimientos
    @Dias INT = 90
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy DATE = CAST(GETDATE() AS DATE);
    SELECT e.CodigoInterno AS [Código],
           e.Nombre AS [Equipo],
           c.Nombre AS [Categoría],
           e.Estado,
           e.FechaUltimoMantenimiento AS [Último mantenimiento],
           e.FechaProximoMantenimiento AS [Próximo mantenimiento],
           DATEDIFF(DAY, @Hoy, e.FechaProximoMantenimiento) AS [Días restantes],
           CASE WHEN e.FechaProximoMantenimiento < @Hoy THEN N'Atrasado' ELSE N'Programado' END AS [Situación]
    FROM dbo.Equipamiento e
    INNER JOIN dbo.CategoriaEquipamiento c ON c.IDCategoriaEquipamiento = e.IDCategoriaEquipamiento
    WHERE e.Estado <> N'Baja'
      AND e.FechaProximoMantenimiento IS NOT NULL
      AND e.FechaProximoMantenimiento <= DATEADD(DAY, @Dias, @Hoy)
    ORDER BY e.FechaProximoMantenimiento;
END
GO

-- FINANZAS --------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_AportesPorPeriodo
    @Desde DATE = NULL,
    @Hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT a.Fecha, t.Nombre AS [Tipo], a.Descripcion AS [Descripción], a.Monto
    FROM dbo.Aportes a
    INNER JOIN dbo.TipoAporte t ON t.IDTipoAporte = a.IDTipoAporte
    WHERE (@Desde IS NULL OR a.Fecha >= @Desde)
      AND (@Hasta IS NULL OR a.Fecha <= @Hasta)
    ORDER BY a.Fecha;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_AportesMensuales
    @Anio INT
AS
BEGIN
    SET NOCOUNT ON;
    WITH Meses AS (SELECT 1 AS Mes UNION ALL SELECT Mes + 1 FROM Meses WHERE Mes < 12)
    SELECT RIGHT(N'0' + CAST(m.Mes AS NVARCHAR(2)), 2) + N'/' + CAST(@Anio AS NVARCHAR(4)) AS [Mes],
           COUNT(a.IDAporte) AS [Cantidad],
           ISNULL(SUM(a.Monto), 0) AS [Total]
    FROM Meses m
    LEFT JOIN dbo.Aportes a ON YEAR(a.Fecha) = @Anio AND MONTH(a.Fecha) = m.Mes
    GROUP BY m.Mes
    ORDER BY m.Mes;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_AportesPorTipo
    @Desde DATE = NULL,
    @Hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Total DECIMAL(14,2) =
        (SELECT SUM(Monto) FROM dbo.Aportes
         WHERE (@Desde IS NULL OR Fecha >= @Desde) AND (@Hasta IS NULL OR Fecha <= @Hasta));

    SELECT t.Nombre AS [Tipo de aporte],
           COUNT(a.IDAporte) AS [Cantidad],
           ISNULL(SUM(a.Monto), 0) AS [Total],
           CAST(CASE WHEN ISNULL(@Total, 0) = 0 THEN 0 ELSE ISNULL(SUM(a.Monto), 0) * 100.0 / @Total END AS DECIMAL(5,2)) AS [% del total]
    FROM dbo.TipoAporte t
    LEFT JOIN dbo.Aportes a ON a.IDTipoAporte = t.IDTipoAporte
                           AND (@Desde IS NULL OR a.Fecha >= @Desde)
                           AND (@Hasta IS NULL OR a.Fecha <= @Hasta)
    GROUP BY t.Nombre
    ORDER BY ISNULL(SUM(a.Monto), 0) DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_GastosPorPeriodo
    @Desde DATE = NULL,
    @Hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT g.Fecha, t.Nombre AS [Tipo], g.Descripcion AS [Descripción],
           v.Apellido + N', ' + v.Nombre AS [Autorizado por], g.Monto
    FROM dbo.Gastos g
    INNER JOIN dbo.TipoGasto t ON t.IDTipoGasto = g.IDTipoGasto
    INNER JOIN dbo.Voluntarios v ON v.IDVoluntario = g.IDVoluntarioAutorizador
    WHERE (@Desde IS NULL OR g.Fecha >= @Desde)
      AND (@Hasta IS NULL OR g.Fecha <= @Hasta)
    ORDER BY g.Fecha;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_GastosPorTipo
    @Desde DATE = NULL,
    @Hasta DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Nombre AS [Tipo de gasto],
           COUNT(g.IDGasto) AS [Cantidad],
           ISNULL(SUM(g.Monto), 0) AS [Total]
    FROM dbo.TipoGasto t
    LEFT JOIN dbo.Gastos g ON g.IDTipoGasto = t.IDTipoGasto
                          AND (@Desde IS NULL OR g.Fecha >= @Desde)
                          AND (@Hasta IS NULL OR g.Fecha <= @Hasta)
    GROUP BY t.Nombre
    ORDER BY ISNULL(SUM(g.Monto), 0) DESC;
END
GO

CREATE OR ALTER PROCEDURE dbo.sp_Rpt_SaldoPorCaja
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.Nombre AS [Caja],
           COUNT(m.IDMovimiento) AS [Movimientos],
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto END), 0) AS [Ingresos],
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Egreso'  THEN m.Monto END), 0) AS [Egresos],
           ISNULL(SUM(CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto ELSE -m.Monto END), 0) AS [Saldo],
           MAX(m.Fecha) AS [Último movimiento]
    FROM dbo.Caja c
    LEFT JOIN dbo.MovimientoCaja m ON m.IDCaja = c.IDCaja
    GROUP BY c.IDCaja, c.Nombre
    ORDER BY c.Nombre;
END
GO

-- Movimientos con saldo acumulado por caja
CREATE OR ALTER PROCEDURE dbo.sp_Rpt_MovimientosCaja
    @IDCaja INT  = NULL,
    @Desde  DATE = NULL,
    @Hasta  DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT x.[Caja], x.[Fecha], x.[Tipo], x.[Concepto], x.[Ingreso], x.[Egreso], x.[Saldo acumulado]
    FROM (
        SELECT c.Nombre AS [Caja],
               m.Fecha AS [Fecha],
               m.TipoMovimiento AS [Tipo],
               m.Concepto AS [Concepto],
               CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto END AS [Ingreso],
               CASE WHEN m.TipoMovimiento = N'Egreso'  THEN m.Monto END AS [Egreso],
               SUM(CASE WHEN m.TipoMovimiento = N'Ingreso' THEN m.Monto ELSE -m.Monto END)
                   OVER (PARTITION BY m.IDCaja ORDER BY m.Fecha, m.IDMovimiento
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS [Saldo acumulado],
               m.IDMovimiento
        FROM dbo.MovimientoCaja m
        INNER JOIN dbo.Caja c ON c.IDCaja = m.IDCaja
        WHERE @IDCaja IS NULL OR m.IDCaja = @IDCaja
    ) x
    -- El filtro de fechas se aplica después para que el saldo acumulado considere todo el historial
    WHERE (@Desde IS NULL OR x.[Fecha] >= @Desde)
      AND (@Hasta IS NULL OR x.[Fecha] < DATEADD(DAY, 1, CAST(@Hasta AS DATETIME)))
    ORDER BY x.[Caja], x.[Fecha], x.IDMovimiento;
END
GO

PRINT N'Stored Procedures creados correctamente.';
GO
