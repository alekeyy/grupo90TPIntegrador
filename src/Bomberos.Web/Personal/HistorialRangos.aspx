<%@ Page Title="Historial de rangos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HistorialRangos.aspx.cs" Inherits="Bomberos.Web.Personal.HistorialRangos" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-award text-danger"></i> Historial de rangos</h1>
            <p class="subtitulo">Un voluntario no puede tener más de un rango vigente al mismo tiempo.</p>
        </div>
        <div class="d-flex gap-2">
            <asp:LinkButton ID="btnAscenso" runat="server" CssClass="btn btn-success" CausesValidation="false" OnClick="btnAscenso_Click">
                <i class="bi bi-arrow-up-circle"></i> Registrar ascenso
            </asp:LinkButton>
            <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
                <i class="bi bi-plus-lg"></i> Nuevo registro
            </asp:LinkButton>
        </div>
    </div>

    <!-- ===================== Registrar ascenso ===================== -->
    <asp:Panel ID="pnlAscenso" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnConfirmarAscenso">
        <div class="card-header"><i class="bi bi-arrow-up-circle"></i> Registrar ascenso</div>
        <div class="card-body">
            <p class="text-muted small">Se finaliza el rango vigente en la fecha del ascenso y se registra el nuevo rango como vigente (operación transaccional).</p>
            <div class="row g-3">
                <div class="col-12 col-md-5">
                    <label class="form-label" for="<%= ddlAscVoluntario.ClientID %>">Voluntario<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAscVoluntario" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlAscVoluntario_SelectedIndexChanged" />
                    <asp:RequiredFieldValidator ID="rfvAscVoluntario" runat="server" ControlToValidate="ddlAscVoluntario" ValidationGroup="Ascenso"
                        ErrorMessage="Seleccione un voluntario." Display="Dynamic" CssClass="validador" />
                    <div class="form-text"><asp:Literal ID="litRangoActual" runat="server" /></div>
                </div>
                <div class="col-12 col-md-4">
                    <label class="form-label" for="<%= ddlAscRango.ClientID %>">Nuevo rango<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlAscRango" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvAscRango" runat="server" ControlToValidate="ddlAscRango" ValidationGroup="Ascenso"
                        ErrorMessage="Seleccione el nuevo rango." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtAscFecha.ClientID %>">Fecha del ascenso<span class="req">*</span></label>
                    <asp:TextBox ID="txtAscFecha" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvAscFecha" runat="server" ControlToValidate="txtAscFecha" ValidationGroup="Ascenso"
                        ErrorMessage="Ingrese la fecha." Display="Dynamic" CssClass="validador" />
                </div>
            </div>
        </div>
        <div class="card-footer bg-white d-flex gap-2 justify-content-end">
            <asp:Button ID="btnCancelarAscenso" runat="server" Text="Cancelar" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancelar_Click" />
            <asp:Button ID="btnConfirmarAscenso" runat="server" Text="Confirmar ascenso" CssClass="btn btn-success" ValidationGroup="Ascenso" OnClick="btnConfirmarAscenso_Click" />
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
                    <label class="form-label" for="<%= ddlRango.ClientID %>">Rango<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlRango" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvRango" runat="server" ControlToValidate="ddlRango" ValidationGroup="Form"
                        ErrorMessage="Seleccione un rango." Display="Dynamic" CssClass="validador" />
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
                    <div class="form-text">Dejar vacío si es el rango vigente.</div>
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
            <asp:GridView ID="gvHistorial" runat="server" AutoGenerateColumns="false" DataKeyNames="IDHistorialRango"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvHistorial_PageIndexChanging" OnRowCommand="gvHistorial_RowCommand">
                <Columns>
                    <asp:BoundField DataField="VoluntarioNombre" HeaderText="Voluntario" />
                    <asp:BoundField DataField="RangoNombre" HeaderText="Rango" />
                    <asp:BoundField DataField="FechaDesde" HeaderText="Desde" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="FechaHasta" HeaderText="Hasta" DataFormatString="{0:dd/MM/yyyy}" NullDisplayText="-" />
                    <asp:TemplateField HeaderText="Situación">
                        <ItemTemplate>
                            <span class='<%# (bool)Eval("Vigente") ? "badge text-bg-success" : "badge text-bg-secondary" %>'><%# (bool)Eval("Vigente") ? "Vigente" : "Finalizado" %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDHistorialRango") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDHistorialRango") %>'
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
