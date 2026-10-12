# grupo90TPIntegrador — Sistema de Gestión de Cuartel de Bomberos Voluntarios

Aplicación base en **ASP.NET Web Forms (.NET Framework 4.8)** + **SQL Server**, con arquitectura en capas,
para que el equipo construya el sistema sobre ella.

## Contenido

| Ruta | Descripción |
|---|---|
| `1. Set-up.sql` | Creación de la base `DB_Bomberos`. |
| `2. Initial Data.sql` | Datos iniciales. |
| `Bomberos.sln` | Solución de Visual Studio. |
| `src/Bomberos.Entities` | Una clase por tabla de la base, con sus columnas. |
| `src/Bomberos.DAL` | `Conexion` (lee la cadena del Web.config) y `SqlHelper` (ejecución de comandos con ADO.NET). |
| `src/Bomberos.BLL` | Capa de negocio (vacía, a completar). |
| `src/Bomberos.Web` | Master Page con menú lateral (Bootstrap 5), página de inicio y una página vacía por tabla. |

## Puesta en marcha

1. Ejecutar en SQL Server `1. Set-up.sql` y `2. Initial Data.sql`.
2. Abrir `Bomberos.sln` con Visual Studio 2019/2022.
3. Ajustar la cadena de conexión `DBBomberos` en `src/Bomberos.Web/Web.config`.
4. Establecer `Bomberos.Web` como proyecto de inicio y ejecutar (F5).
