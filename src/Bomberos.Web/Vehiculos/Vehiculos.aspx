<%@ Page Title="Vehículos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Vehiculos.aspx.cs" Inherits="Bomberos.Web.Vehiculos.Vehiculos" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-truck-front text-danger"></i> Vehículos</h1>
            <p class="subtitulo">Flota del cuartel. Búsqueda por patente, estado y tipo.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo vehículo
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtNombre.ClientID %>">Nombre / identificación<span class="req">*</span></label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" placeholder="Ej.: Autobomba 03" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre" ValidationGroup="Form"
                        ErrorMessage="El nombre es obligatorio." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtPatente.ClientID %>">Patente<span class="req">*</span></label>
                    <asp:TextBox ID="txtPatente" runat="server" CssClass="form-control text-uppercase" MaxLength="10" placeholder="AB123CD" />
                    <asp:RequiredFieldValidator ID="rfvPatente" runat="server" ControlToValidate="txtPatente" ValidationGroup="Form"
                        ErrorMessage="La patente es obligatoria." Display="Dynamic" CssClass="validador" />
                    <asp:RegularExpressionValidator ID="revPatente" runat="server" ControlToValidate="txtPatente" ValidationGroup="Form"
                        ValidationExpression="^\s*([A-Za-z]{3}\s?-?\d{3}|[A-Za-z]{2}\s?-?\d{3}\s?-?[A-Za-z]{2}|[A-Za-z]\d{3}[A-Za-z]{3}|\d{3}[A-Za-z]{3})\s*$"
                        ErrorMessage="Formato de patente inválido (ABC123, AB123CD, A123BCD)." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtAnio.ClientID %>">Año<span class="req">*</span></label>
                    <asp:TextBox ID="txtAnio" runat="server" CssClass="form-control" TextMode="Number" />
                    <asp:RequiredFieldValidator ID="rfvAnio" runat="server" ControlToValidate="txtAnio" ValidationGroup="Form"
                        ErrorMessage="El año es obligatorio." Display="Dynamic" CssClass="validador" />
                    <asp:RangeValidator ID="rvAnio" runat="server" ControlToValidate="txtAnio" ValidationGroup="Form" Type="Integer"
                        MinimumValue="1950" MaximumValue="2100" ErrorMessage="Año inválido." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlTipo.ClientID %>">Tipo<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipo" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipo" runat="server" ControlToValidate="ddlTipo" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo de vehículo." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlEstado.ClientID %>">Estado<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" />
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
                    <label class="form-label small mb-1" for="<%= txtFiltroPatente.ClientID %>">Patente</label>
                    <asp:TextBox ID="txtFiltroPatente" runat="server" CssClass="form-control text-uppercase" placeholder="Patente o parte" />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroEstado.ClientID %>">Estado</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroTipo.ClientID %>">Tipo</label>
                    <asp:DropDownList ID="ddlFiltroTipo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-search"></i> Buscar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </asp:Panel>

    <div class="card">
        <div class="table-responsive">
            <asp:GridView ID="gvVehiculos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDVehiculo"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvVehiculos_PageIndexChanging" OnRowCommand="gvVehiculos_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Nombre" HeaderText="Vehículo" ItemStyle-CssClass="fw-semibold" />
                    <asp:BoundField DataField="TipoNombre" HeaderText="Tipo" />
                    <asp:BoundField DataField="Patente" HeaderText="Patente" />
                    <asp:BoundField DataField="Anio" HeaderText="Año" />
                    <asp:TemplateField HeaderText="Estado">
                        <ItemTemplate><span class='<%# ClaseEstado(Eval("Estado")) %>'><%# Html(Eval("Estado")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Documentación">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkDocs" runat="server" NavigateUrl='<%# "~/Vehiculos/Documentacion.aspx?vehiculo=" + Eval("IDVehiculo") %>'
                                CssClass='<%# (int)Eval("DocumentosVencidos") > 0 ? "text-danger fw-semibold" : "" %>'>
                                <%# (int)Eval("DocumentosVencidos") > 0 ? "<i class=\"bi bi-exclamation-triangle-fill\"></i> " + Eval("DocumentosVencidos") + " vencido(s)" : "<i class=\"bi bi-folder2-open\"></i> Ver" %>
                            </asp:HyperLink>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDVehiculo") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDVehiculo") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el vehículo y su documentación?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No se encontraron vehículos.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
