<%@ Page Title="Historial de roles" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HistorialRoles.aspx.cs" Inherits="Bomberos.Web.Personal.HistorialRoles" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-person-badge text-danger"></i> Historial de roles</h1>
            <p class="subtitulo">Un voluntario puede tener varios roles a la vez, pero no el mismo rol vigente dos veces.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Asignar rol
        </asp:LinkButton>
    </div>

    <!-- ===================== Finalizar vigencia ===================== -->
    <asp:Panel ID="pnlFinalizar" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnConfirmarFinalizar">
        <div class="card-header"><i class="bi bi-stop-circle"></i> Finalizar vigencia del rol</div>
        <div class="card-body">
            <p class="mb-3"><asp:Literal ID="litFinalizarDetalle" runat="server" /></p>
            <div class="row g-3">
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= txtFechaFin.ClientID %>">Fecha de finalización<span class="req">*</span></label>
                    <asp:TextBox ID="txtFechaFin" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFechaFin" runat="server" ControlToValidate="txtFechaFin" ValidationGroup="Finalizar"
                        ErrorMessage="Ingrese la fecha de finalización." Display="Dynamic" CssClass="validador" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelarFinalizar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnConfirmarFinalizar" runat="server" Text="Finalizar vigencia" CssClass="btn btn-warning" ValidationGroup="Finalizar" OnClick="btnConfirmarFinalizar_Click" />
        </div>
    </asp:Panel>

    <!-- ===================== Formulario ABM ===================== -->
    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlVoluntario.ClientID %>">Voluntario<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlVoluntario" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvVoluntario" runat="server" ControlToValidate="ddlVoluntario" ValidationGroup="Form"
                        ErrorMessage="Seleccione un voluntario." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlRol.ClientID %>">Rol<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlRol" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvRol" runat="server" ControlToValidate="ddlRol" ValidationGroup="Form"
                        ErrorMessage="Seleccione un rol." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtDesde.ClientID %>">Desde<span class="req">*</span></label>
                    <asp:TextBox ID="txtDesde" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvDesde" runat="server" ControlToValidate="txtDesde" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha desde." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtHasta.ClientID %>">Hasta</label>
                    <asp:TextBox ID="txtHasta" runat="server" CssClass="form-control" TextMode="Date" />
                    <div class="form-text">Dejar vacío si el rol está vigente.</div>
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelar" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnGuardar" runat="server" Text="Guardar" CssClass="btn btn-primary" ValidationGroup="Form" OnClick="btnGuardar_Click" />
        </div>
    </asp:Panel>

    <!-- ===================== Filtros ===================== -->
    <div class="card mb-3">
        <div class="card-body">
            <div class="row g-2 align-items-end">
                <div class="col-12 col-md-6">
                    <label class="form-label small mb-1" for="<%= ddlFiltroVoluntario.ClientID %>">Voluntario</label>
                    <asp:DropDownList ID="ddlFiltroVoluntario" runat="server" CssClass="form-select" />
                </div>
                <div class="col-auto">
                    <asp:CheckBox ID="chkSoloVigentes" runat="server" CssClass="chk-bs" Text="Solo vigentes" />
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-funnel"></i> Filtrar</asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <!-- ===================== Listado ===================== -->
    <div class="card">
        <div class="table-responsive">
            <asp:GridView ID="gvHistorial" runat="server" AutoGenerateColumns="false" DataKeyNames="IDHistorialRol"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvHistorial_PageIndexChanging" OnRowCommand="gvHistorial_RowCommand">
                <Columns>
                    <asp:BoundField DataField="VoluntarioNombre" HeaderText="Voluntario" />
                    <asp:BoundField DataField="RolNombre" HeaderText="Rol" />
                    <asp:BoundField DataField="FechaDesde" HeaderText="Desde" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="FechaHasta" HeaderText="Hasta" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Situación">
                        <ItemTemplate>
                            <span class='<%# (bool)Eval("Vigente") ? "badge text-bg-success" : "badge text-bg-secondary" %>'><%# (bool)Eval("Vigente") ? "Vigente" : "Finalizado" %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnFinalizar" runat="server" CommandName="Finalizar" CommandArgument='<%# Eval("IDHistorialRol") %>'
                                CssClass="btn btn-sm btn-outline-warning" CausesValidation="false" ToolTip="Finalizar vigencia"
                                Visible='<%# (bool)Eval("Vigente") %>'><i class="bi bi-stop-circle"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDHistorialRol") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDHistorialRol") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar este registro del historial?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay registros de historial.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
