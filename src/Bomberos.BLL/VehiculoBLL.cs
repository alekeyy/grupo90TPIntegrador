using System;
using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Vehículos.
    /// </summary>
    public class VehiculoBLL
    {
        public const int AnioMinimo = 1950;

        /// <summary>
        /// Formatos de patente argentina: AAA999 (1995-2016), AA999AA (Mercosur),
        /// A999AAA (motos Mercosur) y 999AAA (motos anteriores).
        /// </summary>
        public const string PatronPatente = @"^([A-Z]{3}\d{3}|[A-Z]{2}\d{3}[A-Z]{2}|[A-Z]\d{3}[A-Z]{3}|\d{3}[A-Z]{3})$";

        private readonly VehiculoDAL _dal = new VehiculoDAL();

        public List<Vehiculo> Listar(string patente, string estado, int? idTipoVehiculo)
        {
            return _dal.Listar(Texto.NormalizarCodigo(patente), Texto.Normalizar(estado), idTipoVehiculo);
        }

        public Vehiculo Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public List<ItemCombo> Combo(bool soloOperativos)
        {
            return _dal.Combo(soloOperativos);
        }

        public int Guardar(Vehiculo v)
        {
            v.Nombre = Texto.Normalizar(v.Nombre);
            v.Patente = Texto.NormalizarCodigo(v.Patente);
            v.Estado = Texto.Normalizar(v.Estado);
            int anioMaximo = DateTime.Today.Year + 1;

            new Validador()
                .Requerido(v.Nombre, "Nombre").LongitudMaxima(v.Nombre, 100, "Nombre")
                .Requerido(v.Patente, "Patente").LongitudMaxima(v.Patente, 10, "Patente")
                .Patron(v.Patente, PatronPatente, "La patente no tiene un formato válido (ej.: ABC123, AB123CD o A123BCD).")
                .Regla(v.Anio >= AnioMinimo && v.Anio <= anioMaximo, "El año debe estar entre " + AnioMinimo + " y " + anioMaximo + ".")
                .EnLista(v.Estado, Constantes.EstadosVehiculo, "Estado")
                .Seleccionado(v.IDTipoVehiculo, "un tipo de vehículo")
                .Lanzar();

            if (v.IDVehiculo == 0)
                return _dal.Insertar(v);

            _dal.Actualizar(v);
            return v.IDVehiculo;
        }

        public void Eliminar(int id)
        {
            _dal.Eliminar(id);
        }
    }
}
