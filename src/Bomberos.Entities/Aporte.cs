using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Aporte económico recibido por el cuartel (tabla Aportes).
    /// </summary>
    [Serializable]
    public class Aporte
    {
        public int IDAporte { get; set; }
        public int IDTipoAporte { get; set; }
        public DateTime Fecha { get; set; }
        public decimal Monto { get; set; }
        public string Descripcion { get; set; }

        public string TipoNombre { get; set; }
    }
}
