<%@ Page Title="Voluntarios" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Voluntarios.aspx.cs" Inherits="Bomberos.Web.Personal.Voluntarios" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-people text-danger"></i> Voluntarios</h1>
            <p class="subtitulo">Alta, modificación, baja lógica y consulta del personal voluntario.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-person-plus"></i> Nuevo voluntario
        </asp:LinkButton>
    </div>

    <!-- ===================== Formulario ===================== -->
    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtApellido.ClientID %>">Apellido<span class="req">*</span></label>
                    <asp:TextBox ID="txtApellido" runat="server" CssClass="form-control" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvApellido" runat="server" ControlToValidate="txtApellido" ValidationGroup="Form"
                        ErrorMessage="El apellido es obligatorio." Display="Dynamic" CssClass="validador" SetFocusOnError="true" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtNombre.ClientID %>">Nombre<span class="req">*</span></label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="100" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre" ValidationGroup="Form"
                        ErrorMessage="El nombre es obligatorio." Display="Dynamic" CssClass="validador" SetFocusOnError="true" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtDNI.ClientID %>">DNI<span class="req">*</span></label>
                    <asp:TextBox ID="txtDNI" runat="server" CssClass="form-control" MaxLength="10" placeholder="Solo números" />
                    <asp:RequiredFieldValidator ID="rfvDNI" runat="server" ControlToValidate="txtDNI" ValidationGroup="Form"
                        ErrorMessage="El DNI es obligatorio." Display="Dynamic" CssClass="validador" SetFocusOnError="true" />
                    <asp:RegularExpressionValidator ID="revDNI" runat="server" ControlToValidate="txtDNI" ValidationGroup="Form"
                        ValidationExpression="^\d{7,8}$" ErrorMessage="El DNI debe tener 7 u 8 dígitos." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtFechaNacimiento.ClientID %>">Fecha de nacimiento<span class="req">*</span></label>
                    <asp:TextBox ID="txtFechaNacimiento" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFechaNacimiento" runat="server" ControlToValidate="txtFechaNacimiento" ValidationGroup="Form"
                        ErrorMessage="La fecha de nacimiento es obligatoria." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtFechaIngreso.ClientID %>">Fecha de ingreso<span class="req">*</span></label>
                    <asp:TextBox ID="txtFechaIngreso" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFechaIngreso" runat="server" ControlToValidate="txtFechaIngreso" ValidationGroup="Form"
                        ErrorMessage="La fecha de ingreso es obligatoria." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlEstado.ClientID %>">Estado<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtTelefono.ClientID %>">Teléfono</label>
                    <asp:TextBox ID="txtTelefono" runat="server" CssClass="form-control" MaxLength="30" TextMode="Phone" />
                    <asp:RegularExpressionValidator ID="revTelefono" runat="server" ControlToValidate="txtTelefono" ValidationGroup="Form"
                        ValidationExpression="^[0-9+()\-\s]{6,30}$" ErrorMessage="Teléfono inválido." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtEmail.ClientID %>">Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" MaxLength="100" TextMode="Email" />
                    <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="txtEmail" ValidationGroup="Form"
                        ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" ErrorMessage="El email no tiene un formato válido." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtDireccion.ClientID %>">Dirección</label>
                    <asp:TextBox ID="txtDireccion" runat="server" CssClass="form-control" MaxLength="200" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar" CssClass="btn btn-primary" ValidationGroup="Form" OnClick="btnGuardar_Click" />
        </div>
    </asp:Panel>

    <!-- ===================== Ficha (DetailsView) ===================== -->
    <asp:Panel ID="pnlFicha" runat="server" CssClass="card mb-4" Visible="false">
        <div class="card-header d-flex justify-content-between align-items-center">
            <span><i class="bi bi-person-vcard"></i> Ficha del voluntario</span>
            <asp:LinkButton ID="btnCerrarFicha" runat="server" CssClass="btn-close" CausesValidation="false" OnClick="btnCerrarFicha_Click" ToolTip="Cerrar" />
        </div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-lg-7">
                    <asp:DetailsView ID="dvFicha" runat="server" AutoGenerateRows="true" CssClass="table table-sm detalle mb-0" GridLines="None" />
                </div>
                <div class="col-12 col-lg-5">
                    <div class="d-grid gap-2">
                        <asp:HyperLink ID="lnkHistorialRangos" runat="server" CssClass="btn btn-outline-secondary"><i class="bi bi-award"></i> Historial de rangos</asp:HyperLink>
                        <asp:HyperLink ID="lnkHistorialRoles" runat="server" CssClass="btn btn-outline-secondary"><i class="bi bi-person-badge"></i> Historial de roles</asp:HyperLink>
                        <asp:HyperLink ID="lnkEntrenamientos" runat="server" CssClass="btn btn-outline-secondary"><i class="bi bi-mortarboard"></i> Entrenamientos</asp:HyperLink>
                        <asp:HyperLink ID="lnkGuardias" runat="server" CssClass="btn btn-outline-secondary"><i class="bi bi-calendar-week"></i> Guardias</asp:HyperLink>
                        <asp:HyperLink ID="lnkMisiones" runat="server" CssClass="btn btn-outline-secondary"><i class="bi bi-broadcast"></i> Misiones</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- ===================== Filtros ===================== -->
    <asp:Panel ID="pnlBusqueda" runat="server" CssClass="card mb-3" DefaultButton="btnBuscar">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-12 col-md-6">
                    <label class="form-label small mb-1" for="<%= txtBuscar.ClientID %>">Buscar</label>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" placeholder="Nombre, apellido, DNI o email" />
                </div>
                <div class="col-12 col-sm-6 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroEstado.ClientID %>">Estado</label>
                    <asp:DropDownList ID="ddlFiltroEstado" runat="server" CssClass="form-select" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-search"></i> Buscar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- ===================== Listado ===================== -->
    <div class="card">
        <div class="card-header d-flex justify-content-between">
            <span>Listado</span><span class="text-muted small"><asp:Literal ID="litCantidad" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvVoluntarios" runat="server" AutoGenerateColumns="false" DataKeyNames="IDVoluntario"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvVoluntarios_PageIndexChanging" OnRowCommand="gvVoluntarios_RowCommand">
                <Columns>
                    <asp:TemplateField HeaderText="Voluntario">
                        <ItemTemplate>
                            <div class="fw-semibold"><%# Html(Eval("NombreCompleto")) %></div>
                            <div class="small text-muted"><%# Html(Eval("Email")) %></div>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="DNI" HeaderText="DNI" />
                    <asp:BoundField DataField="Telefono" HeaderText="Teléfono" NullDisplayText="-" />
                    <asp:BoundField DataField="FechaIngreso" HeaderText="Ingreso" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="RangoActual" HeaderText="Rango actual" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Estado">
                        <ItemTemplate><span class='<%# ClaseEstado(Eval("Estado")) %>'><%# Html(Eval("Estado")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnVer" runat="server" CommandName="Ver" CommandArgument='<%# Eval("IDVoluntario") %>'
                                CssClass="btn btn-sm btn-outline-secondary" CausesValidation="false" ToolTip="Ver ficha"><i class="bi bi-eye"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDVoluntario") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnBaja" runat="server" CommandName="Baja" CommandArgument='<%# Eval("IDVoluntario") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Dar de baja"
                                Visible='<%# (string)Eval("Estado") != "Baja" %>'
                                OnClientClick="return confirm('¿Confirma la baja del voluntario? Se conservará su historial.');"><i class="bi bi-person-x"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No se encontraron voluntarios con los filtros indicados.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
