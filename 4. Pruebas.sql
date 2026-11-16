USE DB_Bomberos;
GO;

-- Vista 1
SELECT TOP 1 * FROM Misiones order by FechaInicio DESC
SELECT * FROM TipoMision 
SELECT * FROM Incidentes
SELECT * FROM MisionVoluntario
SELECT * FROM Voluntarios 

SELECT * FROM VW_ULTIMA_MISION_REALIZADA;

-- Vista 2
SELECT * FROM Voluntarios 
SELECT * FROM Entrenamientos 
SELECT * FROM AsistenciaEntrenamiento

INSERT INTO Voluntarios (Nombre, Apellido, DNI, FechaNacimiento, Telefono, Email, Direccion, FechaIngreso, Estado) VALUES
(N'Juanito', N'Perez', N'12345678', '1981-03-11', N'11-4222-1001', N'juanito.crack@gmail.com', N'Av. Siempre viva 743', '2026-11-10', N'Activo')


INSERT INTO AsistenciaEntrenamiento (IDEntrenamiento, IDVoluntario, Observaciones) VALUES
(7, 13, N'Buen desempeño')

INSERT INTO Entrenamientos (IDTipoEntrenamiento, Fecha, Observaciones) VALUES
(2, '2026-11-15', N'Circuito de resistencia')

SELECT * FROM VW_Staff_Activo;

-- Vista 3
SELECT * FROM Equipamiento
SELECT * FROM Misiones WHERE IDMision = 8;
SELECT * FROM MisionEquipamiento
SELECT * FROM MantenimientosEquipamiento

SELECT * FROM VW_Equipamiento_Sin_Mantenimiento

--- Stored Procedure
-- EJEMPLOS DE USO

-- sp_AscenderVoluntario ------------------------------------------------

SELECT * FROM Voluntarios where IDVoluntario = 2
SELECT * FROM HistorialRangos WHERE IDVOLUNTARIO = 2;
SELECT * FROM Rangos
-- Correcto: Valeria Pereyra (ID 6) pasa de Bombero a Cabo
EXEC sp_AscenderVoluntario @IDVoluntario = 6, @IDRangoNuevo = 3
SELECT * FROM HistorialRangos WHERE IDVoluntario = 6;
GO

-- Error: Martin Gomez (ID 1) ya es Sargento, no puede pasar a Cabo
EXEC sp_AscenderVoluntario @IDVoluntario = 1, @IDRangoNuevo = 2;
GO

-- sp_RegistrarGasto ----------------------------------------------------

-- Correcto: gasto de $15000 en la Caja General autorizado por Carlos Rodriguez (ID 3)
SELECT * FROM Caja 
select * from MovimientoCaja where IDCaja = 1
select * from Gastos where idvoluntarioautorizador = 3

EXEC sp_RegistrarGasto @IDTipoGasto = 2, @IDCaja = 1, @IDVoluntarioAutorizador = 3,
                       @Monto = 25000, @Descripcion = N'Vales de gasto';
GO

-- Error: la Caja Chica tiene $89500, no alcanza para $100000
EXEC sp_RegistrarGasto @IDTipoGasto = 1, @IDCaja = 2, @IDVoluntarioAutorizador = 3,
                       @Monto = 100000, @Descripcion = N'Gasto de prueba';
GO