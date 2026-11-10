USE DB_Bomberos;
GO

INSERT INTO Rangos (Nombre) VALUES
(N'Bombero'),
(N'Cabo'),
(N'Sargento'),
(N'Oficial')
GO

INSERT INTO Roles (Nombre) VALUES
(N'Operativo'),
(N'Instructor'),
(N'Jefe de Unidad'),
(N'Administrativo')
GO

INSERT INTO Voluntarios (Nombre, Apellido, DNI, FechaNacimiento, Telefono, Email, Direccion, FechaIngreso, Estado) VALUES
(N'Martín', N'Gómez', N'30125478', '1988-03-14', N'11-4523-1001', N'martin.gomez@mail.com', N'Av. San Martín 1200', '2012-05-10', N'Activo'),
(N'Lucía', N'Fernández', N'32456789', '1990-07-22', N'11-4523-1002', N'lucia.fernandez@mail.com', N'Calle Belgrano 455', '2014-03-01', N'Activo'),
(N'Carlos', N'Rodríguez', N'28745123', '1985-11-02', N'11-4523-1003', N'carlos.rodriguez@mail.com', N'Calle Mitre 78', '2010-08-15', N'Activo'),
(N'Ana', N'Martínez', N'35123456', '1993-01-30', N'11-4523-1004', N'ana.martinez@mail.com', N'Pasaje Rivadavia 210', '2016-09-20', N'Activo'),
(N'Diego', N'Sosa', N'33987654', '1991-05-18', N'11-4523-1005', N'diego.sosa@mail.com', N'Av. Libertad 980', '2015-04-12', N'Activo'),
(N'Valeria', N'Pereyra', N'36234567', '1994-09-09', N'11-4523-1006', N'valeria.pereyra@mail.com', N'Calle Sarmiento 332', '2018-02-25', N'Activo'),
(N'Julián', N'Acosta', N'31876543', '1989-12-05', N'11-4523-1007', N'julian.acosta@mail.com', N'Calle Moreno 1450', '2013-06-30', N'Activo'),
(N'Sofía', N'Benítez', N'38123987', '1997-04-17', N'11-4523-1008', N'sofia.benitez@mail.com', N'Barrio Los Álamos, mz 4', '2020-10-03', N'Activo'),
(N'Matías', N'Romero', N'34567890', '1992-08-27', N'11-4523-1009', N'matias.romero@mail.com', N'Av. Independencia 640', '2017-01-18', N'Activo'),
(N'Camila', N'Ortiz', N'39456123', '1998-02-11', N'11-4523-1010', N'camila.ortiz@mail.com', N'Calle Alsina 123', '2021-05-22', N'Licencia'),
(N'Ramiro', N'Díaz', N'29345678', '1986-06-25', N'11-4523-1011', N'ramiro.diaz@mail.com', N'Calle Urquiza 870', '2011-11-09', N'Inactivo'),
(N'Florencia', N'Luna', N'37890123', '1996-10-03', N'11-4523-1012', N'florencia.luna@mail.com', N'Calle Córdoba 56', '2019-07-14', N'Activo')
GO

INSERT INTO HistorialRangos (IDVoluntario, IDRango, FechaDesde, FechaHasta) VALUES
(1, 1, '2012-05-10', '2015-05-10'),
(1, 2, '2015-05-10', '2019-06-01'),
(1, 3, '2019-06-01', NULL),
(2, 1, '2014-03-01', '2018-03-01'),
(2, 2, '2018-03-01', NULL),
(3, 1, '2010-08-15', '2013-08-15'),
(3, 2, '2013-08-15', '2016-08-15'),
(3, 3, '2016-08-15', '2021-08-15'),
(3, 4, '2021-08-15', NULL),
(4, 1, '2016-09-20', '2021-09-20'),
(4, 2, '2021-09-20', NULL),
(5, 1, '2015-04-12', '2020-04-12'),
(5, 2, '2020-04-12', NULL),
(6, 1, '2018-02-25', NULL),
(7, 1, '2013-06-30', '2017-06-30'),
(7, 2, '2017-06-30', '2022-06-30'),
(7, 3, '2022-06-30', NULL),
(8, 1, '2020-10-03', NULL),
(9, 1, '2017-01-18', '2022-01-18'),
(9, 2, '2022-01-18', NULL),
(10, 1, '2021-05-22', NULL),
(11, 1, '2011-11-09', '2014-11-09'),
(11, 2, '2014-11-09', NULL),
(12, 1, '2019-07-14', NULL)
GO

