# Manual de Usuario

**Sistema de Gestión de Cuartel de Bomberos Voluntarios**

---

## 1. Ingreso y navegación

Al abrir el sistema se muestra el **Dashboard**. A la izquierda está el **menú lateral**, agrupado por módulo:

| Menú | Opciones |
|---|---|
| Dashboard | Resumen general |
| Personal | Voluntarios · Rangos · Historial de rangos · Roles · Historial de roles |
| Vehículos | Vehículos · Tipos de vehículo · Documentación |
| Equipamiento | Equipamiento · Tipos de equipamiento · Categorías |
| Operaciones | Incidentes · Misiones · Tipos de misión |
| Capacitación | Entrenamientos · Tipos de entrenamiento |
| Guardias | Guardias |
| Finanzas | Aportes · Tipos de aporte · Gastos · Tipos de gasto · Cajas · Movimientos de caja |
| Reportes | Personal · Operaciones · Vehículos · Equipamiento · Finanzas |

En celulares y tablets el menú se abre con el botón ☰ de la barra superior.

### 1.1 Funcionamiento común de las pantallas

Todas las pantallas de administración siguen el mismo esquema:

1. **Nuevo**: botón rojo arriba a la derecha. Abre el formulario de alta.
2. **Formulario**: los campos con <span style="color:red">*</span> son obligatorios. Si falta un dato o tiene un formato
   incorrecto, aparece un aviso debajo del campo. Al presionar **Guardar** el sistema verifica además las reglas del
   cuartel (por ejemplo, que el DNI no esté repetido) y muestra un aviso amarillo si algo no se cumple.
3. **Filtros**: permiten buscar y acotar el listado. **Limpiar** quita todos los filtros.
4. **Listado**: muestra 10 registros por página (con los números de página abajo). En cada fila:
   * ✏️ **Editar**: carga el registro en el formulario.
   * 🗑️ **Eliminar**: pide confirmación. Si el registro está relacionado con otros datos, el sistema no lo elimina y lo informa.

Mensajes: **verde** = operación correcta, **amarillo** = dato o regla a revisar, **rojo** = error del sistema o de conexión.

Formatos: fechas `dd/mm/aaaa`; importes con coma decimal (`15000,50`). También se aceptan `15000.50` y `15.000,50`.

---

## 2. Dashboard

Muestra en tiempo real:

* Voluntarios activos, vehículos operativos, equipamiento disponible y misiones en curso.
* Guardias activas en este momento y guardias programadas hoy.
* Saldo total de cajas, gastos del mes y aportes del mes.
* **Alertas** (barra amarilla): documentos vencidos o por vencer y mantenimientos próximos. Cada alerta es un enlace al detalle.
* Gráficos: aportes vs. gastos de los últimos 12 meses, misiones por tipo, equipamiento por estado, vehículos por estado
  e incidentes por severidad.

El botón **Registrar incidente** abre directamente el alta de un incidente.

---

## 3. Personal

### 3.1 Voluntarios

* **Alta**: *Nuevo voluntario* → completar apellido, nombre, DNI (7 u 8 dígitos, sin puntos), fecha de nacimiento
  (mínimo 16 años), fecha de ingreso, estado y, opcionalmente, teléfono, email y dirección.
* **Búsqueda**: por nombre, apellido, DNI o email. **Filtro** por estado (Activo, Licencia, Inactivo, Baja).
* 👁️ **Ver ficha**: muestra los datos completos, edad, años de servicio, rango actual, roles vigentes y la cantidad de
  misiones, entrenamientos y guardias, con accesos directos a cada historial.
* **Baja** (ícono de persona tachada): el voluntario pasa a estado *Baja*. **No se borra**: se conserva todo su historial.
  Para reactivarlo, editarlo y cambiar el estado.

### 3.2 Rangos y Roles

Listas de valores (por ejemplo: Bombero, Cabo, Sargento, Oficial / Operativo, Instructor, Jefe de Unidad). La columna
*En uso* indica cuántos registros los utilizan; los que están en uso no se pueden eliminar.

### 3.3 Historial de rangos

