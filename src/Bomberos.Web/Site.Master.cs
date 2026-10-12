using System;
using System.Collections.Generic;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Bomberos.Web.Code;

namespace Bomberos.Web
{
    /// <summary>
    /// Página maestra: estructura general, menú lateral y área de mensajes.
    /// </summary>
    public partial class SiteMaster : MasterPage
    {
        /// <summary>Mensajes ya mostrados en esta respuesta (evita repetir el mismo error).</summary>
        private readonly HashSet<string> _mensajesMostrados = new HashSet<string>();

        protected void Page_Load(object sender, EventArgs e)
        {
            litCuartel.Text = HttpUtility.HtmlEncode(ConfigurationManager.AppSettings["NombreCuartel"] ?? "Bomberos Voluntarios");
            litFecha.Text = DateTime.Today.ToString("dddd, dd 'de' MMMM 'de' yyyy");
            litAnio.Text = DateTime.Today.Year.ToString();

            // Título de la pestaña del navegador: "<título de la página> | Bomberos Voluntarios"
            if (!string.IsNullOrEmpty(Page.Title) && !Page.Title.EndsWith("| Bomberos Voluntarios"))
                Page.Title = Page.Title + " | Bomberos Voluntarios";
        }

        /// <summary>Muestra un mensaje (texto plano, se codifica) como alerta de Bootstrap.</summary>
        public void MostrarMensaje(string mensaje, TipoMensaje tipo)
        {
            MostrarMensajeHtml(HttpUtility.HtmlEncode(mensaje), tipo);
        }

        /// <summary>Muestra un mensaje con HTML ya codificado/confiable como alerta de Bootstrap.</summary>
        public void MostrarMensajeHtml(string html, TipoMensaje tipo)
        {
            if (!_mensajesMostrados.Add(tipo + "|" + html)) return;
            string clase, icono;
            switch (tipo)
            {
                case TipoMensaje.Exito: clase = "alert-success"; icono = "bi-check-circle-fill"; break;
                case TipoMensaje.Advertencia: clase = "alert-warning"; icono = "bi-exclamation-triangle-fill"; break;
                case TipoMensaje.Error: clase = "alert-danger"; icono = "bi-x-octagon-fill"; break;
                default: clase = "alert-info"; icono = "bi-info-circle-fill"; break;
            }

            phMensajes.Controls.Add(new Literal
            {
                Mode = LiteralMode.PassThrough,
                Text = "<div class=\"alert " + clase + " alert-dismissible fade show d-flex gap-2\" role=\"alert\">"
                     + "<i class=\"bi " + icono + "\"></i><div>" + html + "</div>"
                     + "<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Cerrar\"></button></div>"
            });
        }
    }
}
