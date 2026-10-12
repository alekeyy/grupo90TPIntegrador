<%@ Page Title="Inicio" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Bomberos.Web._Default" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="h3 mb-4">Inicio</h1>
    <div class="row g-3">
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-people"></i> Personal</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Personal/Voluntarios.aspx">Voluntarios</a></li>
                        <li><a runat="server" href="~/Personal/Rangos.aspx">Rangos</a></li>
                        <li><a runat="server" href="~/Personal/HistorialRangos.aspx">Historial de rangos</a></li>
                        <li><a runat="server" href="~/Personal/Roles.aspx">Roles</a></li>
                        <li><a runat="server" href="~/Personal/HistorialRoles.aspx">Historial de roles</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-truck-front"></i> Vehículos</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Vehiculos/Vehiculos.aspx">Vehículos</a></li>
                        <li><a runat="server" href="~/Vehiculos/TipoVehiculo.aspx">Tipos de vehículo</a></li>
                        <li><a runat="server" href="~/Vehiculos/DocumentacionVehiculo.aspx">Documentación</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-tools"></i> Equipamiento</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Equipamiento/Equipamiento.aspx">Equipamiento</a></li>
                        <li><a runat="server" href="~/Equipamiento/TipoEquipamiento.aspx">Tipos de equipamiento</a></li>
                        <li><a runat="server" href="~/Equipamiento/CategoriaEquipamiento.aspx">Categorías de equipamiento</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-broadcast"></i> Operaciones</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Operaciones/Incidentes.aspx">Incidentes</a></li>
                        <li><a runat="server" href="~/Operaciones/Misiones.aspx">Misiones</a></li>
                        <li><a runat="server" href="~/Operaciones/TipoMision.aspx">Tipos de misión</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-mortarboard"></i> Capacitación</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Capacitacion/Entrenamientos.aspx">Entrenamientos</a></li>
                        <li><a runat="server" href="~/Capacitacion/TipoEntrenamiento.aspx">Tipos de entrenamiento</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-calendar-week"></i> Guardias</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Guardias/Guardias.aspx">Guardias</a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div class="col-12 col-md-6 col-xl-4">
            <div class="card h-100">
                <div class="card-body">
                    <h2 class="h6"><i class="bi bi-cash-coin"></i> Finanzas</h2>
                    <ul class="mb-0">
                        <li><a runat="server" href="~/Finanzas/Aportes.aspx">Aportes</a></li>
                        <li><a runat="server" href="~/Finanzas/TipoAporte.aspx">Tipos de aporte</a></li>
                        <li><a runat="server" href="~/Finanzas/Gastos.aspx">Gastos</a></li>
                        <li><a runat="server" href="~/Finanzas/TipoGasto.aspx">Tipos de gasto</a></li>
                        <li><a runat="server" href="~/Finanzas/Caja.aspx">Cajas</a></li>
                        <li><a runat="server" href="~/Finanzas/MovimientoCaja.aspx">Movimientos de caja</a></li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
