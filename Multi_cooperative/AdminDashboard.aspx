<%@ Page Title="Tableau de Bord Admin - BIOROCCO" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="AdminDashboard.aspx.cs" Inherits="Multi_cooperative.AdminDashboard" %>

    <asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
        <!-- Bootstrap 5 CSS -->
        <link href="Content/admin-products.css" rel="stylesheet">
    </asp:Content>

    <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
        <!-- Inline styles for custom overrides keeping the theme -->
        <style>
            :root {
                --color-primary: #2D5F3F;
                --color-secondary: #E8967D;
                --color-bg: #F5F1E8;
            }

            body {
                background-color: var(--color-bg);
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            /* Glassmorphism Header */
            .glass-header {
                background: rgba(255, 255, 255, 0.95);
                backdrop-filter: blur(10px);
                border-bottom: 1px solid rgba(0, 0, 0, 0.05);
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            }

            /* Sidebar Styling */
            .sidebar-container {
                background: white;
                border-radius: 16px;
                padding: 1.5rem;
                height: calc(100vh - 100px);
                position: sticky;
                top: 90px;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
            }

            .admin-menu-item {
                border-radius: 12px;
                padding: 12px 20px;
                font-weight: 500;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                border: 1px solid transparent;
                width: 100%;
                text-align: left;
                display: flex;
                align-items: center;
                gap: 12px;
                background: transparent;
                color: #4b5563;
            }

            .admin-menu-item:hover {
                background-color: rgba(232, 150, 125, 0.1);
                color: var(--color-primary);
                transform: translateX(4px);
            }

            .admin-menu-item.active {
                background-color: var(--color-secondary);
                color: white;
                box-shadow: 0 4px 12px rgba(232, 150, 125, 0.3);
            }

            /* Cards */
            .stat-card {
                background: white;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
                transition: transform 0.2s ease, box-shadow 0.2s ease;
                border: 1px solid rgba(0, 0, 0, 0.03);
                height: 100%;
            }

            .stat-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 10px 25px rgba(0, 0, 0, 0.05);
            }

            /* Modern Tables */
            .modern-table thead th {
                background-color: #f8f9fa;
                border-bottom: 2px solid #e9ecef;
                color: #6c757d;
                font-weight: 600;
                text-transform: uppercase;
                font-size: 0.75rem;
                letter-spacing: 0.05em;
                padding: 1rem;
            }

            .modern-table tbody td {
                padding: 1rem;
                vertical-align: middle;
                border-bottom: 1px solid #f1f1f1;
            }

            .modern-table tbody tr {
                transition: background-color 0.1s;
            }

            .modern-table tbody tr:hover {
                background-color: #fafafa;
            }

            /* Utilities */
            .text-primary-custom {
                color: var(--color-primary) !important;
            }

            .bg-secondary-custom {
                background-color: var(--color-secondary) !important;
            }

            .text-secondary-custom {
                color: var(--color-secondary) !important;
            }

            .btn-custom-primary {
                background-color: var(--color-secondary);
                color: white;
                border: none;
                padding: 0.5rem 1.5rem;
                border-radius: 50px;
                transition: all 0.2s;
            }

            .btn-custom-primary:hover {
                background-color: #d8856d;
                color: white;
                transform: translateY(-1px);
            }

            /* Dashboard Overview Lists */
            .rank-circle {
                width: 32px;
                height: 32px;
                background: var(--color-bg);
                color: var(--color-primary);
                font-size: 0.75rem;
                font-weight: 800;
                display: flex;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                border: 1px solid rgba(45, 95, 63, 0.1);
            }

            .hover-bg-light:hover {
                background-color: #f8f9fa;
                cursor: pointer;
            }

            .transition-all {
                transition: all 0.2s ease-in-out;
            }

            /* Page Transitions */
            .admin-page {
                animation: fadeIn 0.4s ease-out;
            }

            .admin-page.hidden {
                display: none;
            }

            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(10px);
                }

                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .modal-custom {
                max-width: 1200px;
                width: 90%;
            }
        </style>

        <div class="min-vh-100 pb-5">
            <!-- Header -->
            <header class="glass-header sticky-top mb-4">
                <div class="container-fluid px-4 md:px-5 py-3 d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center gap-3">
                        <h1 class="h4 mb-0 text-primary-custom fw-bold" style="font-family: 'Baskervville', serif;">
                            BIOROCCO <span class="fs-6 text-muted fw-normal opacity-75">| Administration</span></h1>
                    </div>
                    <asp:LinkButton ID="btnLogout" runat="server"
                        CssClass="text-decoration-none text-secondary d-flex align-items-center gap-2 px-3 py-2 rounded-3 hover-bg-light"
                        OnClick="btnLogout_Click">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none"
                            stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                            <polyline points="16 17 21 12 16 7"></polyline>
                            <line x1="21" y1="12" x2="9" y2="12"></line>
                        </svg>
                        <span>Déconnexion</span>
                    </asp:LinkButton>
                </div>
            </header>

            <div class="container-fluid px-4 md:px-5">
                <div class="row g-4">
                    <!-- Sidebar -->
                    <div class="col-lg-2 d-none d-lg-block">
                        <nav class="sidebar-container">
                            <div class="d-flex flex-column gap-2">
                                <button type="button" class="admin-menu-item active" data-page="overview">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <rect x="3" y="3" width="7" height="7"></rect>
                                        <rect x="14" y="3" width="7" height="7"></rect>
                                        <rect x="14" y="14" width="7" height="7"></rect>
                                        <rect x="3" y="14" width="7" height="7"></rect>
                                    </svg>
                                    Vue d'ensemble
                                </button>
                                <button type="button" class="admin-menu-item" data-page="orders">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <circle cx="9" cy="21" r="1"></circle>
                                        <circle cx="20" cy="21" r="1"></circle>
                                        <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6">
                                        </path>
                                    </svg>
                                    Commandes
                                </button>
                                <button type="button" class="admin-menu-item" data-page="products">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                                        <line x1="3" y1="6" x2="21" y2="6"></line>
                                        <path d="M16 10a4 4 0 0 1-8 0"></path>
                                    </svg>
                                    Produits
                                </button>
                                <button type="button" class="admin-menu-item" data-page="customers">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="9" cy="7" r="4"></circle>
                                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                                    </svg>
                                    Clients
                                </button>
                            </div>
                        </nav>
                    </div>

                    <!-- Main Content -->
                    <main class="col-lg-10">
                        <!-- Overview Page -->
                        <div id="overviewPage" class="admin-page">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h2 class="h3 text-primary-custom fw-bold mb-0">Tableau de bord</h2>
                                <select id="periodSelector" class="form-select border-0 shadow-sm" style="width: auto;">
                                    <option value="day">Aujourd'hui</option>
                                    <option value="week">7 derniers jours</option>
                                    <option value="month" selected>Ce mois</option>
                                    <option value="year">Cette année</option>
                                </select>
                            </div>

                            <!-- Metrics -->
                            <div class="row g-4 mb-4">
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card d-flex flex-column justify-content-between">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div class="p-3 rounded-3 bg-opacity-10"
                                                style="background-color: rgba(232, 150, 125, 0.15);">
                                                <svg class="text-secondary-custom" width="24" height="24"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <line x1="12" y1="1" x2="12" y2="23"></line>
                                                    <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                                                </svg>
                                            </div>
                                            <span class="badge bg-light text-dark border" id="salesChange">--</span>
                                        </div>
                                        <div>
                                            <div class="h3 mb-1 text-primary-custom fw-bold" id="totalSales">0 MAD</div>
                                            <div class="text-muted small text-uppercase fw-semibold tracking-wider">
                                                Chiffre d'affaires</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div class="p-3 rounded-3 bg-opacity-10"
                                                style="background-color: rgba(45, 95, 63, 0.15);">
                                                <svg class="text-primary-custom" width="24" height="24"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                                                    <line x1="3" y1="6" x2="21" y2="6"></line>
                                                    <path d="M16 10a4 4 0 0 1-8 0"></path>
                                                </svg>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="h3 mb-1 text-primary-custom fw-bold" id="totalOrders">0</div>
                                            <div class="text-muted small text-uppercase fw-semibold tracking-wider">
                                                Commandes</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div class="p-3 rounded-3 bg-opacity-10"
                                                style="background-color: rgba(232, 150, 125, 0.15);">
                                                <svg class="text-secondary-custom" width="24" height="24"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                                    <circle cx="9" cy="7" r="4"></circle>
                                                    <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                                    <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                                                </svg>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="h3 mb-1 text-primary-custom fw-bold" id="totalCustomers">0</div>
                                            <div class="text-muted small text-uppercase fw-semibold tracking-wider">
                                                Clients</div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-6 col-xl-3">
                                    <div class="stat-card">
                                        <div class="d-flex justify-content-between align-items-start mb-3">
                                            <div class="p-3 rounded-3 bg-opacity-10"
                                                style="background-color: rgba(45, 95, 63, 0.15);">
                                                <svg class="text-primary-custom" width="24" height="24"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <polygon
                                                        points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2">
                                                    </polygon>
                                                </svg>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="h3 mb-1 text-primary-custom fw-bold" id="totalProductsMain">--
                                            </div>
                                            <div class="text-muted small text-uppercase fw-semibold tracking-wider">
                                                Catalogue</div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Charts Area -->
                            <div class="row g-4 mb-4">
                                <div class="col-lg-8">
                                    <div class="stat-card">
                                        <h3 class="h5 text-primary-custom fw-bold mb-4">Analyse des ventes</h3>
                                        <div style="height: 300px; position: relative; width: 100%;">
                                            <canvas id="salesChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="stat-card">
                                        <h3 class="h5 text-primary-custom fw-bold mb-4">Répartition</h3>
                                        <div style="height: 300px; position: relative; width: 100%;">
                                            <canvas id="ordersChart"></canvas>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Lists -->
                            <div class="row g-4">
                                <div class="col-lg-8">
                                    <div class="stat-card h-100">
                                        <h3 class="h5 text-primary-custom fw-bold mb-3">Top Produits</h3>
                                        <div id="topProductsList" class="d-flex flex-column gap-2">
                                            <!-- Loaded dynamically -->
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4">
                                    <div class="stat-card h-100">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h3 class="h5 text-primary-custom fw-bold mb-0">Alertes Stock</h3>
                                            <span class="badge bg-danger rounded-pill px-2 py-1"
                                                style="font-size: 0.7rem;">Attention</span>
                                        </div>
                                        <div id="lowStockList" class="d-flex flex-column gap-2">
                                            <!-- Loaded dynamically -->
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Products Page -->
                        <div id="productsPage" class="admin-page hidden">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h2 class="h3 text-primary-custom fw-bold mb-0">Gestion Produits</h2>
                                <button type="button" onclick="showProductModal()"
                                    class="btn-custom-primary d-flex align-items-center gap-2 shadow-sm">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <line x1="12" y1="5" x2="12" y2="19"></line>
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                    </svg>
                                    Nouveau Produit
                                </button>
                            </div>

                            <!-- Product Filters -->
                            <div class="row g-3 mb-4">
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Filtrer par catégorie</label>
                                    <select id="productCategoryFilter" class="form-select border-0 shadow-sm bg-white">
                                        <option value="">Toutes les catégories</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label small fw-bold text-muted">Filtrer par statut</label>
                                    <div class="border-bottom overflow-auto">
                                        <div class="d-flex gap-3" style="min-width: max-content;">
                                            <button type="button"
                                                class="btn btn-link text-decoration-none border-bottom border-3 border-secondary-custom text-secondary-custom fw-bold px-0 py-2 product-status-tab"
                                                data-status="">Tous</button>
                                            <button type="button"
                                                class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 product-status-tab"
                                                data-status="true">Actifs</button>
                                            <button type="button"
                                                class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 product-status-tab"
                                                data-status="false">Inactifs</button>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div id="productsList" class="row g-4">
                                <!-- Loaded dynamically -->
                            </div>

                            <!-- Pagination Products -->
                            <div class="d-flex justify-content-between align-items-center mt-4 pt-3 border-top">
                                <div class="text-muted small" id="productsSummary">Chargement...</div>
                                <div class="d-flex gap-2">
                                    <button type="button" class="btn btn-outline-secondary btn-sm" id="productsPrevBtn"
                                        disabled>
                                        ← Précédent
                                    </button>
                                    <div id="productsPageNumbers" class="d-flex gap-1 align-items-center"></div>
                                    <button type="button" class="btn btn-outline-secondary btn-sm" id="productsNextBtn"
                                        disabled>
                                        Suivant →
                                    </button>
                                </div>
                                <div class="input-group input-group-sm" style="width: auto;">
                                    <select class="form-select form-select-sm border-0 shadow-sm bg-white"
                                        id="productsPageSize">
                                        <option value="6">6 / page</option>
                                        <option value="12" selected>12 / page</option>
                                        <option value="24">24 / page</option>
                                        <option value="48">48 / page</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Orders Page -->
                        <div id="ordersPage" class="admin-page hidden">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h2 class="h3 text-primary-custom fw-bold mb-0">Commandes</h2>
                                <div class="input-group" style="max-width: 300px;">
                                    <span class="input-group-text bg-white border-end-0"><svg
                                            xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                            stroke-linecap="round" stroke-linejoin="round" class="text-muted">
                                            <circle cx="11" cy="11" r="8"></circle>
                                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                        </svg></span>
                                    <input type="text" id="orderSearch" class="form-control border-start-0"
                                        placeholder="Rechercher...">
                                </div>
                            </div>

                            <!-- Status Filter -->
                            <div class="border-bottom mb-4 overflow-auto">
                                <div class="d-flex gap-4" style="min-width: max-content;">
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-secondary-custom text-secondary-custom fw-bold px-0 py-2 order-tab"
                                        data-status="Toutes">Toutes</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 order-tab"
                                        data-status="Validée">Validées</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 order-tab"
                                        data-status="En préparation">En préparation</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 order-tab"
                                        data-status="Expédiée">Expédiées</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 order-tab"
                                        data-status="Livrée">Livrées</button>
                                </div>
                            </div>

                            <div class="stat-card p-0 overflow-hidden">
                                <div class="table-responsive">
                                    <table class="table modern-table mb-0">
                                        <thead>
                                            <tr>
                                                <th>N° Commande</th>
                                                <th>Client</th>
                                                <th>Date</th>
                                                <th>Total</th>
                                                <th>Statut</th>
                                                <th class="text-end">Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody id="ordersList">
                                            <!-- Loaded dynamically -->
                                        </tbody>
                                    </table>
                                </div>
                                <!-- Pagination Orders -->
                                <div class="bg-light p-3 border-top d-flex justify-content-between align-items-center">
                                    <div class="text-muted small" id="ordersSummary">Chargement...</div>
                                    <div class="d-flex gap-2">
                                        <button type="button" class="btn btn-white btn-sm border shadow-sm"
                                            id="ordersPrevBtn" disabled>←</button>
                                        <div id="ordersPageNumbers" class="d-flex gap-1 align-items-center"></div>
                                        <button type="button" class="btn btn-white btn-sm border shadow-sm"
                                            id="ordersNextBtn" disabled>→</button>
                                    </div>
                                    <select class="form-select form-select-sm border-0 shadow-sm" id="ordersPageSize"
                                        style="width: auto;">
                                        <option value="5">5 / page</option>
                                        <option value="10" selected>10 / page</option>
                                        <option value="20">20 / page</option>
                                        <option value="50">50 / page</option>
                                    </select>
                                </div>
                            </div>
                        </div>

                        <!-- Customers Page -->
                        <div id="customersPage" class="admin-page hidden">
                            <div class="d-flex justify-content-between align-items-center mb-4">
                                <h2 class="h3 text-primary-custom fw-bold mb-0">Clients</h2>
                                <div class="input-group" style="max-width: 300px;">
                                    <span class="input-group-text bg-white border-end-0"><svg
                                            xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                            stroke-linecap="round" stroke-linejoin="round" class="text-muted">
                                            <circle cx="11" cy="11" r="8"></circle>
                                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                                        </svg></span>
                                    <input type="text" id="customerSearch" class="form-control border-start-0"
                                        placeholder="Rechercher client...">
                                </div>
                            </div>

                            <!-- Customer Filters -->
                            <div class="border-bottom mb-4 overflow-auto">
                                <div class="d-flex gap-4" style="min-width: max-content;">
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-secondary-custom text-secondary-custom fw-bold px-0 py-2 customer-status-tab"
                                        data-status="">Tous</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 customer-status-tab"
                                        data-status="true">Actifs</button>
                                    <button type="button"
                                        class="btn btn-link text-decoration-none border-bottom border-3 border-transparent text-muted px-0 py-2 customer-status-tab"
                                        data-status="false">Bloqués</button>
                                </div>
                            </div>

                            <div class="stat-card p-0 overflow-hidden">
                                <div class="table-responsive">
                                    <table class="table modern-table mb-0">
                                        <thead>
                                            <tr>
                                                <th>Client</th>
                                                <th>Email</th>
                                                <th>Téléphone</th>
                                                <th class="text-center">Commandes</th>
                                                <th class="text-end">Total Dépensé</th>
                                                <th class="text-center">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="customersList">
                                            <!-- Loaded dynamically -->
                                        </tbody>
                                    </table>
                                </div>
                                <!-- Pagination Customers -->
                                <div class="bg-light p-3 border-top d-flex justify-content-between align-items-center">
                                    <div class="text-muted small" id="customersSummary">Chargement...</div>
                                    <div class="d-flex gap-2">
                                        <button type="button" class="btn btn-white btn-sm border shadow-sm"
                                            id="customersPrevBtn" disabled>←</button>
                                        <div id="customersPageNumbers" class="d-flex gap-1 align-items-center"></div>
                                        <button type="button" class="btn btn-white btn-sm border shadow-sm"
                                            id="customersNextBtn" disabled>→</button>
                                    </div>
                                    <select class="form-select form-select-sm border-0 shadow-sm" id="customersPageSize"
                                        style="width: auto;">
                                        <option value="5">5 / page</option>
                                        <option value="10" selected>10 / page</option>
                                        <option value="20">20 / page</option>
                                        <option value="50">50 / page</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </main>
                </div>
            </div>
        </div>

        <!-- Bootstrap 5 Modal for Product -->
        <div class="modal fade" id="productModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-dialog-scrollable modal-xl modal-custom">
                <div class="modal-content border-0 shadow-lg rounded-4">
                    <div class="modal-header border-bottom-0 pb-0">
                        <h5 class="modal-title h4 text-primary-custom fw-bold" id="productModalTitle">Nouveau Produit
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div id="productFormContainer">
                            <input type="hidden" id="productId">

                            <!-- Section 1: Informations Générales -->
                            <div class="mb-4">
                                <h6
                                    class="text-primary-custom fw-bold border-bottom pb-2 mb-3 d-flex align-items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                        <polyline points="14 2 14 8 20 8"></polyline>
                                        <line x1="16" y1="13" x2="8" y2="13"></line>
                                        <line x1="16" y1="17" x2="8" y2="17"></line>
                                        <polyline points="10 9 9 9 8 9"></polyline>
                                    </svg>
                                    Informations Générales
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-8">
                                        <label class="form-label text-muted small fw-bold">Nom du produit <span
                                                class="text-danger">*</span></label>
                                        <input type="text" id="productName"
                                            class="form-control bg-light border-0 py-2 rounded-3">
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label text-muted small fw-bold">Catégorie</label>
                                        <select id="productCategory"
                                            class="form-select bg-light border-0 py-2 rounded-3">
                                            <option value="">Aucune</option>
                                        </select>
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label text-muted small fw-bold">Description courte</label>
                                        <textarea id="productDescription" rows="2"
                                            class="form-control bg-light border-0 rounded-3"
                                            placeholder="Résumé du produit..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 2: Détails & Bienfaits -->
                            <div class="mb-4">
                                <h6
                                    class="text-primary-custom fw-bold border-bottom pb-2 mb-3 d-flex align-items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                                    </svg>
                                    Détails & Bienfaits
                                </h6>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-bold">Ingrédients</label>
                                        <textarea id="productIngredients" rows="2"
                                            class="form-control bg-light border-0 rounded-3"
                                            placeholder="Énumérez les composants..."></textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label text-muted small fw-bold">Conseils
                                            d'utilisation</label>
                                        <textarea id="productUsage" rows="2"
                                            class="form-control bg-light border-0 rounded-3"
                                            placeholder="Comment utiliser le produit..."></textarea>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 3: Prix & Options -->
                            <div class="mb-4">
                                <h6
                                    class="text-primary-custom fw-bold border-bottom pb-2 mb-3 d-flex align-items-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <line x1="12" y1="1" x2="12" y2="23"></line>
                                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path>
                                    </svg>
                                    Configuration & Statut
                                </h6>
                                <div class="row g-3 align-items-end">
                                    <div class="col-md-4">
                                        <label class="form-label text-muted small fw-bold">Prix de base (MAD) <span
                                                class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light border-0">MAD</span>
                                            <input type="number" step="0.01" id="productBasePrice"
                                                class="form-control bg-light border-0 py-2">
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div
                                            class="form-check form-switch p-3 bg-light rounded-3 h-100 d-flex align-items-center gap-2 border-0">
                                            <input class="form-check-input ms-0" type="checkbox" id="productIsOrganic">
                                            <label class="form-check-label fw-bold small text-success mb-0"
                                                for="productIsOrganic">Produit Bio 🌱</label>
                                        </div>
                                    </div>
                                    <div class="col-md-4">
                                        <div
                                            class="form-check form-switch p-3 bg-light rounded-3 h-100 d-flex align-items-center gap-2 border-0">
                                            <input class="form-check-input ms-0" type="checkbox" id="productIsActive"
                                                checked>
                                            <label class="form-check-label fw-bold small text-primary mb-0"
                                                for="productIsActive">Actif en boutique</label>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-4">
                                <div class="col-md-5">
                                    <div class="card h-100 bg-white border shadow-sm rounded-4 overflow-hidden">
                                        <div class="card-header bg-light border-0 py-3">
                                            <h6
                                                class="mb-0 text-primary-custom fw-bold d-flex align-items-center gap-2">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
                                                    <circle cx="8.5" cy="8.5" r="1.5"></circle>
                                                    <polyline points="21 15 16 10 5 21"></polyline>
                                                </svg>
                                                Galerie Photos
                                            </h6>
                                        </div>
                                        <div class="card-body">
                                            <div id="productImagesList" class="d-flex flex-column gap-2 mb-3"
                                                style="max-height: 200px; overflow-y: auto;">
                                                <!-- Dynamic -->
                                            </div>
                                            <div class="input-group input-group-sm">
                                                <input type="text" id="newImageUrl" class="form-control border-light"
                                                    placeholder="URL de l'image...">
                                                <button type="button" onclick="addProductImage()"
                                                    class="btn btn-primary bg-secondary-custom border-0 shadow-none">Ajouter</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-7">
                                    <div class="card h-100 bg-white border shadow-sm rounded-4">
                                        <div
                                            class="card-header bg-light border-0 py-3 d-flex justify-content-between align-items-center">
                                            <h6
                                                class="mb-0 text-primary-custom fw-bold d-flex align-items-center gap-2">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16"
                                                    viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                    stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                    <path
                                                        d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z">
                                                    </path>
                                                </svg>
                                                Formats & Stocks
                                            </h6>
                                            <button type="button" onclick="addProductFormat()"
                                                class="btn btn-sm btn-outline-primary border-0 fw-bold">
                                                + Ajouter un format
                                            </button>
                                        </div>
                                        <div class="card-body p-0">
                                            <div
                                                class="row g-2 p-2 bg-light border-bottom small fw-bold text-muted mx-0">
                                                <div class="col-3">Format</div>
                                                <div class="col-2">Prix</div>
                                                <div class="col-2">Stock</div>
                                                <div class="col-2">Stock Min</div>
                                                <div class="col-3">Exp.</div>
                                            </div>
                                            <div id="productFormatsList" class="d-flex flex-column h-100"
                                                style="max-height: 250px; overflow-y: auto;">
                                                <!-- Dynamic -->
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 pt-0">
                        <button type="button" class="btn btn-nav text-muted" data-bs-dismiss="modal">Annuler</button>
                        <button type="button" id="saveProductBtn"
                            class="btn btn-custom-primary shadow-sm">Enregistrer</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Order Modal (Custom implementation kept but styled closer to Bootstrap) -->
        <!-- Order Modal -->
        <div class="modal fade" id="orderModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
            <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
                <div class="modal-content shadow-lg border-0 rounded-4">
                    <div class="modal-header border-bottom-0 bg-light rounded-top-4">
                        <h5 class="modal-title text-primary-custom fw-bold" id="orderModalTitle">Détails Commande</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4 overflow-auto">
                        <div class="card border-0 bg-secondary-custom bg-opacity-10 mb-4 rounded-4">
                            <div class="card-body d-flex flex-wrap justify-content-between align-items-center gap-3">
                                <div>
                                    <small class="text-muted d-block uppercase tracking-wide">Statut actuel</small>
                                    <span id="orderDetailStatus"
                                        class="badge rounded-pill bg-warning text-dark fs-6 mt-1">--</span>
                                </div>
                                <div class="d-flex gap-2 align-items-center">
                                    <select id="updateStatusSelect" class="form-select border-0 shadow-sm"
                                        style="min-width: 150px;">
                                        <option value="Validée">Validée</option>
                                        <option value="En préparation">En préparation</option>
                                        <option value="Expédiée">Expédiée</option>
                                        <option value="Livrée">Livrée</option>
                                        <option value="Annulée">Annulée</option>
                                    </select>
                                    <button type="button" onclick="updateOrderStatusFunc()"
                                        class="btn btn-custom-primary">Mettre à jour</button>
                                </div>
                            </div>
                        </div>

                        <!-- Cancellation Reason -->
                        <div id="orderCancellationInfo" class="alert alert-danger d-none mb-4 rounded-4">
                            <div class="d-flex align-items-start gap-3">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="flex-shrink-0 mt-1">
                                    <circle cx="12" cy="12" r="10"></circle>
                                    <line x1="12" y1="8" x2="12" y2="12"></line>
                                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                                </svg>
                                <div class="flex-grow-1">
                                    <h6 class="fw-bold mb-2">Commande annulée</h6>
                                    <p class="mb-1"><strong>Motif d'annulation:</strong></p>
                                    <p class="mb-2" id="orderCancellationReason"></p>
                                    <small class="text-muted" id="orderCancelledAt"></small>
                                </div>
                            </div>
                        </div>

                        <div class="row g-4 mb-4">
                            <div class="col-md-6">
                                <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Client</h6>
                                <p class="mb-1"><strong id="orderCustomerName"></strong></p>
                                <p class="mb-1 text-muted" id="orderCustomerEmail"></p>
                                <p class="mb-1 text-muted" id="orderCustomerPhone"></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Livraison</h6>
                                <p class="mb-1"><strong id="orderRecipientName"></strong></p>
                                <p class="mb-1" id="orderShippingAddress"></p>
                                <p class="mb-1"><span id="orderShippingZip"></span> <span id="orderShippingCity"></span>
                                </p>
                            </div>
                        </div>

                        <div class="table-responsive mb-4 rounded-3 border">
                            <table class="table table-borderless table-striped mb-0">
                                <thead class="bg-light">
                                    <tr>
                                        <th class="ps-3">Produit</th>
                                        <th>Format</th>
                                        <th class="text-center">Qté</th>
                                        <th class="text-end">Prix</th>
                                        <th class="text-end pe-3">Total</th>
                                    </tr>
                                </thead>
                                <tbody id="orderItemsList">
                                    <!-- Dynamic -->
                                </tbody>
                            </table>
                        </div>

                        <div class="d-flex justify-content-end">
                            <div style="min-width: 250px;">
                                <div class="d-flex justify-content-between mb-2 text-muted">
                                    <span>Sous-total HT</span>
                                    <span id="orderSubtotal">0,00 MAD</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2 text-muted">
                                    <span>Frais de port</span>
                                    <span id="orderShippingFee">0,00 MAD</span>
                                </div>
                                <div
                                    class="d-flex justify-content-between border-top pt-2 mt-2 h5 fw-bold text-primary-custom">
                                    <span>Total TTC</span>
                                    <span id="orderTotal">0,00 MAD</span>
                                </div>
                            </div>
                        </div>

                        <div id="trackingSection" class="mt-4 pt-4 border-top">
                            <h6 class="text-primary-custom fw-bold mb-3">Suivi de colis</h6>
                            <div class="input-group">
                                <input type="text" id="orderTrackingNumber" class="form-control"
                                    placeholder="Numéro de suivi...">
                                <button type="button" class="btn btn-outline-secondary"
                                    onclick="saveTracking()">Enregistrer</button>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 bg-light rounded-bottom-4">
                        <button type="button" onclick="window.print()"
                            class="btn btn-outline-secondary rounded-pill me-auto">
                            🖨️ Facture
                        </button>
                        <button type="button" data-bs-dismiss="modal"
                            class="btn btn-secondary rounded-pill px-4">Fermer</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap 5 Modal for Product Details (View) -->
        <div class="modal fade" id="productDetailsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-scrollable modal-lg">
                <div class="modal-content border-0 shadow-lg rounded-4">
                    <div class="modal-header border-bottom-0 pb-0">
                        <h5 class="modal-title h4 text-primary-custom fw-bold">Fiche Produit</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body p-4">
                        <div class="row">
                            <!-- Main Image -->
                            <div class="col-md-5 mb-4">
                                <img id="productDetailsMainImage" src="" class="img-fluid rounded-4 shadow-sm"
                                    style="width: 100%; height: 300px; object-fit: cover;" alt="Image produit">
                            </div>
                            <!-- Product Info -->
                            <div class="col-md-7">
                                <h3 id="productDetailsName" class="text-primary-custom fw-bold mb-3"></h3>
                                <div class="mb-3">
                                    <span class="badge bg-light text-dark me-2" id="productDetailsCategory"></span>
                                    <span id="productDetailsIsOrganic"></span>
                                    <span id="productDetailsIsActive" class="ms-2"></span>
                                </div>
                                <div class="mb-3">
                                    <h5 class="text-primary-custom">Prix de base: <span
                                            id="productDetailsBasePrice"></span></h5>
                                </div>
                            </div>
                        </div>

                        <!-- Description -->
                        <div class="mb-4">
                            <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Description</h6>
                            <p id="productDetailsDescription" class="text-muted"></p>
                        </div>

                        <!-- Ingredients & Usage -->
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Ingrédients</h6>
                                <p id="productDetailsIngredients" class="text-muted"></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Conseils d'utilisation
                                </h6>
                                <p id="productDetailsUsage" class="text-muted"></p>
                            </div>
                        </div>

                        <!-- Formats -->
                        <div class="mb-4">
                            <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Formats Disponibles</h6>
                            <div id="productDetailsFormats"></div>
                        </div>

                        <!-- Images Gallery -->
                        <div class="mb-4">
                            <h6 class="text-primary-custom fw-bold border-bottom pb-2 mb-3">Galerie d'images</h6>
                            <div class="row" id="productDetailsImages"></div>
                        </div>
                    </div>
                    <div class="modal-footer border-top-0 bg-light rounded-bottom-4">
                        <button type="button" class="btn btn-secondary rounded-pill px-4"
                            data-bs-dismiss="modal">Fermer</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chart.js for graphs -->
        <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
        <!-- Bootstrap 5 JS Bundle (required for modals to work) -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <!-- Admin Notifications System -->
        <script src="Scripts/admin-notifications.js"></script>
        <!-- Admin Dashboard Script -->
        <script src="Scripts/admin-dashboard.js"></script>
    </asp:Content>