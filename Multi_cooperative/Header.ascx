<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="Multi_cooperative.Header" %>

<!-- Announcement Bar - Réduite en hauteur -->
<div class="fixed top-0 left-0 right-0 z-[60] bg-[#2D5F3F] text-white text-center py-1">
    <div class="container mx-auto px-4">
        <p class="text-xs font-medium"> Livraison au Maroc à partir de 25dh</p>
    </div>
</div>

<!-- Header élargi - Positionné juste après la barre réduite -->
<header id="mainHeader" class="fixed top-6 left-4 right-4 z-50 glass-effect rounded-2xl shadow-soft transition-all duration-500">
    <div class="container mx-auto px-6 py-3">
        <div class="flex items-center justify-between">
            <!-- Logo -->
            <a href="Default.aspx" class="cursor-pointer no-underline">
                <div class="flex items-center space-x-2">
                    <div class="relative premium-float">
                        <div class="w-12 h-12 bg-gradient-to-br from-[#2D5F3F] to-[#3A7A4D] rounded-full flex items-center justify-center shadow-lg transform transition-transform hover:rotate-12">
                            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z" />
                            </svg>
                        </div>
                        <div class="absolute -top-1 -right-1 w-4 h-4 bg-[#E8967D] border-2 border-white rounded-full"></div>
                    </div>
                    <div>
                        <!-- Logo en noir -->
                        <div class="text-2xl font-black tracking-tighter text-black" id="logoText">BIOROCCO</div>
                        <div class="text-[10px] uppercase font-bold tracking-widest -mt-1 text-gray-500">Pure Nature</div>
                    </div>
                </div>
            </a>

            <!-- Desktop Navigation -->
            <nav class="hidden lg:flex items-center space-x-10">
                <a href="Default.aspx" 
                   class="text-black hover:text-[#E8967D] font-medium transition-all duration-200 px-3 py-2 rounded-lg hover:bg-gray-50 no-underline">
                    Accueil
                </a>
                
                <!-- Dropdown Nos Produits -->
                <div class="relative group">
                    <a href="Products.aspx" 
                       class="text-black hover:text-[#E8967D] font-medium transition-all duration-200 px-3 py-2 rounded-lg hover:bg-gray-50 flex items-center space-x-1 no-underline">
                        <span>Nos Produits</span>
                        <svg class="w-4 h-4 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"></path>
                        </svg>
                    </a>
                    <div class="absolute top-full left-0 mt-2 w-56 bg-white rounded-xl shadow-2xl opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 border border-gray-100 overflow-hidden">
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Accessoires
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Chantilly De Karité
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Coffret Cadeau
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Huiles Essentielles
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Huiles Végétales
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Hydrolats
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Les Huiles Aromatiques
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Nos Savons
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 border-b border-gray-50 no-underline">
                            Solutions Naturelles
                        </a>
                        <a href="Products.aspx" class="w-full text-left block px-4 py-3 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 no-underline">
                            Huiles Capillaires
                        </a>
                    </div>
                </div>

                <a href="#contact" 
                   class="text-black hover:text-[#E8967D] font-medium transition-all duration-200 px-3 py-2 rounded-lg hover:bg-gray-50 no-underline">
                    Contact
                </a>
            </nav>

            <!-- Action Buttons Desktop -->
            <div class="hidden lg:flex items-center space-x-4">
                <button type="button" id="searchBtn" 
                        class="p-3 rounded-full transition-all duration-200 hover:bg-gray-100 text-black hover:text-[#E8967D]">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                </button>
                
                <!-- Bouton Panier FONCTIONNEL -->
                <a href="Cart.aspx" 
                   class="p-3 rounded-full transition-all duration-200 hover:bg-gray-100 text-black hover:text-[#E8967D] relative no-underline">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                    </svg>
                    <!-- Badge dynamique du nombre d'items -->
                    <% if (CartItemCount > 0) { %>
                        <span class="absolute -top-1 -right-1 w-5 h-5 bg-[#E8967D] text-white text-xs font-bold rounded-full flex items-center justify-center">
                            <%= CartItemCount %>
                        </span>
                    <% } %>
                </a>

                <!-- DÉBUT LOGIQUE CONNEXION DESKTOP -->
                <% if (Session["UserId"] == null) { %>
                    
                    <!-- CAS 1 : NON CONNECTÉ -> Bouton Premium -->
                    <a href="Login.aspx" 
                       class="btn-premium btn-premium-accent shadow-premium no-underline">
                        <span>Connexion</span>
                    </a>

                <% } else { %>

                    <!-- CAS 2 : CONNECTÉ -> Bouton Vert avec Nom -->
                    <div class="relative">
                        <!-- Le bouton avec le nom -->
                        <button type="button" onclick="toggleUserMenu()" 
                                class="btn-premium btn-premium-primary shadow-premium no-underline">
                            <i class="fas fa-user-circle me-2"></i>
                            <span class="font-medium text-white"><%= Session["UserName"] %></span>
                            <i class="fas fa-chevron-down ms-2 small"></i>
                        </button>

                        <!-- Le Menu Déroulant (Caché par défaut) -->
                        <div id="userMenuDropdown" class="hidden absolute right-0 top-full mt-2 w-48 bg-white rounded-xl shadow-2xl py-2 z-50 transform origin-top-right transition-all duration-200 border border-gray-200">
                            <!-- Mon Profil -->
                            <a href="ClientProfile.aspx" class="block w-full text-left px-4 py-3 text-sm text-black hover:bg-[#F5F1E8] hover:text-[#E8967D] transition-all duration-150 flex items-center space-x-2 border-b border-gray-100 no-underline">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                                <span>Mon Profil</span>
                            </a>
                            <% if (Session["UserRole"] != null && Session["UserRole"].ToString().ToLower() == "admin") { %>
                            <!-- Administration -->
                            <a href="AdminDashboard.aspx" class="block w-full text-left px-4 py-3 text-sm text-black hover:bg-[#F5F1E8] hover:text-[#E8967D] transition-all duration-150 flex items-center space-x-2 border-b border-gray-100 no-underline">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                                <span class="font-bold">Administration</span>
                            </a>
                            <% } %>
                            <!-- Déconnexion -->
                            <asp:LinkButton ID="lnkLogout" runat="server" OnClick="lnkLogout_Click" 
                                CssClass="block w-full text-left px-4 py-3 text-sm text-red-600 hover:bg-red-50 transition-all duration-150 flex items-center space-x-2 no-underline">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path></svg>
                                <span>Se déconnecter</span>
                            </asp:LinkButton>
                        </div>
                    </div>

                <% } %>
                <!-- FIN LOGIQUE CONNEXION DESKTOP -->

            </div>

            <!-- Mobile Menu Button -->
            <button type="button" id="mobileMenuBtn" 
                    class="lg:hidden p-3 hover:bg-gray-100 rounded-lg transition-all duration-200 text-black">
                <svg id="menuIcon" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
                </svg>
                <svg id="closeIcon" class="w-6 h-6 hidden" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                </svg>
            </button>
        </div>

        <!-- Mobile Menu -->
        <div id="mobileMenu" class="lg:hidden mt-4 bg-white rounded-xl shadow-xl p-4 hidden border border-gray-200">
            <nav class="flex flex-col space-y-3">
                <a href="Default.aspx" 
                   class="py-3 px-4 text-left text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 rounded-lg no-underline">
                    Accueil
                </a>
                
                <div class="py-2">
                    <a href="Products.aspx" 
                       class="py-3 px-4 text-black mb-2 hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 rounded-lg block no-underline">
                        Nos Produits
                    </a>
                    <div class="pl-6 space-y-1">
                        <a href="Products.aspx" class="block w-full text-left py-2 text-sm text-black hover:text-[#E8967D] hover:bg-gray-50 transition-all duration-150 rounded-lg px-4 no-underline">
                            Accessoires
                        </a>
                        <a href="Products.aspx" class="block w-full text-left py-2 text-sm text-black hover:text-[#E8967D] hover:bg-gray-50 transition-all duration-150 rounded-lg px-4 no-underline">
                            Chantilly De Karité
                        </a>
                        <a href="Products.aspx" class="block w-full text-left py-2 text-sm text-black hover:text-[#E8967D] hover:bg-gray-50 transition-all duration-150 rounded-lg px-4 no-underline">
                            Coffret Cadeau
                        </a>
                    </div>
                </div>
                
                <a href="#contact" 
                   class="py-3 px-4 text-black hover:text-[#E8967D] hover:bg-[#F5F1E8] transition-all duration-150 rounded-lg no-underline">
                    Contact
                </a>
                
                <div class="flex flex-col space-y-3 pt-4 border-t border-gray-200">
                    <!-- DÉBUT LOGIQUE CONNEXION MOBILE -->
                    <% if (Session["UserId"] == null) { %>
                        <!-- Bouton de connexion mobile avec nouvelle couleur -->
                        <a href="Login.aspx" 
                           class="flex items-center justify-center space-x-2 px-4 py-3 bg-gradient-to-r from-[#F5E6CA] to-[#E8D5B5] text-[#8B7355] rounded-lg hover:from-[#E8D5B5] hover:to-[#D4C29E] transition-all duration-200 shadow-md no-underline border border-[#E0C9A0]">
                            <span class="font-semibold">Connexion</span>
                        </a>
                    <% } else { %>
                        <div class="text-center py-3 text-black font-bold border-b border-gray-100 mb-2 bg-[#F5F1E8] rounded-lg">
                            👋 Bonjour, <%= Session["UserName"] %>
                        </div>
                        <a href="ClientProfile.aspx" 
                           class="flex items-center justify-center space-x-2 px-4 py-3 bg-gradient-to-r from-[#E8967D] to-[#d6856c] text-white rounded-lg hover:from-[#d6856c] hover:to-[#E8967D] transition-all duration-200 shadow-md mb-2 no-underline">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" /></svg>
                            <span class="font-medium">Mon Profil</span>
                        </a>
                        <% if (Session["UserRole"] != null && Session["UserRole"].ToString().ToLower() == "admin") { %>
                        <a href="AdminDashboard.aspx" 
                           class="flex items-center justify-center space-x-2 px-4 py-3 bg-white text-[#2D5F3F] border border-[#2D5F3F] rounded-lg hover:bg-gray-50 transition-all duration-200 shadow-md mb-2 no-underline">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z" /></svg>
                            <span class="font-bold">Administration</span>
                        </a>
                        <% } %>
                        <asp:LinkButton ID="lnkMobileLogout" runat="server" OnClick="lnkLogout_Click" 
                                         CssClass="flex items-center justify-center space-x-2 px-4 py-3 bg-gradient-to-r from-red-500 to-red-600 text-white rounded-lg hover:from-red-600 hover:to-red-700 transition-all duration-200 shadow-md no-underline">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"></path></svg>
                            <span class="font-medium">Se déconnecter</span>
                        </asp:LinkButton>
                    <% } %>
                    <!-- FIN LOGIQUE CONNEXION MOBILE -->
                </div>
            </nav>
        </div>

        <!-- Search Bar -->
        <div id="searchBar" class="mt-4 overflow-hidden hidden">
            <div class="bg-white rounded-lg p-3 shadow-lg border border-gray-200">
                <div class="flex items-center space-x-3">
                    <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <input type="text" placeholder="Rechercher un produit..." 
                           class="flex-1 bg-transparent border-none outline-none text-black placeholder-gray-400 text-sm" />
                    <button type="button" class="text-gray-400 hover:text-[#E8967D] transition-colors">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    // Mobile menu toggle
    document.getElementById('mobileMenuBtn').addEventListener('click', function () {
        const menu = document.getElementById('mobileMenu');
        const menuIcon = document.getElementById('menuIcon');
        const closeIcon = document.getElementById('closeIcon');
        menu.classList.toggle('hidden');
        menuIcon.classList.toggle('hidden');
        closeIcon.classList.toggle('hidden');
    });

    // Search toggle
    const searchBtn = document.getElementById('searchBtn');
    if (searchBtn) {
        searchBtn.addEventListener('click', function () {
            const searchBar = document.getElementById('searchBar');
            if (searchBar) {
                searchBar.classList.toggle('hidden');
                // Focus sur l'input quand la barre de recherche s'ouvre
                const searchInput = searchBar.querySelector('input');
                if (searchInput && !searchBar.classList.contains('hidden')) {
                    setTimeout(() => searchInput.focus(), 100);
                }
            }
        });
    }

    // Fermer la barre de recherche avec la croix
    document.addEventListener('click', function (event) {
        const searchBar = document.getElementById('searchBar');
        const closeBtn = event.target.closest('#searchBar button');

        if (closeBtn && searchBar) {
            searchBar.classList.add('hidden');
        }
    });

    // --- SCRIPT POUR LE MENU UTILISATEUR ---
    function toggleUserMenu() {
        const menu = document.getElementById('userMenuDropdown');
        if (menu) {
            menu.classList.toggle('hidden');
        }
    }

    // Ferme le menu si on clique ailleurs sur la page
    document.addEventListener('click', function (event) {
        const menu = document.getElementById('userMenuDropdown');
        const userButton = event.target.closest('button[onclick="toggleUserMenu()"]');

        if (menu && !menu.classList.contains('hidden')) {
            if (!userButton) {
                menu.classList.add('hidden');
            }
        }
    });

    // Effet de scroll léger pour l'ombre du header
    window.addEventListener('scroll', function () {
        const header = document.getElementById('mainHeader');
        if (window.scrollY > 10) {
            header.classList.add('shadow-lg');
        } else {
            header.classList.remove('shadow-lg');
        }
    });
