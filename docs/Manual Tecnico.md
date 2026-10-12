# Manual Técnico

**Sistema de Gestión de Cuartel de Bomberos Voluntarios** · Grupo 90

---

## 1. Descripción general

Aplicación web que centraliza la información operativa, administrativa y financiera de un cuartel de bomberos
voluntarios: personal (voluntarios, rangos, roles y sus historiales), vehículos y documentación, equipamiento,
incidentes y misiones con sus recursos asignados, entrenamientos, guardias, aportes, gastos y cajas.

| Aspecto | Tecnología |
|---|---|
| Presentación | ASP.NET Web Forms (.NET Framework 4.8), Master Page, Bootstrap 5.3, Bootstrap Icons, Chart.js 4 |
| Lógica de negocio | Biblioteca de clases C# (BLL) |
| Acceso a datos | ADO.NET (`System.Data.SqlClient`), sin Entity Framework |
| Base de datos | SQL Server 2017+ con Stored Procedures |
| Lenguaje | C# 7.3 |

## 2. Arquitectura en capas

```
┌────────────────────────────────────────────────────────────┐
│ Bomberos.Web  (Presentation Layer)                         │
│  Site.Master · páginas .aspx · BasePage · Logger           │
│  Validadores ASP.NET (cliente) · GridView/DetailsView/FormView│
└───────────────▲────────────────────────────────────────────┘
                │ usa
┌───────────────┴────────────────────────────────────────────┐
│ Bomberos.BLL  (Business Layer)                             │
│  *BLL: validaciones, normalización y reglas de negocio     │
│  ValidacionException · Validador                           │
└───────────────▲────────────────────────────────────────────┘
                │ usa
┌───────────────┴────────────────────────────────────────────┐
│ Bomberos.DAL  (Data Access Layer)                          │
│  Conexion · SqlHelper · *DAL (mapeo IDataRecord → entidad) │
└───────────────▲────────────────────────────────────────────┘
                │ ADO.NET + Stored Procedures
┌───────────────┴────────────────────────────────────────────┐
│ SQL Server · DB_Bomberos · sp_*                            │
└────────────────────────────────────────────────────────────┘

Bomberos.Entities: entidades, constantes y DatosException (referenciado por todas las capas)
```

Reglas de dependencia:

* La **Web** referencia solo a **BLL** y **Entities** (nunca a la DAL). `Bomberos.DAL.dll` se copia al `bin` de la
  web como dependencia de la BLL.
* La **BLL** referencia a **DAL** y **Entities**.
* La **DAL** referencia solo a **Entities**.

### 2.1 Estructura de la solución

```
Bomberos.sln
src/
├─ Bomberos.Entities/      Voluntario, Vehiculo, Mision, ... · Constantes · TipoCatalogo · TipoRecurso
│                          ReporteDefinicion / FiltroReporte · DatosException
├─ Bomberos.DAL/           Conexion.cs · SqlHelper.cs · DataRecordExtensions.cs · <Entidad>DAL.cs
├─ Bomberos.BLL/           Validador.cs · ValidacionException.cs · <Entidad>BLL.cs · ReporteBLL.cs
└─ Bomberos.Web/
   ├─ Site.Master          Estructura, menú lateral y área de mensajes
   ├─ Default.aspx         Dashboard
   ├─ Error.aspx           Página de error amigable
   ├─ Code/                BasePage.cs · Logger.cs · TipoMensaje.cs
   ├─ Catalogos/           Catalogo.aspx (ABM genérico de catálogos)
   ├─ Personal/            Voluntarios · HistorialRangos · HistorialRoles
   ├─ Vehiculos/           Vehiculos · Documentacion
   ├─ Equipamiento/        Equipamiento
   ├─ Operaciones/         Incidentes · Misiones · MisionDetalle
   ├─ Capacitacion/        Entrenamientos
   ├─ Guardias/            Guardias
   ├─ Finanzas/            Aportes · Gastos · MovimientosCaja
   ├─ Reportes/            Reportes.aspx (todas las categorías)
   ├─ Content/site.css · Scripts/site.js
   └─ Web.config
```

## 3. Instalación

### 3.1 Requisitos

* Windows 10/11 o Windows Server con IIS / IIS Express.
* Visual Studio 2019 o 2022 con la carga de trabajo **ASP.NET y desarrollo web** (.NET Framework 4.8 Developer Pack).
* SQL Server 2017 o superior (Express o Developer) y SQL Server Management Studio.
* Acceso a internet desde el navegador (Bootstrap, iconos y Chart.js se cargan desde `cdn.jsdelivr.net`).

### 3.2 Base de datos

