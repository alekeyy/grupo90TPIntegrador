using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de la documentación de vehículos (VTV, seguros, habilitaciones).
    /// </summary>
    public class DocumentoVehiculoBLL
    {
        public const string SituacionVencido = "Vencido";
        public const string SituacionProximo = "Próximo a vencer";
        public const string SituacionVigente = "Vigente";

        private readonly DocumentoVehiculoDAL _dal = new DocumentoVehiculoDAL();

        /// <param name="filtroSituacion">Vencido | Proximo | Vigente | null</param>
        public List<DocumentoVehiculo> Listar(int? idVehiculo, string filtroSituacion)
        {
            // Antes de listar se sincroniza el estado almacenado con la fecha del día.
            _dal.ActualizarEstados();
            return _dal.Listar(idVehiculo, Texto.Normalizar(filtroSituacion), Constantes.DiasAvisoVencimiento);
        }

        public DocumentoVehiculo Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(DocumentoVehiculo d)
        {
            d.TipoDocumento = Texto.Normalizar(d.TipoDocumento);

            new Validador()
                .Seleccionado(d.IDVehiculo, "un vehículo")
                .Requerido(d.TipoDocumento, "Tipo de documento").LongitudMaxima(d.TipoDocumento, 50, "Tipo de documento")
                .FechaValida(d.FechaEmision, "Fecha de emisión")
                .FechaValida(d.FechaVencimiento, "Fecha de vencimiento")
                .Regla(d.FechaVencimiento > d.FechaEmision, "La fecha de vencimiento debe ser posterior a la fecha de emisión.")
                .Lanzar();

            if (d.IDDocumento == 0)
                return _dal.Insertar(d);

            _dal.Actualizar(d);
            return d.IDDocumento;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
