<%@ Page Title="Gastos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Gastos.aspx.cs" Inherits="Bomberos.Web.Finanzas.Gastos" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-arrow-down-circle text-danger"></i> Gastos</h1>
            <p class="subtitulo">Todo gasto debe tener un voluntario autorizador registrado.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo gasto
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlTipo.ClientID %>">Tipo de gasto<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipo" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipo" runat="server" ControlToValidate="ddlTipo" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-6 col-md-4">
                    <label class="form-label" for="<%= txtFecha.ClientID %>">Fecha<span class="req">*</span></label>
                    <asp:TextBox ID="txtFecha" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFecha" runat="server" ControlToValidate="txtFecha" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-6 col-md-4">
                    <label class="form-label" for="<%= txtMonto.ClientID %>">Monto ($)<span class="req">*</span></label>
                    <asp:TextBox ID="txtMonto" runat="server" CssClass="form-control text-end" placeholder="0,00" />
                    <asp:RequiredFieldValidator ID="rfvMonto" runat="server" ControlToValidate="txtMonto" ValidationGroup="Form"
                        ErrorMessage="Ingrese el monto." Display="Dynamic" CssClass="validador" />
                    <asp:RegularExpressionValidator ID="revMonto" runat="server" ControlToValidate="txtMonto" ValidationGroup="Form"
                        ValidationExpression="^\s*\d{1,3}(\.?\d{3})*([,\.]\d{1,2})?\s*$" ErrorMessage="Monto inválido (ej.: 15000,50)." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlAutorizador.ClientID %>">Voluntario autorizador<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAutorizador" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvAutorizador" runat="server" ControlToValidate="ddlAutorizador" ValidationGroup="Form"
                        ErrorMessage="Debe seleccionar el voluntario que autoriza el gasto." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtDescripcion.ClientID %>">Descripción</label>
                    <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" MaxLength="250" />
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
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtDesde.ClientID %>">Desde</label>
                    <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtHasta.ClientID %>">Hasta</label>
                    <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-12 col-sm-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroTipo.ClientID %>">Tipo</label>
                    <asp:DropDownList ID="ddlFiltroTipo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroAutorizador.ClientID %>">Autorizado por</label>
                    <asp:DropDownList ID="ddlFiltroAutorizador" runat="server" CssClass="form-select" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-funnel"></i> Filtrar</asp:LinkButton>
                    <asp:LinkButton ID="btnMes" runat="server" CssClass="btn btn-outline-dark" CausesValidation="false" OnClick="btnMes_Click">Mes actual</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-flex justify-content-between">
            <span>Listado</span><span class="resumen-total text-danger"><asp:Literal ID="litTotal" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvGastos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDGasto"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvGastos_PageIndexChanging" OnRowCommand="gvGastos_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="TipoNombre" HeaderText="Tipo" />
                    <asp:BoundField DataField="Descripcion" HeaderText="Descripción" NullDisplayText="-" />
                    <asp:BoundField DataField="AutorizadorNombre" HeaderText="Autorizado por" />
                    <asp:BoundField DataField="Monto" HeaderText="Monto" DataFormatString="{0:C2}" ItemStyle-CssClass="text-end fw-semibold" HeaderStyle-CssClass="text-end" />
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDGasto") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDGasto") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el gasto?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay gastos para los filtros indicados.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
