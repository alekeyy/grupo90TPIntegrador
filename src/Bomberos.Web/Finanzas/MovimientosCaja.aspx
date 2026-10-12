<%@ Page Title="Movimientos de caja" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MovimientosCaja.aspx.cs" Inherits="Bomberos.Web.Finanzas.MovimientosCaja" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-safe2 text-danger"></i> Movimientos de caja</h1>
            <p class="subtitulo">Ingresos y egresos de cada caja. Un egreso no puede dejar la caja con saldo negativo.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo movimiento
        </asp:LinkButton>
    </div>

    <!-- Saldos por caja -->
    <div class="row g-3 mb-3">
        <asp:Repeater ID="rptSaldos" runat="server">
            <ItemTemplate>
                <div class="col-12 col-md-6 col-xl-4">
                    <div class="card kpi">
                        <div class='kpi-icono <%# (decimal)Eval("Saldo") >= 0 ? "kpi-verde" : "kpi-rojo" %>'><i class="bi bi-wallet2"></i></div>
                        <div class="flex-grow-1">
                            <div class="kpi-etiqueta"><%# Html(Eval("Nombre")) %></div>
                            <div class="kpi-valor"><%# FormatearMoneda(Eval("Saldo")) %></div>
                            <div class="kpi-detalle">
                                <span class="text-success">+<%# FormatearMoneda(Eval("TotalIngresos")) %></span> &middot;
                                <span class="text-danger">-<%# FormatearMoneda(Eval("TotalEgresos")) %></span> &middot;
                                <%# Eval("CantidadMovimientos") %> mov.
                            </div>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlCaja.ClientID %>">Caja<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlCaja" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvCaja" runat="server" ControlToValidate="ddlCaja" ValidationGroup="Form"
                        ErrorMessage="Seleccione la caja." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtFecha.ClientID %>">Fecha y hora<span class="req">*</span></label>
                    <asp:TextBox ID="txtFecha" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    <asp:RequiredFieldValidator ID="rfvFecha" runat="server" ControlToValidate="txtFecha" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label d-block">Tipo de movimiento<span class="req">*</span></label>
                    <asp:RadioButtonList ID="rblTipo" runat="server" RepeatDirection="Horizontal" RepeatLayout="Flow" CssClass="chk-bs gap-3" />
                    <asp:RequiredFieldValidator ID="rfvTipo" runat="server" ControlToValidate="rblTipo" ValidationGroup="Form"
                        ErrorMessage="Seleccione Ingreso o Egreso." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtMonto.ClientID %>">Monto ($)<span class="req">*</span></label>
                    <asp:TextBox ID="txtMonto" runat="server" CssClass="form-control text-end" placeholder="0,00" />
                    <asp:RequiredFieldValidator ID="rfvMonto" runat="server" ControlToValidate="txtMonto" ValidationGroup="Form"
                        ErrorMessage="Ingrese el monto." Display="Dynamic" CssClass="validador" />
                    <asp:RegularExpressionValidator ID="revMonto" runat="server" ControlToValidate="txtMonto" ValidationGroup="Form"
                        ValidationExpression="^\s*\d{1,3}(\.?\d{3})*([,\.]\d{1,2})?\s*$" ErrorMessage="Monto inválido (ej.: 15000,50)." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-8">
                    <label class="form-label" for="<%= txtConcepto.ClientID %>">Concepto</label>
                    <asp:TextBox ID="txtConcepto" runat="server" CssClass="form-control" MaxLength="250" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar" CssClass="btn btn-primary" ValidationGroup="Form" OnClick="btnGuardar_Click" />
        </div>
    </asp:Panel>

    <div class="card mb-3">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-12 col-sm-6 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroCaja.ClientID %>">Caja</label>
                    <asp:DropDownList ID="ddlFiltroCaja" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroTipo.ClientID %>">Tipo</label>
                    <asp:DropDownList ID="ddlFiltroTipo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtDesde.ClientID %>">Desde</label>
                    <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtHasta.ClientID %>">Hasta</label>
                    <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-funnel"></i> Filtrar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-flex flex-wrap justify-content-between gap-2">
            <span>Movimientos</span>
            <span class="small"><asp:Literal ID="litTotales" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvMovimientos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDMovimiento"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvMovimientos_PageIndexChanging" OnRowCommand="gvMovimientos_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                    <asp:BoundField DataField="CajaNombre" HeaderText="Caja" />
                    <asp:TemplateField HeaderText="Tipo">
                        <ItemTemplate><span class='<%# ClaseEstado(Eval("TipoMovimiento")) %>'><%# Html(Eval("TipoMovimiento")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Concepto" HeaderText="Concepto" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Monto" ItemStyle-CssClass="text-end fw-semibold" HeaderStyle-CssClass="text-end">
                        <ItemTemplate>
                            <span class='<%# (decimal)Eval("MontoConSigno") < 0 ? "text-danger" : "text-success" %>'><%# FormatearMoneda(Eval("MontoConSigno")) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDMovimiento") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDMovimiento") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el movimiento?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay movimientos para los filtros indicados.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
