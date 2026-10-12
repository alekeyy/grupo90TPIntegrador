using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;

namespace Bomberos.Web.Code
{
    /// <summary>
    /// Página base de la aplicación. Todas las páginas heredan de esta clase para reutilizar:
    ///  - manejo de mensajes (alertas Bootstrap en la Master Page),
    ///  - manejo centralizado de excepciones,
    ///  - lectura/escritura de valores de controles (fechas, montos, combos),
    ///  - helpers de presentación usados desde el markup (clases CSS de estados).
    /// </summary>
    public abstract class BasePage : Page
    {
        private const string ClaveMensajePendiente = "__MensajePendiente";
        private static readonly CultureInfo Invariante = CultureInfo.InvariantCulture;

        /// <summary>Cantidad de filas por página de las grillas (configurable en Web.config).</summary>
        protected int FilasPorPagina
        {
            get
            {
                int filas;
                return int.TryParse(ConfigurationManager.AppSettings["FilasPorPagina"], out filas) && filas > 0 ? filas : 10;
            }
        }

        /// <summary>ID del registro que se está editando (0 = alta). Se conserva en ViewState.</summary>
        protected int IdEdicion
        {
            get { return ViewState["IdEdicion"] == null ? 0 : (int)ViewState["IdEdicion"]; }
            set { ViewState["IdEdicion"] = value; }
        }

