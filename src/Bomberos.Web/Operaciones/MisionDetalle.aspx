<%@ Page Title="Asignación de recursos" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MisionDetalle.aspx.cs" Inherits="Bomberos.Web.Operaciones.MisionDetalle" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-people-fill text-danger"></i> Asignación de recursos</h1>
            <p class="subtitulo">Voluntarios, vehículos y equipamiento afectados a la misión.</p>
        </div>
        <a runat="server" href="~/Operaciones/Misiones.aspx" class="btn btn-outline-secondary"><i class="bi bi-arrow-left"></i> Volver a misiones</a>
    </div>

    <!-- Encabezado de la misión (FormView de solo lectura) -->
    <asp:FormView ID="fvMision" runat="server" DataKeyNames="IDMision" RenderOuterTable="false">
        <ItemTemplate>
            <div class="card mb-4">
                <div class="card-body">
                    <div class="d-flex flex-wrap justify-content-between gap-2 mb-2">
                        <h2 class="h5 mb-0"><%# Html(Eval("Nombre")) %> <span class="text-muted fw-normal">#<%# Eval("IDMision") %></span></h2>
                        <span class='<%# ClaseEstado(Eval("Estado")) %> fs-6'><%# Html(Eval("Estado")) %></span>
                    </div>
                    <div class="row g-2 small">
                        <div class="col-12 col-md-4"><span class="text-muted">Tipo:</span> <%# Html(Eval("TipoMisionNombre")) %></div>
                        <div class="col-12 col-md-4"><span class="text-muted">Inicio:</span> <%# Eval("FechaInicio", "{0:dd/MM/yyyy HH:mm}") %></div>
                        <div class="col-12 col-md-4"><span class="text-muted">Fin:</span> <%# Eval("FechaFin") == null ? "-" : Eval("FechaFin", "{0:dd/MM/yyyy HH:mm}") %></div>
                        <div class="col-12 col-md-8"><span class="text-muted">Incidente:</span> <%# Html(Eval("IncidenteDireccion")) %> (<%# Eval("IncidenteFechaHora", "{0:dd/MM/yyyy HH:mm}") %>)</div>
                        <div class="col-12 col-md-4"><span class="text-muted">Severidad:</span> <span class='<%# ClaseSeveridad(Eval("IncidenteSeveridad")) %>'><%# Html(Eval("IncidenteSeveridad")) %></span></div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
        <EmptyDataTemplate>
            <div class="alert alert-warning">La misión solicitada no existe.</div>
        </EmptyDataTemplate>
    </asp:FormView>

    <asp:Panel ID="pnlRecursos" runat="server" CssClass="row g-3">
        <!-- ===================== Voluntarios ===================== -->
        <div class="col-12 col-xl-4">
            <div class="card h-100">
                <div class="card-header"><i class="bi bi-people"></i> Voluntarios <span class="badge text-bg-secondary"><asp:Literal ID="litCantVoluntarios" runat="server" Text="0" /></span></div>
                <div class="card-body">
                    <div class="input-group mb-3">
                        <asp:DropDownList ID="ddlVoluntario" runat="server" CssClass="form-select" />
                        <asp:LinkButton ID="btnAgregarVoluntario" runat="server" CssClass="btn btn-success" CommandArgument="Voluntario"
                            OnCommand="Agregar_Command" ValidationGroup="Vol"><i class="bi bi-plus-lg"></i></asp:LinkButton>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvVoluntario" runat="server" ControlToValidate="ddlVoluntario" ValidationGroup="Vol"
                        ErrorMessage="Seleccione un voluntario." Display="Dynamic" CssClass="validador mb-2" />
                    <asp:GridView ID="gvVoluntarios" runat="server" AutoGenerateColumns="false" DataKeyNames="ID" ShowHeader="false"
                        CssClass="table table-sm grid" GridLines="None" OnRowCommand="Quitar_RowCommand">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="fw-semibold"><%# Html(Eval("Descripcion")) %></div>
                                    <div class="small text-muted"><%# Html(Eval("Detalle")) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="acciones">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnQuitar" runat="server" CommandName="Voluntario" CommandArgument='<%# Eval("ID") %>'
                                        CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Quitar"
                                        OnClientClick="return confirm('¿Quitar el voluntario de la misión?');"><i class="bi bi-x-lg"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate><div class="text-muted small">Sin voluntarios asignados.</div></EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- ===================== Vehículos ===================== -->
        <div class="col-12 col-xl-4">
            <div class="card h-100">
                <div class="card-header"><i class="bi bi-truck-front"></i> Vehículos <span class="badge text-bg-secondary"><asp:Literal ID="litCantVehiculos" runat="server" Text="0" /></span></div>
                <div class="card-body">
                    <div class="input-group mb-3">
                        <asp:DropDownList ID="ddlVehiculo" runat="server" CssClass="form-select" />
                        <asp:LinkButton ID="btnAgregarVehiculo" runat="server" CssClass="btn btn-success" CommandArgument="Vehiculo"
                            OnCommand="Agregar_Command" ValidationGroup="Veh"><i class="bi bi-plus-lg"></i></asp:LinkButton>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvVehiculo" runat="server" ControlToValidate="ddlVehiculo" ValidationGroup="Veh"
                        ErrorMessage="Seleccione un vehículo." Display="Dynamic" CssClass="validador mb-2" />
                    <asp:GridView ID="gvVehiculos" runat="server" AutoGenerateColumns="false" DataKeyNames="ID" ShowHeader="false"
                        CssClass="table table-sm grid" GridLines="None" OnRowCommand="Quitar_RowCommand">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="fw-semibold"><%# Html(Eval("Descripcion")) %></div>
                                    <div class="small text-muted"><%# Html(Eval("Detalle")) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="acciones">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnQuitar" runat="server" CommandName="Vehiculo" CommandArgument='<%# Eval("ID") %>'
                                        CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Quitar"
                                        OnClientClick="return confirm('¿Quitar el vehículo de la misión?');"><i class="bi bi-x-lg"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate><div class="text-muted small">Sin vehículos asignados.</div></EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>

        <!-- ===================== Equipamiento ===================== -->
        <div class="col-12 col-xl-4">
            <div class="card h-100">
                <div class="card-header"><i class="bi bi-tools"></i> Equipamiento <span class="badge text-bg-secondary"><asp:Literal ID="litCantEquipos" runat="server" Text="0" /></span></div>
                <div class="card-body">
                    <div class="input-group mb-3">
                        <asp:DropDownList ID="ddlEquipo" runat="server" CssClass="form-select" />
                        <asp:LinkButton ID="btnAgregarEquipo" runat="server" CssClass="btn btn-success" CommandArgument="Equipamiento"
                            OnCommand="Agregar_Command" ValidationGroup="Eq"><i class="bi bi-plus-lg"></i></asp:LinkButton>
                    </div>
                    <asp:RequiredFieldValidator ID="rfvEquipo" runat="server" ControlToValidate="ddlEquipo" ValidationGroup="Eq"
                        ErrorMessage="Seleccione un equipo." Display="Dynamic" CssClass="validador mb-2" />
                    <asp:GridView ID="gvEquipos" runat="server" AutoGenerateColumns="false" DataKeyNames="ID" ShowHeader="false"
                        CssClass="table table-sm grid" GridLines="None" OnRowCommand="Quitar_RowCommand">
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <div class="fw-semibold"><%# Html(Eval("Descripcion")) %></div>
                                    <div class="small text-muted"><%# Html(Eval("Detalle")) %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:TemplateField ItemStyle-CssClass="acciones">
                                <ItemTemplate>
                                    <asp:LinkButton ID="btnQuitar" runat="server" CommandName="Equipamiento" CommandArgument='<%# Eval("ID") %>'
                                        CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Quitar"
                                        OnClientClick="return confirm('¿Quitar el equipo de la misión?');"><i class="bi bi-x-lg"></i></asp:LinkButton>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                        <EmptyDataTemplate><div class="text-muted small">Sin equipamiento asignado.</div></EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </asp:Panel>
</asp:Content>