INSERT INTO HistorialRoles (IDVoluntario, IDRol, FechaDesde, FechaHasta) VALUES
(1, 1, '2012-05-10', '2019-06-01'),
(1, 3, '2019-06-01', NULL),
(2, 1, '2014-03-01', '2018-03-01'),
(2, 2, '2018-03-01', NULL),
(3, 1, '2010-08-15', '2016-08-15'),
(3, 3, '2016-08-15', '2021-08-15'),
(3, 4, '2021-08-15', NULL),
(4, 1, '2016-09-20', NULL),
(5, 1, '2015-04-12', NULL),
(6, 1, '2018-02-25', NULL),
(7, 1, '2013-06-30', '2022-06-30'),
(7, 3, '2022-06-30', NULL),
(8, 1, '2020-10-03', NULL),
(9, 1, '2017-01-18', NULL),
(9, 2, '2023-03-01', NULL),
(10, 1, '2021-05-22', NULL),
(11, 1, '2011-11-09', '2024-01-31'),
(12, 4, '2019-07-14', NULL)
GO

INSERT INTO TipoVehiculo (Nombre) VALUES
(N'Autobomba'),
(N'Camión'),
(N'Camioneta'),
(N'Moto')
GO

INSERT INTO Vehiculos (Nombre, Año, Patente, Estado, IDTipoVehiculo) VALUES
(N'Autobomba 01', 2015, N'AA123BC', N'Operativo', 1),
(N'Autobomba 02', 2009, N'HJK458', N'Operativo', 1),
(N'Camión Cisterna', 2012, N'KMN921', N'En mantenimiento', 2),
(N'Camión de Rescate', 2018, N'AC789DE', N'Operativo', 2),
(N'Camioneta Rural 4x4', 2020, N'AD234FG', N'Operativo', 3),
(N'Camioneta Utilitaria', 2006, N'FGT552', N'Fuera de servicio', 3),
(N'Moto de Respuesta Rápida', 2021, N'A456CDE', N'Operativo', 4)
GO

INSERT INTO DocumentacionVehiculo (IDVehiculo, TipoDocumento, FechaEmision, FechaVencimiento, Estado) VALUES
(1, N'VTV', '2025-11-10', '2026-11-10', N'Vigente'),
(1, N'Seguro', '2026-03-01', '2027-03-01', N'Vigente'),
(2, N'VTV', '2024-05-20', '2025-05-20', N'Vencido'),
(2, N'Seguro', '2026-01-15', '2027-01-15', N'Vigente'),
(3, N'Habilitación', '2025-08-01', '2026-08-01', N'Vencido'),
(3, N'Seguro', '2026-03-01', '2027-03-01', N'Vigente'),
(4, N'Inspección técnica', '2026-06-10', '2027-06-10', N'Vigente'),
(5, N'VTV', '2026-02-12', '2027-02-12', N'Vigente'),
(5, N'Seguro', '2026-02-12', '2027-02-12', N'Vigente'),
(6, N'VTV', '2023-04-05', '2024-04-05', N'Vencido'),
(7, N'VTV', '2026-05-20', '2027-05-20', N'Vigente'),
(7, N'Seguro', '2026-05-20', '2027-05-20', N'Vigente')
GO

INSERT INTO TipoEquipamiento (Nombre) VALUES
(N'Protección Personal'),
(N'Herramienta'),
(N'Comunicación')
GO

INSERT INTO CategoriaEquipamiento (Nombre) VALUES
(N'Casco'),
(N'Manguera'),
(N'Equipo de Respiración'),
(N'Radios')
GO

