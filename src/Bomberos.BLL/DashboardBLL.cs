using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Indicadores y series para el Dashboard.
    /// </summary>
    public class DashboardBLL
    {
        private readonly DashboardDAL _dal = new DashboardDAL();

        public DashboardIndicadores ObtenerIndicadores()
        {
            return _dal.ObtenerIndicadores();
        }

        public List<FinanzaMensual> FinanzasMensuales(int meses = 12)
        {
            if (meses < 1) meses = 1;
            if (meses > 36) meses = 36;
            return _dal.FinanzasMensuales(meses);
        }

        public List<SerieDato> MisionesPorTipo()
        {
            return _dal.Serie("sp_Dashboard_MisionesPorTipo");
        }

        public List<SerieDato> EquipamientoPorEstado()
        {
            return _dal.Serie("sp_Dashboard_EquipamientoPorEstado");
        }

        public List<SerieDato> VehiculosPorEstado()
        {
            return _dal.Serie("sp_Dashboard_VehiculosPorEstado");
        }

        public List<SerieDato> IncidentesPorSeveridad()
        {
            return _dal.Serie("sp_Dashboard_IncidentesPorSeveridad");
        }
    }
}