</script>

<style>
    /* Reset des couleurs pour tous les textes du header */
    #mainHeader *:not(.text-white):not(.text-red-600):not(.text-[#E8967D]):not(.text-[#8B7355]) {
        color: #000000 !important;
    }
    
    /* Texte du logo en noir */
    #logoText {
        color: #000000 !important;
    }
    
    /* Navigation links en noir */
    nav a, .tabs-nav a {
        color: #000000 !important;
    }
    
    nav a:hover, .tabs-nav a:hover {
        color: #E8967D !important;
    }
    
    /* Icônes en noir */
    #mainHeader svg:not(.text-white) {
        color: #000000 !important;
    }
    
    #mainHeader button svg:not(.text-white) {
        color: #000000 !important;
    }
    
    /* Placeholder en gris */
    input::placeholder {
        color: #9CA3AF !important;
    }
    
    /* Suppression des soulignements par défaut pour tous les liens */
    a {
        text-decoration: none !important;
    }
    
    /* Style spécifique pour le bouton connexion avec nouvelle couleur */
    .bg-gradient-to-r.from-\[\#F5E6CA\].to-\[\#E8D5B5\] {
        color: #8B7355 !important;
        font-weight: 600 !important;
    }
    
    .bg-gradient-to-r.from-\[\#F5E6CA\].to-\[\#E8D5B5\]:hover {
        color: #7A6245 !important;
    }
    
    /* Amélioration de la visibilité du panier */
    .relative .bg-\[\#E8967D\] {
        background-color: #E8967D !important;
        border: 2px solid white;
    }
    
    /* Ajustement de la bannière pour qu'elle soit moins large */
    .fixed.top-0 .left-0 .right-0 .z-\[60\] {
        width: 100%;
        height: auto;
        min-height: 0;
    }
    
    /* Header plus large avec plus d'espacement */
    .fixed.top-6 .left-0 .right-0 .z-50 {
        top: 6px !important;
    }
    
    /* Espacement accru entre les éléments de navigation */
    .hidden.lg\\:flex.items-center.space-x-10 > * {
        margin-right: 2.5rem;
    }
    
    /* Padding augmenté pour le header */
    .container.mx-auto.px-4.py-4 {
        padding-top: 1rem !important;
        padding-bottom: 1rem !important;
    }
    
    /* Boutons plus grands */
    .hidden.lg\\:flex.items-center.space-x-4 button,
    .hidden.lg\\:flex.items-center.space-x-4 a {
        padding: 0.75rem !important;
    }
    
    /* Conteneur principal plus large */
    .container {
        max-width: 1280px !important;
    }
</style>