USE DB_Bomberos;
GO


-- Cierra el rango actual del voluntario y le abre uno nuevo en HistorialRangos.
CREATE OR ALTER PROCEDURE sp_AscenderVoluntario
    @IDVoluntario INT,
    @IDRangoNuevo INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Voluntarios
                   WHERE IDVoluntario = @IDVoluntario AND Estado = N'Activo')
        THROW 50001, N'El voluntario no existe o no esta activo.', 1;

    DECLARE @RangoActual INT;
    SELECT @RangoActual = IDRango
    FROM HistorialRangos
    WHERE IDVoluntario = @IDVoluntario AND FechaHasta IS NULL;

    IF @IDRangoNuevo <= @RangoActual
        THROW 50002, N'El nuevo rango debe ser superior al actual.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE HistorialRangos
        SET FechaHasta = GETDATE()
        WHERE IDVoluntario = @IDVoluntario AND FechaHasta IS NULL;

        INSERT INTO HistorialRangos (IDVoluntario, IDRango, FechaDesde)
        VALUES (@IDVoluntario, @IDRangoNuevo, GETDATE());

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


-- Registra un gasto y el egreso de dinero en la caja.
CREATE OR ALTER PROCEDURE sp_RegistrarGasto
    @IDTipoGasto             INT,
    @IDCaja                  INT,
    @IDVoluntarioAutorizador INT,
    @Monto                   DECIMAL(12,2),
    @Descripcion             NVARCHAR(250) = NULL
AS
BEGIN
    IF @Monto <= 0
        THROW 50010, N'El monto debe ser mayor a cero.', 1;

    IF NOT EXISTS (SELECT 1 FROM Voluntarios
                   WHERE IDVoluntario = @IDVoluntarioAutorizador AND Estado = N'Activo')
        THROW 50011, N'El autorizador no existe o no esta activo.', 1;

    DECLARE @Saldo DECIMAL(12,2);
    SELECT @Saldo = ISNULL(SUM(CASE WHEN TipoMovimiento = N'Ingreso'
                                    THEN Monto ELSE -Monto END), 0)
    FROM MovimientoCaja
    WHERE IDCaja = @IDCaja;

    IF @Monto > @Saldo
        THROW 50012, N'Saldo insuficiente en la caja.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Gastos (Monto, Descripcion, IDTipoGasto, IDVoluntarioAutorizador, IDCaja)
        VALUES (@Monto, @Descripcion, @IDTipoGasto, @IDVoluntarioAutorizador, @IDCaja);

        DECLARE @IDGasto INT = SCOPE_IDENTITY();   --ID del gasto recien creado

        INSERT INTO MovimientoCaja (IDCaja, TipoMovimiento, Monto, Concepto, IDGasto)
        VALUES (@IDCaja, N'Egreso', @Monto, @Descripcion, @IDGasto);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO


-- EJEMPLOS DE USO

-- sp_AscenderVoluntario ------------------------------------------------

-- Correcto: Valeria Pereyra (ID 6) pasa de Bombero a Cabo
EXEC sp_AscenderVoluntario @IDVoluntario = 6, @IDRangoNuevo = 2;
SELECT * FROM HistorialRangos WHERE IDVoluntario = 6;
GO

-- Error: Martin Gomez (ID 1) ya es Sargento, no puede pasar a Cabo
EXEC sp_AscenderVoluntario @IDVoluntario = 1, @IDRangoNuevo = 2;
GO

-- sp_RegistrarGasto ----------------------------------------------------

-- Correcto: gasto de $15000 en la Caja General autorizado por Carlos Rodriguez (ID 3)
EXEC sp_RegistrarGasto @IDTipoGasto = 2, @IDCaja = 1, @IDVoluntarioAutorizador = 3,
                       @Monto = 15000, @Descripcion = N'Carga de combustible';
SELECT TOP 1 * FROM Gastos ORDER BY IDGasto DESC;
SELECT TOP 1 * FROM MovimientoCaja ORDER BY IDMovimiento DESC;
GO

-- Error: la Caja Chica tiene $89500, no alcanza para $100000
EXEC sp_RegistrarGasto @IDTipoGasto = 1, @IDCaja = 2, @IDVoluntarioAutorizador = 3,
                       @Monto = 100000, @Descripcion = N'Gasto de prueba';
GO