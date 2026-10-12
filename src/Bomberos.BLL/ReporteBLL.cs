using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Catálogo de reportes disponibles y su ejecución.
    /// Solo se pueden ejecutar los reportes definidos aquí (lista blanca de Stored Procedures).
    /// </summary>
    public class ReporteBLL
    {
        public const string CatPersonal = "personal";
        public const string CatOperaciones = "operaciones";
        public const string CatVehiculos = "vehiculos";
        public const string CatEquipamiento = "equipamiento";
        public const string CatFinanzas = "finanzas";

        private readonly ReporteDAL _dal = new ReporteDAL();

        private static readonly List<ReporteDefinicion> Definiciones = new List<ReporteDefinicion>
        {
            // Personal
            Def("voluntarios-activos", CatPersonal, "Voluntarios activos", "Voluntarios en estado Activo con su rango y roles vigentes.", "sp_Rpt_VoluntariosActivos", ParametroReporte.Ninguno),
            Def("historial-rangos", CatPersonal, "Historial de rangos", "Evolución de rangos de todos los voluntarios o de uno en particular.", "sp_Rpt_HistorialRangos", ParametroReporte.Voluntario),
            Def("historial-roles", CatPersonal, "Historial de roles", "Roles desempeñados a lo largo del tiempo.", "sp_Rpt_HistorialRoles", ParametroReporte.Voluntario),

            // Operaciones
            Def("incidentes-periodo", CatOperaciones, "Incidentes por período", "Incidentes ocurridos entre dos fechas, con misiones y voluntarios intervinientes.", "sp_Rpt_IncidentesPorPeriodo", ParametroReporte.Periodo),
            Def("misiones-estado", CatOperaciones, "Misiones por estado", "Misiones filtradas por estado (En curso, Finalizada, Cancelada).", "sp_Rpt_MisionesPorEstado", ParametroReporte.EstadoMision),
            Def("misiones-voluntario", CatOperaciones, "Misiones por voluntario", "Sin seleccionar voluntario muestra un resumen; con voluntario, el detalle de sus misiones.", "sp_Rpt_MisionesPorVoluntario", ParametroReporte.Voluntario),

            // Vehículos
            Def("vehiculos-operativos", CatVehiculos, "Vehículos operativos", "Vehículos en estado Operativo con su situación documental.", "sp_Rpt_VehiculosOperativos", ParametroReporte.Ninguno),
            Def("documentacion-vencida", CatVehiculos, "Documentación vencida", "Documentos vencidos y próximos a vencer dentro de los días indicados.", "sp_Rpt_DocumentacionVencida", ParametroReporte.Dias, 30),

            // Equipamiento
            Def("equipamiento-estado", CatEquipamiento, "Equipamiento por estado", "Equipamiento disponible, en mantenimiento, fuera de servicio, etc.", "sp_Rpt_EquipamientoPorEstado", ParametroReporte.EstadoEquipo),
            Def("proximos-mantenimientos", CatEquipamiento, "Próximos mantenimientos", "Equipos con mantenimiento atrasado o programado dentro de los días indicados.", "sp_Rpt_ProximosMantenimientos", ParametroReporte.Dias, 90),

            // Finanzas
            Def("aportes-periodo", CatFinanzas, "Aportes por período", "Detalle de aportes recibidos entre dos fechas.", "sp_Rpt_AportesPorPeriodo", ParametroReporte.Periodo),
            Def("aportes-mensuales", CatFinanzas, "Aportes mensuales", "Total de aportes por mes del año seleccionado.", "sp_Rpt_AportesMensuales", ParametroReporte.Anio),
            Def("aportes-tipo", CatFinanzas, "Aportes por tipo", "Total y porcentaje de aportes agrupados por tipo.", "sp_Rpt_AportesPorTipo", ParametroReporte.Periodo),
            Def("gastos-periodo", CatFinanzas, "Gastos por período", "Detalle de gastos entre dos fechas con su autorizador.", "sp_Rpt_GastosPorPeriodo", ParametroReporte.Periodo),
            Def("gastos-tipo", CatFinanzas, "Gastos por tipo", "Total de gastos agrupados por tipo.", "sp_Rpt_GastosPorTipo", ParametroReporte.Periodo),
            Def("saldo-caja", CatFinanzas, "Saldo por caja", "Ingresos, egresos y saldo actual de cada caja.", "sp_Rpt_SaldoPorCaja", ParametroReporte.Ninguno),
            Def("movimientos-caja", CatFinanzas, "Movimientos de caja", "Movimientos con saldo acumulado, por caja y período.", "sp_Rpt_MovimientosCaja", ParametroReporte.Caja | ParametroReporte.Periodo)
        };

        private static ReporteDefinicion Def(string clave, string categoria, string titulo, string descripcion,
                                             string sp, ParametroReporte parametros, int diasPorDefecto = 0)
        {
            return new ReporteDefinicion
            {
                Clave = clave,
                Categoria = categoria,
                Titulo = titulo,
                Descripcion = descripcion,
                StoredProcedure = sp,
                Parametros = parametros,
                DiasPorDefecto = diasPorDefecto
            };
        }

        public static string TituloCategoria(string categoria)
        {
            switch (categoria)
            {
                case CatPersonal: return "Personal";
                case CatOperaciones: return "Operaciones";
                case CatVehiculos: return "Vehículos";
                case CatEquipamiento: return "Equipamiento";
                case CatFinanzas: return "Finanzas";
                default: return "Reportes";
            }
        }

        public List<ReporteDefinicion> ListarPorCategoria(string categoria)
        {
            return Definiciones.Where(d => d.Categoria == categoria).ToList();
        }

        public ReporteDefinicion Obtener(string clave)
        {
            return Definiciones.FirstOrDefault(d => d.Clave == clave);
        }

        public DataTable Ejecutar(string clave, FiltroReporte filtro)
        {
            ReporteDefinicion def = Obtener(clave);
            if (def == null)
                throw new ValidacionException("El reporte solicitado no existe.");

            filtro = filtro ?? new FiltroReporte();
            new Validador()
                .Regla(!(filtro.Desde.HasValue && filtro.Hasta.HasValue) || filtro.Desde <= filtro.Hasta,
                       "La fecha 'desde' no puede ser posterior a la fecha 'hasta'.")
                .Regla(!def.Usa(ParametroReporte.Anio) || (filtro.Anio >= 2000 && filtro.Anio <= DateTime.Today.Year + 1),
                       "Ingrese un año válido.")
                .Regla(!def.Usa(ParametroReporte.Dias) || !filtro.Dias.HasValue || (filtro.Dias >= 0 && filtro.Dias <= 3650),
                       "La cantidad de días debe estar entre 0 y 3650.")
                .Lanzar();

            return _dal.Ejecutar(def, filtro);
        }
    }
}
