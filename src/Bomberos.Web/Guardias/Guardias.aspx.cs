using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Guardias
{
    /// <summary>
    /// ABM de guardias con consultas por fecha y por voluntario.
    /// (La clase se llama GuardiasPage para no colisionar con el namespace.)
    /// </summary>
    public partial class GuardiasPage : BasePage
    {
        private readonly GuardiaBLL _bll = new GuardiaBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvGuardias.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    var voluntarios = new VoluntarioBLL().Combo(false);
                    CargarCombo(ddlVoluntario, voluntarios, "-- Seleccione --");
                    CargarCombo(ddlFiltroVoluntario, voluntarios, "(Todos)");
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
                List<Guardia> lista = _bll.Listar(IdFiltro(ddlFiltroVoluntario), LeerFecha(txtDesde), LeerFecha(txtHasta));
                litResumen.Text = lista.Count + " guardia(s) · " + lista.Sum(g => g.DuracionHoras).ToString("0.#") + " horas";
                gvGuardias.DataSource = lista;
                gvGuardias.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvGuardias.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnHoy_Click(object sender, EventArgs e)
        {
            EscribirFecha(txtDesde, DateTime.Today);
            EscribirFecha(txtHasta, DateTime.Today);
            gvGuardias.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlFiltroVoluntario.ClearSelection();
            txtDesde.Text = txtHasta.Text = string.Empty;
            gvGuardias.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvGuardias_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvGuardias.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvGuardias_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Guardia g = _bll.Obtener(id);
                    if (g == null) { MostrarAdvertencia("La guardia ya no existe."); CargarGrilla(); return; }
                    IdEdicion = g.IDGuardia;
                    Seleccionar(ddlVoluntario, g.IDVoluntario);
                    EscribirFecha(txtFecha, g.Fecha);
                    EscribirHora(txtHoraInicio, g.HoraInicio);
                    EscribirHora(txtHoraFin, g.HoraFin);
                    MostrarFormulario("Modificar guardia de " + g.VoluntarioNombre);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Guardia eliminada.");
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
            EscribirFecha(txtFecha, DateTime.Today);
            txtHoraInicio.Text = "08:00";
            txtHoraFin.Text = "20:00";
            MostrarFormulario("Nueva guardia");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Guardia g = new Guardia
                {
                    IDGuardia = IdEdicion,
                    IDVoluntario = IdSeleccionado(ddlVoluntario),
                    Fecha = LeerFecha(txtFecha) ?? DateTime.MinValue,
                    HoraInicio = LeerHora(txtHoraInicio) ?? TimeSpan.Zero,
                    HoraFin = LeerHora(txtHoraFin) ?? TimeSpan.Zero
                };
                bool esAlta = g.IDGuardia == 0;
                _bll.Guardar(g);
                OcultarFormulario();
                MostrarExito(esAlta ? "Guardia registrada correctamente." : "Guardia actualizada correctamente.");
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
