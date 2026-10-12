using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.Entities;

namespace Bomberos.DAL
{
    /// <summary>
    /// Acceso a datos de la tabla MovimientoCaja y saldos de cajas.
    /// </summary>
    public class MovimientoCajaDAL
    {
        private static MovimientoCaja Mapear(IDataRecord r)
        {
            return new MovimientoCaja
            {
                IDMovimiento = r.LeerInt("IDMovimiento"),
                IDCaja = r.LeerInt("IDCaja"),
                Fecha = r.LeerFecha("Fecha"),
                TipoMovimiento = r.LeerString("TipoMovimiento"),
                Monto = r.LeerDecimal("Monto"),
                Concepto = r.LeerString("Concepto"),
                CajaNombre = r.LeerString("CajaNombre")
            };
        }

        private static CajaSaldo MapearSaldo(IDataRecord r)
        {
            return new CajaSaldo
            {
                IDCaja = r.LeerInt("IDCaja"),
                Nombre = r.LeerString("Nombre"),
                TotalIngresos = r.LeerDecimal("TotalIngresos"),
                TotalEgresos = r.LeerDecimal("TotalEgresos"),
                Saldo = r.LeerDecimal("Saldo"),
                CantidadMovimientos = r.LeerInt("CantidadMovimientos")
            };
        }

        public List<MovimientoCaja> Listar(int? idCaja, DateTime? desde, DateTime? hasta, string tipoMovimiento)
        {
            return SqlHelper.EjecutarLista("sp_MovimientoCaja_Listar", Mapear,
                SqlHelper.P("@IDCaja", idCaja),
                SqlHelper.P("@Desde", desde),
                SqlHelper.P("@Hasta", hasta),
                SqlHelper.P("@TipoMovimiento", tipoMovimiento));
        }

        public MovimientoCaja Obtener(int id)
        {
            return SqlHelper.EjecutarUno("sp_MovimientoCaja_Obtener", Mapear, SqlHelper.P("@IDMovimiento", id));
        }

        public int Insertar(MovimientoCaja m)
        {
            return SqlHelper.EjecutarInsert("sp_MovimientoCaja_Insertar",
                SqlHelper.P("@IDCaja", m.IDCaja),
                SqlHelper.P("@Fecha", m.Fecha),
                SqlHelper.P("@TipoMovimiento", m.TipoMovimiento),
                SqlHelper.P("@Monto", m.Monto),
                SqlHelper.P("@Concepto", m.Concepto));
        }

        public void Actualizar(MovimientoCaja m)
        {
            SqlHelper.EjecutarNonQuery("sp_MovimientoCaja_Actualizar",
                SqlHelper.P("@IDMovimiento", m.IDMovimiento),
                SqlHelper.P("@IDCaja", m.IDCaja),
                SqlHelper.P("@Fecha", m.Fecha),
                SqlHelper.P("@TipoMovimiento", m.TipoMovimiento),
                SqlHelper.P("@Monto", m.Monto),
                SqlHelper.P("@Concepto", m.Concepto));
        }

        public void Eliminar(int id)
        {
            SqlHelper.EjecutarNonQuery("sp_MovimientoCaja_Eliminar", SqlHelper.P("@IDMovimiento", id));
        }

        public List<CajaSaldo> Saldos()
        {
            return SqlHelper.EjecutarLista("sp_Caja_Saldos", MapearSaldo);
        }
    }
}
