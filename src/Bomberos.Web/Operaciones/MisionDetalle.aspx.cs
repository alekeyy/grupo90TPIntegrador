using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Operaciones
{
    /// <summary>
    /// Detalle de una misión (FormView) y administración de las tablas
    /// MisionVoluntario, MisionVehiculo y MisionEquipamiento.
    /// </summary>
    public partial class MisionDetalle : BasePage
    {
        private readonly MisionBLL _bll = new MisionBLL();

        private int IdMision
        {
            get
            {
                int id;
                return int.TryParse(Request.QueryString["id"], out id) ? id : 0;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                CargarTodo();
        }

        private void CargarTodo()
        {
            try
            {
                Mision m = _bll.Obtener(IdMision);
                fvMision.DataSource = m == null ? new List<Mision>() : new List<Mision> { m };
                fvMision.DataBind();
                pnlRecursos.Visible = m != null;
                if (m == null) return;

                bool cancelada = m.Estado == Constantes.MisionCancelada;
                foreach (WebControl c in new WebControl[] { ddlVoluntario, ddlVehiculo, ddlEquipo, btnAgregarVoluntario, btnAgregarVehiculo, btnAgregarEquipo })
                    c.Enabled = !cancelada;
                if (cancelada)
                    MostrarMensaje("La misión está cancelada: no se pueden asignar nuevos recursos.", TipoMensaje.Informacion);

                CargarRecursos();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }

        /// <summary>
        /// Carga las grillas de asignados y los combos con los recursos disponibles
        /// (excluyendo los ya asignados).
        /// </summary>
        private void CargarRecursos()
        {
            List<RecursoAsignado> voluntarios = _bll.ListarRecursos(TipoRecurso.Voluntario, IdMision);
            List<RecursoAsignado> vehiculos = _bll.ListarRecursos(TipoRecurso.Vehiculo, IdMision);
            List<RecursoAsignado> equipos = _bll.ListarRecursos(TipoRecurso.Equipamiento, IdMision);

            Enlazar(gvVoluntarios, litCantVoluntarios, voluntarios);
            Enlazar(gvVehiculos, litCantVehiculos, vehiculos);
            Enlazar(gvEquipos, litCantEquipos, equipos);

            CargarCombo(ddlVoluntario, Excluir(new VoluntarioBLL().Combo(true), voluntarios), "-- Voluntario activo --");
            CargarCombo(ddlVehiculo, Excluir(new VehiculoBLL().Combo(true), vehiculos), "-- Vehículo operativo --");
            CargarCombo(ddlEquipo, Excluir(new EquipamientoBLL().Combo(false), equipos), "-- Equipo --");
        }

        private static void Enlazar(GridView gv, Literal contador, List<RecursoAsignado> datos)
        {
            gv.DataSource = datos;
            gv.DataBind();
            contador.Text = datos.Count.ToString();
        }

        private static IEnumerable<ItemCombo> Excluir(IEnumerable<ItemCombo> disponibles, List<RecursoAsignado> asignados)
        {
            HashSet<int> ids = new HashSet<int>(asignados.Select(a => a.ID));
            return disponibles.Where(d => !ids.Contains(d.Valor));
        }

        protected void Agregar_Command(object sender, CommandEventArgs e)
        {
            TipoRecurso tipo = (TipoRecurso)Enum.Parse(typeof(TipoRecurso), Convert.ToString(e.CommandArgument));
            DropDownList ddl = tipo == TipoRecurso.Voluntario ? ddlVoluntario : tipo == TipoRecurso.Vehiculo ? ddlVehiculo : ddlEquipo;
            if (!IsValid) return;   // valida el grupo del botón (Vol / Veh / Eq)
            try
            {
                _bll.AgregarRecurso(tipo, IdMision, IdSeleccionado(ddl));
                MostrarExito("Recurso asignado a la misión.");
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
            Recargar();
        }

        protected void Quitar_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            TipoRecurso tipo;
            if (!Enum.TryParse(e.CommandName, out tipo)) return;
            try
            {
                _bll.QuitarRecurso(tipo, IdMision, Convert.ToInt32(e.CommandArgument));
                MostrarExito("Recurso quitado de la misión.");
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
            Recargar();
        }

        private void Recargar()
        {
            try
            {
                CargarRecursos();
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
            }
        }
    }
}
