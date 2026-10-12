using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Capacitacion
{
    /// <summary>
    /// ABM de entrenamientos y consulta del historial por voluntario.
    /// </summary>
    public partial class Entrenamientos : BasePage
    {
        private readonly EntrenamientoBLL _bll = new EntrenamientoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvEntrenamientos.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    var voluntarios = new VoluntarioBLL().Combo(false);
                    CargarCombo(ddlVoluntario, voluntarios, "-- Seleccione --");
                    CargarCombo(ddlFiltroVoluntario, voluntarios, "(Todos)");
                    CargarCatalogo(ddlTipo, TipoCatalogo.TipoEntrenamiento, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoEntrenamiento, "(Todos)");
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
                List<Entrenamiento> lista = _bll.Listar(IdFiltro(ddlFiltroVoluntario), IdFiltro(ddlFiltroTipo), LeerFecha(txtDesde), LeerFecha(txtHasta));
                gvEntrenamientos.DataSource = lista;
                gvEntrenamientos.DataBind();

                // Historial por voluntario: resumen por tipo
                pnlResumen.Visible = IdFiltro(ddlFiltroVoluntario).HasValue;
                if (pnlResumen.Visible)
                {
                    string porTipo = string.Join(" &middot; ", lista.GroupBy(x => x.TipoNombre)
                        .Select(g => Html(g.Key) + ": <strong>" + g.Count() + "</strong>"));
                    litResumen.Text = "<span><strong>" + Html(ddlFiltroVoluntario.SelectedItem.Text) + "</strong> &mdash; "
                        + lista.Count + " entrenamiento(s)" + (lista.Count > 0 ? ". Último: " + lista.Max(x => x.Fecha).ToString("dd/MM/yyyy") : "")
                        + "</span><span>" + porTipo + "</span>";
                }
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvEntrenamientos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlFiltroVoluntario.ClearSelection();
            ddlFiltroTipo.ClearSelection();
            txtDesde.Text = txtHasta.Text = string.Empty;
            gvEntrenamientos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvEntrenamientos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvEntrenamientos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvEntrenamientos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Entrenamiento en = _bll.Obtener(id);
                    if (en == null) { MostrarAdvertencia("El registro ya no existe."); CargarGrilla(); return; }
                    IdEdicion = en.IDEntrenamiento;
                    Seleccionar(ddlVoluntario, en.IDVoluntario);
                    Seleccionar(ddlTipo, en.IDTipoEntrenamiento);
                    EscribirFecha(txtFecha, en.Fecha);
                    txtObservaciones.Text = en.Observaciones;
                    MostrarFormulario("Modificar entrenamiento");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Entrenamiento eliminado.");
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
            ddlTipo.ClearSelection();
            EscribirFecha(txtFecha, DateTime.Today);
            txtObservaciones.Text = string.Empty;
            MostrarFormulario("Registrar entrenamiento");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Entrenamiento en = new Entrenamiento
                {
                    IDEntrenamiento = IdEdicion,
                    IDVoluntario = IdSeleccionado(ddlVoluntario),
                    IDTipoEntrenamiento = IdSeleccionado(ddlTipo),
                    Fecha = LeerFecha(txtFecha) ?? DateTime.MinValue,
                    Observaciones = txtObservaciones.Text
                };
                bool esAlta = en.IDEntrenamiento == 0;
                _bll.Guardar(en);
                OcultarFormulario();
                MostrarExito(esAlta ? "Entrenamiento registrado correctamente." : "Entrenamiento actualizado correctamente.");
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
