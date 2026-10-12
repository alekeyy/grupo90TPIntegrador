<%@ Page Title="Incidentes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Incidentes.aspx.cs" Inherits="Bomberos.Web.Operaciones.Incidentes" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-exclamation-diamond text-danger"></i> Incidentes</h1>
            <p class="subtitulo">Registro de emergencias. Cada incidente puede generar una o más misiones.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo incidente
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtFechaHora.ClientID %>">Fecha y hora<span class="req">*</span></label>
                    <asp:TextBox ID="txtFechaHora" runat="server" CssClass="form-control" TextMode="DateTimeLocal" />
                    <asp:RequiredFieldValidator ID="rfvFechaHora" runat="server" ControlToValidate="txtFechaHora" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha y hora." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-5">
                    <label class="form-label" for="<%= txtDireccion.ClientID %>">Dirección<span class="req">*</span></label>
                    <asp:TextBox ID="txtDireccion" runat="server" CssClass="form-control" MaxLength="200" />
                    <asp:RequiredFieldValidator ID="rfvDireccion" runat="server" ControlToValidate="txtDireccion" ValidationGroup="Form"
                        ErrorMessage="La dirección es obligatoria." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= ddlSeveridad.ClientID %>">Severidad<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlSeveridad" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvSeveridad" runat="server" ControlToValidate="ddlSeveridad" ValidationGroup="Form"
                        ErrorMessage="Seleccione la severidad." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12">
                    <label class="form-label" for="<%= txtDescripcion.ClientID %>">Descripción</label>
                    <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" MaxLength="500" />
                    <asp:RegularExpressionValidator ID="revDescripcion" runat="server" ControlToValidate="txtDescripcion" ValidationGroup="Form"
                        ValidationExpression="^[\s\S]{0,500}$" ErrorMessage="Máximo 500 caracteres." Display="Dynamic" CssClass="validador" />
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
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtDesde.ClientID %>">Desde</label>
                    <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label small mb-1" for="<%= txtHasta.ClientID %>">Hasta</label>
                    <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date" />
                </div>
                <div class="col-12 col-sm-4 col-md-2">
                    <label class="form-label small mb-1" for="<%= ddlFiltroSeveridad.ClientID %>">Severidad</label>
                    <asp:DropDownList ID="ddlFiltroSeveridad" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-sm-8 col-md-3">
                    <label class="form-label small mb-1" for="<%= txtBuscar.ClientID %>">Dirección o descripción</label>
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
            <asp:GridView ID="gvIncidentes" runat="server" AutoGenerateColumns="false" DataKeyNames="IDIncidente"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvIncidentes_PageIndexChanging" OnRowCommand="gvIncidentes_RowCommand">
                <Columns>
                    <asp:BoundField DataField="IDIncidente" HeaderText="N°" ItemStyle-CssClass="text-muted" />
                    <asp:BoundField DataField="FechaHora" HeaderText="Fecha y hora" DataFormatString="{0:dd/MM/yyyy HH:mm}" />
                    <asp:BoundField DataField="Direccion" HeaderText="Dirección" />
                    <asp:BoundField DataField="Descripcion" HeaderText="Descripción" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Severidad">
                        <ItemTemplate><span class='<%# ClaseSeveridad(Eval("Severidad")) %>'><%# Html(Eval("Severidad")) %></span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Misiones">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkMisiones" runat="server" NavigateUrl='<%# "~/Operaciones/Misiones.aspx?incidente=" + Eval("IDIncidente") %>'
                                Text='<%# Eval("CantidadMisiones") + " misión(es)" %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:HyperLink ID="lnkNuevaMision" runat="server" NavigateUrl='<%# "~/Operaciones/Misiones.aspx?nuevo=1&incidente=" + Eval("IDIncidente") %>'
                                CssClass="btn btn-sm btn-outline-success" ToolTip="Generar misión"><i class="bi bi-plus-circle"></i></asp:HyperLink>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDIncidente") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDIncidente") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el incidente?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No se encontraron incidentes.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
