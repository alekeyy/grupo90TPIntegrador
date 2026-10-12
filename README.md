# grupo90TPIntegrador — Sistema de Gestión de Cuartel de Bomberos Voluntarios

Aplicación web en **ASP.NET Web Forms (.NET Framework 4.8)** + **SQL Server**, con arquitectura en capas
(Presentación / BLL / DAL / Entidades), ADO.NET sin Entity Framework y Stored Procedures para todas las operaciones.

## Contenido del repositorio

| Ruta | Descripción |
|---|---|
| `1. Set-up.sql` | Creación de la base `DB_Bomberos` (tablas y relaciones). |
| `2. Initial Data.sql` | Datos iniciales de ejemplo. |
| `3. Stored Procedures.sql` | 163 Stored Procedures (CRUD, validaciones, dashboard y reportes) + índices de integridad. |
| `4. Datos de ejemplo adicionales.sql` | Datos con fechas relativas al día de ejecución (misión en curso, guardias de hoy, movimientos del mes). Opcional. |
| `Bomberos.sln` | Solución de Visual Studio. |
| `src/Bomberos.Entities` | Entidades, constantes de dominio y excepción de datos compartida. |
| `src/Bomberos.DAL` | Acceso a datos: `Conexion`, `SqlHelper` y una clase DAL por entidad. |
| `src/Bomberos.BLL` | Reglas de negocio y validaciones. |
| `src/Bomberos.Web` | Interfaz Web Forms (Master Page, Bootstrap 5, Chart.js). |
| `docs/Manual Tecnico.md` | Arquitectura, instalación, base de datos y guía para extender el sistema. |
| `docs/Manual de Usuario.md` | Uso de cada módulo. |

## Puesta en marcha rápida

1. En SQL Server Management Studio ejecutar, en orden: `1. Set-up.sql`, `2. Initial Data.sql`,
   `3. Stored Procedures.sql` y (opcional) `4. Datos de ejemplo adicionales.sql`.
2. Abrir `Bomberos.sln` con Visual Studio 2019/2022 (carga de trabajo *ASP.NET y desarrollo web*).
3. Ajustar la cadena de conexión `DBBomberos` en `src/Bomberos.Web/Web.config` (por defecto `.\SQLEXPRESS` con seguridad integrada).
4. Establecer `Bomberos.Web` como proyecto de inicio y ejecutar (F5). Se abre el Dashboard en IIS Express.

Requisitos: Windows, .NET Framework 4.8 Developer Pack, SQL Server 2017 o superior (Express sirve) y conexión a internet
para Bootstrap, Bootstrap Icons y Chart.js (se cargan desde CDN).
