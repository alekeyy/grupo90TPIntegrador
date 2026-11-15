-- Vistas
-- Datos ultima misión realizada

USE DB_Bomberos;
GO

-- Llamado Vista
SELECT * FROM VW_ULTIMA_MISION_REALIZADA

-- Vista 1
CREATE OR ALTER VIEW VW_ULTIMA_MISION_REALIZADA
AS
SELECT
    M.IDMision,
    TM.Nombre AS TipoMision,
    V.IDVoluntario,
    V.Nombre + ' ' + V.Apellido AS Voluntario,
    CONCAT(I.Descripcion, ' en ', I.Direccion,
           ' a las ', FORMAT(I.FechaHora, 'HH:mm'),
           ' con una severidad ', I.Severidad) AS InfoIncidente
FROM Misiones M
INNER JOIN TipoMision TM ON TM.IDTipoMision = M.IDTipoMision
INNER JOIN Incidentes I ON I.IDIncidente = M.IDIncidente
INNER JOIN MisionVoluntario MV ON MV.IDMision = M.IDMision
INNER JOIN Voluntarios V ON V.IDVoluntario = MV.IDVoluntario
WHERE M.IDMision = (
    SELECT TOP 1 IDMision
    FROM Misiones
    WHERE Estado = 'Finalizada'
    ORDER BY FechaFin DESC, IDMision DESC
)
GO

-- Vista 2
CREATE OR ALTER VIEW VW_Staff_Activo
AS
SELECT
    V.IDVoluntario,
    V.Nombre + ' ' + V.Apellido AS Voluntario,
    MAX(E.Fecha) AS UltimoEntrenamiento,
    DATEDIFF(DAY, MAX(E.Fecha), GETDATE()) AS DiasDesdeUltimoEntrenamiento,
    CASE
        WHEN MAX(E.Fecha) IS NULL THEN 'Sin entrenamiento'
        WHEN DATEDIFF(DAY, MAX(E.Fecha), GETDATE()) <= 60 THEN 'Al día'
        WHEN DATEDIFF(DAY, MAX(E.Fecha), GETDATE()) <= 90 THEN 'Próximo a vencer'
        ELSE 'Vencido'
    END AS EstadoEntrenamiento
FROM Voluntarios V
LEFT JOIN AsistenciaEntrenamiento A ON A.IDVoluntario = V.IDVoluntario
LEFT JOIN Entrenamientos E ON E.IDEntrenamiento = A.IDEntrenamiento
WHERE V.Estado = 'Activo'
GROUP BY V.IDVoluntario, V.Nombre, V.Apellido
GO

-- Vista 3
CREATE OR ALTER VIEW VW_Equipamiento_Sin_Mantenimiento
AS
SELECT
    EQ.IDEquipamiento,
    EQ.CodigoInterno,
    EQ.Nombre,
    EQ.Estado,
    U.UltimoUso,
    DATEDIFF(DAY, U.UltimoUso, GETDATE()) AS DiasDesdeUltimoUso,
    MT.UltimoMantenimiento
FROM Equipamiento EQ
INNER JOIN (
    SELECT ME.IDEquipamiento, MAX(COALESCE(M.FechaFin, M.FechaInicio)) AS UltimoUso
    FROM MisionEquipamiento ME
    INNER JOIN Misiones M ON M.IDMision = ME.IDMision
    GROUP BY ME.IDEquipamiento
) U ON U.IDEquipamiento = EQ.IDEquipamiento
LEFT JOIN (
    SELECT IDEquipamiento, MAX(FechaMantenimiento) AS UltimoMantenimiento
    FROM MantenimientosEquipamiento
    GROUP BY IDEquipamiento
) MT ON MT.IDEquipamiento = EQ.IDEquipamiento
WHERE EQ.Estado <> 'Baja'
  AND (MT.UltimoMantenimiento IS NULL OR MT.UltimoMantenimiento < CAST(U.UltimoUso AS DATE))
GO