INSERT INTO Equipamiento (CodigoInterno, Nombre, Estado, FechaCompra, FechaProximoMantenimiento, IDTipoEquipamiento, IDCategoriaEquipamiento) VALUES
(N'EQ-001', N'Casco de bombero estructural', N'Disponible', '2021-03-10', '2027-03-10', 1, 1),
(N'EQ-002', N'Casco de bombero estructural', N'Disponible', '2021-03-10', '2027-03-10', 1, 1),
(N'EQ-003', N'Casco de rescate técnico', N'Disponible', '2022-06-15', '2027-06-15', 1, 1),
(N'EQ-004', N'Manguera 45 mm x 25 m', N'Disponible', '2019-09-01', '2027-04-28', 2, 2),
(N'EQ-005', N'Manguera 70 mm x 25 m', N'Disponible', '2020-02-20', '2027-05-02', 2, 2),
(N'EQ-006', N'Equipo de respiración autónoma', N'Disponible', '2022-11-05', '2027-01-10', 1, 3),
(N'EQ-007', N'Equipo de respiración autónoma', N'Disponible', '2022-11-05', '2027-01-10', 1, 3),
(N'EQ-008', N'Radio portátil', N'Disponible', '2023-04-18', '2027-04-18', 3, 4),
(N'EQ-009', N'Radio portátil', N'Disponible', '2023-04-18', '2027-04-18', 3, 4),
(N'EQ-010', N'Radio base', N'Baja', '2014-01-20', NULL, 3, 4)
GO

INSERT INTO MantenimientosEquipamiento (IDEquipamiento, FechaMantenimiento, TipoMantenimiento, TareasRealizadas, Costo, Responsable) VALUES
(1, '2026-03-10', N'Preventivo', N'Inspección de carcasa, visor y correaje', 0.00, N'Taller propio'),
(2, '2026-03-10', N'Preventivo', N'Inspección de carcasa, visor y correaje', 0.00, N'Taller propio'),
(3, '2026-06-15', N'Preventivo', N'Revisión de arnés y del sistema de retención', 0.00, N'Taller propio'),
(4, '2026-04-01', N'Preventivo', N'Prueba hidrostática y revisión de uniones', 8500.00, N'Hidráulica del Sur S.R.L.'),
(4, '2026-10-28', N'Correctivo', N'Cambio de acoples y prueba de presión', 12000.00, N'Hidráulica del Sur S.R.L.'),
(5, '2026-05-02', N'Preventivo', N'Prueba hidrostática y revisión de uniones', 8500.00, N'Hidráulica del Sur S.R.L.'),
(6, '2026-07-10', N'Preventivo', N'Calibración de regulador y prueba de hermeticidad', 18000.00, N'Seguridad Industrial Norte'),
(7, '2026-07-10', N'Preventivo', N'Calibración de regulador y prueba de hermeticidad', 18000.00, N'Seguridad Industrial Norte'),
(8, '2026-04-18', N'Preventivo', N'Actualización de firmware y cambio de batería', 9500.00, N'Comunicaciones Delta'),
(9, '2026-04-18', N'Preventivo', N'Actualización de firmware y cambio de batería', 9500.00, N'Comunicaciones Delta'),
(10, '2022-01-20', N'Correctivo', N'Reparación de fuente de alimentación; sin repuestos, se da de baja', 6000.00, N'Comunicaciones Delta')
GO

INSERT INTO Incidentes (FechaHora, Direccion, Descripcion, Severidad) VALUES
('20260114 03:20', N'Av. San Martín 1520', N'Incendio en vivienda familiar', N'Alta'),
('20260203 17:45', N'Ruta 5 km 112', N'Choque entre dos vehículos con personas atrapadas', N'Critica'),
('20260319 11:10', N'Calle Belgrano 340', N'Principio de incendio en cocina de local comercial', N'Media'),
('20260427 21:05', N'Barrio Los Álamos, manzana 8', N'Persona con dificultad respiratoria', N'Media'),
('20260608 09:30', N'Escuela N° 14, Calle Mitre 900', N'Inspección preventiva y simulacro de evacuación', N'Baja'),
('20260722 14:50', N'Camino Rural km 7', N'Incendio de pastizales', N'Alta'),
('20260905 23:40', N'Pasaje Rivadavia 55', N'Pérdida de gas en edificio', N'Alta'),
('20261009 16:15', N'Plaza Central', N'Persona atrapada en ascensor', N'Baja')
GO

