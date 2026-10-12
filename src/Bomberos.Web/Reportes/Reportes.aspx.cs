using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using Bomberos.BLL;
using Bomberos.Entities;
using Bomberos.Web.Code;

namespace Bomberos.Web.Reportes
{
    /// <summary>
    /// Página única de reportes. La categoría se indica en la URL (?cat=personal|operaciones|vehiculos|equipamiento|finanzas)
    /// y opcionalmente el reporte (&amp;rep=clave). Los parámetros visibles dependen de la definición del reporte.
    /// </summary>
    public partial class ReportesPage : BasePage
    {
        private static readonly CultureInfo Ar = CultureInfo.GetCultureInfo("es-AR");
        private readonly ReporteBLL _bll = new ReporteBLL();

        private string Categoria
        {
            get
            {
                string cat = (Request.QueryString["cat"] ?? ReporteBLL.CatPersonal).ToLowerInvariant();
                return _bll.ListarPorCategoria(cat).Count > 0 ? cat : ReporteBLL.CatPersonal;
            }
        }

        /// <summary>Clave del reporte seleccionado (se conserva en ViewState).</summary>
        protected string ClaveActual
        {
            get { return ViewState["Clave"] as string; }
            set { ViewState["Clave"] = value; }
        }

        private ReporteDefinicion Definicion
        {
            get { return _bll.Obtener(ClaveActual); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string tituloCategoria = ReporteBLL.TituloCategoria(Categoria);
            litCategoria.Text = tituloCategoria;
            Title = "Reportes de " + tituloCategoria;

            if (!IsPostBack)
            {
                List<ReporteDefinicion> reportes = _bll.ListarPorCategoria(Categoria);
                string solicitado = Request.QueryString["rep"];
                ClaveActual = reportes.Any(r => r.Clave == solicitado) ? solicitado : reportes[0].Clave;

                EscribirFecha(txtDesde, new DateTime(DateTime.Today.Year, 1, 1));
                EscribirFecha(txtHasta, DateTime.Today);
                txtAnio.Text = DateTime.Today.Year.ToString();
                rvAnio.MaximumValue = (DateTime.Today.Year + 1).ToString();
                try
                {
                    CargarCombo(ddlVoluntario, new VoluntarioBLL().Combo(false), "(Todos)");
                    CargarCatalogo(ddlCaja, TipoCatalogo.Caja, "(Todas)");
                    Seleccionar(ddlVoluntario, Request.QueryString["voluntario"]);
                }
                catch (Exception ex)
                {
                    ManejarExcepcion(ex);
                }
                ConfigurarReporte(true);
                Generar();
            }
        }

        /// <summary>Muestra los filtros que corresponden al reporte seleccionado.</summary>
        private void ConfigurarReporte(bool reiniciarValores)
        {
            ReporteDefinicion def = Definicion;
            rptReportes.DataSource = _bll.ListarPorCategoria(Categoria);
            rptReportes.DataBind();

            litTitulo.Text = Html(def.Titulo);
            litDescripcion.Text = Html(def.Descripcion);
            litTituloResultado.Text = Html(def.Titulo);

            phPeriodo.Visible = def.Usa(ParametroReporte.Periodo);
            phVoluntario.Visible = def.Usa(ParametroReporte.Voluntario);
            phEstado.Visible = def.Usa(ParametroReporte.EstadoMision) || def.Usa(ParametroReporte.EstadoEquipo);
            phCaja.Visible = def.Usa(ParametroReporte.Caja);
            phAnio.Visible = def.Usa(ParametroReporte.Anio);
            phDias.Visible = def.Usa(ParametroReporte.Dias);

            if (reiniciarValores)
            {
                if (def.Usa(ParametroReporte.EstadoMision))
                    CargarCombo(ddlEstado, Constantes.EstadosMision, "(Todos)");
                else if (def.Usa(ParametroReporte.EstadoEquipo))
                    CargarCombo(ddlEstado, Constantes.EstadosEquipamiento, "(Todos)");
                txtDias.Text = def.DiasPorDefecto.ToString();
            }
        }

        private FiltroReporte LeerFiltro()
        {
            ReporteDefinicion def = Definicion;
            FiltroReporte f = new FiltroReporte();
            if (def.Usa(ParametroReporte.Periodo)) { f.Desde = LeerFecha(txtDesde); f.Hasta = LeerFecha(txtHasta); }
            if (def.Usa(ParametroReporte.Voluntario)) f.IDVoluntario = IdFiltro(ddlVoluntario);
            if (phEstado.Visible) f.Estado = TextoFiltro(ddlEstado);
            if (def.Usa(ParametroReporte.Caja)) f.IDCaja = IdFiltro(ddlCaja);
            if (def.Usa(ParametroReporte.Anio)) f.Anio = LeerEntero(txtAnio);
            if (def.Usa(ParametroReporte.Dias)) f.Dias = string.IsNullOrWhiteSpace(txtDias.Text) ? (int?)null : LeerEntero(txtDias);
            return f;
        }

        private void Generar()
        {
            try
            {
                DataTable dt = _bll.Ejecutar(ClaveActual, LeerFiltro());
                litResumen.Text = dt.Rows.Count + " fila(s) · generado el " + DateTime.Now.ToString("dd/MM/yyyy HH:mm");
                gvReporte.DataSource = dt;
                gvReporte.DataBind();
            }
            catch (Exception ex)
            {
                litResumen.Text = string.Empty;
                gvReporte.DataSource = null;
                gvReporte.DataBind();
                ManejarExcepcion(ex);
            }
        }

        protected void SeleccionarReporte_Command(object sender, CommandEventArgs e)
        {
            ClaveActual = Convert.ToString(e.CommandArgument);
            gvReporte.PageIndex = 0;
            ConfigurarReporte(true);
            Generar();
        }

        protected void btnGenerar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            gvReporte.PageIndex = 0;
            ConfigurarReporte(false);
            Generar();
        }

