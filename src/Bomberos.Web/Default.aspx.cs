using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.Script.Serialization;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web
{
    /// <summary>
    /// Dashboard: indicadores principales y gráficos (Chart.js).
    /// </summary>
    public partial class _Default : BasePage
    {
        private readonly DashboardBLL _bll = new DashboardBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                CargarDashboard();
        }

        private void CargarDashboard()
        {
            try
            {
                CultureInfo ar = CultureInfo.GetCultureInfo("es-AR");
                DashboardIndicadores ind = _bll.ObtenerIndicadores();

                litVoluntarios.Text = ind.VoluntariosActivos.ToString();
                litVoluntariosTotal.Text = "de " + ind.VoluntariosTotales + " registrados (sin bajas)";
                litVehiculos.Text = ind.VehiculosOperativos.ToString();
                litVehiculosTotal.Text = "de " + ind.VehiculosTotales + " vehículos";
                litEquipamiento.Text = ind.EquipamientoDisponible.ToString();
                litEquipamientoTotal.Text = "de " + ind.EquipamientoTotal + " equipos (sin bajas)";
                litMisiones.Text = ind.MisionesEnCurso.ToString();
                litGuardias.Text = ind.GuardiasActivas.ToString();
                litGuardiasHoy.Text = ind.GuardiasHoy + " guardias programadas hoy";
                litSaldo.Text = ind.SaldoTotalCajas.ToString("C0", ar);
                litGastos.Text = ind.GastosMes.ToString("C0", ar);
                litAportes.Text = ind.AportesMes.ToString("C0", ar);
                string mes = ar.TextInfo.ToTitleCase(DateTime.Today.ToString("MMMM yyyy", ar));
                litMes1.Text = mes;
                litMes2.Text = mes;

                // Alertas
                lnkDocVencidos.Text = ind.DocumentosVencidos + " documento(s) de vehículos vencido(s)";
                lnkDocVencidos.Visible = ind.DocumentosVencidos > 0;
                lnkDocPorVencer.Text = ind.DocumentosPorVencer + " documento(s) por vencer en 30 días";
                lnkDocPorVencer.Visible = ind.DocumentosPorVencer > 0;
                lnkMantenimientos.Text = ind.MantenimientosProximos + " mantenimiento(s) de equipos en los próximos 30 días";
                lnkMantenimientos.Visible = ind.MantenimientosProximos > 0;
                pnlAlertas.Visible = lnkDocVencidos.Visible || lnkDocPorVencer.Visible || lnkMantenimientos.Visible;

                // Datos para los gráficos (se serializan a JSON)
                List<FinanzaMensual> finanzas = _bll.FinanzasMensuales(12);
                var datos = new
                {
                    finanzas = new
                    {
                        periodos = finanzas.Select(f => f.Periodo).ToArray(),
                        aportes = finanzas.Select(f => f.Aportes).ToArray(),
                        gastos = finanzas.Select(f => f.Gastos).ToArray()
                    },
                    misiones = Serie(_bll.MisionesPorTipo()),
                    equipamiento = Serie(_bll.EquipamientoPorEstado()),
                    vehiculos = Serie(_bll.VehiculosPorEstado()),
                    incidentes = Serie(_bll.IncidentesPorSeveridad())
                };
                // JavaScriptSerializer escapa "<" y ">" como < / >, seguro para incrustar en <script>.
                litDatosJson.Text = new JavaScriptSerializer().Serialize(datos);
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        private static object Serie(List<SerieDato> serie)
        {
            return new
            {
                etiquetas = serie.Select(s => s.Etiqueta).ToArray(),
                valores = serie.Select(s => s.Valor).ToArray()
            };
        }
    }
}
