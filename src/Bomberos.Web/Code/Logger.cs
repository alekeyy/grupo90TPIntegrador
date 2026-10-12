using System;
using System.IO;
using System.Text;
using System.Web;
using System.Web.Hosting;

namespace Bomberos.Web.Code
{
    /// <summary>
    /// Registro simple de errores en archivo de texto (App_Data\Logs\errores-AAAAMMDD.log).
    /// Nunca lanza excepciones: si no puede escribir, el error se ignora.
    /// </summary>
    public static class Logger
    {
        private static readonly object Bloqueo = new object();

        public static void Error(Exception ex, string contexto = null)
        {
            if (ex == null) return;
            try
            {
                string carpeta = HostingEnvironment.MapPath("~/App_Data/Logs");
                if (string.IsNullOrEmpty(carpeta)) return;
                Directory.CreateDirectory(carpeta);
                string archivo = Path.Combine(carpeta, "errores-" + DateTime.Now.ToString("yyyyMMdd") + ".log");

                StringBuilder sb = new StringBuilder();
                sb.AppendLine("==== " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " ====");
                if (!string.IsNullOrEmpty(contexto)) sb.AppendLine("URL: " + contexto);
                sb.AppendLine(ex.ToString());
                sb.AppendLine();

                lock (Bloqueo)
                {
                    File.AppendAllText(archivo, sb.ToString(), Encoding.UTF8);
                }
                System.Diagnostics.Trace.TraceError(ex.ToString());
            }
            catch
            {
                // El registro de errores nunca debe interrumpir la aplicación.
            }
        }
    }
}
