CREATE DATABASE DB_Bomberos
Collate Latin1_General_CI_AI
GO
USE DB_Bomberos;
GO
 
-- 1. PERSONAL
CREATE TABLE Voluntarios (
    IDVoluntario INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Apellido NVARCHAR(100) NOT NULL,
    DNI NVARCHAR(10) NOT NULL UNIQUE,
    FechaNacimiento DATE NOT NULL,
    Telefono NVARCHAR(30) NULL,
    Email NVARCHAR(100) NULL,
    Direccion NVARCHAR(200) NULL,
    FechaIngreso DATE NOT NULL DEFAULT GETDATE(),
    Estado NVARCHAR(30) NOT NULL DEFAULT 'Activo'
)
GO
 
CREATE TABLE Rangos (
    IDRango INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO
 
-- Un voluntario solo puede tener un rango vigente (FechaHasta IS NULL) a la vez
CREATE TABLE HistorialRangos (
    IDHistorialRango INT PRIMARY KEY IDENTITY(1,1),
    IDVoluntario INT NOT NULL,
    IDRango INT NOT NULL,
    FechaDesde DATE NOT NULL,
    FechaHasta DATE NULL, -- NULL si es el rango actual
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario),
    FOREIGN KEY (IDRango) REFERENCES Rangos(IDRango)
)
GO
 
CREATE TABLE Roles (
    IDRol INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO

-- Un voluntario puede tener varios roles a la vez, pero no el mismo rol vigente dos veces 
CREATE TABLE HistorialRoles (
    IDHistorialRol INT PRIMARY KEY IDENTITY(1,1),
    IDVoluntario INT NOT NULL,
    IDRol INT NOT NULL,
    FechaDesde DATE NOT NULL,
    FechaHasta DATE NULL, -- NULL si es el rol actual
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario),
    FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
)
GO
 

