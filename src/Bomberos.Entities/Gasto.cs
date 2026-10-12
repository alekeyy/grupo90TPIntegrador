using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Gasto del cuartel autorizado por un voluntario (tabla Gastos).
    /// </summary>
    [Serializable]
    public class Gasto
    {
        public int IDGasto { get; set; }
        public DateTime Fecha { get; set; }
        public decimal Monto { get; set; }
        public string Descripcion { get; set; }
        public int IDTipoGasto { get; set; }
        public int IDVoluntarioAutorizador { get; set; }

        public string TipoNombre { get; set; }
        public string AutorizadorNombre { get; set; }
    }
}
