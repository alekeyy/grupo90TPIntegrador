using System;
using System.Collections.Generic;
using System.Data;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de Voluntarios.
    /// </summary>
    public class VoluntarioBLL
    {
        public const int EdadMinima = 16;
        private readonly VoluntarioDAL _dal = new VoluntarioDAL();

        public List<Voluntario> Listar(string texto, string estado)
        {
            return _dal.Listar(Texto.Normalizar(texto), Texto.Normalizar(estado));
        }

        public Voluntario Obtener(int id)
        {
            return _dal.Obtener(id);
        }

        public DataTable ObtenerFicha(int id)
        {
            return _dal.ObtenerFicha(id);
        }

        /// <summary>Voluntarios para combos. soloActivos = true: solo estado Activo; false: todos menos los dados de baja.</summary>
        public List<ItemCombo> Combo(bool soloActivos)
        {
            return _dal.Combo(soloActivos);
        }

        public int Guardar(Voluntario v)
        {
            v.Nombre = Texto.Normalizar(v.Nombre);
            v.Apellido = Texto.Normalizar(v.Apellido);
            v.DNI = Texto.NormalizarCodigo(v.DNI);
            if (v.DNI != null) v.DNI = v.DNI.Replace(".", "");
            v.Telefono = Texto.Normalizar(v.Telefono);
            v.Email = Texto.Normalizar(v.Email);
            v.Direccion = Texto.Normalizar(v.Direccion);
            v.Estado = Texto.Normalizar(v.Estado) ?? Constantes.VoluntarioActivo;

            new Validador()
                .Requerido(v.Nombre, "Nombre").LongitudMaxima(v.Nombre, 100, "Nombre")
                .Requerido(v.Apellido, "Apellido").LongitudMaxima(v.Apellido, 100, "Apellido")
                .Requerido(v.DNI, "DNI")
                .Patron(v.DNI, @"^\d{7,8}$", "El DNI debe contener 7 u 8 dígitos numéricos.")
                .FechaValida(v.FechaNacimiento, "Fecha de nacimiento")
                .FechaValida(v.FechaIngreso, "Fecha de ingreso")
                .Regla(v.FechaNacimiento == DateTime.MinValue || v.Edad >= EdadMinima,
                       "El voluntario debe tener al menos " + EdadMinima + " años.")
                .Regla(v.FechaNacimiento.Date <= DateTime.Today, "La fecha de nacimiento no puede ser futura.")
                .Regla(v.FechaIngreso.Date <= DateTime.Today, "La fecha de ingreso no puede ser futura.")
                .Regla(v.FechaIngreso >= v.FechaNacimiento, "La fecha de ingreso no puede ser anterior a la fecha de nacimiento.")
                .LongitudMaxima(v.Telefono, 30, "Teléfono")
                .Patron(v.Telefono, @"^[0-9+()\-\s]{6,30}$", "El teléfono solo puede contener números, espacios, guiones, paréntesis y '+'.")
                .LongitudMaxima(v.Email, 100, "Email")
                .Patron(v.Email, @"^[^@\s]+@[^@\s]+\.[^@\s]+$", "El email no tiene un formato válido.")
                .LongitudMaxima(v.Direccion, 200, "Dirección")
                .EnLista(v.Estado, Constantes.EstadosVoluntario, "Estado")
                .Lanzar();

            if (v.IDVoluntario == 0)
                return _dal.Insertar(v);

            _dal.Actualizar(v);
            return v.IDVoluntario;
        }

        /// <summary>
        /// Baja lógica: conserva el registro y su historial, cambiando el estado a "Baja".
        /// </summary>
        public void DarDeBaja(int id)
        {
            Voluntario v = _dal.Obtener(id);
            if (v == null) throw new ValidacionException("El voluntario no existe.");
            if (v.Estado == Constantes.VoluntarioBaja) throw new ValidacionException("El voluntario ya se encuentra dado de baja.");
            _dal.BajaLogica(id);
        }
    }
}
