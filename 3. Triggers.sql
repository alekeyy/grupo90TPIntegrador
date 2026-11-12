USE DB_Bomberos;
GO

CREATE TRIGGER TR_Gastos_RegistrarMovimiento ON Gastos
AFTER INSERT
AS
BEGIN
    IF (SELECT COUNT(*)
        FROM inserted i
        INNER JOIN Voluntarios v ON v.IDVoluntario = i.IDVoluntarioAutorizador
        WHERE v.Estado <> 'Activo') > 0
    BEGIN
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO MovimientoCaja (IDCaja, Fecha, TipoMovimiento, Monto, Concepto, IDGasto)
    SELECT IDCaja, Fecha, 'Egreso', Monto, Descripcion, IDGasto
    FROM inserted;
END
GO

CREATE TRIGGER TR_Voluntarios_BajaLogica ON Voluntarios
INSTEAD OF DELETE
AS
BEGIN
    UPDATE Voluntarios
    SET Estado = 'Inactivo'
    WHERE IDVoluntario IN (SELECT IDVoluntario FROM deleted);
END
GO