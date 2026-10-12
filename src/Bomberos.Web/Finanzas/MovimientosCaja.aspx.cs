using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Finanzas
{
    /// <summary>
    /// ABM de movimientos de caja (Ingreso / Egreso) con saldos por caja.
    /// </summary>
    public partial class MovimientosCaja : BasePage
    {
        private readonly MovimientoCajaBLL _bll = new MovimientoCajaBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvMovimientos.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    CargarCatalogo(ddlCaja, TipoCatalogo.Caja, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroCaja, TipoCatalogo.Caja, "(Todas)");
                    CargarCombo(ddlFiltroTipo, Constantes.TiposMovimiento, "(Todos)");
                    rblTipo.Items.Clear();
                    foreach (string t in Constantes.TiposMovimiento)
                        rblTipo.Items.Add(new ListItem(t, t));
                    Seleccionar(ddlFiltroCaja, Request.QueryString["caja"]);
                }
                catch (Exception ex)
                {
                    ManejarExcepcion(ex);
                }
                CargarDatos();
            }
        }

        private void CargarDatos()
        {
            try
            {
                rptSaldos.DataSource = _bll.Saldos();
                rptSaldos.DataBind();

                List<MovimientoCaja> lista = _bll.Listar(IdFiltro(ddlFiltroCaja), LeerFecha(txtDesde), LeerFecha(txtHasta), TextoFiltro(ddlFiltroTipo));
                decimal ingresos = lista.Where(m => m.TipoMovimiento == Constantes.MovimientoIngreso).Sum(m => m.Monto);
                decimal egresos = lista.Where(m => m.TipoMovimiento == Constantes.MovimientoEgreso).Sum(m => m.Monto);
                litTotales.Text = "<span class=\"text-success\">Ingresos " + FormatearMoneda(ingresos) + "</span> &middot; "
                                + "<span class=\"text-danger\">Egresos " + FormatearMoneda(egresos) + "</span> &middot; "
                                + "<strong>Neto " + FormatearMoneda(ingresos - egresos) + "</strong>";
                gvMovimientos.DataSource = lista;
                gvMovimientos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvMovimientos.PageIndex = 0;
            CargarDatos();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlFiltroCaja.ClearSelection();
            ddlFiltroTipo.ClearSelection();
            txtDesde.Text = txtHasta.Text = string.Empty;
            gvMovimientos.PageIndex = 0;
            CargarDatos();
        }

        protected void gvMovimientos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMovimientos.PageIndex = e.NewPageIndex;
            CargarDatos();
        }

        protected void gvMovimientos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    MovimientoCaja m = _bll.Obtener(id);
                    if (m == null) { MostrarAdvertencia("El movimiento ya no existe."); CargarDatos(); return; }
                    IdEdicion = m.IDMovimiento;
                    Seleccionar(ddlCaja, m.IDCaja);
                    EscribirFechaHora(txtFecha, m.Fecha);
                    rblTipo.ClearSelection();
                    ListItem item = rblTipo.Items.FindByValue(m.TipoMovimiento);
                    if (item != null) item.Selected = true;
                    txtMonto.Text = m.Monto.ToString("0.00").Replace('.', ',');
                    txtConcepto.Text = m.Concepto;
                    MostrarFormulario("Modificar movimiento");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Movimiento eliminado.");
                    CargarDatos();
                }
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            IdEdicion = 0;
            Seleccionar(ddlCaja, ddlFiltroCaja.SelectedValue);
            EscribirFechaHora(txtFecha, DateTime.Now);
            rblTipo.ClearSelection();
            txtMonto.Text = txtConcepto.Text = string.Empty;
            MostrarFormulario("Nuevo movimiento");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                MovimientoCaja m = new MovimientoCaja
                {
                    IDMovimiento = IdEdicion,
                    IDCaja = IdSeleccionado(ddlCaja),
                    Fecha = LeerFechaHora(txtFecha) ?? DateTime.MinValue,
                    TipoMovimiento = rblTipo.SelectedValue,
                    Monto = LeerDecimal(txtMonto),
                    Concepto = txtConcepto.Text
                };
                bool esAlta = m.IDMovimiento == 0;
                _bll.Guardar(m);
                OcultarFormulario();
                MostrarExito(esAlta ? "Movimiento registrado correctamente." : "Movimiento actualizado correctamente.");
                CargarDatos();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            OcultarFormulario();
        }

        private void MostrarFormulario(string titulo)
        {
            litTituloFormulario.Text = titulo;
            pnlFormulario.Visible = true;
        }

        private void OcultarFormulario()
        {
            pnlFormulario.Visible = false;
            IdEdicion = 0;
        }
    }
}