-- 2. VEH�CULOS
CREATE TABLE TipoVehiculo (
    IDTipoVehiculo INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO
 
CREATE TABLE Vehiculos (
    IDVehiculo INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(100) NOT NULL,
    Año INT NOT NULL,
    Patente NVARCHAR(10) NOT NULL UNIQUE,
    Estado NVARCHAR(30) NOT NULL DEFAULT 'Operativo',
    IDTipoVehiculo INT NOT NULL,
    FOREIGN KEY (IDTipoVehiculo) REFERENCES TipoVehiculo(IDTipoVehiculo)
)
GO
 
CREATE TABLE DocumentacionVehiculo (
    IDDocumento INT PRIMARY KEY IDENTITY(1,1),
    IDVehiculo INT NOT NULL,
    TipoDocumento NVARCHAR(50) NOT NULL,
    FechaEmision DATE NOT NULL,
    FechaVencimiento DATE NOT NULL,
    Estado NVARCHAR(30) NOT NULL DEFAULT 'Vigente',
    FOREIGN KEY (IDVehiculo) REFERENCES Vehiculos(IDVehiculo)
)
GO
 
-- 3. EQUIPAMIENTO
CREATE TABLE TipoEquipamiento (
    IDTipoEquipamiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO
 
CREATE TABLE CategoriaEquipamiento (
    IDCategoriaEquipamiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO
 
CREATE TABLE Equipamiento (
    IDEquipamiento INT PRIMARY KEY IDENTITY(1,1),
    CodigoInterno NVARCHAR(20) NOT NULL UNIQUE,
    Nombre NVARCHAR(100) NOT NULL,
    Estado NVARCHAR(30) NOT NULL DEFAULT 'Disponible',
    FechaCompra DATE NULL,
    FechaProximoMantenimiento DATE NULL,   -- fecha programada a futuro
    IDTipoEquipamiento INT NOT NULL,
    IDCategoriaEquipamiento INT NOT NULL,
    FOREIGN KEY (IDTipoEquipamiento) REFERENCES TipoEquipamiento(IDTipoEquipamiento),
    FOREIGN KEY (IDCategoriaEquipamiento) REFERENCES CategoriaEquipamiento(IDCategoriaEquipamiento)
)
GO

CREATE TABLE MantenimientosEquipamiento (
    IDMantenimiento INT PRIMARY KEY IDENTITY(1,1),
    IDEquipamiento INT NOT NULL,
    FechaMantenimiento DATE NOT NULL DEFAULT GETDATE(),
    TipoMantenimiento NVARCHAR(20) NOT NULL
        CHECK (TipoMantenimiento IN ('Preventivo', 'Correctivo')),
    TareasRealizadas NVARCHAR(500) NOT NULL,
    Costo DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (Costo >= 0),
    Responsable NVARCHAR(100) NULL,        -- taller o proveedor que lo realizó
    FOREIGN KEY (IDEquipamiento) REFERENCES Equipamiento(IDEquipamiento)
)
GO
 
-- 4. OPERACIONES Y EMERGENCIAS

CREATE TABLE Incidentes (
    IDIncidente INT PRIMARY KEY IDENTITY(1,1),
    FechaHora DATETIME NOT NULL DEFAULT GETDATE(),
    Direccion NVARCHAR(200) NOT NULL,
    Descripcion NVARCHAR(500) NULL,
    Severidad NVARCHAR(20) NOT NULL
)
GO
 
CREATE TABLE TipoMision (
    IDTipoMision INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(250) NULL
)
GO
 
CREATE TABLE Misiones (
    IDMision INT PRIMARY KEY IDENTITY(1,1),
    IDIncidente INT NOT NULL,
    IDTipoMision INT NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    FechaInicio DATETIME NOT NULL,
    FechaFin DATETIME NULL,
    Estado NVARCHAR(30) NOT NULL DEFAULT 'En curso',
    FOREIGN KEY (IDIncidente) REFERENCES Incidentes(IDIncidente),
    FOREIGN KEY (IDTipoMision) REFERENCES TipoMision(IDTipoMision)
)
GO
 
CREATE TABLE MisionVoluntario (
    IDMision INT NOT NULL,
    IDVoluntario INT NOT NULL,
    IDRol INT NOT NULL,
    PRIMARY KEY (IDMision, IDVoluntario),
    FOREIGN KEY (IDMision) REFERENCES Misiones(IDMision),
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario),
    FOREIGN KEY (IDRol) REFERENCES Roles(IDRol)
)
GO
 
CREATE TABLE MisionVehiculo (
    IDMision INT NOT NULL,
    IDVehiculo INT NOT NULL,
    KIlometrajeInicial INT NOT NULL,
    KIlometrajeFinal INT NOT NULL,
    PRIMARY KEY (IDMision, IDVehiculo),
    FOREIGN KEY (IDMision) REFERENCES Misiones(IDMision),
    FOREIGN KEY (IDVehiculo) REFERENCES Vehiculos(IDVehiculo)
)
GO
 
CREATE TABLE MisionEquipamiento (
    IDMision INT NOT NULL,
    IDEquipamiento INT NOT NULL,
    PRIMARY KEY (IDMision, IDEquipamiento),
    FOREIGN KEY (IDMision) REFERENCES Misiones(IDMision),
    FOREIGN KEY (IDEquipamiento) REFERENCES Equipamiento(IDEquipamiento)
)
GO
 

-- 5. CAPACITACI�N
CREATE TABLE TipoEntrenamiento (
    IDTipoEntrenamiento INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO
 
CREATE TABLE Entrenamientos (
    IDEntrenamiento INT PRIMARY KEY IDENTITY(1,1),
    IDTipoEntrenamiento INT NOT NULL,
    Fecha DATE NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    FOREIGN KEY (IDTipoEntrenamiento) REFERENCES TipoEntrenamiento(IDTipoEntrenamiento),
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario)
)
GO

CREATE TABLE AsistenciaEntrenamiento (
    IDEntrenamiento INT PRIMARY KEY IDENTITY(1,1),
    IDVoluntario INT NOT NULL,
    Observaciones NVARCHAR(500) NULL,
    FOREIGN KEY (IDVoluntario) REFERENCES Entrenamientos(IDEntrenamiento),
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario)
)
GO
 
--  6. GUARDIAS
CREATE TABLE Guardias (
    IDGuardia INT PRIMARY KEY IDENTITY(1,1),
    IDVoluntario INT NOT NULL,
    Fecha DATE NOT NULL,
    HoraInicio TIME NOT NULL,
    HoraFin TIME NOT NULL,
    FOREIGN KEY (IDVoluntario) REFERENCES Voluntarios(IDVoluntario)
)
GO
 
--7. GESTIÓN FINANCIERA

CREATE TABLE Caja (
    IDCaja INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE TipoAporte (
    IDTipoAporte INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO

-- Origen de los aportes: persona, empresa u organismo (ej. subsidio)
CREATE TABLE Donantes (
    IDDonante INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(150) NOT NULL,
    TipoDonante NVARCHAR(30) NOT NULL
        CHECK (TipoDonante IN ('Persona', 'Empresa', 'Organismo')),
    DocumentoFiscal NVARCHAR(20) NULL,   -- DNI o CUIT
    Telefono NVARCHAR(30) NULL,
    Email NVARCHAR(100) NULL
)
GO

CREATE TABLE Aportes (
    IDAporte INT PRIMARY KEY IDENTITY(1,1),
    IDTipoAporte INT NOT NULL,
    IDCaja INT NOT NULL,                 
    IDDonante INT NULL,                  
    Fecha DATE NOT NULL DEFAULT GETDATE(),
    Monto DECIMAL(12,2) NOT NULL CHECK (Monto > 0),
    Descripcion NVARCHAR(250) NULL,
    FOREIGN KEY (IDTipoAporte) REFERENCES TipoAporte(IDTipoAporte),
    FOREIGN KEY (IDCaja) REFERENCES Caja(IDCaja),
    FOREIGN KEY (IDDonante) REFERENCES Donantes(IDDonante)
)
GO

CREATE TABLE TipoGasto (
    IDTipoGasto INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL
)
GO

CREATE TABLE Gastos (
    IDGasto INT PRIMARY KEY IDENTITY(1,1),
    Fecha DATE NOT NULL DEFAULT GETDATE(),
    Monto DECIMAL(12,2) NOT NULL CHECK (Monto > 0),
    Descripcion NVARCHAR(250) NULL,
    IDTipoGasto INT NOT NULL,
    IDVoluntarioAutorizador INT NOT NULL,
    IDCaja INT NOT NULL,                 -- caja de la que sale el dinero
    FOREIGN KEY (IDTipoGasto) REFERENCES TipoGasto(IDTipoGasto),
    FOREIGN KEY (IDVoluntarioAutorizador) REFERENCES Voluntarios(IDVoluntario),
    FOREIGN KEY (IDCaja) REFERENCES Caja(IDCaja)
)
GO

CREATE TABLE MovimientoCaja (
    IDMovimiento INT PRIMARY KEY IDENTITY(1,1),
    IDCaja INT NOT NULL,
    Fecha DATETIME NOT NULL DEFAULT GETDATE(),
    TipoMovimiento NVARCHAR(10) NOT NULL
        CHECK (TipoMovimiento IN ('Ingreso', 'Egreso')),
    Monto DECIMAL(12,2) NOT NULL CHECK (Monto > 0),
    Concepto NVARCHAR(250) NULL,
    IDAporte INT NULL,                   -- origen si es un ingreso por aporte
    IDGasto INT NULL,                    -- origen si es un egreso por gasto
    FOREIGN KEY (IDCaja) REFERENCES Caja(IDCaja),
    FOREIGN KEY (IDAporte) REFERENCES Aportes(IDAporte),
    FOREIGN KEY (IDGasto) REFERENCES Gastos(IDGasto),
    CONSTRAINT CK_MovimientoCaja_Origen CHECK (
        (TipoMovimiento = 'Ingreso' AND IDGasto IS NULL)
        OR (TipoMovimiento = 'Egreso' AND IDAporte IS NULL)
    )
)
GO