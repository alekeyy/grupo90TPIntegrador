using System;
using System.Web;
using Bomberos.Web.Code;

namespace Bomberos.Web
{
    /// <summary>
    /// Eventos de la aplicación.
    /// </summary>
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Manejador global de errores no controlados: registra el error en App_Data\Logs.
        /// La redirección a Error.aspx la realiza la sección customErrors del Web.config.
        /// </summary>
        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            if (ex is HttpUnhandledException && ex.InnerException != null)
                ex = ex.InnerException;

            HttpException httpEx = ex as HttpException;
            if (httpEx != null && httpEx.GetHttpCode() == 404)
                return;

            Logger.Error(ex, Request.RawUrl);
        }
    }
}