Ejecutar en SSMS, en este orden:

| # | Script | Contenido |
|---|---|---|
| 1 | `1. Set-up.sql` | Crea `DB_Bomberos` (intercalación `Latin1_General_CI_AI`) y las 23 tablas. |
| 2 | `2. Initial Data.sql` | Datos iniciales. |
| 3 | `3. Stored Procedures.sql` | Índices de integridad y 163 Stored Procedures. Se puede volver a ejecutar (usa `CREATE OR ALTER`). |
| 4 | `4. Datos de ejemplo adicionales.sql` | Opcional. Datos relativos a la fecha actual para que el Dashboard muestre valores. Se ejecuta una sola vez (lo verifica). |

> Los scripts 3 y 4 están codificados en UTF-8 con BOM (la tabla `Vehiculos` tiene la columna `[Año]`).
> SSMS los abre correctamente. Si se usa `sqlcmd`, indicar la página de códigos:
> `sqlcmd -S .\SQLEXPRESS -E -f 65001 -i "3. Stored Procedures.sql"`.

### 3.3 Aplicación

1. Abrir `Bomberos.sln`.
2. Editar la cadena de conexión en `src/Bomberos.Web/Web.config`:

   ```xml
   <add name="DBBomberos"
        connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=DB_Bomberos;Integrated Security=True;..."
        providerName="System.Data.SqlClient" />
   ```

   | Instancia | Data Source |
   |---|---|
   | SQL Server Express | `.\SQLEXPRESS` |
   | LocalDB | `(localdb)\MSSQLLocalDB` |
   | Instancia por defecto | `localhost` |
   | Autenticación SQL | reemplazar `Integrated Security=True` por `User ID=...;Password=...` |

3. Clic derecho en `Bomberos.Web` → *Establecer como proyecto de inicio* → **F5**.

La solución no usa paquetes NuGet: compila sin restaurar paquetes.

### 3.4 Publicación en IIS

1. Clic derecho en `Bomberos.Web` → *Publicar* → *Carpeta* (configuración **Release**). La transformación
   `Web.Release.config` quita `debug="true"` y activa `customErrors`.
2. Crear un sitio o aplicación en IIS apuntando a la carpeta publicada, con un *Application Pool* **.NET CLR v4.0 / Integrado**.
3. Con seguridad integrada, dar acceso a la base al usuario del Application Pool
   (`IIS APPPOOL\<NombreDelPool>`), o usar autenticación SQL en la cadena de conexión.
4. Dar permiso de escritura sobre `App_Data` a la identidad del pool (registro de errores).

### 3.5 Configuración (`appSettings`)

| Clave | Uso |
|---|---|
| `ValidationSettings:UnobtrusiveValidationMode` | `None`: los validadores usan el script clásico de ASP.NET (no requieren jQuery). |
| `NombreCuartel` | Texto de la barra superior. |
| `FilasPorPagina` | Filas por página de las grillas (por defecto 10). |

La cultura de la aplicación es **es-AR** (`<globalization culture="es-AR">`): moneda `$ 1.234,56` y fechas `dd/MM/yyyy`.

## 4. Base de datos

### 4.1 Modelo

```
Voluntarios ─┬─< HistorialRangos >── Rangos
             ├─< HistorialRoles  >── Roles
             ├─< Entrenamientos  >── TipoEntrenamiento
             ├─< Guardias
             ├─< Gastos          >── TipoGasto            (IDVoluntarioAutorizador)
             └─< MisionVoluntario >─┐
TipoVehiculo ──< Vehiculos ─┬─< DocumentacionVehiculo   │
                            └─< MisionVehiculo >────────┤
TipoEquipamiento ──┐                                    │
CategoriaEquip. ───┴─< Equipamiento ─< MisionEquipamiento >┤
Incidentes ──< Misiones >── TipoMision                  │
                  └─────────────────────────────────────┘
TipoAporte ──< Aportes
Caja ──< MovimientoCaja   (TipoMovimiento CHECK IN ('Ingreso','Egreso'))
```

### 4.2 Reglas de integridad agregadas por el script 3

| Objeto | Regla |
|---|---|
| `UX_HistorialRangos_Vigente` | Índice único filtrado `(IDVoluntario) WHERE FechaHasta IS NULL`: un solo rango vigente por voluntario. |
| `UX_HistorialRoles_Vigente` | Índice único filtrado `(IDVoluntario, IDRol) WHERE FechaHasta IS NULL`: el mismo rol no puede estar vigente dos veces. |

### 4.3 Convención de Stored Procedures