> Regla: **un voluntario no puede tener más de un rango vigente al mismo tiempo.**

* **Registrar ascenso** (botón verde): elegir el voluntario (se muestra su rango actual), el nuevo rango y la fecha.
  El sistema cierra el rango vigente en esa fecha y registra el nuevo como vigente.
* **Nuevo registro**: para cargar períodos históricos. Si se deja *Hasta* vacío, el rango queda vigente.
* Filtros: voluntario y *Solo vigentes*.

### 3.4 Historial de roles

Un voluntario puede tener **varios roles a la vez**, pero no el mismo rol vigente dos veces.

* **Asignar rol**: voluntario, rol y fecha desde (*Hasta* vacío = vigente).
* ⏹️ **Finalizar vigencia** (solo en roles vigentes): indicar la fecha de finalización.

---

## 4. Vehículos

### 4.1 Vehículos

* Datos: nombre o identificación, patente (`ABC123`, `AB123CD` o `A123BCD`), año, tipo y estado
  (Operativo, En mantenimiento, Fuera de servicio).
* Búsqueda por **patente**, **estado** y **tipo**.
* La columna *Documentación* indica en rojo si el vehículo tiene documentos vencidos; el enlace lleva a sus documentos.
* Un vehículo que participó en misiones no se puede eliminar: hay que pasarlo a *Fuera de servicio*.

### 4.2 Documentación de vehículos

Registra VTV, seguros, habilitaciones, inspecciones técnicas, etc.

| Indicador | Significado |
|---|---|
| 🔴 Rojo | Vencido |
| 🟡 Amarillo | Vence en los próximos 30 días |
| 🟢 Verde | Vigente |

* Las tres tarjetas superiores muestran cuántos documentos hay en cada situación; al hacer clic se filtra el listado.
* Las filas vencidas se resaltan en rojo y las próximas a vencer en amarillo. La columna *Días* indica cuánto falta o
  hace cuánto venció.
* Para **renovar** un documento, editarlo y cargar las nuevas fechas de emisión y vencimiento.

---

## 5. Equipamiento

* Datos: código interno (ej. `EQ-011`), nombre, estado (Disponible, En uso, En mantenimiento, Fuera de servicio, Baja),
  tipo, categoría, fecha de compra, último y próximo mantenimiento.
* Accesos rápidos: **Disponible**, **En mantenimiento**, **Fuera de servicio**, **Todos**.
* Filtros por texto, estado, tipo y categoría.
* Si el próximo mantenimiento ya pasó, la fecha aparece en rojo con un ícono de alerta.
* **Tipos** (Protección personal, Herramienta, Comunicación...) y **Categorías** (Casco, Manguera, Radios...) se
  administran desde el menú.

---

## 6. Operaciones

### 6.1 Incidentes

* Datos: fecha y hora, dirección, severidad (Baja, Media, Alta, Crítica) y descripción.
* Filtros por período, severidad y texto.
* En cada fila: enlace a sus misiones y botón verde ➕ para **generar una misión** a partir del incidente.

### 6.2 Misiones

* Datos: incidente, tipo de misión, nombre, inicio, fin y estado.
* Estados: **En curso** (sin fecha de fin), **Finalizada** (requiere fecha de fin) y **Cancelada**.
* La misión no puede comenzar antes del incidente.
* Al crear una misión el sistema abre automáticamente la pantalla de **asignación de recursos**.
* La columna *Recursos* muestra la cantidad de voluntarios / vehículos / equipos asignados.

### 6.3 Asignación de recursos

Desde el botón verde 👥 de una misión:

* El encabezado muestra los datos de la misión y del incidente.
* Hay tres paneles: **Voluntarios**, **Vehículos** y **Equipamiento**. Para agregar, se elige un elemento del desplegable
  y se presiona ➕. Para quitar, se usa ✖.
* Solo se ofrecen voluntarios *Activos*, vehículos *Operativos* y equipos que no estén dados de baja. Un recurso no se
  puede asignar dos veces.
* A una misión **cancelada** no se le pueden asignar recursos.

---

## 7. Capacitación

