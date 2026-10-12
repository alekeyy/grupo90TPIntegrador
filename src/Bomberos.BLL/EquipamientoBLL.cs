using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Equipamiento.
    /// </summary>
    public class EquipamientoBLL
    {
        private readonly EquipamientoDAL _dal = new EquipamientoDAL();

        public List<Equipamiento> Listar(string texto, string estado, int? idTipo, int? idCategoria)
        {
            return _dal.Listar(Texto.Normalizar(texto), Texto.Normalizar(estado), idTipo, idCategoria);
        }

        public Equipamiento Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public List<ItemCombo> Combo(bool soloDisponibles)
        {
            return _dal.Combo(soloDisponibles);
        }

        public int Guardar(Equipamiento e)
        {
            e.CodigoInterno = Texto.Normalizar(e.CodigoInterno);
            if (e.CodigoInterno != null) e.CodigoInterno = e.CodigoInterno.ToUpperInvariant();
            e.Nombre = Texto.Normalizar(e.Nombre);
            e.Estado = Texto.Normalizar(e.Estado);

            new Validador()
                .Requerido(e.CodigoInterno, "Código interno").LongitudMaxima(e.CodigoInterno, 20, "Código interno")
                .Patron(e.CodigoInterno, @"^[A-Z0-9\-]+$", "El código interno solo puede contener letras, números y guiones.")
                .Requerido(e.Nombre, "Nombre").LongitudMaxima(e.Nombre, 100, "Nombre")
                .EnLista(e.Estado, Constantes.EstadosEquipamiento, "Estado")
                .Seleccionado(e.IDTipoEquipamiento, "un tipo de equipamiento")
                .Seleccionado(e.IDCategoriaEquipamiento, "una categoría")
                .Regla(!e.FechaCompra.HasValue || e.FechaCompra.Value.Date <= DateTime.Today, "La fecha de compra no puede ser futura.")
                .Regla(!e.FechaCompra.HasValue || !e.FechaUltimoMantenimiento.HasValue || e.FechaUltimoMantenimiento >= e.FechaCompra,
                       "El último mantenimiento no puede ser anterior a la fecha de compra.")
                .Regla(!e.FechaUltimoMantenimiento.HasValue || e.FechaUltimoMantenimiento.Value.Date <= DateTime.Today,
                       "La fecha del último mantenimiento no puede ser futura.")
                .Regla(!e.FechaUltimoMantenimiento.HasValue || !e.FechaProximoMantenimiento.HasValue || e.FechaProximoMantenimiento >= e.FechaUltimoMantenimiento,
                       "El próximo mantenimiento no puede ser anterior al último mantenimiento.")
                .Lanzar();

            if (e.IDEquipamiento == 0)
                return _dal.Insertar(e);

            _dal.Actualizar(e);
            return e.IDEquipamiento;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
