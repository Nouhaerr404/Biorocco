<%@ Page Title="Détail Produit" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ProductDetail.aspx.cs" Inherits="Multi_cooperative.ProductDetail" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
        <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>


            <!-- ScriptManager obligatoire pour l'AJAX (UpdatePanel) -->


            <!-- STYLES INTEGRES (Pour éviter les problèmes de cache) -->
            <style>
                /* --- STYLE GENERAL --- */
                body {
                    font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
                    color: #333;
                }

                .product-title {
                    font-family: 'Georgia', serif;
                    font-size: 1.8rem;
                    margin-bottom: 0.5rem;
                    color: #1a1a1a;
                }

                .product-price {
                    font-size: 1.5rem;
                    font-weight: 600;
                    margin-bottom: 1rem;
                    color: #1a1a1a;
                }

                .section-title {
                    font-size: 0.9rem;
                    font-weight: bold;
                    text-decoration: underline;
                    margin-top: 25px;
                    margin-bottom: 8px;
                    color: #000;
                }

                /* Dropdown Format */
                .form-select-luxe {
                    border-radius: 0;
                    padding: 12px;
                    border: 1px solid #e5e5e5;
                    width: 100%;
                    font-size: 0.9rem;
                }

                .form-select-luxe:focus {
                    border-color: #2D5F3F;
                    box-shadow: none;
                }

                /* --- BOUTONS PRINCIPAUX --- */
                .btn-natus-outline {
                    display: inline-flex !important;
                    align-items: center;
                    justify-content: center;
                    gap: 10px;
                    width: 100%;
                    background-color: transparent;
                    color: #000000;
                    border: 2px solid #000000;
                    padding: 16px 0;
                    text-transform: uppercase;
                    font-size: 13px;
                    font-weight: 700;
                    letter-spacing: 2px;
                    border-radius: 50px;
                    cursor: pointer;
                    margin-top: 20px;
                    margin-bottom: 10px;
                    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                }

                .btn-natus-outline:hover {
                    background-color: #000000;
                    color: #ffffff;
                    transform: translateY(-3px);
                    box-shadow: 0 10px 20px rgba(0, 0, 0, 0.1);
                }

                .btn-natus-green {
                    display: inline-flex !important;
                    align-items: center;
                    justify-content: center;
                    gap: 10px;
                    width: 100%;
                    background: linear-gradient(135deg, #2D5F3F 0%, #3A7A4D 100%);
                    color: #ffffff;
                    border: none;
                    padding: 18px 0;
                    text-transform: uppercase;
                    font-size: 13px;
                    font-weight: 700;
                    letter-spacing: 2px;
                    border-radius: 50px;
                    cursor: pointer;
                    transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
                    box-shadow: 0 4px 15px rgba(45, 95, 63, 0.3);
                }

                .btn-natus-green:hover {
                    background: linear-gradient(135deg, #3A7A4D 0%, #2D5F3F 100%);
                    transform: translateY(-3px) scale(1.01);
                    box-shadow: 0 10px 25px rgba(45, 95, 63, 0.4);
                }

                /* --- SIDEBAR PANIER --- */

                /* --- OVERLAY (FOND NOIR SEMI-TRANSPARENT) --- */
                .cart-overlay {
                    position: fixed;
                    top: 0;
                    left: 0;
                    width: 100%;
                    height: 100%;
                    background: rgba(0, 0, 0, 0.5);
                    z-index: 1040;
                    opacity: 0;
                    visibility: hidden;
                    transition: opacity 0.3s, visibility 0.3s;
                }

                .cart-overlay.open {
                    opacity: 1;
                    visibility: visible;
                }

                /* --- SIDEBAR PRINCIPALE --- */
                .cart-sidebar {
                    position: fixed;
                    top: 0;
                    right: -950px;
                    width: 900px;
                    max-width: 95%;
                    height: 100vh;
                    /* ← CHANGEMENT PRINCIPAL */
                    background: rgba(255, 255, 255, 0.95);
                    backdrop-filter: blur(20px);
                    -webkit-backdrop-filter: blur(20px);
                    z-index: 1050;
                    transition: right 0.6s cubic-bezier(0.16, 1, 0.3, 1);
                    box-shadow: -10px 0 40px rgba(0, 0, 0, 0.2);
                    display: flex;
                    overflow: hidden;
                    /* ← CHANGEMENT */
                }

                .cart-sidebar.open {
                    right: 0;
                }

                body.cart-open {
                    overflow: hidden !important;
                    position: fixed;
                    width: 100%;
                }

                /* --- COLONNE GAUCHE : RECOMMANDATIONS --- */
                .cart-col-reco {
                    width: 35%;
                    background-color: rgba(253, 251, 247, 0.8);
                    padding: 40px 20px;
                    border-right: 1px solid rgba(0, 0, 0, 0.08);
                    overflow-y: auto;
                    /* ← CHANGEMENT */
                    height: 100%;
                    /* ← CHANGEMENT */
                }

                /* --- COLONNE DROITE : PANIER --- */
                .cart-col-items {
                    flex: 1;
                    padding: 40px 30px;
                    display: flex;
                    flex-direction: column;
                    height: 100%;
                    /* ← CHANGEMENT */
                    overflow: hidden;
                    /* ← CHANGEMENT */
                }

                /* --- ZONE SCROLLABLE DES ITEMS --- */
                .cart-items-scroll {
                    flex: 1;
                    overflow-y: auto;
                    padding-right: 10px;
                    margin-bottom: 20px;
                }

                /* Personnalisation de la scrollbar */
                .cart-items-scroll::-webkit-scrollbar,
                .cart-col-reco::-webkit-scrollbar {
                    width: 6px;
                }

                .cart-items-scroll::-webkit-scrollbar-track,
                .cart-col-reco::-webkit-scrollbar-track {
                    background: rgba(0, 0, 0, 0.05);
                    border-radius: 10px;
                }

                .cart-items-scroll::-webkit-scrollbar-thumb,
                .cart-col-reco::-webkit-scrollbar-thumb {
                    background: rgba(45, 95, 63, 0.3);
                    border-radius: 10px;
                }

                .cart-items-scroll::-webkit-scrollbar-thumb:hover,
                .cart-col-reco::-webkit-scrollbar-thumb:hover {
                    background: rgba(45, 95, 63, 0.5);
                }

                /* --- RESPONSIVE --- */
                @media (max-width: 768px) {
                    .cart-col-reco {
                        display: none;
                    }

                    .cart-sidebar {
                        width: 100%;
                        max-width: 100%;
                    }

                    .cart-col-items {
                        padding: 30px 20px;
                    }
                }

                /* --- TITRE SIDEBAR --- */
                .cart-title {
                    font-size: 0.85rem;
                    font-weight: 700;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    margin-bottom: 20px;
                    border-bottom: 1px solid rgba(0, 0, 0, 0.1);
                    padding-bottom: 15px;
                    color: #1a1a1a;
                }

                /* --- ITEMS DU PANIER --- */
                .cart-item {
                    display: flex;
                    gap: 15px;
                    margin-bottom: 20px;
                    border-bottom: 1px solid #f5f5f5;
                    padding-bottom: 15px;
                }

                .cart-item-img {
                    width: 80px;
                    height: 80px;
                    object-fit: cover;
                    border: 1px solid #eee;
                    border-radius: 4px;
                }

                .cart-item-details h4 {
                    font-size: 0.9rem;
                    font-weight: 600;
                    margin: 0 0 5px 0;
                    font-family: 'Georgia', serif;
                    color: #1a1a1a;
                }

                .cart-item-price {
                    font-weight: 700;
                    margin-left: auto;
                    font-size: 0.95rem;
                    color: #2D5F3F;
                }

                /* --- SÉLECTEUR QUANTITÉ --- */
                .qty-selector {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 10px;
                }

                /* Boutons + et - */
                .qty-btn {
                    display: flex;
                    /* IMPORTANT */
                    align-items: center;
                    justify-content: center;
                    width: 36px;
                    height: 36px;
                    line-height: 1;
                    font-size: 20px;
                    font-weight: 600;
                    padding: 0;
                    text-align: center;
                    font-family: Arial, sans-serif;
                    transition: all 0.2s;
                    color: #2D5F3F;
                    text-decoration: none;
                }

                .qty-btn:hover {
                    background: #2D5F3F;
                    color: white;
                    transform: scale(1.1);
                    text-decoration: none;
                }

                /* Nombre */
                .qty-number {
                    display: flex;
                    /* IMPORTANT */
                    align-items: center;
                    justify-content: center;
                    min-width: 32px;
                    height: 36px;
                    font-size: 1rem;
                    font-weight: 600;
                    color: #333;
                }

                /* --- BOUTON SUPPRIMER --- */
                .btn-remove-icon {
                    background: #fff5f5;
                    border: none;
                    cursor: pointer;
                    padding: 6px;
                    color: #e53e3e;
                    transition: all 0.3s;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border-radius: 50%;
                    width: 32px;
                    height: 32px;
                }

                .btn-remove-icon:hover {
                    background: #e53e3e;
                    color: white;
                    transform: scale(1.1);
                }

                .btn-remove-icon svg {
                    width: 18px;
                    height: 18px;
                    stroke-width: 1.5;
                }

                /* --- FOOTER PANIER --- */
                .cart-footer {
                    margin-top: auto;
                    border-top: 2px solid rgba(0, 0, 0, 0.1);
                    padding-top: 20px;
                    background: rgba(255, 255, 255, 0.95);
                }

                .cart-subtotal {
                    display: flex;
                    justify-content: space-between;
                    font-size: 1.1rem;
                    font-weight: 700;
                    margin-bottom: 15px;
                    color: #1a1a1a;
                }

                /* --- BOUTONS FOOTER --- */
                .btn-cart-pay {
                    background-color: #F9E895;
                    color: black;
                    width: 100%;
                    padding: 15px;
                    text-transform: uppercase;
                    font-weight: 700;
                    border: none;
                    letter-spacing: 1px;
                    display: block;
                    text-align: center;
                    text-decoration: none;
                    margin-bottom: 10px;
                    border-radius: 4px;
                    transition: all 0.3s;
                }

                .btn-cart-pay:hover {
                    background-color: #f7e476;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }

                .btn-cart-view {
                    background-color: white;
                    color: black;
                    width: 100%;
                    padding: 15px;
                    text-transform: uppercase;
                    font-weight: 700;
                    border: 2px solid black;
                    letter-spacing: 1px;
                    display: block;
                    text-align: center;
                    text-decoration: none;
                    border-radius: 4px;
                    transition: all 0.3s;
                }

                .btn-cart-view:hover {
                    background-color: black;
                    color: white;
                    transform: translateY(-2px);
                    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
                }

                /* --- BOUTON FERMER --- */
                .btn-close-cart {
                    position: absolute;
                    top: 20px;
                    right: 25px;
                    background: rgba(0, 0, 0, 0.05);
                    border: none;
                    font-size: 1.5rem;
                    cursor: pointer;
                    color: #333;
                    z-index: 10;
                    width: 35px;
                    height: 35px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    transition: all 0.3s;
                }

                .btn-close-cart:hover {
                    background: rgba(0, 0, 0, 0.1);
                    transform: rotate(90deg);
                }

                /* --- RECOMMANDATIONS --- */
                .reco-item {
                    display: flex;
                    gap: 15px;
                    margin-bottom: 20px;
                    align-items: center;
                    padding: 10px;
                    border-radius: 8px;
                    transition: all 0.2s;
                }

                .reco-item:hover {
                    background-color: rgba(255, 255, 255, 0.5);
                    transform: translateX(5px);
                }

                .reco-img {
                    width: 60px;
                    height: 60px;
                    object-fit: cover;
                    border: 1px solid #eee;
                    border-radius: 4px;
                }

                .reco-link {
                    font-size: 0.7rem;
                    text-transform: uppercase;
                    color: #2D5F3F;
                    font-weight: 700;
                    letter-spacing: 1px;
                    text-decoration: none;
                    transition: color 0.2s;
                }

                .reco-link:hover {
                    color: #3A7A4D;
                    text-decoration: underline;
                }
            </style>

            <asp:UpdatePanel ID="updProduct" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <uc:Header ID="Header1" runat="server" />

                    <!-- --- PAGE PRODUIT PRINCIPALE --- -->
                    <div style="background-color: #FDFBF7; min-height: 100vh;">
                        <!-- Padding pour Header Fixe -->
                        <div style="padding-top: 120px; padding-bottom: 80px;">
                            <div class="container">

                                <!-- Fil d'ariane -->
                                <div class="mb-4 small text-uppercase text-muted" style="letter-spacing: 1px;">
                                    <a href="Default.aspx" class="text-muted text-decoration-none">Accueil</a> /
                                    <span class="text-dark">
                                        <asp:Literal ID="litBreadcrumbName" runat="server"></asp:Literal>
                                    </span>
                                </div>

                                <div class="row g-5">

                                    <!-- COLONNE GAUCHE : IMAGE -->
                                    <div class="col-md-7">
                                        <div class="text-center bg-white p-4 shadow-sm mb-3">
                                            <asp:Image ID="imgMain" runat="server" CssClass="img-fluid"
                                                style="max-height: 500px; object-fit: contain;" />
                                        </div>
                                        <div class="d-flex gap-2 justify-content-center product-thumbs">
                                            <asp:PlaceHolder ID="phThumbs" runat="server" />
                                        </div>
                                    </div>

                                    <!-- COLONNE DROITE : DETAILS -->
                                    <div class="col-md-5">

                                        <div class="text-muted text-uppercase small mb-2"
                                            style="letter-spacing: 2px; color: #E8967D; font-weight: 700;">
                                            <asp:Literal ID="litCategory" runat="server"></asp:Literal>
                                        </div>

                                        <h1 class="product-title">
                                            <asp:Literal ID="litProductName" runat="server"></asp:Literal>
                                        </h1>

                                        <div class="product-price">
                                            <asp:Label ID="lblPrice" runat="server"></asp:Label> MAD
                                        </div>

                                        <p class="text-muted mb-4" style="line-height: 1.6; font-size: 0.95rem;">
                                            <asp:Literal ID="litDescription" runat="server"></asp:Literal>
                                        </p>

                                        <div class="mb-3">
                                            <label class="fw-bold mb-2 small text-uppercase"
                                                style="letter-spacing: 1px;">Format</label>
                                            <asp:DropDownList ID="ddlFormats" runat="server" AutoPostBack="true"
                                                OnSelectedIndexChanged="ddlFormats_SelectedIndexChanged"
                                                CssClass="form-select form-select-luxe">
                                            </asp:DropDownList>
                                        </div>




                                        <!-- DETAILS SUPPLEMENTAIRES -->
                                        <div class="mt-5 pt-3 border-top">
                                            <div class="section-title">Ingrédients</div>
                                            <p class="small text-muted fst-italic mb-3">
                                                <asp:Literal ID="litIngredients" runat="server"></asp:Literal>
                                            </p>

                                            <div class="section-title">Conseils d'utilisation</div>
                                            <p class="small text-muted">
                                                <asp:Literal ID="litUsage" runat="server"></asp:Literal>
                                            </p>
                                        </div>

                                        <div class="mt-4">
                                            <!-- Quantité cachée (valeur 1 par défaut) -->
                                            <asp:TextBox ID="txtQuantity" runat="server" Text="1" Visible="false">
                                            </asp:TextBox>

                                            <!-- Bouton 1 : Blanc/Noir -->
                                            <asp:Button ID="btnAddToCart" runat="server" Text="AJOUTER AU PANIER"
                                                OnClick="btnAddToCart_Click" CssClass="btn-natus-outline" />

                                            <!-- Bouton 2 : Vert Biorocco -->
                                            <asp:Button ID="btnBuyNow" runat="server" Text="ACHETER MAINTENANT"
                                                OnClick="btnBuyNow_Click" CssClass="btn-natus-green" />
                                        </div>

                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- --- SIDEBAR PANIER (SLIDE-OUT) --- -->

                    <div id="cartOverlay" class="cart-overlay" onclick="closeCart()"></div>

                    <div id="cartSidebar" class="cart-sidebar">

                        <!-- COLONNE GAUCHE : RECOMMANDATIONS -->
                        <div class="cart-col-reco">
                            <h5 class="cart-title">VOUS AIMEREZ AUSSI</h5>
                            <asp:Repeater ID="rptRecommendations" runat="server">
                                <ItemTemplate>
                                    <div class="reco-item d-flex gap-3 mb-4 align-items-center">
                                        <a href='ProductDetail.aspx?id=<%# Eval("ProductId") %>'>
                                            <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>'
                                                class="reco-img" />
                                        </a>
                                        <div>
                                            <a href='ProductDetail.aspx?id=<%# Eval("ProductId") %>'
                                                class="d-block text-dark text-decoration-none fw-bold small mb-1"
                                                style="font-family:'Georgia', serif;">
                                                <%# Eval("Name") %>
                                            </a>
                                            <div class="small text-muted mb-1">
                                                <%# Eval("Price", "{0:N2}" ) %> MAD
                                            </div>
                                            <a href='ProductDetail.aspx?id=<%# Eval("ProductId") %>'
                                                class="reco-link">VOIR LE PRODUIT</a>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- COLONNE DROITE : PANIER -->
                        <div class="cart-col-items">
                            <button type="button" class="btn-close-cart" onclick="closeCart()">✕</button>

                            <h5 class="cart-title">VOTRE PANIER</h5>

                            <div class="cart-items-scroll">
                                <asp:Repeater ID="rptCartItems" runat="server">
                                    <ItemTemplate>
                                        <div class="cart-item">
                                            <!-- Image -->
                                            <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>'
                                                class="cart-item-img" />

                                            <div class="w-100 ps-2">
                                                <!-- Titre & Poubelle -->
                                                <div class="d-flex justify-content-between align-items-start mb-1">
                                                    <h4 class="m-0">
                                                        <%# Eval("Name") %>
                                                    </h4>
                                                    <asp:LinkButton ID="btnRemove" runat="server" CommandName="Remove"
                                                        CommandArgument='<%# Eval("CartItemId") %>'
                                                        CssClass="btn-remove-icon" ToolTip="Supprimer">
                                                        <svg viewBox="0 0 24 24" stroke-linecap="round"
                                                            stroke-linejoin="round" fill="none" stroke="currentColor">
                                                            <polyline points="3 6 5 6 21 6"></polyline>
                                                            <path
                                                                d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2">
                                                            </path>
                                                            <line x1="10" y1="11" x2="10" y2="17"></line>
                                                            <line x1="14" y1="11" x2="14" y2="17"></line>
                                                        </svg>
                                                    </asp:LinkButton>
                                                </div>

                                                <div class="small text-muted mb-2 text-uppercase"
                                                    style="font-size: 0.75rem;">
                                                    <%# Eval("Label") %>
                                                </div>

                                                <!-- Prix & Quantité -->
                                                <div class="d-flex justify-content-between align-items-center">
                                                    <!-- Selecteur Quantité -->
                                                    <div class="qty-selector">
                                                        <asp:LinkButton ID="btnMinus" runat="server"
                                                            CommandName="Decrease"
                                                            CommandArgument='<%# Eval("CartItemId") %>'
                                                            CssClass="qty-btn">-</asp:LinkButton>
                                                        <span class="qty-number">
                                                            <%# Eval("Quantity") %>
                                                        </span>
                                                        <asp:LinkButton ID="btnPlus" runat="server"
                                                            CommandName="Increase"
                                                            CommandArgument='<%# Eval("CartItemId") %>'
                                                            CssClass="qty-btn">+</asp:LinkButton>
                                                    </div>

                                                    <div class="cart-item-price">
                                                        <%# Eval("TotalPrice", "{0:N2}" ) %> Dh
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <asp:Label ID="lblEmptyCart" runat="server" Text="Votre panier est vide."
                                    Visible="false" CssClass="text-center mt-5 d-block text-muted small">
                                </asp:Label>
                            </div>

                            <!-- FOOTER PANIER -->
                            <div class="cart-footer">
                                <div class="cart-subtotal">
                                    <span>SOUS-TOTAL</span>
                                    <span>
                                        <asp:Literal ID="litSubTotal" runat="server"></asp:Literal> MAD
                                    </span>
                                </div>
                                <p class="small text-muted mb-3" style="font-size: 0.75rem;">Taxes et frais
                                    d'expédition calculés au paiement.</p>

                                <a href="Checkout.aspx" class="btn-cart-pay">PAIEMENT</a>
                                <a href="Cart.aspx" class="btn-cart-view">VOIR LE PANIER</a>
                            </div>
                        </div>
                    </div>


                </ContentTemplate>
            </asp:UpdatePanel>

            <!-- SCRIPT JS -->
            <script>
                function openCart() {
                    document.getElementById('cartOverlay').classList.add('open');
                    document.getElementById('cartSidebar').classList.add('open');
                    document.body.classList.add('cart-open');
                }

                function closeCart() {
                    document.getElementById('cartOverlay').classList.remove('open');
                    document.getElementById('cartSidebar').classList.remove('open');
                    document.body.classList.remove('cart-open');
                }

                // Script pour changer l'image principale au clic sur une miniature
                document.addEventListener('click', function (e) {
                    if (e.target && e.target.parentElement.classList.contains('product-thumbs')) {
                        var newSrc = e.target.getAttribute('data-src') || e.target.src;
                        var mainImg = document.getElementById('<%= imgMain.ClientID %>');
                        if (mainImg) mainImg.src = newSrc;
                    }
                });
            </script>

    </asp:Content>