<%@ Page Title="Documentación de vehículos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Documentacion.aspx.cs" Inherits="Bomberos.Web.Vehiculos.Documentacion" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-file-earmark-text text-danger"></i> Documentación de vehículos</h1>
            <p class="subtitulo">VTV, seguros, habilitaciones y otros documentos con control de vencimientos.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nuevo documento
        </asp:LinkButton>
    </div>

    <!-- Resumen por situación (semáforo) -->
    <div class="row g-3 mb-3">
        <div class="col-12 col-md-4">
            <asp:LinkButton ID="btnVerVencidos" runat="server" CssClass="card kpi text-decoration-none text-reset" CausesValidation="false" OnClick="btnVerVencidos_Click">
                <div class="kpi-icono kpi-rojo"><i class="bi bi-x-octagon"></i></div>
                <div><div class="kpi-valor"><asp:Literal ID="litVencidos" runat="server" Text="0" /></div><div class="kpi-etiqueta"><span class="semaforo semaforo-rojo"></span>Vencidos</div></div>
            </asp:LinkButton>
        </div>
        <div class="col-12 col-md-4">
            <asp:LinkButton ID="btnVerProximos" runat="server" CssClass="card kpi text-decoration-none text-reset" CausesValidation="false" OnClick="btnVerProximos_Click">
                <div class="kpi-icono kpi-naranja"><i class="bi bi-hourglass-split"></i></div>
                <div><div class="kpi-valor"><asp:Literal ID="litProximos" runat="server" Text="0" /></div><div class="kpi-etiqueta"><span class="semaforo semaforo-amarillo"></span>Próximos a vencer (30 días)</div></div>
            </asp:LinkButton>
        </div>
        <div class="col-12 col-md-4">
            <asp:LinkButton ID="btnVerVigentes" runat="server" CssClass="card kpi text-decoration-none text-reset" CausesValidation="false" OnClick="btnVerVigentes_Click">
                <div class="kpi-icono kpi-verde"><i class="bi bi-check2-circle"></i></div>
                <div><div class="kpi-valor"><asp:Literal ID="litVigentes" runat="server" Text="0" /></div><div class="kpi-etiqueta"><span class="semaforo semaforo-verde"></span>Vigentes</div></div>
            </asp:LinkButton>
        </div>
    </div>

    <asp:Panel ID="pnlFormulario" runat="server" CssClass="card card-form mb-4" Visible="false" DefaultButton="btnGuardar">
        <div class="card-header"><asp:Literal ID="litTituloFormulario" runat="server" /></div>
        <div class="card-body">
            <div class="row g-3">
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlVehiculo.ClientID %>">Vehículo<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlVehiculo" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvVehiculo" runat="server" ControlToValidate="ddlVehiculo" ValidationGroup="Form"
                        ErrorMessage="Seleccione un vehículo." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= ddlTipoDocumento.ClientID %>">Tipo de documento<span class="req">*</span></label>
                    <asp:DropDownList ID="ddlTipoDocumento" runat="server" CssClass="form-select" />
                    <asp:RequiredFieldValidator ID="rfvTipoDocumento" runat="server" ControlToValidate="ddlTipoDocumento" ValidationGroup="Form"
                        ErrorMessage="Seleccione el tipo de documento." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtEmision.ClientID %>">Fecha de emisión<span class="req">*</span></label>
                    <asp:TextBox ID="txtEmision" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvEmision" runat="server" ControlToValidate="txtEmision" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha de emisión." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-12 col-md-6">
                    <label class="form-label" for="<%= txtVencimiento.ClientID %>">Fecha de vencimiento<span class="req">*</span></label>
                    <asp:TextBox ID="txtVencimiento" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvVencimiento" runat="server" ControlToValidate="txtVencimiento" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha de vencimiento." Display="Dynamic" CssClass="validador" />
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
                <div class="col-12 col-md-5">
                    <label class="form-label small mb-1" for="<%= ddlFiltroVehiculo.ClientID %>">Vehículo</label>
                    <asp:DropDownList ID="ddlFiltroVehiculo" runat="server" CssClass="form-select" />
                </div>
                <div class="col-12 col-md-3">
                    <label class="form-label small mb-1" for="<%= ddlFiltroSituacion.ClientID %>">Situación</label>
                    <asp:DropDownList ID="ddlFiltroSituacion" runat="server" CssClass="form-select">
                        <asp:ListItem Text="(Todas)" Value="" />
                        <asp:ListItem Text="Vencidos" Value="Vencido" />
                        <asp:ListItem Text="Próximos a vencer" Value="Proximo" />
                        <asp:ListItem Text="Vigentes" Value="Vigente" />
                    </asp:DropDownList>
                </div>
                <div class="col-auto">
                    <asp:LinkButton ID="btnBuscar" runat="server" CssClass="btn btn-dark" CausesValidation="false" OnClick="btnBuscar_Click"><i class="bi bi-funnel"></i> Filtrar</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="table-responsive">
            <asp:GridView ID="gvDocumentos" runat="server" AutoGenerateColumns="false" DataKeyNames="IDDocumento"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvDocumentos_PageIndexChanging" OnRowCommand="gvDocumentos_RowCommand" OnRowDataBound="gvDocumentos_RowDataBound">
                <Columns>
                    <asp:TemplateField HeaderText="Situación">
                        <ItemTemplate>
                            <span class='semaforo <%# ClaseSemaforo(Eval("Situacion")) %>'></span>
                            <span class='<%# ClaseEstado(Eval("Situacion")) %>'><%# Html(Eval("Situacion")) %></span>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Vehículo">
                        <ItemTemplate><%# Html(Eval("VehiculoNombre")) %> <span class="text-muted small">(<%# Html(Eval("Patente")) %>)</span></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="TipoDocumento" HeaderText="Documento" />
                    <asp:BoundField DataField="FechaEmision" HeaderText="Emisión" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:BoundField DataField="FechaVencimiento" HeaderText="Vencimiento" DataFormatString="{0:dd/MM/yyyy}" />
                    <asp:TemplateField HeaderText="Días">
                        <ItemTemplate><%# TextoDias(Eval("DiasParaVencer")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDDocumento") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar / renovar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDDocumento") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar el documento?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay documentos para mostrar.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
