<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Bomberos.Web._Default" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-speedometer2 text-danger"></i> Dashboard</h1>
            <p class="subtitulo">Resumen operativo, administrativo y financiero del cuartel.</p>
        </div>
        <a runat="server" href="~/Operaciones/Incidentes.aspx?nuevo=1" class="btn btn-primary"><i class="bi bi-plus-lg"></i> Registrar incidente</a>
    </div>

    <asp:Panel ID="pnlIndicadores" runat="server">
        <!-- Alertas operativas -->
        <asp:Panel ID="pnlAlertas" runat="server" CssClass="row g-3 mb-1" Visible="false">
            <div class="col-12">
                <div class="alert alert-warning d-flex flex-wrap gap-3 align-items-center mb-0">
                    <i class="bi bi-bell-fill"></i>
                    <asp:HyperLink ID="lnkDocVencidos" runat="server" NavigateUrl="~/Vehiculos/Documentacion.aspx?situacion=Vencido" CssClass="alert-link" />
                    <asp:HyperLink ID="lnkDocPorVencer" runat="server" NavigateUrl="~/Vehiculos/Documentacion.aspx?situacion=Proximo" CssClass="alert-link" />
                    <asp:HyperLink ID="lnkMantenimientos" runat="server" NavigateUrl="~/Reportes/Reportes.aspx?cat=equipamiento&rep=proximos-mantenimientos" CssClass="alert-link" />
                </div>
            </div>
        </asp:Panel>

        <!-- Indicadores principales -->
        <div class="row g-3 mt-0">
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-rojo"><i class="bi bi-people-fill"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litVoluntarios" runat="server" Text="0" /></div>
                        <div class="kpi-etiqueta">Voluntarios activos</div>
                        <div class="kpi-detalle"><asp:Literal ID="litVoluntariosTotal" runat="server" /></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-verde"><i class="bi bi-truck-front-fill"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litVehiculos" runat="server" Text="0" /></div>
                        <div class="kpi-etiqueta">Vehículos operativos</div>
                        <div class="kpi-detalle"><asp:Literal ID="litVehiculosTotal" runat="server" /></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-azul"><i class="bi bi-tools"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litEquipamiento" runat="server" Text="0" /></div>
                        <div class="kpi-etiqueta">Equipamiento disponible</div>
                        <div class="kpi-detalle"><asp:Literal ID="litEquipamientoTotal" runat="server" /></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-naranja"><i class="bi bi-broadcast"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litMisiones" runat="server" Text="0" /></div>
                        <div class="kpi-etiqueta">Misiones en curso</div>
                        <div class="kpi-detalle"><a runat="server" href="~/Operaciones/Misiones.aspx?estado=En%20curso">Ver misiones</a></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-violeta"><i class="bi bi-shield-check"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litGuardias" runat="server" Text="0" /></div>
                        <div class="kpi-etiqueta">Guardias activas ahora</div>
                        <div class="kpi-detalle"><asp:Literal ID="litGuardiasHoy" runat="server" /></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-verde"><i class="bi bi-safe2"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litSaldo" runat="server" Text="$ 0" /></div>
                        <div class="kpi-etiqueta">Saldo total de cajas</div>
                        <div class="kpi-detalle"><a runat="server" href="~/Finanzas/MovimientosCaja.aspx">Ver movimientos</a></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-rojo"><i class="bi bi-arrow-down-circle"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litGastos" runat="server" Text="$ 0" /></div>
                        <div class="kpi-etiqueta">Gastos del mes</div>
                        <div class="kpi-detalle"><asp:Literal ID="litMes1" runat="server" /></div>
                    </div>
                </div>
            </div>
            <div class="col-12 col-sm-6 col-xl-3">
                <div class="card kpi">
                    <div class="kpi-icono kpi-azul"><i class="bi bi-arrow-up-circle"></i></div>
                    <div>
                        <div class="kpi-valor"><asp:Literal ID="litAportes" runat="server" Text="$ 0" /></div>
                        <div class="kpi-etiqueta">Aportes del mes</div>
                        <div class="kpi-detalle"><asp:Literal ID="litMes2" runat="server" /></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Gráficos -->
        <div class="row g-3 mt-1">
            <div class="col-12 col-xl-8">
                <div class="card h-100">
                    <div class="card-header">Aportes vs. gastos (últimos 12 meses)</div>
                    <div class="card-body"><div class="chart-box"><canvas id="chartFinanzas" aria-label="Gráfico de aportes y gastos mensuales" role="img"></canvas></div></div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-xl-4">
                <div class="card h-100">
                    <div class="card-header">Misiones por tipo</div>
                    <div class="card-body"><div class="chart-box"><canvas id="chartMisiones" aria-label="Gráfico de misiones por tipo" role="img"></canvas></div></div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-xl-4">
                <div class="card h-100">
                    <div class="card-header">Equipamiento por estado</div>
                    <div class="card-body"><div class="chart-box"><canvas id="chartEquipamiento" aria-label="Gráfico de equipamiento por estado" role="img"></canvas></div></div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-xl-4">
                <div class="card h-100">
                    <div class="card-header">Vehículos por estado</div>
                    <div class="card-body"><div class="chart-box"><canvas id="chartVehiculos" aria-label="Gráfico de vehículos por estado" role="img"></canvas></div></div>
                </div>
            </div>
            <div class="col-12 col-md-6 col-xl-4">
                <div class="card h-100">
                    <div class="card-header">Incidentes por severidad</div>
                    <div class="card-body"><div class="chart-box"><canvas id="chartIncidentes" aria-label="Gráfico de incidentes por severidad" role="img"></canvas></div></div>
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="cScripts" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.js"></script>
    <script>
        // Datos generados en el servidor (Default.aspx.cs)
        var datosDashboard = <asp:Literal ID="litDatosJson" runat="server" Mode="PassThrough" Text="null" />;
    </script>
    <script>
        (function () {
            if (!datosDashboard || typeof Chart === 'undefined') return;
            var paleta = ['#c62828', '#1565c0', '#2e7d32', '#ef6c00', '#6a1b9a', '#00838f', '#5d4037', '#455a64'];
            var moneda = new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS', maximumFractionDigits: 0 });
            Chart.defaults.font.family = getComputedStyle(document.body).fontFamily;

            new Chart(document.getElementById('chartFinanzas'), {
                type: 'bar',
                data: {
                    labels: datosDashboard.finanzas.periodos,
                    datasets: [
                        { label: 'Aportes', data: datosDashboard.finanzas.aportes, backgroundColor: '#2e7d32' },
                        { label: 'Gastos', data: datosDashboard.finanzas.gastos, backgroundColor: '#c62828' }
                    ]
                },
                options: {
                    maintainAspectRatio: false,
                    scales: { y: { beginAtZero: true, ticks: { callback: function (v) { return moneda.format(v); } } } },
                    plugins: { tooltip: { callbacks: { label: function (c) { return c.dataset.label + ': ' + moneda.format(c.parsed.y); } } } }
                }
            });

            function torta(id, serie, tipo) {
                new Chart(document.getElementById(id), {
                    type: tipo,
                    data: { labels: serie.etiquetas, datasets: [{ data: serie.valores, backgroundColor: paleta, borderWidth: 1 }] },
                    options: {
                        maintainAspectRatio: false,
                        plugins: { legend: { position: tipo === 'bar' ? 'none' : 'bottom', display: tipo !== 'bar' } },
                        scales: tipo === 'bar' ? { y: { beginAtZero: true, ticks: { precision: 0 } } } : {}
                    }
                });
            }
            torta('chartMisiones', datosDashboard.misiones, 'doughnut');
            torta('chartEquipamiento', datosDashboard.equipamiento, 'pie');
            torta('chartVehiculos', datosDashboard.vehiculos, 'doughnut');
            torta('chartIncidentes', datosDashboard.incidentes, 'bar');
        })();
    </script>
</asp:Content>
