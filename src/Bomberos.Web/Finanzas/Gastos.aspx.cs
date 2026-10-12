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
    /// ABM de gastos. Regla: debe seleccionarse un voluntario autorizador existente.
    /// </summary>
    public partial class Gastos : BasePage
    {
        private readonly GastoBLL _bll = new GastoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvGastos.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    CargarCatalogo(ddlTipo, TipoCatalogo.TipoGasto, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoGasto, "(Todos)");
                    var voluntarios = new VoluntarioBLL().Combo(false);
                    CargarCombo(ddlAutorizador, voluntarios, "-- Seleccione --");
                    CargarCombo(ddlFiltroAutorizador, voluntarios, "(Todos)");
                }
                catch (Exception ex)
                {
                    ManejarExcepcion(ex);
                }
                CargarGrilla();
            }
        }

        private void CargarGrilla()
        {
            try
            {
                List<Gasto> lista = _bll.Listar(LeerFecha(txtDesde), LeerFecha(txtHasta), IdFiltro(ddlFiltroTipo), IdFiltro(ddlFiltroAutorizador));
                litTotal.Text = "Total: " + FormatearMoneda(lista.Sum(g => g.Monto));
                gvGastos.DataSource = lista;
                gvGastos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvGastos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnMes_Click(object sender, EventArgs e)
        {
            DateTime inicio = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            EscribirFecha(txtDesde, inicio);
            EscribirFecha(txtHasta, inicio.AddMonths(1).AddDays(-1));
            gvGastos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtDesde.Text = txtHasta.Text = string.Empty;
            ddlFiltroTipo.ClearSelection();
            ddlFiltroAutorizador.ClearSelection();
            gvGastos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvGastos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvGastos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvGastos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Gasto g = _bll.Obtener(id);
                    if (g == null) { MostrarAdvertencia("El gasto ya no existe."); CargarGrilla(); return; }
                    IdEdicion = g.IDGasto;
                    Seleccionar(ddlTipo, g.IDTipoGasto);
                    EscribirFecha(txtFecha, g.Fecha);
                    txtMonto.Text = g.Monto.ToString("0.00").Replace('.', ',');
                    txtDescripcion.Text = g.Descripcion;
                    // Si el autorizador fue dado de baja no figura en el combo: se agrega para poder visualizarlo
                    if (ddlAutorizador.Items.FindByValue(g.IDVoluntarioAutorizador.ToString()) == null)
                        ddlAutorizador.Items.Add(new ListItem(g.AutorizadorNombre + " (baja)", g.IDVoluntarioAutorizador.ToString()));
                    Seleccionar(ddlAutorizador, g.IDVoluntarioAutorizador);
                    MostrarFormulario("Modificar gasto");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Gasto eliminado.");
                    CargarGrilla();
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
            ddlTipo.ClearSelection();
            ddlAutorizador.ClearSelection();
            EscribirFecha(txtFecha, DateTime.Today);
            txtMonto.Text = txtDescripcion.Text = string.Empty;
            MostrarFormulario("Nuevo gasto");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Gasto g = new Gasto
                {
                    IDGasto = IdEdicion,
                    IDTipoGasto = IdSeleccionado(ddlTipo),
                    IDVoluntarioAutorizador = IdSeleccionado(ddlAutorizador),
                    Fecha = LeerFecha(txtFecha) ?? DateTime.MinValue,
                    Monto = LeerDecimal(txtMonto),
                    Descripcion = txtDescripcion.Text
                };
                bool esAlta = g.IDGasto == 0;
                _bll.Guardar(g);
                OcultarFormulario();
                MostrarExito(esAlta ? "Gasto registrado correctamente." : "Gasto actualizado correctamente.");
                CargarGrilla();
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
