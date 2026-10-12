using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Operaciones
{
    /// <summary>
    /// ABM de misiones. La asignación de recursos se realiza en MisionDetalle.aspx.
    /// </summary>
    public partial class Misiones : BasePage
    {
        private readonly MisionBLL _bll = new MisionBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvMisiones.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    CargarCombo(ddlEstado, Constantes.EstadosMision, null);
                    CargarCombo(ddlFiltroEstado, Constantes.EstadosMision, "(Todos)");
                    CargarCatalogo(ddlTipoMision, TipoCatalogo.TipoMision, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoMision, "(Todos)");
                    var incidentes = new IncidenteBLL().Combo();
                    CargarCombo(ddlIncidente, incidentes, "-- Seleccione --");
                    CargarCombo(ddlFiltroIncidente, incidentes, "(Todos)");
                    Seleccionar(ddlFiltroEstado, Request.QueryString["estado"]);
                    Seleccionar(ddlFiltroIncidente, Request.QueryString["incidente"]);
                }
                catch (Exception ex)
                {
                    ManejarExcepcion(ex);
                }
                CargarGrilla();
                if (Request.QueryString["nuevo"] == "1")
                    btnNuevo_Click(this, EventArgs.Empty);
            }
        }

        private void CargarGrilla()
        {
            try
            {
                gvMisiones.DataSource = _bll.Listar(TextoFiltro(ddlFiltroEstado), IdFiltro(ddlFiltroIncidente), IdFiltro(ddlFiltroTipo), txtBuscar.Text);
                gvMisiones.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvMisiones.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlFiltroEstado.ClearSelection();
            ddlFiltroTipo.ClearSelection();
            ddlFiltroIncidente.ClearSelection();
            txtBuscar.Text = string.Empty;
            gvMisiones.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvMisiones_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvMisiones.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvMisiones_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Mision m = _bll.Obtener(id);
                    if (m == null) { MostrarAdvertencia("La misión ya no existe."); CargarGrilla(); return; }
                    IdEdicion = m.IDMision;
                    Seleccionar(ddlIncidente, m.IDIncidente);
                    Seleccionar(ddlTipoMision, m.IDTipoMision);
                    txtNombre.Text = m.Nombre;
                    Seleccionar(ddlEstado, m.Estado);
                    EscribirFechaHora(txtInicio, m.FechaInicio);
                    EscribirFechaHora(txtFin, m.FechaFin);
                    MostrarFormulario("Modificar misión: " + m.Nombre);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Misión eliminada.");
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
            Seleccionar(ddlIncidente, Request.QueryString["incidente"] ?? ddlFiltroIncidente.SelectedValue);
            ddlTipoMision.ClearSelection();
            txtNombre.Text = string.Empty;
            Seleccionar(ddlEstado, Constantes.MisionEnCurso);
            EscribirFechaHora(txtInicio, DateTime.Now);
            txtFin.Text = string.Empty;
            MostrarFormulario("Nueva misión");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Mision m = new Mision
                {
                    IDMision = IdEdicion,
                    IDIncidente = IdSeleccionado(ddlIncidente),
                    IDTipoMision = IdSeleccionado(ddlTipoMision),
                    Nombre = txtNombre.Text,
                    Estado = ddlEstado.SelectedValue,
                    FechaInicio = LeerFechaHora(txtInicio) ?? DateTime.MinValue,
                    FechaFin = LeerFechaHora(txtFin)
                };
                bool esAlta = m.IDMision == 0;
                int id = _bll.Guardar(m);
                OcultarFormulario();
                if (esAlta)
                {
                    // Tras crear la misión se continúa con la asignación de recursos
                    RedirigirConMensaje("~/Operaciones/MisionDetalle.aspx?id=" + id,
                        "Misión creada. Asigne ahora los voluntarios, vehículos y equipamiento.", TipoMensaje.Exito);
                    return;
                }
                MostrarExito("Misión actualizada correctamente.");
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
