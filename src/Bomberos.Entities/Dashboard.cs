using System;

namespace Bomberos.Entities
{
    /// <summary>
    /// Indicadores que se muestran en la página inicial.
    /// </summary>
    [Serializable]
    public class DashboardIndicadores
    {
        public int VoluntariosActivos { get; set; }
        public int VoluntariosTotales { get; set; }
        public int VehiculosOperativos { get; set; }
        public int VehiculosTotales { get; set; }
        public int EquipamientoDisponible { get; set; }
        public int EquipamientoTotal { get; set; }
        public int MisionesEnCurso { get; set; }
        public int GuardiasActivas { get; set; }
        public int GuardiasHoy { get; set; }
        public decimal SaldoTotalCajas { get; set; }
        public decimal GastosMes { get; set; }
        public decimal AportesMes { get; set; }
        public int DocumentosVencidos { get; set; }
        public int DocumentosPorVencer { get; set; }
        public int MantenimientosProximos { get; set; }
    }

    /// <summary>
    /// Punto de una serie para gráficos (etiqueta + valor).
    /// </summary>
    [Serializable]
    public class SerieDato
    {
        public string Etiqueta { get; set; }
        public decimal Valor { get; set; }
    }

    /// <summary>
    /// Totales mensuales de aportes y gastos.
    /// </summary>
    [Serializable]
    public class FinanzaMensual
    {
        public string Periodo { get; set; }
        public decimal Aportes { get; set; }
        public decimal Gastos { get; set; }
    }
}
