<%@ Page Title="Reportes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Reportes.aspx.cs" Inherits="Bomberos.Web.Reportes.ReportesPage" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-file-earmark-bar-graph text-danger"></i> Reportes &middot; <asp:Literal ID="litCategoria" runat="server" /></h1>
            <p class="subtitulo">Seleccione el reporte, complete los filtros y presione "Generar".</p>
        </div>
    </div>

    <!-- Reportes de la categoría (pestañas) -->
    <ul class="nav nav-pills flex-wrap gap-1 mb-3 no-print">
        <asp:Repeater ID="rptReportes" runat="server">
            <ItemTemplate>
                <li class="nav-item">
                    <asp:LinkButton ID="btnReporte" runat="server" CausesValidation="false" CommandArgument='<%# Eval("Clave") %>' OnCommand="SeleccionarReporte_Command"
                        CssClass='<%# "nav-link" + ((string)Eval("Clave") == ClaveActual ? " active bg-danger" : " text-dark bg-white border") %>'
                        Text='<%# Html(Eval("Titulo")) %>' />
                </li>
            </ItemTemplate>
        </asp:Repeater>
    </ul>

    <asp:Panel ID="pnlFiltros" runat="server" CssClass="card mb-3 no-print" DefaultButton="btnGenerar">
        <div class="card-header"><asp:Literal ID="litTitulo" runat="server" /></div>
        <div class="card-body">
            <p class="text-muted small"><asp:Literal ID="litDescripcion" runat="server" /></p>
            <div class="row g-2 align-items-end">
                <asp:PlaceHolder ID="phPeriodo" runat="server">
                    <div class="col-6 col-md-2">
                        <label class="form-label small mb-1" for="<%= txtDesde.ClientID %>">Desde</label>
                        <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date" />
                    </div>
                    <div class="col-6 col-md-2">
                        <label class="form-label small mb-1" for="<%= txtHasta.ClientID %>">Hasta</label>
                        <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phVoluntario" runat="server">
                    <div class="col-12 col-md-4">
                        <label class="form-label small mb-1" for="<%= ddlVoluntario.ClientID %>">Voluntario</label>
                        <asp:DropDownList ID="ddlVoluntario" runat="server" CssClass="form-select" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phEstado" runat="server">
                    <div class="col-12 col-md-3">
                        <label class="form-label small mb-1" for="<%= ddlEstado.ClientID %>">Estado</label>
                        <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phCaja" runat="server">
                    <div class="col-12 col-md-3">
                        <label class="form-label small mb-1" for="<%= ddlCaja.ClientID %>">Caja</label>
                        <asp:DropDownList ID="ddlCaja" runat="server" CssClass="form-select" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phAnio" runat="server">
                    <div class="col-6 col-md-2">
                        <label class="form-label small mb-1" for="<%= txtAnio.ClientID %>">Año</label>
                        <asp:TextBox ID="txtAnio" runat="server" CssClass="form-control" TextMode="Number" />
                        <asp:RangeValidator ID="rvAnio" runat="server" ControlToValidate="txtAnio" Type="Integer" MinimumValue="2000" MaximumValue="2100"
                            ErrorMessage="Año inválido." Display="Dynamic" CssClass="validador" ValidationGroup="Rpt" />
                    </div>
                </asp:PlaceHolder>
                <asp:PlaceHolder ID="phDias" runat="server">
                    <div class="col-6 col-md-2">
                        <label class="form-label small mb-1" for="<%= txtDias.ClientID %>">Próximos días</label>
                        <asp:TextBox ID="txtDias" runat="server" CssClass="form-control" TextMode="Number" />
                        <asp:RangeValidator ID="rvDias" runat="server" ControlToValidate="txtDias" Type="Integer" MinimumValue="0" MaximumValue="3650"
                            ErrorMessage="Entre 0 y 3650." Display="Dynamic" CssClass="validador" ValidationGroup="Rpt" />
                    </div>
                </asp:PlaceHolder>
                <div class="col-auto">
                    <asp:LinkButton ID="btnGenerar" runat="server" CssClass="btn btn-primary" ValidationGroup="Rpt" OnClick="btnGenerar_Click"><i class="bi bi-play-fill"></i> Generar</asp:LinkButton>
                    <asp:LinkButton ID="btnExportar" runat="server" CssClass="btn btn-outline-success" ValidationGroup="Rpt" OnClick="btnExportar_Click"><i class="bi bi-filetype-csv"></i> Exportar CSV</asp:LinkButton>
                    <button type="button" class="btn btn-outline-secondary" onclick="window.print();"><i class="bi bi-printer"></i> Imprimir</button>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="card">
        <div class="card-header d-flex flex-wrap justify-content-between gap-2">
            <span><asp:Literal ID="litTituloResultado" runat="server" /></span>
            <span class="text-muted small"><asp:Literal ID="litResumen" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvReporte" runat="server" AutoGenerateColumns="true" CssClass="table table-hover table-sm grid" GridLines="None"
                AllowPaging="true" PageSize="20" OnPageIndexChanging="gvReporte_PageIndexChanging" OnRowDataBound="gvReporte_RowDataBound">
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">El reporte no devolvió resultados.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