INSERT INTO TipoMision (Nombre, Descripcion) VALUES
(N'Incendio', N'Combate y control de incendios'),
(N'Rescate', N'Rescate de personas y bienes'),
(N'Asistencia médica', N'Primeros auxilios y traslado de pacientes'),
(N'Prevención', N'Inspecciones, simulacros y charlas preventivas')
GO

INSERT INTO Misiones (IDIncidente, IDTipoMision, Nombre, FechaInicio, FechaFin, Estado) VALUES
(1, 1, N'Extinción de incendio en vivienda', '20260114 03:35', '20260114 05:10', N'Finalizada'),
(1, 3, N'Asistencia a familia afectada', '20260114 03:40', '20260114 04:30', N'Finalizada'),
(2, 2, N'Rescate de víctimas del choque', '20260203 18:00', '20260203 19:30', N'Finalizada'),
(2, 3, N'Asistencia médica en ruta', '20260203 18:00', '20260203 19:00', N'Finalizada'),
(3, 1, N'Control de incendio en local comercial', '20260319 11:20', '20260319 12:00', N'Finalizada'),
(4, 3, N'Traslado de paciente al hospital', '20260427 21:15', '20260427 22:00', N'Finalizada'),
(5, 4, N'Simulacro de evacuación escolar', '20260608 09:30', '20260608 11:30', N'Finalizada'),
(6, 1, N'Combate de incendio de pastizales', '20260722 15:10', '20260722 19:45', N'Finalizada'),
(7, 1, N'Control de fuga de gas', '20260905 23:50', '20260906 01:30', N'Finalizada'),
(8, 2, N'Rescate de persona en ascensor', '20261009 16:25', '20261009 17:10', N'Finalizada')
GO

INSERT INTO MisionVoluntario (IDMision, IDVoluntario, IDRol) VALUES
(1, 1, 3),
(1, 5, 1),
(1, 7, 3),
(1, 9, 1),
(2, 4, 1),
(2, 8, 1),
(3, 2, 2),
(3, 5, 1),
(3, 7, 3),
(3, 9, 1),
(4, 4, 1),
(4, 6, 1),
(5, 1, 3),
(5, 5, 1),
(6, 4, 1),
(6, 6, 1),
(7, 2, 2),
(7, 8, 1),
(7, 9, 2),
(8, 1, 3),
(8, 5, 1),
(8, 6, 1),
(8, 7, 3),
(8, 9, 1),
(9, 1, 3),
(9, 5, 1),
(9, 7, 3),
(10, 5, 1),
(10, 9, 1)
GO

INSERT INTO MisionVehiculo (IDMision, IDVehiculo, KIlometrajeInicial, KIlometrajeFinal) VALUES
(1, 1, 48200, 48214),
(1, 3, 35100, 35114),
(2, 5, 15010, 15018),
(3, 4, 22300, 22345),
(4, 5, 15102, 15148),
(5, 1, 48390, 48396),
(6, 5, 15400, 15412),
(7, 5, 15980, 15985),
(8, 2, 61500, 61540),
(8, 3, 35820, 35860),
(8, 5, 16300, 16342),
(9, 1, 49020, 49031),
(9, 5, 16900, 16909),
(10, 4, 23100, 23106)
GO

INSERT INTO MisionEquipamiento (IDMision, IDEquipamiento) VALUES
(1, 1), (1, 2), (1, 6), (1, 7),
(3, 3), (3, 8), (3, 9),
(5, 1), (5, 5),
(8, 1), (8, 2), (8, 5), (8, 8),
(9, 6), (9, 7), (9, 8),
(10, 3), (10, 8)
GO

INSERT INTO TipoEntrenamiento (Nombre) VALUES
(N'Cardio'),
(N'Simulación'),
(N'Rescate'),
(N'Manejo de vehículos')
GO

