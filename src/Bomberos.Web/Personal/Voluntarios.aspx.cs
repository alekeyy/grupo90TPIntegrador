using System;
using System.Collections.Generic;
using System.Data;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Personal
{
    /// <summary>
    /// ABM de voluntarios con búsqueda, filtro por estado, ficha (DetailsView) y baja lógica.
    /// </summary>
    public partial class Voluntarios : BasePage
    {
        private readonly VoluntarioBLL _bll = new VoluntarioBLL();

        protected void Page_Load(object sender, EventArgs e)
        {
            gvVoluntarios.PageSize = FilasPorPagina;
            if (!IsPostBack)
            {
                CargarCombo(ddlEstado, Constantes.EstadosVoluntario, null);
                CargarCombo(ddlFiltroEstado, Constantes.EstadosVoluntario, "(Todos)");
                CargarGrilla();
            }
        }

        private void CargarGrilla()
        {
            try
            {
                List<Voluntario> lista = _bll.Listar(txtBuscar.Text, TextoFiltro(ddlFiltroEstado));
                litCantidad.Text = lista.Count + " voluntario(s)";
                gvVoluntarios.DataSource = lista;
                gvVoluntarios.DataBind();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        protected void btnBuscar_Click(object sender, EventArgs e)
        {
            gvVoluntarios.PageIndex = 0;
            CargarGrilla();
        }

        protected void btnLimpiar_Click(object sender, EventArgs e)
        {
            txtBuscar.Text = string.Empty;
            ddlFiltroEstado.ClearSelection();
            gvVoluntarios.PageIndex = 0;
            CargarGrilla();
        }

        protected void gvVoluntarios_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvVoluntarios.PageIndex = e.NewPageIndex;
            CargarGrilla();
        }

        protected void gvVoluntarios_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "Page") return;
            int id = Convert.ToInt32(e.CommandArgument);
            try
            {
                switch (e.CommandName)
                {
                    case "Ver":
                        MostrarFicha(id);
                        break;
                    case "Editar":
                        Editar(id);
                        break;
                    case "Baja":
                        _bll.DarDeBaja(id);
                        MostrarExito("El voluntario fue dado de baja. Su historial se conserva.");
                        pnlFicha.Visible = false;
                        CargarGrilla();
                        break;
                }
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        private void MostrarFicha(int id)
        {
            DataTable ficha = _bll.ObtenerFicha(id);
            if (ficha.Rows.Count == 0) { MostrarAdvertencia("El voluntario no existe."); return; }
            ficha.Columns.Remove("IDVoluntario");
            dvFicha.DataSource = ConvertirFechas(ficha);
            dvFicha.DataBind();

            lnkHistorialRangos.NavigateUrl = "~/Personal/HistorialRangos.aspx?voluntario=" + id;
            lnkHistorialRoles.NavigateUrl = "~/Personal/HistorialRoles.aspx?voluntario=" + id;
            lnkEntrenamientos.NavigateUrl = "~/Capacitacion/Entrenamientos.aspx?voluntario=" + id;
            lnkGuardias.NavigateUrl = "~/Guardias/Guardias.aspx?voluntario=" + id;
            lnkMisiones.NavigateUrl = "~/Reportes/Reportes.aspx?cat=operaciones&rep=misiones-voluntario&voluntario=" + id;
            pnlFicha.Visible = true;
            pnlFormulario.Visible = false;
        }

        /// <summary>Convierte las columnas de fecha a texto dd/MM/yyyy para el DetailsView.</summary>
        private static DataTable ConvertirFechas(DataTable origen)
        {
            DataTable destino = new DataTable();
            foreach (DataColumn c in origen.Columns)
                destino.Columns.Add(c.ColumnName, c.DataType == typeof(DateTime) ? typeof(string) : c.DataType);
            foreach (DataRow r in origen.Rows)
            {
                DataRow n = destino.NewRow();
                foreach (DataColumn c in origen.Columns)
                    n[c.ColumnName] = c.DataType == typeof(DateTime) && r[c] != DBNull.Value
                        ? ((DateTime)r[c]).ToString("dd/MM/yyyy") : r[c];
                destino.Rows.Add(n);
            }
            return destino;
        }

        private void Editar(int id)
        {
            Voluntario v = _bll.Obtener(id);
            if (v == null) { MostrarAdvertencia("El voluntario no existe."); CargarGrilla(); return; }

            IdEdicion = v.IDVoluntario;
            txtNombre.Text = v.Nombre;
            txtApellido.Text = v.Apellido;
            txtDNI.Text = v.DNI;
            EscribirFecha(txtFechaNacimiento, v.FechaNacimiento);
            EscribirFecha(txtFechaIngreso, v.FechaIngreso);
            txtTelefono.Text = v.Telefono;
            txtEmail.Text = v.Email;
            txtDireccion.Text = v.Direccion;
            Seleccionar(ddlEstado, v.Estado);
            MostrarFormulario("Modificar voluntario: " + v.NombreCompleto);
        }

        protected void btnNuevo_Click(object sender, EventArgs e)
        {
            IdEdicion = 0;
            foreach (TextBox tb in new[] { txtNombre, txtApellido, txtDNI, txtTelefono, txtEmail, txtDireccion, txtFechaNacimiento })
                tb.Text = string.Empty;
            EscribirFecha(txtFechaIngreso, DateTime.Today);
            Seleccionar(ddlEstado, Constantes.VoluntarioActivo);
            MostrarFormulario("Nuevo voluntario");
        }

        protected void btnGuardar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            try
            {
                Voluntario v = new Voluntario
                {
                    IDVoluntario = IdEdicion,
                    Nombre = txtNombre.Text,
                    Apellido = txtApellido.Text,
                    DNI = txtDNI.Text,
                    FechaNacimiento = LeerFecha(txtFechaNacimiento) ?? DateTime.MinValue,
                    FechaIngreso = LeerFecha(txtFechaIngreso) ?? DateTime.MinValue,
                    Telefono = txtTelefono.Text,
                    Email = txtEmail.Text,
                    Direccion = txtDireccion.Text,
                    Estado = ddlEstado.SelectedValue
                };
                bool esAlta = v.IDVoluntario == 0;
                _bll.Guardar(v);
                OcultarFormulario();
                MostrarExito(esAlta ? "Voluntario registrado correctamente." : "Voluntario actualizado correctamente.");
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

        protected void btnCerrarFicha_Click(object sender, EventArgs e)
        {
            pnlFicha.Visible = false;
        }

        private void MostrarFormulario(string titulo)
        {
            litTituloFormulario.Text = titulo;
            pnlFormulario.Visible = true;
            pnlFicha.Visible = false;
        }

        private void OcultarFormulario()
        {
            pnlFormulario.Visible = false;
            IdEdicion = 0;
        }
    }
}
