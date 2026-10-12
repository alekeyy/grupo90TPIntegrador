<%@ Page Title="Catálogo" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Catalogo.aspx.cs" Inherits="Bomberos.Web.Catalogos.Catalogo" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-list-ul text-danger"></i> <asp:Literal ID="litTitulo" runat="server" /></h1>
            <p class="subtitulo">Módulo <asp:Literal ID="litModulo" runat="server" /> &middot; catálogo de valores utilizados en el sistema.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo
        </asp:LinkButton>
    </div>

    <!-- Formulario de alta / modificación -->
    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtNombre.ClientID %>">Nombre<span class="req">*</span></label>
                    <asp:TextBox ID="txtNombre" runat="server" CssClass="form-control" MaxLength="50" />
                    <asp:RequiredFieldValidator ID="rfvNombre" runat="server" ControlToValidate="txtNombre" ValidationGroup="Form"
                        ErrorMessage="El nombre es obligatorio." Display="Dynamic" CssClass="validador" SetFocusOnError="true" />
                </div>
                <asp:PlaceHolder ID="phDescripcion" runat="server">
                    <div class="col-12 col-md-6">
                        <label class="form-label" for="<%= txtDescripcion.ClientID %>">Descripción</label>
                        <asp:TextBox ID="txtDescripcion" runat="server" CssClass="form-control" MaxLength="250" />
                    </div>
                </asp:PlaceHolder>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar" CssClass="btn btn-primary" ValidationGroup="Form" OnClick="btnGuardar_Click" />
        </div>
    </asp:Panel>

    <!-- Búsqueda -->
    <asp:Panel ID="pnlBusqueda" runat="server" CssClass="card mb-3" DefaultButton="btnBuscar">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-12 col-md-6">
                    <label class="form-label small mb-1" for="<%= txtBuscar.ClientID %>">Buscar por nombre</label>
                    <asp:TextBox ID="txtBuscar" runat="server" CssClass="form-control" placeholder="Texto a buscar..." />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-search"></i> Buscar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </asp:Panel>

    <!-- Listado -->
    <div class="card">
        <div class="table-responsive">
            <asp:GridView ID="gvDatos" runat="server" AutoGenerateColumns="false" DataKeyNames="ID"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvDatos_PageIndexChanging" OnRowCommand="gvDatos_RowCommand" OnRowDataBound="gvDatos_RowDataBound">
                <Columns>
                    <asp:BoundField DataField="ID" HeaderText="ID" ItemStyle-CssClass="text-muted" />
                    <asp:BoundField DataField="Nombre" HeaderText="Nombre" />
                    <asp:BoundField DataField="Descripcion" HeaderText="Descripción" NullDisplayText="-" />
                    <asp:BoundField DataField="CantidadRegistros" HeaderText="En uso" ItemStyle-CssClass="text-center" HeaderStyle-CssClass="text-center" />
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("ID") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("ID") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Confirma la eliminación del registro?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay registros para mostrar.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
