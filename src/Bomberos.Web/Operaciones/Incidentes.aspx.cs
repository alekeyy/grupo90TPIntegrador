using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Operaciones
{
    /// <summary>
    /// ABM de incidentes con filtros por período, severidad y texto.
    /// </summary>
    public partial class Incidentes : BasePage
    {
        private readonly IncidenteBLL _bll = new IncidenteBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvIncidentes.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                CargarCombo(ddlSeveridad, Constantes.Severidades, "-- Seleccione --");
                CargarCombo(ddlFiltroSeveridad, Constantes.Severidades, "(Todas)");
                CargarGrilla();
                if (Request.QueryString["nuevo"] == "1")
                    btnNuevo_Click(this, EventArgs.Empty);
            }
        }

        private void CargarGrilla()
        {
            try
            {
                gvIncidentes.DataSource = _bll.Listar(LeerFecha(txtDesde), LeerFecha(txtHasta), TextoFiltro(ddlFiltroSeveridad), txtBuscar.Text);
                gvIncidentes.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvIncidentes.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtDesde.Text = txtHasta.Text = txtBuscar.Text = string.Empty;
            ddlFiltroSeveridad.ClearSelection();
            gvIncidentes.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvIncidentes_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvIncidentes.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvIncidentes_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Incidente i = _bll.Obtener(id);
                    if (i == null) { MostrarAdvertencia("El incidente ya no existe."); CargarGrilla(); return; }
                    IdEdicion = i.IDIncidente;
                    EscribirFechaHora(txtFechaHora, i.FechaHora);
                    txtDireccion.Text = i.Direccion;
                    txtDescripcion.Text = i.Descripcion;
                    Seleccionar(ddlSeveridad, i.Severidad);
                    MostrarFormulario("Modificar incidente N° " + i.IDIncidente);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Incidente eliminado.");
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
            EscribirFechaHora(txtFechaHora, DateTime.Now);
            txtDireccion.Text = txtDescripcion.Text = string.Empty;
            ddlSeveridad.ClearSelection();
            MostrarFormulario("Nuevo incidente");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Incidente i = new Incidente
                {
                    IDIncidente = IdEdicion,
                    FechaHora = LeerFechaHora(txtFechaHora) ?? DateTime.MinValue,
                    Direccion = txtDireccion.Text,
                    Descripcion = txtDescripcion.Text,
                    Severidad = ddlSeveridad.SelectedValue
                };
                bool esAlta = i.IDIncidente == 0;
                int id = _bll.Guardar(i);
                OcultarFormulario();
                if (esAlta)
                    MostrarMensaje("Incidente N° " + id + " registrado. Puede generar una misión desde el botón verde del listado.", TipoMensaje.Exito);
                else
                    MostrarExito("Incidente actualizado correctamente.");
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
