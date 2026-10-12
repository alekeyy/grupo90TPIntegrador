using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Entrenamientos.
    /// </summary>
    public class EntrenamientoBLL
    {
        private readonly EntrenamientoDAL _dal = new EntrenamientoDAL();

        public List<Entrenamiento> Listar(int? idVoluntario, int? idTipo, DateTime? desde, DateTime? hasta)
        {
            if (desde.HasValue && hasta.HasValue && desde > hasta)
                throw new ValidacionException("La fecha 'desde' no puede ser posterior a la fecha 'hasta'.");
            return _dal.Listar(idVoluntario, idTipo, desde, hasta);
        }

        public Entrenamiento Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public int Guardar(Entrenamiento e)
        {
            e.Observaciones = Texto.Normalizar(e.Observaciones);

            new Validador()
                .Seleccionado(e.IDTipoEntrenamiento, "un tipo de entrenamiento")
                .Seleccionado(e.IDVoluntario, "un voluntario")
                .FechaValida(e.Fecha, "Fecha")
                .LongitudMaxima(e.Observaciones, 500, "Observaciones")
                .Lanzar();

            if (e.IDEntrenamiento == 0)
                return _dal.Insertar(e);

            _dal.Actualizar(e);
            return e.IDEntrenamiento;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
