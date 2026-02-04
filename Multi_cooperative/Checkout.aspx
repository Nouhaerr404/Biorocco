<%@ Page Title="Paiement" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="Multi_cooperative.Checkout" %>
<%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <link href="Content/checkout-pages.css" rel="stylesheet" />
    
    <!-- HEADER -->
    <uc:Header ID="Header1" runat="server" />
    
    <div style="background: linear-gradient(to bottom, #ffffff 0%, #F9F7F2 100%); min-height: 100vh; padding-top: 120px; padding-bottom: 80px;">
        <div class="checkout-container">
            
            <h1 class="cart-page-title text-center" style="margin-bottom: 50px;">Finaliser la commande</h1>

            <div class="row g-5">
                
                <!-- COLONNE GAUCHE : ADRESSE & LIVRAISON -->
                <div class="col-md-7">
                    <div class="checkout-section">
                        
                        <h4 class="checkout-section-title">1. Adresse de livraison</h4>
                        
                        <div class="mb-4">
                            <label class="small text-muted mb-2 d-block">Choisir une adresse enregistrée</label>
                            <asp:DropDownList ID="ddlAddresses" runat="server" CssClass="form-select-modern w-100">
                            </asp:DropDownList>
                            <div class="mt-2 text-end">
                                <a href="ClientProfile.aspx" class="link-return">Gérer mes adresses</a>
                            </div>
                        </div>

                        <hr class="my-4" style="border-color: var(--light);" />

                        <h4 class="checkout-section-title">2. Mode de livraison</h4>
                        
                        <div class="mb-4">
                            <label class="small text-muted mb-2 d-block">Choisir le transporteur</label>
                            <asp:DropDownList ID="ddlShipping" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlShipping_SelectedIndexChanged" CssClass="form-select-modern w-100">
                            </asp:DropDownList>
                        </div>

                        <hr class="my-4" style="border-color: var(--light);" />

                        <!-- SECTION PAIEMENT -->
                        <h4 class="checkout-section-title">3. Mode de Paiement</h4>
                        <div class="mb-4">
                            <label class="small text-muted mb-2 d-block">Choisir le mode de paiement</label>
                            <asp:DropDownList ID="ddlPaymentMethod" runat="server" CssClass="form-select-modern w-100">
                                <asp:ListItem Value="CarteBancaire" Text="Carte Bancaire" />
                                <asp:ListItem Value="PaiementLivraison" Text="Paiement à la livraison" />
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>

                <!-- COLONNE DROITE : RÉCAPITULATIF -->
                <div class="col-md-5">
                    <div class="checkout-summary">
                        <h4 class="checkout-summary-title">Récapitulatif</h4>

                        <div class="summary-row">
                            <span>Sous-total</span>
                            <span><asp:Label ID="lblSubTotal" runat="server"></asp:Label> MAD</span>
                        </div>

                        <div class="summary-row">
                            <span>Frais de livraison</span>
                            <span><asp:Label ID="lblShippingFee" runat="server"></asp:Label> MAD</span>
                        </div>

                        <div class="summary-row summary-total">
                            <span>Total TTC</span>
                            <span><asp:Label ID="lblTotalTTC" runat="server"></asp:Label> MAD</span>
                        </div>

                        <asp:Button ID="btnPay" runat="server" Text="CONFIRMER ET PAYER" OnClick="btnPay_Click" 
                            CssClass="btn-pay-modern" />
                        
                        <p class="mt-3 text-center small" style="opacity: 0.8;">
                            En cliquant, vous acceptez nos CGV.
                        </p>
                    </div>
                </div>

            </div>
        </div>
    </div>

  

</asp:Content>