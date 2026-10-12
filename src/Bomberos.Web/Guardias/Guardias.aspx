<%@ Page Title="Guardias" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Guardias.aspx.cs" Inherits="Bomberos.Web.Guardias.GuardiasPage" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="page-header">
        <div>
            <h1><i class="bi bi-calendar-week text-danger"></i> Guardias</h1>
            <p class="subtitulo">Turnos de guardia. Si la hora de fin es menor a la de inicio, la guardia termina al día siguiente.</p>
        </div>
        <asp:LinkButton ID="btnNuevo" runat="server" CssClass="btn btn-primary" CausesValidation="false" OnClick="btnNuevo_Click">
            <i class="bi bi-plus-lg"></i> Nueva guardia
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
                <div class="col-12 col-md-3">
                    <label class="form-label" for="<%= txtFecha.ClientID %>">Fecha<span class="req">*</span></label>
                    <asp:TextBox ID="txtFecha" runat="server" CssClass="form-control" TextMode="Date" />
                    <asp:RequiredFieldValidator ID="rfvFecha" runat="server" ControlToValidate="txtFecha" ValidationGroup="Form"
                        ErrorMessage="Ingrese la fecha." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label" for="<%= txtHoraInicio.ClientID %>">Hora inicio<span class="req">*</span></label>
                    <asp:TextBox ID="txtHoraInicio" runat="server" CssClass="form-control" TextMode="Time" />
                    <asp:RequiredFieldValidator ID="rfvHoraInicio" runat="server" ControlToValidate="txtHoraInicio" ValidationGroup="Form"
                        ErrorMessage="Obligatoria." Display="Dynamic" CssClass="validador" />
                </div>
                <div class="col-6 col-md-2">
                    <label class="form-label" for="<%= txtHoraFin.ClientID %>">Hora fin<span class="req">*</span></label>
                    <asp:TextBox ID="txtHoraFin" runat="server" CssClass="form-control" TextMode="Time" />
                    <asp:RequiredFieldValidator ID="rfvHoraFin" runat="server" ControlToValidate="txtHoraFin" ValidationGroup="Form"
                        ErrorMessage="Obligatoria." Display="Dynamic" CssClass="validador" />
                    <asp:CompareValidator ID="cvHoras" runat="server" ControlToValidate="txtHoraFin" ControlToCompare="txtHoraInicio"
                        Operator="NotEqual" ValidationGroup="Form" ErrorMessage="Debe ser distinta del inicio." Display="Dynamic" CssClass="validador" />
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
                    <label class="form-label small mb-1" for="<%= ddlFiltroVoluntario.ClientID %>">Guardias por voluntario</label>
                    <asp:DropDownList ID="ddlFiltroVoluntario" runat="server" CssClass="form-select" />
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
                    <asp:LinkButton ID="btnHoy" runat="server" CssClass="btn btn-outline-dark" CausesValidation="false" OnClick="btnHoy_Click">Hoy</asp:LinkButton>
                    <asp:LinkButton ID="btnLimpiar" runat="server" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnLimpiar_Click">Limpiar</asp:LinkButton>
                </div>
            </div>
            <div class="form-text">Para consultar las guardias de una fecha, indique la misma fecha en "Desde" y "Hasta" (o use "Hoy").</div>
        </div>
    </div>

    <div class="card">
        <div class="card-header d-flex justify-content-between">
            <span>Listado</span><span class="text-muted small"><asp:Literal ID="litResumen" runat="server" /></span>
        </div>
        <div class="table-responsive">
            <asp:GridView ID="gvGuardias" runat="server" AutoGenerateColumns="false" DataKeyNames="IDGuardia"
                CssClass="table table-hover grid" GridLines="None" AllowPaging="true" PageSize="10"
                OnPageIndexChanging="gvGuardias_PageIndexChanging" OnRowCommand="gvGuardias_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Fecha" HeaderText="Fecha" DataFormatString="{0:ddd dd/MM/yyyy}" />
                    <asp:BoundField DataField="VoluntarioNombre" HeaderText="Voluntario" />
                    <asp:TemplateField HeaderText="Horario">
                        <ItemTemplate>
                            <%# ((TimeSpan)Eval("HoraInicio")).ToString(@"hh\:mm") %> a <%# ((TimeSpan)Eval("HoraFin")).ToString(@"hh\:mm") %>
                            <%# (bool)Eval("TerminaDiaSiguiente") ? "<span class=\"small text-muted\">(+1 día)</span>" : "" %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Duración">
                        <ItemTemplate><%# string.Format("{0:0.#} h", Eval("DuracionHoras")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Situación">
                        <ItemTemplate>
                            <%# (bool)Eval("EnCurso") ? "<span class=\"badge text-bg-primary\"><i class=\"bi bi-broadcast\"></i> En curso</span>" : "" %>
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ItemStyle-CssClass="acciones">
                        <ItemTemplate>
                            <asp:LinkButton ID="btnEditar" runat="server" CommandName="Editar" CommandArgument='<%# Eval("IDGuardia") %>'
                                CssClass="btn btn-sm btn-outline-primary" CausesValidation="false" ToolTip="Editar"><i class="bi bi-pencil"></i></asp:LinkButton>
                            <asp:LinkButton ID="btnEliminar" runat="server" CommandName="Eliminar" CommandArgument='<%# Eval("IDGuardia") %>'
                                CssClass="btn btn-sm btn-outline-danger" CausesValidation="false" ToolTip="Eliminar"
                                OnClientClick="return confirm('¿Eliminar la guardia?');"><i class="bi bi-trash"></i></asp:LinkButton>
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
                <PagerStyle CssClass="grid-pager" />
                <EmptyDataTemplate><div class="grid-vacia">No hay guardias para los filtros indicados.</div></EmptyDataTemplate>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