INSERT INTO Entrenamientos (IDTipoEntrenamiento, Fecha, Observaciones) VALUES
(1, '2026-03-05', N'Circuito de resistencia'),
(2, '2026-04-12', N'Simulacro de incendio estructural'),
(3, '2026-05-18', N'Rescate en altura con cuerdas'),
(4, '2026-06-20', N'Práctica de conducción de autobomba'),
(2, '2026-08-08', N'Simulacro de evacuación del cuartel'),
(1, '2026-09-10', N'Circuito de resistencia y fuerza')
GO

INSERT INTO AsistenciaEntrenamiento (IDEntrenamiento, IDVoluntario, Observaciones) VALUES
(1, 1, N'Buen desempeño'),
(1, 4, NULL),
(1, 6, N'Debe mejorar la resistencia'),
(2, 1, NULL),
(2, 5, NULL),
(2, 8, N'Primera participación en un simulacro'),
(3, 2, NULL),
(3, 5, NULL),
(3, 9, NULL),
(4, 5, NULL),
(4, 7, NULL),
(4, 9, N'Maniobras en espacios reducidos'),
(5, 4, NULL),
(5, 8, NULL),
(5, 12, NULL),
(6, 4, NULL),
(6, 6, NULL),
(6, 8, NULL)
GO

INSERT INTO Guardias (IDVoluntario, Fecha, HoraInicio, HoraFin) VALUES
(1, '2026-10-03', '08:00', '20:00'),
(5, '2026-10-03', '08:00', '20:00'),
(4, '2026-10-03', '20:00', '08:00'),
(6, '2026-10-03', '20:00', '08:00'),
(3, '2026-10-04', '08:00', '20:00'),
(7, '2026-10-04', '08:00', '20:00'),
(2, '2026-10-04', '20:00', '08:00'),
(9, '2026-10-04', '20:00', '08:00'),
(1, '2026-10-10', '08:00', '20:00'),
(8, '2026-10-10', '08:00', '20:00'),
(5, '2026-10-10', '20:00', '08:00'),
(9, '2026-10-10', '20:00', '08:00'),
(12, '2026-10-11', '08:00', '16:00'),
(7, '2026-10-11', '16:00', '00:00')
GO

INSERT INTO Caja (Nombre) VALUES
(N'Caja General'),
(N'Caja Chica')
GO

INSERT INTO TipoAporte (Nombre) VALUES
(N'Donación'),
(N'Subsidio estatal'),
(N'Evento benéfico'),
(N'Fondos propios')
GO

INSERT INTO Donantes (Nombre, TipoDonante, DocumentoFiscal, Telefono, Email) VALUES
(N'Constructora Del Valle S.A.', N'Empresa', N'30-71234567-8', N'11-4600-2001', N'contacto@delvalle.com'),
(N'Gobierno de la Provincia', N'Organismo', N'30-67890123-4', NULL, NULL),
(N'Municipalidad', N'Organismo', N'30-54321098-7', N'11-4600-2003', N'intendencia@municipio.gob'),
(N'Familia Herrera', N'Persona', N'14234567', N'11-4600-2004', NULL),
(N'Panadería La Espiga', N'Empresa', N'30-70123456-9', N'11-4600-2005', NULL),
(N'Roberto Suárez', N'Persona', N'20876543', NULL, N'rsuarez@mail.com'),
(N'Club de Leones', N'Organismo', N'30-65432109-5', N'11-4600-2007', N'clubleones@mail.com')
GO

INSERT INTO Aportes (IDTipoAporte, IDCaja, IDDonante, Fecha, Monto, Descripcion) VALUES
(2, 1, 2, '2026-01-10', 500000.00, N'Subsidio provincial anual'),
(1, 1, 1, '2026-02-14', 150000.00, N'Donación de empresa constructora local'),
(3, 1, NULL, '2026-03-28', 85000.00, N'Cena benéfica por el aniversario del cuartel'),
(1, 1, 4, '2026-05-06', 60000.00, N'Donación de la familia Herrera'),
(4, 2, NULL, '2026-06-01', 40000.00, N'Cuotas de socios colaboradores'),
(3, 1, NULL, '2026-08-15', 72000.00, N'Rifa solidaria'),
(2, 1, 3, '2026-09-01', 200000.00, N'Subsidio municipal para equipamiento'),
(1, 2, 6, '2026-09-20', 25000.00, N'Donación particular'),
(1, 1, 5, '2026-10-05', 30000.00, N'Donación de panadería local'),
(1, 1, 7, '2026-10-20', 45000.00, N'Donación del Club de Leones')
GO