        protected SiteMaster Sitio
        {
            get { return Master as SiteMaster; }
        }

        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);
            // Mensaje guardado antes de un Response.Redirect
            if (!IsPostBack && Session != null && Session[ClaveMensajePendiente] != null)
            {
                Tuple<string, TipoMensaje> pendiente = Session[ClaveMensajePendiente] as Tuple<string, TipoMensaje>;
                Session.Remove(ClaveMensajePendiente);
                if (pendiente != null) MostrarMensaje(pendiente.Item1, pendiente.Item2);
            }
        }

        // ------------------------------------------------------------------
        // Mensajes
        // ------------------------------------------------------------------
        protected void MostrarMensaje(string mensaje, TipoMensaje tipo)
        {
            if (Sitio != null) Sitio.MostrarMensaje(mensaje, tipo);
        }

        protected void MostrarExito(string mensaje)
        {
            MostrarMensaje(mensaje, TipoMensaje.Exito);
        }

        protected void MostrarAdvertencia(string mensaje)
        {
            MostrarMensaje(mensaje, TipoMensaje.Advertencia);
        }

        protected void MostrarError(string mensaje)
        {
            MostrarMensaje(mensaje, TipoMensaje.Error);
        }

        /// <summary>Guarda un mensaje para mostrarlo después de redirigir a otra página.</summary>
        protected void RedirigirConMensaje(string url, string mensaje, TipoMensaje tipo)
        {
            Session[ClaveMensajePendiente] = Tuple.Create(mensaje, tipo);
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        /// <summary>
        /// Manejo centralizado de excepciones:
        ///  - ValidacionException: errores de reglas de negocio (advertencia, lista de errores).
        ///  - DatosException: errores de base de datos traducidos (regla de SP = advertencia; otro = error).
        ///  - Cualquier otra: error genérico y registro en el log.
        /// </summary>
        protected void ManejarExcepcion(Exception ex)
        {
            ValidacionException vex = ex as ValidacionException;
            if (vex != null)
            {
                if (vex.Errores.Count == 1)
                    MostrarAdvertencia(vex.Errores[0]);
                else
                    MostrarAdvertenciaHtml("Revise los siguientes datos:<ul class=\"mb-0\">"
                        + string.Concat(vex.Errores.Select(er => "<li>" + HttpUtility.HtmlEncode(er) + "</li>")) + "</ul>");
                return;
            }

            DatosException dex = ex as DatosException;
            if (dex != null)
            {
                if (dex.EsReglaDeNegocio)
                    MostrarAdvertencia(dex.Message);
                else
                {
                    Logger.Error(dex.InnerException ?? dex, Request.RawUrl);
                    MostrarError(dex.Message);
                }
                return;
            }

            Logger.Error(ex, Request.RawUrl);
            MostrarError("Ocurrió un error inesperado. El detalle fue registrado para su revisión.");
        }

        private void MostrarAdvertenciaHtml(string html)
        {
            if (Sitio != null) Sitio.MostrarMensajeHtml(html, TipoMensaje.Advertencia);
        }

        // ------------------------------------------------------------------
        // Lectura de valores de controles
        // ------------------------------------------------------------------

        /// <summary>Lee una fecha de un TextBox type="date" (yyyy-MM-dd) o en formato dd/MM/yyyy.</summary>
        protected static DateTime? LeerFecha(TextBox tb)
        {
            string s = tb.Text.Trim();
            if (s.Length == 0) return null;
            DateTime d;
            string[] formatos = { "yyyy-MM-dd", "dd/MM/yyyy", "d/M/yyyy" };
            if (DateTime.TryParseExact(s, formatos, Invariante, DateTimeStyles.None, out d)) return d;
            throw new ValidacionException("La fecha '" + s + "' no es válida.");
        }

        /// <summary>Lee fecha y hora de un TextBox type="datetime-local" (yyyy-MM-ddTHH:mm).</summary>
        protected static DateTime? LeerFechaHora(TextBox tb)
        {
            string s = tb.Text.Trim();
            if (s.Length == 0) return null;
            DateTime d;
            string[] formatos = { "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss", "yyyy-MM-dd HH:mm", "dd/MM/yyyy HH:mm" };
            if (DateTime.TryParseExact(s, formatos, Invariante, DateTimeStyles.None, out d)) return d;
            throw new ValidacionException("La fecha y hora '" + s + "' no es válida.");
        }

        /// <summary>Lee una hora de un TextBox type="time" (HH:mm).</summary>
        protected static TimeSpan? LeerHora(TextBox tb)
        {
            string s = tb.Text.Trim();
            if (s.Length == 0) return null;
            TimeSpan t;
            string[] formatos = { @"hh\:mm", @"hh\:mm\:ss", @"h\:mm" };
            if (TimeSpan.TryParseExact(s, formatos, Invariante, out t)) return t;
            throw new ValidacionException("La hora '" + s + "' no es válida.");
        }

        /// <summary>
        /// Lee un importe aceptando punto o coma decimal ("1500.50", "1500,50" o "1.500,50").
        /// </summary>
        protected static decimal LeerDecimal(TextBox tb)
        {
            string s = tb.Text.Trim().Replace("$", "").Replace(" ", "");
            if (s.Length == 0) return 0m;
            int ultimaComa = s.LastIndexOf(',');
            int ultimoPunto = s.LastIndexOf('.');
            if (ultimaComa > ultimoPunto)
                s = s.Replace(".", "").Replace(',', '.');   // formato es-AR: 1.500,50
            else if (ultimaComa < 0 && ultimoPunto >= 0
                     && (s.IndexOf('.') != ultimoPunto || s.Length - ultimoPunto - 1 == 3))
                s = s.Replace(".", "");                     // solo separadores de miles: 1.500 / 1.500.000
            else
                s = s.Replace(",", "");                     // formato invariante: 1,500.50 / 1500.5
            decimal valor;
            if (decimal.TryParse(s, NumberStyles.Number, Invariante, out valor)) return Math.Round(valor, 2);
            throw new ValidacionException("El importe '" + tb.Text + "' no es válido.");
        }

        protected static int LeerEntero(TextBox tb)
        {
            int valor;
            return int.TryParse(tb.Text.Trim(), out valor) ? valor : 0;
        }

        /// <summary>Valor seleccionado de un combo (0 si no hay selección).</summary>
        protected static int IdSeleccionado(DropDownList ddl)
        {
            int valor;
            return int.TryParse(ddl.SelectedValue, out valor) ? valor : 0;
        }

        /// <summary>Valor seleccionado de un combo de filtro (null si es "Todos").</summary>
        protected static int? IdFiltro(DropDownList ddl)
        {
            int valor = IdSeleccionado(ddl);
            return valor > 0 ? valor : (int?)null;
        }

        /// <summary>Texto seleccionado de un combo de filtro (null si es "Todos").</summary>
        protected static string TextoFiltro(DropDownList ddl)
        {
            return string.IsNullOrEmpty(ddl.SelectedValue) ? null : ddl.SelectedValue;
        }

        // ------------------------------------------------------------------
        // Escritura de valores en controles
        // ------------------------------------------------------------------
        protected static void EscribirFecha(TextBox tb, DateTime? fecha)
        {
            tb.Text = fecha.HasValue ? fecha.Value.ToString("yyyy-MM-dd", Invariante) : string.Empty;
        }

        protected static void EscribirFechaHora(TextBox tb, DateTime? fecha)
        {
            tb.Text = fecha.HasValue ? fecha.Value.ToString("yyyy-MM-ddTHH:mm", Invariante) : string.Empty;
        }

        protected static void EscribirHora(TextBox tb, TimeSpan hora)
        {
            tb.Text = hora.ToString(@"hh\:mm", Invariante);
        }

        protected static void EscribirDecimal(TextBox tb, decimal valor)
        {
            tb.Text = valor.ToString("0.00", Invariante);
        }

        /// <summary>Selecciona un valor del combo solo si existe (evita excepciones).</summary>
        protected static void Seleccionar(DropDownList ddl, object valor)
        {
            ddl.ClearSelection();
            if (valor == null) return;
            ListItem item = ddl.Items.FindByValue(Convert.ToString(valor, Invariante));
            if (item != null) item.Selected = true;
        }

        // ------------------------------------------------------------------
        // Carga de combos
        // ------------------------------------------------------------------
        protected static void CargarCombo(DropDownList ddl, IEnumerable<ItemCombo> items, string textoVacio)
        {
            ddl.Items.Clear();
            if (textoVacio != null) ddl.Items.Add(new ListItem(textoVacio, ""));
            foreach (ItemCombo i in items)
                ddl.Items.Add(new ListItem(i.Texto, i.Valor.ToString(Invariante)));
        }

        protected static void CargarCombo(DropDownList ddl, IEnumerable<Catalogo> items, string textoVacio)
        {
            CargarCombo(ddl, items.Select(c => new ItemCombo { Valor = c.ID, Texto = c.Nombre }), textoVacio);
        }

        protected static void CargarCombo(DropDownList ddl, IEnumerable<string> valores, string textoVacio)
        {
            ddl.Items.Clear();
            if (textoVacio != null) ddl.Items.Add(new ListItem(textoVacio, ""));
            foreach (string v in valores)
                ddl.Items.Add(new ListItem(v, v));
        }

        protected static void CargarCatalogo(DropDownList ddl, TipoCatalogo tipo, string textoVacio)
        {
            CargarCombo(ddl, new CatalogoBLL().Listar(tipo), textoVacio);
        }

        // ------------------------------------------------------------------
        // Helpers de presentación (se usan desde el markup con <%# ... %>)
        // ------------------------------------------------------------------

        /// <summary>Clase CSS de Bootstrap (badge) según el estado.</summary>
        protected static string ClaseEstado(object estado)
        {
            switch (Convert.ToString(estado))
            {
                case "Activo":
                case "Operativo":
                case "Disponible":
                case "Finalizada":
                case "Vigente":
                case "Ingreso":
                    return "badge text-bg-success";
                case "Licencia":
                case "En mantenimiento":
                case "Próximo a vencer":
                    return "badge text-bg-warning";
                case "En curso":
                case "En uso":
                    return "badge text-bg-primary";
                case "Baja":
                case "Fuera de servicio":
                case "Vencido":
                case "Egreso":
                    return "badge text-bg-danger";
                default:
                    return "badge text-bg-secondary";
            }
        }

        /// <summary>Clase CSS de Bootstrap (badge) según la severidad del incidente.</summary>
        protected static string ClaseSeveridad(object severidad)
        {
            switch (Convert.ToString(severidad))
            {
                case "Baja": return "badge text-bg-info";
                case "Media": return "badge text-bg-warning";
                case "Alta": return "badge sev-alta";
                case "Critica": return "badge text-bg-danger";
                default: return "badge text-bg-secondary";
            }
        }

        protected static string FormatearFecha(object fecha)
        {
            if (fecha == null || fecha == DBNull.Value) return "-";
            return Convert.ToDateTime(fecha).ToString("dd/MM/yyyy");
        }

        protected static string FormatearMoneda(object monto)
        {
            if (monto == null || monto == DBNull.Value) return "-";
            return Convert.ToDecimal(monto).ToString("C2", CultureInfo.GetCultureInfo("es-AR"));
        }

        protected static string Html(object valor)
        {
            return HttpUtility.HtmlEncode(Convert.ToString(valor));
        }
    }
}