| Patrón | Uso |
|---|---|
| `sp_<Entidad>_Listar` | Consulta con filtros opcionales (`NULL` = sin filtro). |
| `sp_<Entidad>_Obtener` | Un registro por ID. |
| `sp_<Entidad>_Insertar` | Alta. Devuelve el ID generado (`SELECT ... AS ID`). |
| `sp_<Entidad>_Actualizar` | Modificación. |
| `sp_<Entidad>_Eliminar` | Baja física (verifica referencias antes de borrar). |
| `sp_<Entidad>_Validar` | Validación compartida por Insertar/Actualizar. |
| `sp_<Entidad>_Combo` | Pares `Valor`/`Texto` para los `DropDownList`. |
| `sp_Dashboard_*` | Indicadores y series para gráficos. |
| `sp_Rpt_*` | Reportes (columnas con nombres legibles). |

Errores de negocio: los SP usan `THROW 50001..50099, N'mensaje', 1`. La DAL detecta los números `>= 50000` y muestra
el mensaje tal cual al usuario.

| Número | Significado |
|---|---|
| 50001 | Duplicado (DNI, patente, código interno, nombre de catálogo, etc.) |
| 50002 | No se puede eliminar porque tiene registros relacionados |
| 50003 | Rango de fechas inválido |
| 50004 | El registro no existe |
| 50010–50015 | Historial de rangos y roles (vigencias y superposición) |
| 50020–50023 | Misiones (estado, fechas, fecha del incidente) |
| 50030–50034 | Asignación de recursos a misiones |
| 50040–50041 | Guardias (horario igual, superposición) |
| 50050–50052 | Montos y voluntario autorizador |
| 50060–50062 | Movimientos de caja (tipo, saldo insuficiente) |

### 4.4 Inventario de Stored Procedures

| Módulo | Stored Procedures |
|---|---|
| Catálogos (×10 tablas) | `sp_{Rangos, Roles, TipoVehiculo, TipoEquipamiento, CategoriaEquipamiento, TipoMision, TipoEntrenamiento, TipoAporte, TipoGasto, Caja}_{Listar, Obtener, Insertar, Actualizar, Eliminar}` |
| Voluntarios | `sp_Voluntarios_Listar/Obtener/Ficha/Insertar/Actualizar/BajaLogica/Combo` |
| Historial de rangos | `sp_HistorialRangos_Listar/Obtener/Validar/Insertar/Actualizar/Eliminar/Ascender` |
| Historial de roles | `sp_HistorialRoles_Listar/Obtener/Validar/Insertar/Actualizar/Finalizar/Eliminar` |
| Vehículos | `sp_Vehiculos_Listar/Obtener/Insertar/Actualizar/Eliminar/Combo` |
| Documentación | `sp_DocumentacionVehiculo_ActualizarEstados/Listar/Obtener/Insertar/Actualizar/Eliminar` |
| Equipamiento | `sp_Equipamiento_Listar/Obtener/Insertar/Actualizar/Eliminar/Combo` |
| Incidentes | `sp_Incidentes_Listar/Obtener/Insertar/Actualizar/Eliminar/Combo` |
| Misiones | `sp_Misiones_Listar/Obtener/Validar/Insertar/Actualizar/Eliminar/ValidarAsignacion` |
| Asignaciones | `sp_MisionVoluntario_*`, `sp_MisionVehiculo_*`, `sp_MisionEquipamiento_*` (`Listar/Agregar/Quitar`) |
| Entrenamientos | `sp_Entrenamientos_Listar/Obtener/Insertar/Actualizar/Eliminar` |
| Guardias | `sp_Guardias_Listar/Obtener/Validar/Insertar/Actualizar/Eliminar` |
| Aportes | `sp_Aportes_Listar/Obtener/Insertar/Actualizar/Eliminar` |
| Gastos | `sp_Gastos_Listar/Obtener/Validar/Insertar/Actualizar/Eliminar` |
| Caja | `sp_MovimientoCaja_Listar/Obtener/Validar/Insertar/Actualizar/Eliminar`, `sp_Caja_Saldos` |
| Dashboard | `sp_Dashboard_Indicadores/FinanzasMensuales/MisionesPorTipo/EquipamientoPorEstado/VehiculosPorEstado/IncidentesPorSeveridad` |
| Reportes | `sp_Rpt_VoluntariosActivos/HistorialRangos/HistorialRoles/IncidentesPorPeriodo/MisionesPorEstado/MisionesPorVoluntario/VehiculosOperativos/DocumentacionVencida/EquipamientoPorEstado/ProximosMantenimientos/AportesPorPeriodo/AportesMensuales/AportesPorTipo/GastosPorPeriodo/GastosPorTipo/SaldoPorCaja/MovimientosCaja` |

