<%@ Page Title="Nos Produits - BIOROCCO" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Products.aspx.cs" Inherits="Multi_cooperative.Products" %>
    <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

        <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

            <!-- STYLES POUR LA SIDEBAR (COPIÉS DEPUIS ProductDetail.aspx) -->
            <style>
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
                    color: #888;
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
                    background: none;
                    border: none;
                    cursor: pointer;
                    padding: 5px;
                    color: #999;
                    transition: color 0.3s;
                }

                .btn-remove-icon:hover {
                    color: #d9534f;
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

                body.cart-open {
                    overflow: hidden !important;
                    position: fixed;
                    width: 100%;
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
            <div class="min-h-screen bg-[#F5F1E8] pt-60">
                <uc:Header ID="Header1" runat="server" />
                <div class="h-24"></div>

                <!-- Header Image -->
                <div
                    class="relative bg-gradient-to-b from-black/40 via-black/30 to-black/60 h-48 md:h-56 overflow-hidden">
                    <img src="https://images.unsplash.com/photo-1642067958024-1a2d9f836920?q=80&w=2388&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                        alt="Nos Produits" class="w-full h-full object-cover" />
                    <div class="absolute inset-0 bg-black/30 flex items-center justify-center">
                        <h1 class="text-xl md:text-2xl lg:text-3xl font-bold text-white">Nos Produits</h1>
                    </div>
                </div>

                <div class="container mx-auto px-4 py-8">
                    <div class="flex gap-8">
                        <!-- Sidebar Filters -->
                        <aside class="w-64 flex-shrink-0">
                            <div class="bg-white rounded-lg shadow-sm p-6 sticky top-24">
                                <div class="mb-8">
                                    <h3 class="text-[#2D5F3F] mb-4">Filtrer par prix (MAD)</h3>
                                    <div class="px-2">
                                        <div class="flex justify-between text-xs text-gray-500 mb-1">
                                            <span>Min</span>
                                            <span>Max</span>
                                        </div>
                                        <input type="range" id="priceMin" min="0" max="500" value="0"
                                            class="w-full mb-2 price-slider" />
                                        <input type="range" id="priceMax" min="0" max="500" value="500"
                                            class="w-full mb-4 price-slider" />
                                        <div class="flex justify-between text-sm font-medium text-[#2D5F3F]">
                                            <span id="priceMinValue">0</span>
                                            <span id="priceMaxValue">500</span>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </aside>

                        <!-- Products Grid -->
                        <div class="flex-1">
                            <!-- Toolbar -->
                            <div class="bg-white rounded-lg shadow-sm p-4 mb-6 flex items-center justify-between">
                                <asp:Label ID="lblProductCount" runat="server" CssClass="text-gray-600 font-medium"
                                    Text="Chargement..."></asp:Label>

                                <div class="flex-1 max-w-md mx-4">
                                    <asp:TextBox ID="txtSearch" runat="server"
                                        CssClass="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D] focus:border-transparent"
                                        placeholder="Rechercher un produit..." AutoPostBack="true"
                                        OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                                </div>

                                <div class="flex items-center gap-4">
                                    <asp:DropDownList ID="ddlCategory" runat="server"
                                        CssClass="px-4 py-2 border border-gray-300 rounded-lg hover:border-[#E8967D] transition-colors focus:outline-none focus:ring-2 focus:ring-[#E8967D]"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                                    </asp:DropDownList>

                                    <asp:DropDownList ID="ddlSort" runat="server"
                                        CssClass="px-4 py-2 border border-gray-300 rounded-lg hover:border-[#E8967D] transition-colors focus:outline-none focus:ring-2 focus:ring-[#E8967D]"
                                        AutoPostBack="true" OnSelectedIndexChanged="ddlSort_SelectedIndexChanged">
                                        <asp:ListItem Value="newest">Plus récent</asp:ListItem>
                                        <asp:ListItem Value="price-asc">Prix croissant</asp:ListItem>
                                        <asp:ListItem Value="price-desc">Prix décroissant</asp:ListItem>
                                        <asp:ListItem Value="rating">Meilleures notes</asp:ListItem>
                                    </asp:DropDownList>

                                    <div class="flex gap-1 border border-gray-300 rounded-lg p-1">
                                        <button type="button" id="gridView"
                                            class="p-2 rounded bg-[#E8967D] text-white transition-colors view-mode-btn active"
                                            data-view="grid">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zM14 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zM14 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z" />
                                            </svg>
                                        </button>
                                        <button type="button" id="listView"
                                            class="p-2 rounded text-gray-600 hover:bg-gray-100 transition-colors view-mode-btn"
                                            data-view="list">
                                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M4 6h16M4 12h16M4 18h16" />
                                            </svg>
                                        </button>
                                    </div>
                                </div>
                            </div>

                            <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>
                                    <div id="productsGrid"
                                        class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                                        <asp:Repeater ID="rptProducts" runat="server"
                                            OnItemDataBound="rptProducts_ItemDataBound">
                                            <ItemTemplate>
                                                <div class="product-card-wrapper">
                                                    <div class="product-card bg-white rounded-lg shadow-sm overflow-hidden border border-gray-200 hover:shadow-md transition-shadow duration-300 flex flex-col md:flex-row h-full"
                                                        data-category='<%# Eval("CategoryName") %>'
                                                        data-price='<%# Eval("MinPrice") %>'>

                                                        <div
                                                            class="md:w-1/3 flex-shrink-0 relative h-48 md:h-auto overflow-hidden bg-gray-100">
                                                            <img src='<%# GetImageUrl(Eval("ImageUrl")) %>'
                                                                alt='<%# Eval("Name") %>'
                                                                class="w-full h-full object-cover transition-transform duration-300 hover:scale-110" />

                                                            <div class="absolute top-3 left-3 flex flex-col gap-2">
                                                                <%# Convert.ToBoolean(Eval("IsOrganic"))
                                                                    ? "<span class='bg-green-600 text-white text-xs px-2 py-1 rounded-full'>Bio</span>"
                                                                    : "" %>
                                                                    <span
                                                                        class='bg-[#E8967D] text-white text-xs px-2 py-1 rounded-full'>
                                                                        <%# Eval("CategoryName") %>
                                                                    </span>
                                                            </div>
                                                        </div>

                                                        <div class="md:w-2/3 p-4 md:p-5 flex flex-col justify-between">
                                                            <h3 class="text-lg font-bold text-gray-800 mb-3">
                                                                <a href='<%# "ProductDetail.aspx?id=" + Eval("ProductId") %>'
                                                                    class="hover:text-[#E8967D] transition-colors">
                                                                    <%# Eval("Name") %>
                                                                </a>
                                                            </h3>

                                                            <p
                                                                class="text-gray-600 text-sm mb-4 line-clamp-3 flex-grow">
                                                                <%# GetShortDescription(Eval("Description")) %>
                                                            </p>



                                                            <div class="flex justify-between items-center mt-auto">
                                                                <div class="flex flex-col">
                                                                    <span class="text-[#E8967D] font-bold text-xl">
                                                                        <%# GetFormattedPrice(Eval("MinPrice")) %>
                                                                    </span>
                                                                    <%# HasMultiplePrices(Eval("MinPrice"),
                                                                        Eval("MaxPrice"))
                                                                        ? "<span class='text-gray-400 text-xs mt-1 line-through'>"
                                                                        + GetFormattedPrice(Eval("MaxPrice"))
                                                                        + "</span>" : "" %>
                                                                </div>

                                                                <asp:Button ID="btnAddToCart" runat="server"
                                                                    Text="Ajouter"
                                                                    CommandArgument='<%# Eval("ProductId") %>'
                                                                    OnClick="btnAddToCart_Click"
                                                                    CssClass="bg-[#2D5F3F] text-white px-4 py-2 rounded-lg hover:bg-[#3A7A4D] transition-colors cursor-pointer font-medium text-sm" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>

                                    <asp:Panel ID="pnlNoProducts" runat="server" Visible="false"
                                        CssClass="text-center py-12 bg-white rounded-lg shadow-sm">
                                        <div class="text-gray-500 text-lg">
                                            <svg class="w-16 h-16 mx-auto mb-4 text-gray-300" fill="none"
                                                stroke="currentColor" viewBox="0 0 24 24">
                                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                                    d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                                            </svg>
                                            <p>Aucun produit trouvé</p>
                                            <p class="text-sm mt-2">Essayez de modifier vos critères de recherche</p>
                                        </div>
                                    </asp:Panel>

                                    <!-- Pagination -->
                                    <div class="mt-12 flex flex-col md:flex-row justify-between items-center gap-4 bg-white p-4 rounded-xl shadow-sm border border-gray-100"
                                        id="paginationContainer" runat="server">
                                        <div class="text-gray-500 text-sm">
                                            Affichage de <span class="font-bold text-[#2D5F3F]">
                                                <asp:Literal ID="litStartRange" runat="server">1</asp:Literal>
                                            </span> à <span class="font-bold text-[#2D5F3F]">
                                                <asp:Literal ID="litEndRange" runat="server">12</asp:Literal>
                                            </span> sur <span class="font-normal">
                                                <asp:Literal ID="litTotalCount" runat="server">0</asp:Literal>
                                            </span> produits
                                        </div>

                                        <div class="flex items-center gap-2">
                                            <asp:LinkButton ID="btnPrev" runat="server" OnClick="btnPrev_Click"
                                                CssClass="p-2 rounded-lg border border-gray-200 hover:bg-[#F9E895]/20 hover:border-[#F9E895] text-gray-600 transition-all disabled:opacity-30">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2" d="M15 19l-7-7 7-7" />
                                                </svg>
                                            </asp:LinkButton>

                                            <div class="flex gap-1 items-center">
                                                <asp:Repeater ID="rptPageNumbers" runat="server">
                                                    <ItemTemplate>
                                                        <asp:LinkButton ID="btnPage" runat="server"
                                                            OnClick="btnPage_Click"
                                                            CommandArgument='<%# Container.DataItem %>'
                                                            CssClass='<%# Convert.ToInt32(Container.DataItem) == CurrentPage ? "w-10 h-10 flex items-center justify-center rounded-lg bg-[#2D5F3F] text-white font-bold shadow-sm" : "w-10 h-10 flex items-center justify-center rounded-lg border border-gray-200 text-gray-600 hover:bg-gray-50 transition-colors" %>'>
                                                            <%# Container.DataItem %>
                                                        </asp:LinkButton>
                                                    </ItemTemplate>
                                                </asp:Repeater>
                                            </div>

                                            <asp:LinkButton ID="btnNext" runat="server" OnClick="btnNext_Click"
                                                CssClass="p-2 rounded-lg border border-gray-200 hover:bg-[#F9E895]/20 hover:border-[#F9E895] text-gray-600 transition-all disabled:opacity-30">
                                                <svg class="w-5 h-5" fill="none" stroke="currentColor"
                                                    viewBox="0 0 24 24">
                                                    <path stroke-linecap="round" stroke-linejoin="round"
                                                        stroke-width="2" d="M9 5l7 7-7 7" />
                                                </svg>
                                            </asp:LinkButton>
                                        </div>

                                        <div class="flex items-center gap-3">
                                            <span class="text-sm text-gray-500">Par page</span>
                                            <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true"
                                                OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged"
                                                CssClass="border border-gray-200 rounded-lg px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-[#E8967D] bg-gray-50 font-medium">
                                                <asp:ListItem Value="8">8</asp:ListItem>
                                                <asp:ListItem Value="12" Selected="True">12</asp:ListItem>
                                                <asp:ListItem Value="24">24</asp:ListItem>
                                                <asp:ListItem Value="48">48</asp:ListItem>
                                            </asp:DropDownList>
                                        </div>
                                    </div>

                                    <!-- Hidden Fields for Filters -->
                                    <asp:HiddenField ID="hfPriceMin" runat="server" Value="0" />
                                    <asp:HiddenField ID="hfPriceMax" runat="server" Value="5000" />
                                    <asp:Button ID="btnApplyPriceFilter" runat="server"
                                        OnClick="btnApplyPriceFilter_Click" Style="display:none;" />
                                </ContentTemplate>
                                <Triggers>
                                    <asp:AsyncPostBackTrigger ControlID="txtSearch" EventName="TextChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="ddlCategory"
                                        EventName="SelectedIndexChanged" />
                                    <asp:AsyncPostBackTrigger ControlID="ddlSort" EventName="SelectedIndexChanged" />
                                </Triggers>
                            </asp:UpdatePanel>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ========== SIDEBAR PANIER (COPIÉ DEPUIS ProductDetail.aspx) ========== -->
            <div id="cartOverlay" class="cart-overlay" onclick="closeCart()"></div>

            <asp:UpdatePanel ID="updCartSidebar" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
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
                                            <a href='ProductDetail.aspx?id=<%# Eval("ProductId") %>' class="reco-link">
                                                VOIR LE PRODUIT
                                            </a>
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
                                            <img src='<%# ResolveUrl(Eval("ImageUrl").ToString()) %>'
                                                class="cart-item-img" />

                                            <div class="w-100 ps-2">
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

                                                <div class="d-flex justify-content-between align-items-center">
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
                                <p class="small text-muted mb-3" style="font-size: 0.75rem;">
                                    Taxes et frais d'expédition calculés au paiement.
                                </p>

                                <a href="Checkout.aspx" class="btn-cart-pay">PAIEMENT</a>
                                <a href="Cart.aspx" class="btn-cart-view">VOIR LE PANIER</a>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>


            <!-- JavaScript -->
            <script>
                // ========== FONCTIONS CART SIDEBAR ==========
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

                // ========== FILTRES PRIX ET MODES AFFICHAGE ==========
                document.addEventListener('DOMContentLoaded', function () {
                    console.log('Initialisation des filtres...');
                    initializePriceFilter();
                    initializeViewMode();

                    document.getElementById('gridView')?.addEventListener('click', () => setViewMode('grid'));
                    document.getElementById('listView')?.addEventListener('click', () => setViewMode('list'));
                });

                if (typeof Sys !== 'undefined') {
                    Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                        console.log('Postback terminé, réinitialisation...');
                        initializePriceFilter();
                        initializeViewMode();
                    });
                }

                function initializePriceFilter() {
                    const priceMinSlider = document.getElementById('priceMin');
                    const priceMaxSlider = document.getElementById('priceMax');
                    const priceMinValue = document.getElementById('priceMinValue');
                    const priceMaxValue = document.getElementById('priceMaxValue');
                    const hfMin = document.getElementById('<%= hfPriceMin.ClientID %>');
                    const hfMax = document.getElementById('<%= hfPriceMax.ClientID %>');
                    const btnApply = document.getElementById('<%= btnApplyPriceFilter.ClientID %>');

                    if (!priceMinSlider || !priceMaxSlider) return;

                    // Initialize sliders from hidden fields if they have values
                    if (hfMin && hfMin.value) priceMinSlider.value = hfMin.value;
                    if (hfMax && hfMax.value) priceMaxSlider.value = hfMax.value;

                    priceMinValue.textContent = priceMinSlider.value;
                    priceMaxValue.textContent = priceMaxSlider.value;

                    function updateUI() {
                        const minVal = parseInt(priceMinSlider.value);
                        const maxVal = parseInt(priceMaxSlider.value);

                        if (minVal > maxVal) {
                            priceMinSlider.value = maxVal;
                            priceMinValue.textContent = maxVal;
                        } else {
                            priceMinValue.textContent = minVal;
                        }

                        if (maxVal < minVal) {
                            priceMaxSlider.value = minVal;
                            priceMaxValue.textContent = minVal;
                        } else {
                            priceMaxValue.textContent = maxVal;
                        }
                    }

                    function applyFilters() {
                        if (hfMin) hfMin.value = priceMinSlider.value;
                        if (hfMax) hfMax.value = priceMaxSlider.value;
                        if (btnApply) btnApply.click();
                    }

                    priceMinSlider.addEventListener('input', updateUI);
                    priceMaxSlider.addEventListener('input', updateUI);

                    priceMinSlider.addEventListener('change', applyFilters);
                    priceMaxSlider.addEventListener('change', applyFilters);
                }

                function initializeViewMode() {
                    const savedViewMode = localStorage.getItem('productViewMode') || 'grid';
                    setViewMode(savedViewMode);
                }

                function setViewMode(mode) {
                    const productsGrid = document.getElementById('productsGrid');
                    const gridViewBtn = document.getElementById('gridView');
                    const listViewBtn = document.getElementById('listView');

                    if (!productsGrid) return;

                    if (mode === 'grid') {
                        productsGrid.className = 'grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6';
                        gridViewBtn?.classList.add('bg-[#E8967D]', 'text-white');
                        gridViewBtn?.classList.remove('text-gray-600', 'hover:bg-gray-100');
                        listViewBtn?.classList.remove('bg-[#E8967D]', 'text-white');
                        listViewBtn?.classList.add('text-gray-600', 'hover:bg-gray-100');
                        localStorage.setItem('productViewMode', 'grid');
                    } else {
                        productsGrid.className = 'grid grid-cols-1 gap-4';
                        listViewBtn?.classList.add('bg-[#E8967D]', 'text-white');
                        listViewBtn?.classList.remove('text-gray-600', 'hover:bg-gray-100');
                        gridViewBtn?.classList.remove('bg-[#E8967D]', 'text-white');
                        gridViewBtn?.classList.add('text-gray-600', 'hover:bg-gray-100');
                        localStorage.setItem('productViewMode', 'list');
                    }
                }

                function filterProductsByPrice() {
                    const priceMin = parseInt(document.getElementById('priceMin').value) || 0;
                    const priceMax = parseInt(document.getElementById('priceMax').value) || 500;
                    const productWrappers = document.querySelectorAll('.product-card-wrapper');

                    let visibleCount = 0;

                    productWrappers.forEach(wrapper => {
                        const card = wrapper.querySelector('.product-card');
                        const productPrice = parseFloat(card.getAttribute('data-price')) || 0;
                        const isInRange = (productPrice >= priceMin && productPrice <= priceMax);

                        if (isInRange) {
                            wrapper.style.display = '';
                            visibleCount++;
                        } else {
                            wrapper.style.display = 'none';
                        }
                    });

                    const countElement = document.getElementById('<%= lblProductCount.ClientID %>');
                    if (countElement) {
                        countElement.textContent = visibleCount + ' produit(s)';
                    }
                }
            </script>
        </asp:Content>