### Entrenamientos

* Registrar: voluntario, tipo de entrenamiento, fecha y observaciones.
* **Historial por voluntario**: al filtrar por un voluntario se muestra un resumen con el total de entrenamientos, la
  fecha del último y la cantidad por tipo. Desde la ficha del voluntario hay un acceso directo.

---

## 8. Guardias

* Registrar: voluntario, fecha, hora de inicio y hora de fin. Si la hora de fin es menor que la de inicio
  (ej. 20:00 a 08:00), la guardia termina al día siguiente y se indica "(+1 día)".
* El sistema no permite guardias superpuestas para el mismo voluntario.
* **Guardias por fecha**: indicar la misma fecha en *Desde* y *Hasta*, o usar el botón **Hoy**.
* **Guardias por voluntario**: elegir el voluntario en el filtro.
* Las guardias que están transcurriendo se marcan como **En curso**. El encabezado del listado muestra el total de guardias y de horas.

---

## 9. Finanzas

### 9.1 Aportes

* Registrar: tipo (Donación, Subsidio estatal, Evento benéfico, Fondos propios...), fecha, monto y descripción.
* Filtros por período y tipo; botón **Mes actual**. El total del listado se muestra arriba a la derecha.
* Accesos a los reportes **Aportes mensuales** y **Aportes por tipo**.

### 9.2 Gastos

* Registrar: tipo, fecha, monto, descripción y **voluntario autorizador** (obligatorio, debe ser un voluntario registrado
  que no esté dado de baja).
* Filtros por período, tipo y autorizador.

### 9.3 Cajas y movimientos de caja

* **Cajas** (menú Finanzas → Cajas): alta de cajas, por ejemplo *Caja General* o *Caja Chica*.
* **Movimientos de caja**: arriba se ve el **saldo** de cada caja con sus ingresos y egresos totales.
* Registrar: caja, fecha y hora, tipo (**Ingreso** o **Egreso**, únicos valores permitidos), monto y concepto.
* Un egreso no puede dejar la caja con saldo negativo: el sistema informa el saldo disponible.
* Los importes se muestran en verde (ingresos) y rojo (egresos), con el neto del período filtrado.

---

## 10. Reportes

Menú **Reportes** → elegir la categoría. Cada categoría muestra pestañas con sus reportes:

| Categoría | Reportes |
|---|---|
| Personal | Voluntarios activos · Historial de rangos · Historial de roles |
| Operaciones | Incidentes por período · Misiones por estado · Misiones por voluntario |
| Vehículos | Vehículos operativos · Documentación vencida (y próxima a vencer) |
| Equipamiento | Equipamiento por estado (disponible, en mantenimiento, fuera de servicio...) · Próximos mantenimientos |
| Finanzas | Aportes por período · Aportes mensuales · Aportes por tipo · Gastos por período · Gastos por tipo · Saldo por caja · Movimientos de caja (con saldo acumulado) |

Uso:
1. Elegir la pestaña del reporte.
2. Completar los filtros que aparecen (período, voluntario, estado, caja, año o días, según el reporte).
3. **Generar**: muestra el resultado paginado.
4. **Exportar CSV**: descarga el reporte completo para abrirlo en Excel.
5. **Imprimir**: imprime el resultado sin menús ni botones.

---

## 11. Preguntas frecuentes

| Situación | Qué hacer |
|---|---|
| "No se puede eliminar: ... está siendo utilizado" | El registro tiene datos asociados. En voluntarios use la **baja**; en vehículos y equipos cambie el estado. |
| "El voluntario ya posee un rango vigente" | Use **Registrar ascenso** o cargue una fecha *Hasta* en el rango anterior. |
| "Saldo insuficiente" | El egreso supera el saldo de la caja. Verifique el monto o registre antes el ingreso correspondiente. |
| "No se pudo conectar con la base de datos" | Avise al administrador: SQL Server no está disponible o la configuración es incorrecta. |
| Un voluntario no aparece para asignar a una misión | Solo se listan voluntarios en estado *Activo* y que todavía no están asignados a esa misión. |
