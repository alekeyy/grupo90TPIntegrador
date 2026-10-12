<%@ Page Title="Misiones" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Misiones.aspx.cs" Inherits="Bomberos.Web.Operaciones.Misiones" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-broadcast text-danger"></i> Misiones</h1>
            <p class="subtitulo">Misiones generadas a partir de incidentes. Estados: En curso, Finalizada, Cancelada.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nueva misión
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-7">
                    <label class="form-label" for="<%= ddlIncidente.ClientID %>">Incidente<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlIncidente" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvIncidente" runat="server" ControlToValidate="ddlIncidente" ValidationGroup="Form"
                        ErrorMessage="Seleccione el incidente." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-5">
                    <label class="form-label" for="<%= ddlTipoMision.ClientID %>">Tipo de misión<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipoMision" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipoMision" runat="server" ControlToValidate="ddlTipoMision" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo de misión." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtNombre.ClientID %>">Nombre<span class="req">*</span></label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre" ValidationGroup="Form"
                        ErrorMessage="El nombre es obligatorio." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlEstado.ClientID %>">Estado<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtInicio.ClientID %>">Inicio<span class="req">*</span></label>
                    <asp:TextBox ID="txtInicio" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    <asp:RequiredFieldValidator ID="rfvInicio" runat="server" ControlToValidate="txtInicio" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha y hora de inicio." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtFin.ClientID %>">Fin</label>
                    <asp:TextBox ID="txtFin" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    <div class="form-text">Obligatorio si la misión está finalizada; vacío si está en curso.</div>
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
                <div class="col-12 col-sm-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroEstado.ClientID %>">Estado</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroTipo.ClientID %>">Tipo</label>
                    <asp:DropDownList ID="ddlFiltroTipo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroIncidente.ClientID %>">Incidente</label>
                    <asp:DropDownList ID="ddlFiltroIncidente" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtBuscar.ClientID %>">Texto</label>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" />
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
            <asp:GridView ID="gvMisiones" runat="server" AutoGenerateColumns="false" DataKeyNames="IDMision"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvMisiones_PageIndexChanging" OnRowCommand="gvMisiones_RowCommand">
                <Columns>
                    <asp:TemplateField HeaderText="Misión">
                        <ItemTemplate>
                            <div class="fw-semibold"><%# Html(Eval("Nombre")) %></div>
                            <div class="small text-muted"><%# Html(Eval("TipoMisionNombre")) %></div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Incidente">
                        <ItemTemplate>
                            <div><%# Html(Eval("IncidenteDireccion")) %></div>
                            <span class='<%# ClaseSeveridad(Eval("IncidenteSeveridad")) %>'><%# Html(Eval("IncidenteSeveridad")) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="FechaInicio" HeaderText="Inicio" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                    <asp:BoundField DataField="FechaFin" HeaderText="Fin" DataFormatString="{0:dd/MM/yyyy HH:mm}" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Estado">
                        <ItemTemplate><span class='<%# ClaseEstado(Eval("Estado")) %>'><%# Html(Eval("Estado")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Recursos">
                        <ItemTemplate>
                            <span class="text-nowrap small" title="Voluntarios / Vehículos / Equipos">
                                <i class="bi bi-people"></i> <%# Eval("CantidadVoluntarios") %>
                                <i class="bi bi-truck-front ms-2"></i> <%# Eval("CantidadVehiculos") %>
                                <i class="bi bi-tools ms-2"></i> <%# Eval("CantidadEquipamiento") %>
                            </span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkDetalle" runat="server" NavigateUrl='<%# "~/Operaciones/MisionDetalle.aspx?id=" + Eval("IDMision") %>'
                                CssClass="btn btn-sm btn-outline-success" ToolTip="Asignar recursos"><i class="bi bi-people-fill"></i></asp:HyperLink>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDMision") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDMision") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar la misión y todas sus asignaciones?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No se encontraron misiones.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
