using System;
using Bomberos.Web.Code;

namespace Bomberos.Web
{
    /// <summary>
    /// Página de error amigable (configurada en customErrors del Web.config).
    /// </summary>
    public partial class ErrorPage : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["codigo"] == "404")
            {
                Response.StatusCode = 404;
                litTitulo.Text = "Página no encontrada";
                litDetalle.Text = "La página solicitada no existe o fue movida.";
            }
        }
    }
}
