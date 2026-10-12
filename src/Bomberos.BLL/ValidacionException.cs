using System;
using System.Collections.Generic;

namespace Bomberos.BLL
{
    /// <summary>
    /// Excepción lanzada por la capa de negocio cuando los datos no cumplen las reglas.
    /// Contiene la lista de errores para mostrarlos todos juntos en la interfaz.
    /// </summary>
    [Serializable]
    public class ValidacionException : Exception
    {
        public IList<string> Errores { get; private set; }

        public ValidacionException(string mensaje) : base(mensaje)
        {
            Errores = new List<string> { mensaje };
        }

        public ValidacionException(IList<string> errores) : base(string.Join(" ", errores))
        {
            Errores = errores;
        }
    }
}
