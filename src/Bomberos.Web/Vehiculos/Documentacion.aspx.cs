using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Vehiculos
{
    /// <summary>
    /// ABM de documentación de vehículos con indicador de vencimiento:
    /// verde = vigente, amarillo = próximo a vencer (30 días), rojo = vencido.
    /// </summary>
    public partial class Documentacion : BasePage
    {
        private readonly DocumentoVehiculoBLL _bll = new DocumentoVehiculoBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvDocumentos.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                try
                {
                    var vehiculos = new VehiculoBLL().Combo(false);
                    CargarCombo(ddlVehiculo, vehiculos, "-- Seleccione --");
                    CargarCombo(ddlFiltroVehiculo, vehiculos, "(Todos)");
                    CargarCombo(ddlTipoDocumento, Constantes.TiposDocumentoVehiculo, "-- Seleccione --");
                    Seleccionar(ddlFiltroVehiculo, Request.QueryString["vehiculo"]);
                    Seleccionar(ddlFiltroSituacion, Request.QueryString["situacion"]);
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
                // Resumen del semáforo (sobre el vehículo filtrado, sin filtro de situación)
                List<DocumentoVehiculo> todos = _bll.Listar(IdFiltro(ddlFiltroVehiculo), null);
                litVencidos.Text = todos.Count(d => d.Situacion == DocumentoVehiculoBLL.SituacionVencido).ToString();
                litProximos.Text = todos.Count(d => d.Situacion == DocumentoVehiculoBLL.SituacionProximo).ToString();
                litVigentes.Text = todos.Count(d => d.Situacion == DocumentoVehiculoBLL.SituacionVigente).ToString();

                string filtro = TextoFiltro(ddlFiltroSituacion);
                gvDocumentos.DataSource = filtro == null ? todos : _bll.Listar(IdFiltro(ddlFiltroVehiculo), filtro);
                gvDocumentos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        /// <summary>Clase CSS del semáforo según la situación del documento.</summary>
        protected static string ClaseSemaforo(object situacion)
        {
            switch (Convert.ToString(situacion))
            {
                case DocumentoVehiculoBLL.SituacionVencido: return "semaforo-rojo";
                case DocumentoVehiculoBLL.SituacionProximo: return "semaforo-amarillo";
                default: return "semaforo-verde";
            }
        }

        protected static string TextoDias(object dias)
        {
            int d = Convert.ToInt32(dias);
            if (d < 0) return "<span class=\"text-danger\">Venció hace " + (-d) + " día(s)</span>";
            if (d == 0) return "<span class=\"text-danger\">Vence hoy</span>";
            return "Faltan " + d + " día(s)";
        }

        protected void gvDocumentos_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow) return;
            DocumentoVehiculo d = (DocumentoVehiculo)e.Row.DataItem;
            if (d.Situacion == DocumentoVehiculoBLL.SituacionVencido) e.Row.CssClass = "fila-vencida";
            else if (d.Situacion == DocumentoVehiculoBLL.SituacionProximo) e.Row.CssClass = "fila-por-vencer";
        }

        private void FiltrarSituacion(string valor)
        {
            Seleccionar(ddlFiltroSituacion, valor);
            gvDocumentos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnVerVencidos_Click(object sender, EventArgs e) { FiltrarSituacion("Vencido"); }
        protected void btnVerProximos_Click(object sender, EventArgs e) { FiltrarSituacion("Proximo"); }
        protected void btnVerVigentes_Click(object sender, EventArgs e) { FiltrarSituacion("Vigente"); }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvDocumentos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            ddlFiltroVehiculo.ClearSelection();
            ddlFiltroSituacion.ClearSelection();
            gvDocumentos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvDocumentos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDocumentos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvDocumentos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    DocumentoVehiculo d = _bll.Obtener(id);
                    if (d == null) { MostrarAdvertencia("El documento ya no existe."); CargarGrilla(); return; }
                    IdEdicion = d.IDDocumento;
                    Seleccionar(ddlVehiculo, d.IDVehiculo);
                    if (ddlTipoDocumento.Items.FindByValue(d.TipoDocumento) == null)
                        ddlTipoDocumento.Items.Add(new ListItem(d.TipoDocumento, d.TipoDocumento));
                    Seleccionar(ddlTipoDocumento, d.TipoDocumento);
                    EscribirFecha(txtEmision, d.FechaEmision);
                    EscribirFecha(txtVencimiento, d.FechaVencimiento);
                    MostrarFormulario("Modificar / renovar documento");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(id);
                    MostrarExito("Documento eliminado.");
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
            Seleccionar(ddlVehiculo, ddlFiltroVehiculo.SelectedValue);
            ddlTipoDocumento.ClearSelection();
            EscribirFecha(txtEmision, DateTime.Today);
            EscribirFecha(txtVencimiento, DateTime.Today.AddYears(1));
            MostrarFormulario("Nuevo documento");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                DocumentoVehiculo d = new DocumentoVehiculo
                {
                    IDDocumento = IdEdicion,
                    IDVehiculo = IdSeleccionado(ddlVehiculo),
                    TipoDocumento = ddlTipoDocumento.SelectedValue,
                    FechaEmision = LeerFecha(txtEmision) ?? DateTime.MinValue,
                    FechaVencimiento = LeerFecha(txtVencimiento) ?? DateTime.MinValue
                };
                bool esAlta = d.IDDocumento == 0;
                _bll.Guardar(d);
                OcultarFormulario();
                MostrarExito(esAlta ? "Documento registrado correctamente." : "Documento actualizado correctamente.");
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
