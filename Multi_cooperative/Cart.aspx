<%@ Page Title="Votre Panier" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Cart.aspx.cs" Inherits="Multi_cooperative.Cart" %>
    <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
            <link href="Content/checkout-pages.css" rel="stylesheet" />

            <!-- HEADER -->
            <uc:Header ID="Header1" runat="server" />

            <!-- ESPACE POUR LE HEADER FIXE -->
            <div style="height: 120px;"></div>

            <div class="cart-container">

                <!-- En-tête : Titre + Lien retour -->
                <div class="d-flex justify-content-between align-items-end mb-5">
                    <h1 class="cart-page-title m-0">Votre panier</h1>
                    <a href="Products.aspx" class="link-return">Retour au magasin</a>
                </div>

                <!-- Si le panier est vide -->
                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="text-center py-5">
                    <div style="padding: 60px 20px;">
                        <div
                            style="width: 120px; height: 120px; background: var(--light); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 30px;">
                            <i class="fas fa-shopping-cart" style="font-size: 3rem; color: var(--primary);"></i>
                        </div>
                        <h3 style="color: var(--secondary); font-weight: 600; margin-bottom: 20px;">Votre panier est
                            actuellement vide</h3>
                        <a href="Products.aspx" class="btn-checkout-gold"
                            style="display: inline-block; text-decoration: none; width: auto; padding: 15px 40px;">CONTINUER
                            VOS ACHATS</a>
                    </div>
                </asp:Panel>

                <!-- Contenu du panier -->
                <asp:Panel ID="pnlCartContent" runat="server">

                    <!-- Titres des colonnes -->
                    <div class="cart-header-row">
                        <div class="col-product">PRODUIT</div>
                        <div class="col-price">PRIX</div>
                        <div class="col-qty">QUANTITÉ</div>
                        <div class="col-total text-end" style="padding-right: 40px;">TOTAL</div>
                    </div>

                    <!-- Liste des produits -->
                    <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                        <ItemTemplate>
                            <div class="cart-row">

                                <!-- Colonne 1 : Image & Infos -->
                                <div class="col-product">
                                    <a href='ProductDetail.aspx?id=<%# Eval("ProductId") %>'>
                                        <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>'
                                            class="cart-page-img" />
                                    </a>
                                    <div>
                                        <div class="cart-prod-name">
                                            <%# Eval("Name") %>
                                        </div>
                                        <div class="cart-prod-format">
                                            <%# Eval("Label") %>
                                        </div>
                                    </div>
                                </div>

                                <!-- Colonne 2 : Prix Unitaire -->
                                <div class="col-price">
                                    <span class="cart-price-text">
                                        <%# Eval("UnitPrice", "{0:N2}" ) %> Dh
                                    </span>
                                </div>

                                <!-- Colonne 3 : Sélecteur Quantité -->
                                <div class="col-qty">
                                    <div class="qty-selector">
                                        <asp:LinkButton ID="btnMinus" runat="server" CommandName="Decrease"
                                            CommandArgument='<%# Eval("CartItemId") %>' CssClass="qty-btn">-
                                        </asp:LinkButton>
                                        <span class="qty-number">
                                            <%# Eval("Quantity") %>
                                        </span>
                                        <asp:LinkButton ID="btnPlus" runat="server" CommandName="Increase"
                                            CommandArgument='<%# Eval("CartItemId") %>' CssClass="qty-btn">+
                                        </asp:LinkButton>
                                    </div>
                                </div>

                                <!-- Colonne 4 : Total Ligne + Poubelle -->
                                <div class="col-total">
                                    <span class="cart-total-text">
                                        <%# Eval("TotalPrice", "{0:N2}" ) %> Dh
                                    </span>

                                    <!-- Bouton Supprimer -->
                                    <asp:LinkButton ID="btnRemove" runat="server" CommandName="Remove"
                                        CommandArgument='<%# Eval("CartItemId") %>' CssClass="btn-remove-icon"
                                        ToolTip="Supprimer">
                                        <svg viewBox="0 0 24 24" stroke-linecap="round" stroke-linejoin="round"
                                            width="18" height="18" stroke="#666" fill="none" stroke-width="1.5">
                                            <polyline points="3 6 5 6 21 6"></polyline>
                                            <path
                                                d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2">
                                            </path>
                                        </svg>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <!-- Pied de page (Remarque + Total + Bouton) -->
                    <div class="cart-footer-section" style="justify-content: flex-end;">



                        <!-- Zone Totaux -->
                        <div class="cart-subtotal-area">
                            <div class="d-flex justify-content-between align-items-end mb-2">
                                <span class="fw-bold small text-uppercase">sous-total</span>
                                <span class="cart-subtotal-val">
                                    <asp:Literal ID="litSubTotal" runat="server"></asp:Literal> MAD
                                </span>
                            </div>

                            <p class="small text-muted mb-4">
                                Taxes, r&eacute;ductions et <a href="#"
                                    class="text-dark text-decoration-underline">frais d'exp&eacute;dition</a>
                                calcul&eacute;s &agrave; l'&eacute;tape du paiement.
                            </p>

                            <asp:Button ID="btnCheckout" runat="server" Text="PAIEMENT" OnClick="btnCheckout_Click"
                                CssClass="btn-checkout-gold" />
                        </div>
                    </div>

                </asp:Panel>

            </div>

            <!-- FOOTER -->

        </asp:Content>