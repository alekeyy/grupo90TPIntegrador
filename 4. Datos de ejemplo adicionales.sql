/* =========================================================================
   DB_Bomberos - 4. Datos de ejemplo adicionales (opcional)
   -------------------------------------------------------------------------
   Complementa "2. Initial Data.sql" con datos RELATIVOS A LA FECHA ACTUAL,
   para que el Dashboard muestre indicadores "vivos" sin importar el día en
   que se ejecute el script:
     - un incidente con una misión "En curso" y recursos asignados
     - guardias para hoy (una de ellas activa en este momento)
     - aportes, gastos y movimientos de caja del mes en curso
     - documentación próxima a vencer y un mantenimiento próximo

   Ejecutar DESPUÉS de "3. Stored Procedures.sql". Se puede ejecutar una
   sola vez (verifica si ya fue aplicado).
   ========================================================================= */
USE DB_Bomberos;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF EXISTS (SELECT 1 FROM dbo.Incidentes WHERE Descripcion = N'[DEMO] Incendio en depósito industrial')
BEGIN
    PRINT N'Los datos de ejemplo adicionales ya fueron cargados.';
    RETURN;
END

DECLARE @Ahora DATETIME = GETDATE();
DECLARE @Hoy DATE = CAST(@Ahora AS DATE);
DECLARE @InicioMes DATE = DATEFROMPARTS(YEAR(@Hoy), MONTH(@Hoy), 1);
DECLARE @IDIncidente INT, @IDMision INT;

BEGIN TRY
    BEGIN TRANSACTION;

    -- Incidente y misión en curso -------------------------------------------
    INSERT INTO dbo.Incidentes (FechaHora, Direccion, Descripcion, Severidad)
    VALUES (DATEADD(HOUR, -2, @Ahora), N'Parque Industrial, Nave 3',
            N'[DEMO] Incendio en depósito industrial', N'Alta');
    SET @IDIncidente = SCOPE_IDENTITY();

    INSERT INTO dbo.Misiones (IDIncidente, IDTipoMision, Nombre, FechaInicio, FechaFin, Estado)
    VALUES (@IDIncidente, 1, N'Combate de incendio en depósito', DATEADD(MINUTE, -100, @Ahora), NULL, N'En curso');
    SET @IDMision = SCOPE_IDENTITY();

    INSERT INTO dbo.MisionVoluntario (IDMision, IDVoluntario) VALUES (@IDMision, 1), (@IDMision, 3), (@IDMision, 5), (@IDMision, 9);
    INSERT INTO dbo.MisionVehiculo (IDMision, IDVehiculo) VALUES (@IDMision, 1), (@IDMision, 4);
    INSERT INTO dbo.MisionEquipamiento (IDMision, IDEquipamiento) VALUES (@IDMision, 6), (@IDMision, 7), (@IDMision, 9);
    UPDATE dbo.Equipamiento SET Estado = N'En uso' WHERE IDEquipamiento IN (6, 7, 9);

    -- Guardias de hoy (cubren las 24 hs, por lo que siempre hay una activa) ---
    INSERT INTO dbo.Guardias (IDVoluntario, Fecha, HoraInicio, HoraFin) VALUES
    (2, @Hoy, '08:00', '20:00'),
    (6, @Hoy, '08:00', '20:00'),
    (4, @Hoy, '20:00', '08:00'),
    (12, DATEADD(DAY, -1, @Hoy), '20:00', '08:00');

    -- Movimientos financieros del mes en curso ------------------------------
    INSERT INTO dbo.Aportes (IDTipoAporte, Fecha, Monto, Descripcion) VALUES
    (1, @InicioMes, 30000.00, N'[DEMO] Donación de comercio local'),
    (4, @Hoy, 42000.00, N'[DEMO] Cuotas de socios colaboradores del mes');

    INSERT INTO dbo.Gastos (Fecha, Monto, Descripcion, IDTipoGasto, IDVoluntarioAutorizador) VALUES
    (@InicioMes, 38000.00, N'[DEMO] Combustible del mes', 2, 3),
    (@Hoy, 15500.00, N'[DEMO] Repuestos para equipo de respiración', 1, 1);

    INSERT INTO dbo.MovimientoCaja (IDCaja, Fecha, TipoMovimiento, Monto, Concepto) VALUES
    (1, CAST(@InicioMes AS DATETIME), N'Ingreso', 30000.00, N'[DEMO] Donación de comercio local'),
    (1, CAST(@InicioMes AS DATETIME) + CAST('10:00' AS DATETIME), N'Egreso', 38000.00, N'[DEMO] Combustible del mes'),
    (2, DATEADD(HOUR, -1, @Ahora), N'Ingreso', 42000.00, N'[DEMO] Cuotas de socios'),
    (2, @Ahora, N'Egreso', 15500.00, N'[DEMO] Repuestos equipo de respiración');

    -- Vencimientos próximos -------------------------------------------------
    INSERT INTO dbo.DocumentacionVehiculo (IDVehiculo, TipoDocumento, FechaEmision, FechaVencimiento, Estado)
    VALUES (4, N'Seguro', DATEADD(DAY, 15, DATEADD(YEAR, -1, @Hoy)), DATEADD(DAY, 15, @Hoy), N'Vigente');

    UPDATE dbo.Equipamiento SET FechaProximoMantenimiento = DATEADD(DAY, 10, @Hoy) WHERE IDEquipamiento = 8;

    COMMIT TRANSACTION;
    PRINT N'Datos de ejemplo adicionales cargados correctamente.';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH
GO
