using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Equipamiento
{
    /// <summary>
    /// ABM de equipamiento con filtros y accesos rápidos por estado.
    /// (La clase se llama EquipamientoPage para no colisionar con la entidad Equipamiento.)
    /// </summary>
    public partial class EquipamientoPage : BasePage
    {
        private readonly EquipamientoBLL _bll = new EquipamientoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvEquipos.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    CargarCombo(ddlEstado, Constantes.EstadosEquipamiento, null);
                    CargarCombo(ddlFiltroEstado, Constantes.EstadosEquipamiento, "(Todos)");
                    CargarCatalogo(ddlTipo, TipoCatalogo.TipoEquipamiento, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroTipo, TipoCatalogo.TipoEquipamiento, "(Todos)");
                    CargarCatalogo(ddlCategoria, TipoCatalogo.CategoriaEquipamiento, "-- Seleccione --");
                    CargarCatalogo(ddlFiltroCategoria, TipoCatalogo.CategoriaEquipamiento, "(Todas)");
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
                List<Entities.Equipamiento> lista = _bll.Listar(txtBuscar.Text, TextoFiltro(ddlFiltroEstado),
                                                                IdFiltro(ddlFiltroTipo), IdFiltro(ddlFiltroCategoria));
                litCantidad.Text = lista.Count + " equipo(s)";
                gvEquipos.DataSource = lista;
                gvEquipos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void FiltroRapido_Command(object sender, CommandEventArgs e)
        {
            txtBuscar.Text = string.Empty;
            ddlFiltroTipo.ClearSelection();
            ddlFiltroCategoria.ClearSelection();
            Seleccionar(ddlFiltroEstado, e.CommandArgument);
            gvEquipos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvEquipos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            ddlFiltroEstado.ClearSelection();
            ddlFiltroTipo.ClearSelection();
            ddlFiltroCategoria.ClearSelection();
            gvEquipos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvEquipos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvEquipos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvEquipos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Entities.Equipamiento eq = _bll.Obtener(id);
                    if (eq == null) { MostrarAdvertencia("El equipo ya no existe."); CargarGrilla(); return; }
                    IdEdicion = eq.IDEquipamiento;
                    txtCodigo.Text = eq.CodigoInterno;
                    txtNombre.Text = eq.Nombre;
                    Seleccionar(ddlEstado, eq.Estado);
                    Seleccionar(ddlTipo, eq.IDTipoEquipamiento);
                    Seleccionar(ddlCategoria, eq.IDCategoriaEquipamiento);
                    EscribirFecha(txtCompra, eq.FechaCompra);
                    EscribirFecha(txtUltimoMant, eq.FechaUltimoMantenimiento);
                    EscribirFecha(txtProximoMant, eq.FechaProximoMantenimiento);
                    MostrarFormulario("Modificar equipo " + eq.CodigoInterno);
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Equipo eliminado.");
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
            foreach (TextBox tb in new[] { txtCodigo, txtNombre, txtUltimoMant, txtProximoMant })
                tb.Text = string.Empty;
            EscribirFecha(txtCompra, DateTime.Today);
            Seleccionar(ddlEstado, Constantes.EquipoDisponible);
            ddlTipo.ClearSelection();
            ddlCategoria.ClearSelection();
            MostrarFormulario("Nuevo equipo");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Entities.Equipamiento eq = new Entities.Equipamiento
                {
                    IDEquipamiento = IdEdicion,
                    CodigoInterno = txtCodigo.Text,
                    Nombre = txtNombre.Text,
                    Estado = ddlEstado.SelectedValue,
                    IDTipoEquipamiento = IdSeleccionado(ddlTipo),
                    IDCategoriaEquipamiento = IdSeleccionado(ddlCategoria),
                    FechaCompra = LeerFecha(txtCompra),
                    FechaUltimoMantenimiento = LeerFecha(txtUltimoMant),
                    FechaProximoMantenimiento = LeerFecha(txtProximoMant)
                };
                bool esAlta = eq.IDEquipamiento == 0;
                _bll.Guardar(eq);
                OcultarFormulario();
                MostrarExito(esAlta ? "Equipo registrado correctamente." : "Equipo actualizado correctamente.");
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
