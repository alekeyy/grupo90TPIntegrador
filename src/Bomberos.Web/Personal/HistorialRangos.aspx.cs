using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Personal
{
    /// <summary>
    /// ABM del historial de rangos y registro de ascensos.
    /// </summary>
    public partial class HistorialRangos : BasePage
    {
        private readonly HistorialRangoBLL _bll = new HistorialRangoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvHistorial.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    var voluntarios = new VoluntarioBLL().Combo(false);
                    CargarCombo(ddlFiltroVoluntario, voluntarios, "(Todos)");
                    CargarCombo(ddlVoluntario, voluntarios, "-- Seleccione --");
                    CargarCombo(ddlAscVoluntario, voluntarios, "-- Seleccione --");
                    CargarCatalogo(ddlRango, TipoCatalogo.Rangos, "-- Seleccione --");
                    CargarCatalogo(ddlAscRango, TipoCatalogo.Rangos, "-- Seleccione --");
                    Seleccionar(ddlFiltroVoluntario, Request.QueryString["voluntario"]);
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
                gvHistorial.DataSource = _bll.Listar(IdFiltro(ddlFiltroVoluntario), chkSoloVigentes.Checked);
                gvHistorial.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvHistorial.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvHistorial_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvHistorial.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvHistorial_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    HistorialRango h = _bll.Obtener(id);
                    if (h == null) { MostrarAdvertencia("El registro ya no existe."); CargarGrilla(); return; }
                    IdEdicion = h.IDHistorialRango;
                    Seleccionar(ddlVoluntario, h.IDVoluntario);
                    Seleccionar(ddlRango, h.IDRango);
                    EscribirFecha(txtDesde, h.FechaDesde);
                    EscribirFecha(txtHasta, h.FechaHasta);
                    MostrarFormulario("Modificar historial de " + h.VoluntarioNombre);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Registro eliminado.");
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
            Seleccionar(ddlVoluntario, ddlFiltroVoluntario.SelectedValue);
            ddlRango.ClearSelection();
            EscribirFecha(txtDesde, DateTime.Today);
            txtHasta.Text = string.Empty;
            MostrarFormulario("Nuevo registro de rango");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                HistorialRango h = new HistorialRango
                {
                    IDHistorialRango = IdEdicion,
                    IDVoluntario = IdSeleccionado(ddlVoluntario),
                    IDRango = IdSeleccionado(ddlRango),
                    FechaDesde = LeerFecha(txtDesde) ?? DateTime.MinValue,
                    FechaHasta = LeerFecha(txtHasta)
                };
                bool esAlta = h.IDHistorialRango == 0;
                _bll.Guardar(h);
                Ocultar();
                MostrarExito(esAlta ? "Rango registrado correctamente." : "Registro actualizado correctamente.");
                CargarGrilla();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        // ---------------------- Ascenso ----------------------
        protected void btnAscenso_Click(object sender, EventArgs e)
        {
            Seleccionar(ddlAscVoluntario, ddlFiltroVoluntario.SelectedValue);
            ddlAscRango.ClearSelection();
            EscribirFecha(txtAscFecha, DateTime.Today);
            MostrarRangoActual();
            pnlFormulario.Visible = false;
            pnlAscenso.Visible = true;
        }

        protected void ddlAscVoluntario_SelectedIndexChanged(object sender, EventArgs e)
        {
            MostrarRangoActual();
        }

        private void MostrarRangoActual()
        {
            litRangoActual.Text = string.Empty;
            int id = IdSeleccionado(ddlAscVoluntario);
            if (id == 0) return;
            try
            {
                HistorialRango actual = _bll.ObtenerVigente(id);
                litRangoActual.Text = actual == null
                    ? "El voluntario no tiene rango vigente."
                    : "Rango vigente: <strong>" + Html(actual.RangoNombre) + "</strong> desde el " + actual.FechaDesde.ToString("dd/MM/yyyy") + ".";
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnConfirmarAscenso_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                _bll.RegistrarAscenso(IdSeleccionado(ddlAscVoluntario), IdSeleccionado(ddlAscRango), LeerFecha(txtAscFecha) ?? DateTime.MinValue);
                Seleccionar(ddlFiltroVoluntario, ddlAscVoluntario.SelectedValue);
                Ocultar();
                MostrarExito("Ascenso registrado correctamente.");
                CargarGrilla();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnCancelar_Click(object sender, EventArgs e)
        {
            Ocultar();
        }

        private void MostrarFormulario(string titulo)
        {
            litTituloFormulario.Text = titulo;
            pnlFormulario.Visible = true;
            pnlAscenso.Visible = false;
        }

        private void Ocultar()
        {
            pnlFormulario.Visible = false;
            pnlAscenso.Visible = false;
            IdEdicion = 0;
        }
    }
}
