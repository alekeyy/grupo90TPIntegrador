using System.Collections.Generic;
using Bomberos.DAL;
using Bomberos.Entities;

namespace Bomberos.BLL
{
    /// <summary>
    /// Reglas de negocio de los catálogos simples.
    /// </summary>
    public class CatalogoBLL
    {
        private readonly CatalogoDAL _dal = new CatalogoDAL();

        /// <summary>Título legible de cada catálogo (singular y plural) para la interfaz.</summary>
        public static string Titulo(TipoCatalogo tipo)
        {
            switch (tipo)
            {
                case TipoCatalogo.Rangos: return "Rangos";
                case TipoCatalogo.Roles: return "Roles";
                case TipoCatalogo.TipoVehiculo: return "Tipos de vehículo";
                case TipoCatalogo.TipoEquipamiento: return "Tipos de equipamiento";
                case TipoCatalogo.CategoriaEquipamiento: return "Categorías de equipamiento";
                case TipoCatalogo.TipoMision: return "Tipos de misión";
                case TipoCatalogo.TipoEntrenamiento: return "Tipos de entrenamiento";
                case TipoCatalogo.TipoAporte: return "Tipos de aporte";
                case TipoCatalogo.TipoGasto: return "Tipos de gasto";
                case TipoCatalogo.Caja: return "Cajas";
                default: return tipo.ToString();
            }
        }

        /// <summary>Módulo del menú al que pertenece cada catálogo.</summary>
        public static string Modulo(TipoCatalogo tipo)
        {
            switch (tipo)
            {
                case TipoCatalogo.Rangos:
                case TipoCatalogo.Roles: return "Personal";
                case TipoCatalogo.TipoVehiculo: return "Vehículos";
                case TipoCatalogo.TipoEquipamiento:
                case TipoCatalogo.CategoriaEquipamiento: return "Equipamiento";
                case TipoCatalogo.TipoMision: return "Operaciones";
                case TipoCatalogo.TipoEntrenamiento: return "Capacitación";
                default: return "Finanzas";
            }
        }

        /// <summary>Indica si el catálogo tiene columna Descripcion.</summary>
        public static bool TieneDescripcion(TipoCatalogo tipo)
        {
            return tipo == TipoCatalogo.TipoMision;
        }

        public List<Catalogo> Listar(TipoCatalogo tipo, string texto = null)
        {
            return _dal.Listar(tipo, Texto.Normalizar(texto));
        }

        public Catalogo Obtener(TipoCatalogo tipo, int id)
        {
            return _dal.Obtener(tipo, id);
        }

        public int Guardar(TipoCatalogo tipo, Catalogo item)
        {
            item.Nombre = Texto.Normalizar(item.Nombre);
            item.Descripcion = TieneDescripcion(tipo) ? Texto.Normalizar(item.Descripcion) : null;

            new Validador()
                .Requerido(item.Nombre, "Nombre")
                .LongitudMaxima(item.Nombre, 50, "Nombre")
                .LongitudMaxima(item.Descripcion, 250, "Descripción")
                .Lanzar();

            if (item.ID == 0)
                return _dal.Insertar(tipo, item);

            _dal.Actualizar(tipo, item);
            return item.ID;
        }

        public void Eliminar(TipoCatalogo tipo, int id)
        {
            _dal.Eliminar(tipo, id);
        }
    }
}
