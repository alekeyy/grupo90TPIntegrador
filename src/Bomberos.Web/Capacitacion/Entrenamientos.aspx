<%@ Page Title="Entrenamientos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Entrenamientos.aspx.cs" Inherits="Bomberos.Web.Capacitacion.Entrenamientos" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-mortarboard text-danger"></i> Entrenamientos</h1>
            <p class="subtitulo">Capacitaciones realizadas por los voluntarios. Filtre por voluntario para ver su historial.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Registrar entrenamiento
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-5">
                    <label class="form-label" for="<%= ddlVoluntario.ClientID %>">Voluntario<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlVoluntario" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvVoluntario" runat="server" ControlToValidate="ddlVoluntario" ValidationGroup="Form"
                        ErrorMessage="Seleccione un voluntario." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlTipo.ClientID %>">Tipo de entrenamiento<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipo" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipo" runat="server" ControlToValidate="ddlTipo" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtFecha.ClientID %>">Fecha<span class="req">*</span></label>
                    <asp:TextBox ID="txtFecha" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFecha" runat="server" ControlToValidate="txtFecha" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12">
                    <label class="form-label" for="<%= txtObservaciones.ClientID %>">Observaciones</label>
                    <asp:TextBox ID="txtObservaciones" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="500" />
                    <asp:RegularExpressionValidator ID="revObservaciones" runat="server" ControlToValidate="txtObservaciones" ValidationGroup="Form"
                        ValidationExpression="^[\s\S]{0,500}$" ErrorMessage="Máximo 500 caracteres." Display="Dynamic" CssClass="validador" />
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
                <div class="col-12 col-md-4">
                    <label class="form-label small mb-1" for="<%= ddlFiltroVoluntario.ClientID %>">Voluntario</label>
                    <asp:DropDownList ID="ddlFiltroVoluntario" runat="server" CssClass="form-select" />
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

    <!-- Resumen del historial cuando se filtra por voluntario -->
    <asp:Panel ID="pnlResumen" runat="server" CssClass="alert alert-info d-flex flex-wrap gap-3" Visible="false">
        <i class="bi bi-person-lines-fill"></i>
        <asp:Literal ID="litResumen" runat="server" />
    </asp:Panel>

    <div class="card">
        <div class="table-responsive">
            <asp:GridView ID="gvEntrenamientos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDEntrenamiento"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvEntrenamientos_PageIndexChanging" OnRowCommand="gvEntrenamientos_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="VoluntarioNombre" HeaderText="Voluntario" />
                    <asp:BoundField DataField="TipoNombre" HeaderText="Tipo" />
                    <asp:BoundField DataField="Observaciones" HeaderText="Observaciones" NullDisplayText="-" />
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDEntrenamiento") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDEntrenamiento") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el entrenamiento?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay entrenamientos registrados con esos filtros.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
