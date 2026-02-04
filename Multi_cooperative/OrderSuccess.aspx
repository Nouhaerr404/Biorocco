<%@ Page Title="Commande Confirmée" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OrderSuccess.aspx.cs" Inherits="Multi_cooperative.OrderSuccess" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="Content/checkout-pages.css" rel="stylesheet" />
    <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>
    <uc:Header ID="Header1" runat="server" />
    
    <div class="order-success-container">
        
        <div class="order-success-card">
            
            <div class="success-icon">
                <svg width="50" height="50" fill="none" stroke="currentColor" stroke-width="3" viewBox="0 0 24 24">
                    <polyline points="20 6 9 17 4 12"></polyline>
                </svg>
            </div>

            <h1 class="success-title">Merci pour votre commande !</h1>
            
            <p class="success-message">
                Votre commande a été enregistrée avec succès. <br />
                Un email de confirmation vous a été envoyé.
            </p>

            <div class="order-number-box">
                <div class="order-number-label">Numéro de commande</div>
                <div class="order-number-value">#<asp:Label ID="lblOrderNumber" runat="server"></asp:Label></div>
            </div>

            <div class="success-actions">
                <a href="ClientProfile.aspx" class="btn-success-primary">
                    Suivre ma commande
                </a>
                
                <a href="Products.aspx" class="btn-success-secondary">
                    Continuer mes achats
                </a>
            </div>

        </div>

    </div>

</asp:Content>
