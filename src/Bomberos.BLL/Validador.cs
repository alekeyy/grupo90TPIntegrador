using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;

namespace Bomberos.BLL
{
    /// <summary>
    /// Acumulador de errores de validación. Uso:
    ///   var v = new Validador();
    ///   v.Requerido(x.Nombre, "Nombre");
    ///   v.Lanzar();   // lanza ValidacionException si hubo errores
    /// </summary>
    internal class Validador
    {
        private readonly List<string> _errores = new List<string>();

        public bool EsValido
        {
            get { return _errores.Count == 0; }
        }

        public Validador Requerido(string valor, string campo)
        {
            if (string.IsNullOrWhiteSpace(valor))
                _errores.Add("El campo " + campo + " es obligatorio.");
            return this;
        }

        public Validador LongitudMaxima(string valor, int maximo, string campo)
        {
            if (valor != null && valor.Length > maximo)
                _errores.Add("El campo " + campo + " admite como máximo " + maximo + " caracteres.");
            return this;
        }

        public Validador Patron(string valor, string patron, string mensaje)
        {
            if (!string.IsNullOrEmpty(valor) && !Regex.IsMatch(valor, patron))
                _errores.Add(mensaje);
            return this;
        }

        public Validador Seleccionado(int id, string campo)
        {
            if (id <= 0)
                _errores.Add("Debe seleccionar " + campo + ".");
            return this;
        }

        public Validador EnLista(string valor, IEnumerable<string> permitidos, string campo)
        {
            if (string.IsNullOrEmpty(valor) || !permitidos.Contains(valor))
                _errores.Add("El valor de " + campo + " no es válido. Valores permitidos: " + string.Join(", ", permitidos) + ".");
            return this;
        }

        public Validador FechaValida(DateTime fecha, string campo)
        {
            if (fecha == DateTime.MinValue || fecha.Year < 1900 || fecha.Year > 2100)
                _errores.Add("El campo " + campo + " debe contener una fecha válida.");
            return this;
        }

        /// <summary>Agrega el mensaje si la condición NO se cumple.</summary>
        public Validador Regla(bool condicion, string mensaje)
        {
            if (!condicion)
                _errores.Add(mensaje);
            return this;
        }

        public void Lanzar()
        {
            if (_errores.Count > 0)
                throw new ValidacionException(_errores);
        }
    }

    /// <summary>
    /// Utilidades de normalización de textos.
    /// </summary>
    internal static class Texto
    {
        /// <summary>Quita espacios al inicio/fin y convierte cadenas vacías en null.</summary>
        public static string Normalizar(string valor)
        {
            if (valor == null) return null;
            valor = valor.Trim();
            return valor.Length == 0 ? null : valor;
        }

        /// <summary>Normaliza y además pasa a mayúsculas quitando espacios y guiones internos.</summary>
        public static string NormalizarCodigo(string valor)
        {
            valor = Normalizar(valor);
            return valor == null ? null : valor.Replace(" ", "").Replace("-", "").ToUpperInvariant();
        }
    }
}