## 5. Capa de acceso a datos (DAL)

* **`Conexion`**: lee la cadena `DBBomberos` del `Web.config` y crea objetos `SqlConnection`.
* **`SqlHelper`** (clase reutilizable): `EjecutarLista<T>`, `EjecutarUno<T>`, `EjecutarDataTable`, `EjecutarNonQuery`,
  `EjecutarEscalar`, `EjecutarInsert`. Abre y cierra la conexión con `using`, ejecuta siempre `CommandType.StoredProcedure`
  y traduce `SqlException` a `DatosException` con un mensaje claro (violación de FK 547, duplicado 2601/2627,
  conexión fallida, timeout, SP inexistente, errores de negocio 50000+).
* **`SqlHelper.P(nombre, valor)`**: crea parámetros y convierte `null` en `DBNull.Value`. Todo es parametrizado, sin SQL
  concatenado. Los nombres de SP que se arman en tiempo de ejecución (catálogos y asignaciones) salen de enums, que
  funcionan como lista blanca.
* **`DataRecordExtensions`**: lectura de columnas por nombre con manejo de `NULL` (`LeerInt`, `LeerFechaNull`, ...).
* Cada `<Entidad>DAL` contiene un método `Mapear(IDataRecord)` explícito y un método por SP.

## 6. Capa de negocio (BLL)

* Normaliza textos (`Trim`, cadena vacía → `null`, mayúsculas en patentes y códigos).
* Valida con `Validador` (acumula todos los errores) y lanza `ValidacionException` con la lista completa.
* Reglas principales:

| Entidad | Reglas |
|---|---|
| Voluntario | Campos obligatorios, DNI de 7-8 dígitos, edad mínima 16 años, fechas no futuras, ingreso ≥ nacimiento, email y teléfono con formato válido, estado ∈ {Activo, Licencia, Inactivo, Baja}. La baja es **lógica** (estado `Baja`). |
| Historial de rangos | Un solo rango vigente; sin períodos superpuestos; ascenso transaccional (cierra el vigente y abre el nuevo). |
| Historial de roles | El mismo rol no puede estar vigente dos veces; finalización de vigencia con fecha ≥ inicio. |
| Vehículo | Patente argentina (`ABC123`, `AB123CD`, `A123BCD`, `123ABC`), año entre 1950 y el año próximo, estado ∈ {Operativo, En mantenimiento, Fuera de servicio}. |
| Documentación | Vencimiento posterior a la emisión. Semáforo: vencido (rojo), vence en ≤ 30 días (amarillo), vigente (verde). |
| Equipamiento | Código único, fechas coherentes (compra ≤ último mantenimiento ≤ próximo). |
| Incidente | Fecha no futura, severidad ∈ {Baja, Media, Alta, Critica}. |
| Misión | Estado ∈ {En curso, Finalizada, Cancelada}; si está finalizada debe tener fin; si está en curso no puede tenerlo; inicio ≥ fecha del incidente. Solo se asignan voluntarios *Activos*, vehículos *Operativos* y equipos *Disponibles/En uso*; no se asignan recursos a misiones canceladas. |
| Guardia | Inicio ≠ fin; si el fin es menor que el inicio, la guardia termina al día siguiente; un voluntario no puede tener guardias superpuestas. |
| Aporte / Gasto | Monto > 0, fecha no futura. El gasto exige un voluntario autorizador existente y no dado de baja (al editar se conserva el original aunque luego se haya dado de baja). |
| Movimiento de caja | Tipo ∈ {Ingreso, Egreso}; un egreso (o la eliminación de un ingreso) no puede dejar la caja en negativo. |

Las reglas críticas se validan **dos veces**: en la BLL (mensajes inmediatos) y en el SP (integridad garantizada aunque
se acceda a la base por otro medio).

## 7. Capa de presentación

* **Master Page** (`Site.Master`): menú lateral colapsable (offcanvas en móviles), barra superior y área de mensajes
  (`MostrarMensaje`) con alertas de Bootstrap. `site.js` marca el ítem del menú activo.
* **`BasePage`**: clase base de todas las páginas. Incluye:
  * `ManejarExcepcion(ex)`: `ValidacionException` → advertencia con lista; `DatosException` de negocio → advertencia;
    otros errores → mensaje genérico y registro en el log.
  * Lectura y escritura de fechas (`type="date"`, `datetime-local`, `time`), importes (acepta `1500.50`, `1500,50`,
    `1.500,50`) y combos.
  * Helpers para el markup: `ClaseEstado`, `ClaseSeveridad`, `FormatearMoneda`, `Html` (codificación HTML).
