<%@ Page Title="Equipamiento" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Equipamiento.aspx.cs" Inherits="Bomberos.Web.Equipamiento.EquipamientoPage" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-tools text-danger"></i> Equipamiento</h1>
            <p class="subtitulo">Inventario de equipos, estado y control de mantenimientos.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo equipo
        </asp:LinkButton>
    </div>

    <!-- Accesos rápidos (reportes por estado) -->
    <div class="d-flex flex-wrap gap-2 mb-3">
        <asp:LinkButton ID="btnRptDisponible" runat="server" CssClass="btn btn-sm btn-outline-success" CausesValidation="false" CommandArgument="Disponible" OnCommand="FiltroRapido_Command"><i class="bi bi-check2-circle"></i> Disponible</asp:LinkButton>
        <asp:LinkButton ID="btnRptMantenimiento" runat="server" CssClass="btn btn-sm btn-outline-warning" CausesValidation="false" CommandArgument="En mantenimiento" OnCommand="FiltroRapido_Command"><i class="bi bi-wrench"></i> En mantenimiento</asp:LinkButton>
        <asp:LinkButton ID="btnRptFuera" runat="server" CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" CommandArgument="Fuera de servicio" OnCommand="FiltroRapido_Command"><i class="bi bi-slash-circle"></i> Fuera de servicio</asp:LinkButton>
        <asp:LinkButton ID="btnRptTodos" runat="server" CssClass="btn btn-sm btn-outline-secondary" CausesValidation="false" CommandArgument="" OnCommand="FiltroRapido_Command">Todos</asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtCodigo.ClientID %>">Código interno<span class="req">*</span></label>
                    <asp:TextBox ID="txtCodigo" runat="server" CssClass="form-control text-uppercase" MaxLength="20" placeholder="EQ-011" />
                    <asp:RequiredFieldValidator ID="rfvCodigo" runat="server" ControlToValidate="txtCodigo" ValidationGroup="Form"
                        ErrorMessage="El código es obligatorio." Display="Dynamic" CssClass="validador" />
                    <asp:RegularExpressionValidator ID="revCodigo" runat="server" ControlToValidate="txtCodigo" ValidationGroup="Form"
                        ValidationExpression="^[A-Za-z0-9\-]{1,20}$" ErrorMessage="Solo letras, números y guiones." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-5">
                    <label class="form-label" for="<%= txtNombre.ClientID %>">Nombre<span class="req">*</span></label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre" ValidationGroup="Form"
                        ErrorMessage="El nombre es obligatorio." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlEstado.ClientID %>">Estado<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlTipo.ClientID %>">Tipo<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipo" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipo" runat="server" ControlToValidate="ddlTipo" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlCategoria.ClientID %>">Categoría<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlCategoria" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvCategoria" runat="server" ControlToValidate="ddlCategoria" ValidationGroup="Form"
                        ErrorMessage="Seleccione la categoría." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtCompra.ClientID %>">Fecha de compra</label>
                    <asp:TextBox ID="txtCompra" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtUltimoMant.ClientID %>">Último mantenimiento</label>
                    <asp:TextBox ID="txtUltimoMant" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtProximoMant.ClientID %>">Próximo mantenimiento</label>
                    <asp:TextBox ID="txtProximoMant" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar" CssClass="btn btn-primary" ValidationGroup="Form" OnClick="btnGuardar_Click" />
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlBusqueda" runat="server" CssClass="card mb-3" DefaultButton="btnBuscar">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-12 col-md-3">
                    <label class="form-label small mb-1" for="<%= txtBuscar.ClientID %>">Código o nombre</label>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" />
                </div>
                <div class="col-12 col-sm-4 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroEstado.ClientID %>">Estado</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-4 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroTipo.ClientID %>">Tipo</label>
                    <asp:DropDownList ID="ddlFiltroTipo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-4 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroCategoria.ClientID %>">Categoría</label>
                    <asp:DropDownList ID="ddlFiltroCategoria" runat="server" CssClass="form-select" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-search"></i> Buscar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="card">
        <div class="card-header d-flex justify-content-between">
            <span>Listado</span><span class="text-muted small"><asp:Literal ID="litCantidad" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvEquipos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDEquipamiento"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvEquipos_PageIndexChanging" OnRowCommand="gvEquipos_RowCommand">
                <Columns>
                    <asp:BoundField DataField="CodigoInterno" HeaderText="Código" ItemStyle-CssClass="fw-semibold" />
                    <asp:BoundField DataField="Nombre" HeaderText="Equipo" />
                    <asp:BoundField DataField="TipoNombre" HeaderText="Tipo" />
                    <asp:BoundField DataField="CategoriaNombre" HeaderText="Categoría" />
                    <asp:TemplateField HeaderText="Estado">
                        <ItemTemplate><span class='<%# ClaseEstado(Eval("Estado")) %>'><%# Html(Eval("Estado")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="FechaUltimoMantenimiento" HeaderText="Últ. mant." DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Próx. mant.">
                        <ItemTemplate>
                            <span class='<%# (bool)Eval("MantenimientoVencido") ? "text-danger fw-semibold" : "" %>'>
                                <%# FormatearFecha(Eval("FechaProximoMantenimiento")) %>
                                <%# (bool)Eval("MantenimientoVencido") ? "<i class=\"bi bi-exclamation-circle\" title=\"Mantenimiento atrasado\"></i>" : "" %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDEquipamiento") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDEquipamiento") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el equipo?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No se encontró equipamiento.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
