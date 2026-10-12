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
    /// ABM de aportes con filtros por período y tipo.
    /// </summary>
    public partial class Aportes : BasePage
    {
        private readonly AporteBLL _bll = new AporteBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvAportes.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    CargarCatalogo(ddlTipo, TipoCatalogo.TipoAporte, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoAporte, "(Todos)");
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
                List<Aporte> lista = _bll.Listar(LeerFecha(txtDesde), LeerFecha(txtHasta), IdFiltro(ddlFiltroTipo));
                litTotal.Text = "Total: " + FormatearMoneda(lista.Sum(a => a.Monto));
                gvAportes.DataSource = lista;
                gvAportes.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvAportes.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnMes_Click(object sender, EventArgs e)
        {
            DateTime inicio = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
            EscribirFecha(txtDesde, inicio);
            EscribirFecha(txtHasta, inicio.AddMonths(1).AddDays(-1));
            gvAportes.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtDesde.Text = txtHasta.Text = string.Empty;
            ddlFiltroTipo.ClearSelection();
            gvAportes.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvAportes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvAportes.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvAportes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Aporte a = _bll.Obtener(id);
                    if (a == null) { MostrarAdvertencia("El aporte ya no existe."); CargarGrilla(); return; }
                    IdEdicion = a.IDAporte;
                    Seleccionar(ddlTipo, a.IDTipoAporte);
                    EscribirFecha(txtFecha, a.Fecha);
                    txtMonto.Text = a.Monto.ToString("0.00").Replace('.', ',');
                    txtDescripcion.Text = a.Descripcion;
                    MostrarFormulario("Modificar aporte");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Aporte eliminado.");
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
            EscribirFecha(txtFecha, DateTime.Today);
            txtMonto.Text = txtDescripcion.Text = string.Empty;
            MostrarFormulario("Nuevo aporte");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Aporte a = new Aporte
                {
                    IDAporte = IdEdicion,
                    IDTipoAporte = IdSeleccionado(ddlTipo),
                    Fecha = LeerFecha(txtFecha) ?? DateTime.MinValue,
                    Monto = LeerDecimal(txtMonto),
                    Descripcion = txtDescripcion.Text
                };
                bool esAlta = a.IDAporte == 0;
                _bll.Guardar(a);
                OcultarFormulario();
                MostrarExito(esAlta ? "Aporte registrado correctamente." : "Aporte actualizado correctamente.");
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
