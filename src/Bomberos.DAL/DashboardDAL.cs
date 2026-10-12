using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Consultas de indicadores y series para la página inicial.
    /// </summary>
    public class DashboardDAL
    {
        public DashboardIndicadores ObtenerIndicadores()
        {
            return SqlHelper.EjecutarUno("sp_Dashboard_Indicadores", r => new DashboardIndicadores
            {
                VoluntariosActivos = r.LeerInt("VoluntariosActivos"),
                VoluntariosTotales = r.LeerInt("VoluntariosTotales"),
                VehiculosOperativos = r.LeerInt("VehiculosOperativos"),
                VehiculosTotales = r.LeerInt("VehiculosTotales"),
                EquipamientoDisponible = r.LeerInt("EquipamientoDisponible"),
                EquipamientoTotal = r.LeerInt("EquipamientoTotal"),
                MisionesEnCurso = r.LeerInt("MisionesEnCurso"),
                GuardiasActivas = r.LeerInt("GuardiasActivas"),
                GuardiasHoy = r.LeerInt("GuardiasHoy"),
                SaldoTotalCajas = r.LeerDecimal("SaldoTotalCajas"),
                GastosMes = r.LeerDecimal("GastosMes"),
                AportesMes = r.LeerDecimal("AportesMes"),
                DocumentosVencidos = r.LeerInt("DocumentosVencidos"),
                DocumentosPorVencer = r.LeerInt("DocumentosPorVencer"),
                MantenimientosProximos = r.LeerInt("MantenimientosProximos")
            }) ?? new DashboardIndicadores();
        }

        public List<FinanzaMensual> FinanzasMensuales(int meses)
        {
            return SqlHelper.EjecutarLista("sp_Dashboard_FinanzasMensuales", r => new FinanzaMensual
            {
                Periodo = r.LeerString("Periodo"),
                Aportes = r.LeerDecimal("Aportes"),
                Gastos = r.LeerDecimal("Gastos")
            }, SqlHelper.P("@Meses", meses));
        }

        /// <summary>
        /// Ejecuta un SP de serie (Etiqueta, Valor). Los nombres válidos se definen en la BLL.
        /// </summary>
        public List<SerieDato> Serie(string storedProcedure)
        {
            return SqlHelper.EjecutarLista(storedProcedure, MapearSerie);
        }

        private static SerieDato MapearSerie(IDataRecord r)
        {
            return new SerieDato { Etiqueta = r.LeerString("Etiqueta"), Valor = r.LeerDecimal("Valor") };
        }
    }
}
