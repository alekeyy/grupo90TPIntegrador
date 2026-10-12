<%@ Page Title="Error" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="Bomberos.Web.ErrorPage" %>

<asp:Content ID="cMain" ContentPlaceHolderID="MainContent" runat="server">
    <div class="card mx-auto mt-4" style="max-width: 640px;">
        <div class="card-body text-center p-5">
            <i class="bi bi-exclamation-octagon text-danger" style="font-size: 3.5rem;"></i>
            <h1 class="h3 mt-3"><asp:Literal ID="litTitulo" runat="server" Text="Ocurrió un error" /></h1>
            <p class="text-muted"><asp:Literal ID="litDetalle" runat="server" Text="No pudimos completar la operación. El error fue registrado. Intente nuevamente más tarde." /></p>
            <a runat="server" href="~/Default.aspx" class="btn btn-primary mt-2"><i class="bi bi-house"></i> Volver al inicio</a>
        </div>
    </div>
</asp:Content>
