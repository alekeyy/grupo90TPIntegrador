using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Par valor/texto utilizado para cargar DropDownList.
    /// </summary>
    [Serializable]
    public class ItemCombo
    {
        public int Valor { get; set; }
        public string Texto { get; set; }
    }
}
