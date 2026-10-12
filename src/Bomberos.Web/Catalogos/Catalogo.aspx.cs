using System;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Catalogos
{
    /// <summary>
    /// ABM genérico de catálogos simples. El catálogo se indica en la URL: Catalogo.aspx?tipo=Rangos
    /// (valores válidos: los del enum TipoCatalogo).
    /// </summary>
    public partial class Catalogo : BasePage
    {
        private readonly CatalogoBLL _bll = new CatalogoBLL();

        /// <summary>Catálogo actual, obtenido del parámetro "tipo" de la URL.</summary>
        private TipoCatalogo Tipo
        {
            get
            {
                TipoCatalogo tipo;
                if (Enum.TryParse(Request.QueryString["tipo"], true, out tipo) && Enum.IsDefined(typeof(TipoCatalogo), tipo))
                    return tipo;
                return TipoCatalogo.Rangos;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string titulo = CatalogoBLL.Titulo(Tipo);
            Title = titulo;
            litTitulo.Text = titulo;
            litModulo.Text = CatalogoBLL.Modulo(Tipo);
            phDescripcion.Visible = CatalogoBLL.TieneDescripcion(Tipo);
            gvDatos.Columns[2].Visible = CatalogoBLL.TieneDescripcion(Tipo);
            gvDatos.PageSize = FilasPorPagina;

            if (!IsPostBack)
                CargarGrilla();
        }

        private void CargarGrilla()
        {
            try
            {
                gvDatos.DataSource = _bll.Listar(Tipo, txtBuscar.Text);
                gvDatos.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvDatos.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            gvDatos.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvDatos_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvDatos.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvDatos_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // No se ofrece eliminar si el registro está en uso (igual se valida en la base).
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                Entities.Catalogo item = (Entities.Catalogo)e.Row.DataItem;
                if (item.CantidadRegistros > 0)
                {
                    WebControl btn = (WebControl)e.Row.FindControl("btnEliminar");
                    btn.Visible = false;
                }
            }
        }

        protected void gvDatos_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                if (e.CommandName == "Editar")
                {
                    Entities.Catalogo item = _bll.Obtener(Tipo, id);
                    if (item == null) { MostrarAdvertencia("El registro ya no existe."); CargarGrilla(); return; }
                    IdEdicion = item.ID;
                    txtNombre.Text = item.Nombre;
                    txtDescripcion.Text = item.Descripcion;
                    MostrarFormulario("Modificar registro");
                }
                else if (e.CommandName == "Eliminar")
                {
                    _bll.Eliminar(Tipo, id);
                    MostrarExito("Registro eliminado correctamente.");
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
            txtNombre.Text = string.Empty;
            txtDescripcion.Text = string.Empty;
            MostrarFormulario("Nuevo registro");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Entities.Catalogo item = new Entities.Catalogo
                {
                    ID = IdEdicion,
                    Nombre = txtNombre.Text,
                    Descripcion = txtDescripcion.Text
                };
                bool esAlta = item.ID == 0;
                _bll.Guardar(Tipo, item);
                OcultarFormulario();
                MostrarExito(esAlta ? "Registro creado correctamente." : "Registro actualizado correctamente.");
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