* **Patrón de las páginas ABM**: encabezado con botón *Nuevo* → panel de formulario (oculto hasta que se usa) →
  panel de filtros → `GridView` paginado con acciones *Editar* / *Eliminar* (con confirmación).
* **Controles**: `GridView` en todos los listados (con paginación), `DetailsView` en la ficha del voluntario,
  `FormView` en el encabezado de la misión (`MisionDetalle.aspx`) y `Repeater` en los saldos de caja y en las pestañas de reportes.
* **Validaciones de cliente**: `RequiredFieldValidator`, `RegularExpressionValidator`, `RangeValidator` y
  `CompareValidator`, agrupados por `ValidationGroup`. El servidor vuelve a verificar con `Page.IsValid` y luego la BLL.
* **Catálogo genérico**: `Catalogos/Catalogo.aspx?tipo=<TipoCatalogo>` resuelve el ABM de los 10 catálogos simples.
* **Reportes**: `Reportes/Reportes.aspx?cat=<categoria>&rep=<clave>`. `ReporteBLL` define cada reporte (SP y
  parámetros); la página muestra solo los filtros necesarios, da formato a las columnas según su tipo de dato, pagina,
  exporta a CSV (separador `;`, UTF-8) e imprime.
* **Dashboard**: indicadores (`sp_Dashboard_Indicadores`), alertas de vencimientos y 5 gráficos de Chart.js con datos
  serializados a JSON desde el servidor.
* **Diseño responsive**: grilla de Bootstrap, tablas con `table-responsive` y menú offcanvas por debajo de 992 px.

## 8. Manejo de errores y seguridad

| Mecanismo | Detalle |
|---|---|
| `try/catch` en cada evento | Todas las operaciones de las páginas pasan por `ManejarExcepcion`. |
| `Application_Error` (Global.asax) | Registra los errores no controlados en `App_Data/Logs/errores-AAAAMMDD.log`. |
| `customErrors` | Redirige a `Error.aspx` (en Release para todos; en Debug solo para usuarios remotos). |
| Inyección SQL | Solo Stored Procedures con parámetros. |
| XSS | `BoundField` codifica por defecto; las plantillas usan `Html(...)`; el JSON del dashboard se serializa con `JavaScriptSerializer`. |
| CSV | Se neutralizan valores que empiezan con `= + - @` (inyección de fórmulas). |
| Cabeceras | `X-Content-Type-Options: nosniff`, `X-Frame-Options: SAMEORIGIN`. |

> **Pendiente:** el sistema no tiene autenticación de usuarios (no estaba en el alcance). Para producción se recomienda
> agregar ASP.NET Identity o autenticación por formularios con roles (administrador, jefe de cuerpo, tesorería).

## 9. Cómo extender el sistema

**Agregar un catálogo simple** (tabla ID + Nombre):
1. Crear la tabla y los 5 SP `sp_<Tabla>_Listar/Obtener/Insertar/Actualizar/Eliminar` con el mismo contrato de columnas
   (`ID, Nombre, Descripcion, CantidadRegistros`).
2. Agregar el valor al enum `TipoCatalogo` y sus textos en `CatalogoBLL.Titulo/Modulo`.
3. Agregar el enlace `~/Catalogos/Catalogo.aspx?tipo=<Tabla>` en `Site.Master`.

**Agregar un reporte:**
1. Crear `sp_Rpt_<Nombre>` usando solo los parámetros estándar (`@Desde`, `@Hasta`, `@IDVoluntario`, `@Estado`,
   `@IDCaja`, `@Anio`, `@Dias`).
2. Registrarlo con `Def(...)` en `ReporteBLL.Definiciones`. Aparece automáticamente en su categoría.

**Agregar una entidad con ABM:** crear la entidad → `XxxDAL` (con `Mapear` y SP) → `XxxBLL` (validaciones) → página
`.aspx` que herede de `BasePage`, siguiendo como modelo `Vehiculos/Vehiculos.aspx`.

## 10. Verificación realizada

* Las 4 capas compilan con el compilador de C# y con MSBuild (xbuild), incluido el proyecto Web Application.
* Las 18 páginas se procesaron en un host de ASP.NET: compilación del markup, postbacks, validadores y mensajes de la BLL.
* Verificación estática del script de SP: bloques `BEGIN/END` balanceados, tablas y columnas existentes, y coincidencia
  de nombres y parámetros entre la DAL y los SP.
* **No verificado:** la ejecución contra una instancia real de SQL Server. Recomendamos correr los scripts 1 a 4 en SSMS
  y recorrer los módulos según el *Manual de Usuario* antes de la entrega.