INSERT INTO TipoGasto (Nombre) VALUES
(N'Mantenimiento'),
(N'Combustible'),
(N'Equipamiento'),
(N'Capacitación')
GO

INSERT INTO Gastos (Fecha, Monto, Descripcion, IDTipoGasto, IDVoluntarioAutorizador, IDCaja) VALUES
('2026-02-05', 45000.00, N'Carga de combustible de autobombas', 2, 3, 1),
('2026-03-02', 120000.00, N'Service de la Autobomba 01', 1, 3, 1),
('2026-04-10', 210000.00, N'Reposición de mangueras y accesorios', 3, 3, 1),
('2026-05-20', 35000.00, N'Curso de primeros auxilios para voluntarios', 4, 12, 1),
('2026-06-15', 18500.00, N'Combustible de la camioneta rural', 2, 1, 2),
('2026-07-25', 64000.00, N'Reparación de bomba del camión cisterna', 1, 3, 1),
('2026-08-30', 92000.00, N'Compra de cascos de reposición', 3, 12, 1),
('2026-09-18', 27000.00, N'Cambio de neumáticos de la camioneta rural', 1, 1, 2),
('2026-10-28', 12000.00, N'Reparación de manguera 45 mm', 1, 12, 1)
GO

INSERT INTO MovimientoCaja (IDCaja, Fecha, TipoMovimiento, Monto, Concepto, IDAporte, IDGasto) VALUES
(1, '20260110 10:00', N'Ingreso', 500000.00, N'Subsidio provincial anual', 1, NULL),
(2, '20260115 10:00', N'Ingreso', 50000.00, N'Fondo inicial de caja chica', NULL, NULL),
(1, '20260205 09:30', N'Egreso', 45000.00, N'Combustible de autobombas', NULL, 1),
(1, '20260214 11:15', N'Ingreso', 150000.00, N'Donación de empresa constructora', 2, NULL),
(1, '20260302 15:00', N'Egreso', 120000.00, N'Service de la Autobomba 01', NULL, 2),
(1, '20260328 23:00', N'Ingreso', 85000.00, N'Cena benéfica', 3, NULL),
(1, '20260410 10:45', N'Egreso', 210000.00, N'Mangueras y accesorios', NULL, 3),
(1, '20260506 12:00', N'Ingreso', 60000.00, N'Donación de la familia Herrera', 4, NULL),
(1, '20260520 14:00', N'Egreso', 35000.00, N'Curso de primeros auxilios', NULL, 4),
(2, '20260601 10:00', N'Ingreso', 40000.00, N'Cuotas de socios colaboradores', 5, NULL),
(2, '20260615 08:45', N'Egreso', 18500.00, N'Combustible de la camioneta rural', NULL, 5),
(2, '20260701 10:00', N'Ingreso', 20000.00, N'Reposición del fondo', NULL, NULL),
(1, '20260725 16:20', N'Egreso', 64000.00, N'Reparación bomba del camión cisterna', NULL, 6),
(1, '20260815 22:00', N'Ingreso', 72000.00, N'Rifa solidaria', 6, NULL),
(1, '20260830 11:00', N'Egreso', 92000.00, N'Cascos de reposición', NULL, 7),
(1, '20260901 09:00', N'Ingreso', 200000.00, N'Subsidio municipal', 7, NULL),
(2, '20260918 17:30', N'Egreso', 27000.00, N'Neumáticos de la camioneta rural', NULL, 8),
(2, '20260920 12:00', N'Ingreso', 25000.00, N'Donación particular', 8, NULL),
(1, '20261005 10:30', N'Ingreso', 30000.00, N'Donación de panadería local', 9, NULL),
(1, '20261020 11:00', N'Ingreso', 45000.00, N'Donación del Club de Leones', 10, NULL),
(1, '20261028 15:00', N'Egreso', 12000.00, N'Reparación de manguera 45 mm', NULL, 9)
GO