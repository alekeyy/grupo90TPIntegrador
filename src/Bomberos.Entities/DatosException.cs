using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Excepción de la capa de datos con un mensaje apto para mostrar al usuario.
    /// Se define en Entities (ensamblado compartido) para que la UI pueda capturarla sin referenciar la DAL.
    /// La excepción original de SQL Server queda en InnerException para diagnóstico.
    /// </summary>
    [Serializable]
    public class DatosException : Exception
    {
        /// <summary>Número de error de SQL Server (0 si no proviene de SQL Server).</summary>
        public int NumeroError { get; private set; }

        /// <summary>true si el error corresponde a una regla de negocio validada en un Stored Procedure (THROW 50000+).</summary>
        public bool EsReglaDeNegocio
        {
            get { return NumeroError >= 50000; }
        }

        public DatosException(string mensaje) : base(mensaje) { }

        public DatosException(string mensaje, Exception inner) : base(mensaje, inner) { }

        public DatosException(string mensaje, int numeroError, Exception inner) : base(mensaje, inner)
        {
            NumeroError = numeroError;
        }
    }
}