        protected void gvReporte_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            gvReporte.PageIndex = e.NewPageIndex;
            ConfigurarReporte(false);
            Generar();
        }

        /// <summary>
        /// Da formato a las celdas según el tipo de dato de la columna:
        /// fechas dd/MM/yyyy (con hora si corresponde), importes en moneda y números alineados a la derecha.
        /// </summary>
        protected void gvReporte_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow && e.Row.RowType != DataControlRowType.Header) return;
            DataTable dt = gvReporte.DataSource as DataTable;
            if (dt == null) return;

            for (int i = 0; i < dt.Columns.Count && i < e.Row.Cells.Count; i++)
            {
                DataColumn col = dt.Columns[i];
                bool numerico = col.DataType == typeof(decimal) || col.DataType == typeof(int) || col.DataType == typeof(long) || col.DataType == typeof(double);
                if (numerico) e.Row.Cells[i].CssClass = "text-end";
                if (e.Row.RowType != DataControlRowType.DataRow) continue;

                object valor = ((DataRowView)e.Row.DataItem)[i];
                e.Row.Cells[i].Text = FormatearCelda(col, valor, true);
            }
        }

        private static string FormatearCelda(DataColumn col, object valor, bool html)
        {
            if (valor == null || valor == DBNull.Value) return html ? "-" : "";
            if (col.DataType == typeof(DateTime))
            {
                DateTime d = (DateTime)valor;
                return d.TimeOfDay == TimeSpan.Zero ? d.ToString("dd/MM/yyyy") : d.ToString("dd/MM/yyyy HH:mm");
            }
            if (col.DataType == typeof(decimal))
            {
                decimal m = (decimal)valor;
                if (col.ColumnName.Contains("%")) return m.ToString("0.00", Ar) + " %";
                return html ? m.ToString("C2", Ar) : m.ToString("0.00", Ar);
            }
            string texto = Convert.ToString(valor, Ar);
            return html ? System.Web.HttpUtility.HtmlEncode(texto) : texto;
        }

        /// <summary>Exporta el reporte completo (sin paginación) a CSV separado por ';' (compatible con Excel en español).</summary>
        protected void btnExportar_Click(object sender, EventArgs e)
        {
            if (!IsValid) return;
            DataTable dt;
            try
            {
                ConfigurarReporte(false);
                dt = _bll.Ejecutar(ClaveActual, LeerFiltro());
            }
            catch (Exception ex)
            {
                ManejarExcepcion(ex);
                return;
            }

            StringBuilder sb = new StringBuilder();
            sb.AppendLine(string.Join(";", dt.Columns.Cast<DataColumn>().Select(c => Csv(c.ColumnName))));
            foreach (DataRow r in dt.Rows)
                sb.AppendLine(string.Join(";", dt.Columns.Cast<DataColumn>().Select(c => Csv(FormatearCelda(c, r[c], false)))));

            Response.Clear();
            Response.ContentType = "text/csv";
            Response.ContentEncoding = Encoding.UTF8;
            Response.AddHeader("Content-Disposition", "attachment; filename=" + ClaveActual + "-" + DateTime.Now.ToString("yyyyMMdd-HHmm") + ".csv");
            Response.BinaryWrite(Encoding.UTF8.GetPreamble());
            Response.Write(sb.ToString());
            Response.Flush();
            Context.ApplicationInstance.CompleteRequest();
            Response.SuppressContent = true;
        }

        private static string Csv(string valor)
        {
            valor = valor ?? string.Empty;
            // Evita inyección de fórmulas en Excel
            if (valor.Length > 0 && "=+-@".IndexOf(valor[0]) >= 0 && !char.IsDigit(valor.Length > 1 ? valor[1] : 'x'))
                valor = "'" + valor;
            return valor.IndexOfAny(new[] { ';', '"', '\n', '\r' }) >= 0 ? "\"" + valor.Replace("\"", "\"\"") + "\"" : valor;
        }
    }
}
