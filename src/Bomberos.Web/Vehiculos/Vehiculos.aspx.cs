using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Vehiculos
{
    /// <summary>
    /// ABM de vehículos con búsqueda por patente, estado y tipo.
    /// </summary>
    public partial class Vehiculos : BasePage
    {
        private readonly VehiculoBLL _bll = new VehiculoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvVehiculos.PageSize = FilasPorPagina;
            rvAnio.MaximumValue = (DateTime.Today.Year + 1).ToString();
            if (!IsPostBack)
            {
                try
                {
                    CargarCombo(ddlEstado, Constantes.EstadosVehiculo, null);
                    CargarCombo(ddlFiltroEstado, Constantes.EstadosVehiculo, "(Todos)");
                    CargarCatalogo(ddlTipo, TipoCatalogo.TipoVehiculo, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoVehiculo, "(Todos)");
                    Seleccionar(ddlFiltroEstado, Request.QueryString["estado"]);
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
                gvVehiculos.DataSource = _bll.Listar(txtFiltroPatente.Text, TextoFiltro(ddlFiltroEstado), IdFiltro(ddlFiltroTipo));
                gvVehiculos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvVehiculos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtFiltroPatente.Text = string.Empty;
            ddlFiltroEstado.ClearSelection();
            ddlFiltroTipo.ClearSelection();
            gvVehiculos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvVehiculos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvVehiculos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvVehiculos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Vehiculo v = _bll.Obtener(id);
                    if (v == null) { MostrarAdvertencia("El vehículo ya no existe."); CargarGrilla(); return; }
                    IdEdicion = v.IDVehiculo;
                    txtNombre.Text = v.Nombre;
                    txtPatente.Text = v.Patente;
                    txtAnio.Text = v.Anio.ToString();
                    Seleccionar(ddlTipo, v.IDTipoVehiculo);
                    Seleccionar(ddlEstado, v.Estado);
                    MostrarFormulario("Modificar vehículo: " + v.Nombre);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Vehículo eliminado.");
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
            txtNombre.Text = txtPatente.Text = string.Empty;
            txtAnio.Text = DateTime.Today.Year.ToString();
            ddlTipo.ClearSelection();
            Seleccionar(ddlEstado, Constantes.VehiculoOperativo);
            MostrarFormulario("Nuevo vehículo");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Vehiculo v = new Vehiculo
                {
                    IDVehiculo = IdEdicion,
                    Nombre = txtNombre.Text,
                    Patente = txtPatente.Text,
                    Anio = LeerEntero(txtAnio),
                    IDTipoVehiculo = IdSeleccionado(ddlTipo),
                    Estado = ddlEstado.SelectedValue
                };
                bool esAlta = v.IDVehiculo == 0;
                _bll.Guardar(v);
                OcultarFormulario();
                MostrarExito(esAlta ? "Vehículo registrado correctamente." : "Vehículo actualizado correctamente.");
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
