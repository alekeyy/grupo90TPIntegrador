using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Personal
{
    /// <summary>
    /// ABM del historial de roles: asignación de roles y finalización de vigencias.
    /// </summary>
    public partial class HistorialRoles : BasePage
    {
        private readonly HistorialRolBLL _bll = new HistorialRolBLL();

        /// <summary>ID del registro cuya vigencia se va a finalizar.</summary>
        private int IdFinalizar
        {
            get { return ViewState["IdFinalizar"] == null ? 0 : (int)ViewState["IdFinalizar"]; }
            set { ViewState["IdFinalizar"] = value; }
        }

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
                    CargarCatalogo(ddlRol, TipoCatalogo.Roles, "-- Seleccione --");
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
                HistorialRol h;
                switch (e.CommandName)
                {
                    case "Editar":
                        h = _bll.Obtener(id);
                        if (h == null) { MostrarAdvertencia("El registro ya no existe."); CargarGrilla(); return; }
                        IdEdicion = h.IDHistorialRol;
                        Seleccionar(ddlVoluntario, h.IDVoluntario);
                        Seleccionar(ddlRol, h.IDRol);
                        EscribirFecha(txtDesde, h.FechaDesde);
                        EscribirFecha(txtHasta, h.FechaHasta);
                        litTituloFormulario.Text = "Modificar rol de " + h.VoluntarioNombre;
                        pnlFormulario.Visible = true;
                        pnlFinalizar.Visible = false;
                        break;
                    case "Finalizar":
                        h = _bll.Obtener(id);
                        if (h == null) { MostrarAdvertencia("El registro ya no existe."); CargarGrilla(); return; }
                        IdFinalizar = id;
                        litFinalizarDetalle.Text = "Rol <strong>" + Html(h.RolNombre) + "</strong> de <strong>" + Html(h.VoluntarioNombre)
                                                   + "</strong>, vigente desde el " + h.FechaDesde.ToString("dd/MM/yyyy") + ".";
                        EscribirFecha(txtFechaFin, DateTime.Today);
                        pnlFinalizar.Visible = true;
                        pnlFormulario.Visible = false;
                        break;
                    case "Eliminar":
                        _bll.Eliminar(id);
                        MostrarExito("Registro eliminado.");
                        CargarGrilla();
                        break;
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
            ddlRol.ClearSelection();
            EscribirFecha(txtDesde, DateTime.Today);
            txtHasta.Text = string.Empty;
            litTituloFormulario.Text = "Asignar nuevo rol";
            pnlFormulario.Visible = true;
            pnlFinalizar.Visible = false;
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                HistorialRol h = new HistorialRol
                {
                    IDHistorialRol = IdEdicion,
                    IDVoluntario = IdSeleccionado(ddlVoluntario),
                    IDRol = IdSeleccionado(ddlRol),
                    FechaDesde = LeerFecha(txtDesde) ?? DateTime.MinValue,
                    FechaHasta = LeerFecha(txtHasta)
                };
                bool esAlta = h.IDHistorialRol == 0;
                _bll.Guardar(h);
                Ocultar();
                MostrarExito(esAlta ? "Rol asignado correctamente." : "Registro actualizado correctamente.");
                CargarGrilla();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnConfirmarFinalizar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                _bll.FinalizarVigencia(IdFinalizar, LeerFecha(txtFechaFin) ?? DateTime.MinValue);
                Ocultar();
                MostrarExito("Vigencia del rol finalizada.");
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

        private void Ocultar()
        {
            pnlFormulario.Visible = false;
            pnlFinalizar.Visible = false;
            IdEdicion = 0;
            IdFinalizar = 0;
        }
    }
}
