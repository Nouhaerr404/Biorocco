// Admin Dashboard Service URL
const adminServiceUrl = 'AdminDashboardService.asmx';

// Chart.js instances
// Chart.js instances
let salesChart = null;
let ordersChart = null;

// Pagination State
const paginationState = {
    products: { page: 1, pageSize: 12, total: 0 },
    orders: { page: 1, pageSize: 10, total: 0 },
    customers: { page: 1, pageSize: 10, total: 0 }
};

// Wait for jQuery and DOM to be ready
function initAdminDashboard() {
    if (typeof jQuery === 'undefined') {
        setTimeout(initAdminDashboard, 100);
        return;
    }

    jQuery(document).ready(function ($) {
        // Tab navigation
        $('.admin-menu-item').on('click', function () {
            const page = $(this).data('page');
            switchAdminTab(page);
        });

        // Load initial data
        loadDashboardMetrics();
        loadProducts();
        initOrderEvents();
        initCustomerEvents();
        initProductFilters(); // Initialize product filters

        // Period selector
        const periodSelector = document.getElementById('periodSelector');
        if (periodSelector) {
            periodSelector.addEventListener('change', function () {
                loadDashboardMetrics(this.value);
            });
        }

        // Form handlers (no form submit handler needed since we removed the form tag)
        const saveProductBtn = document.getElementById('saveProductBtn');

        if (saveProductBtn) {
            saveProductBtn.addEventListener('click', function (e) {
                e.preventDefault();
                if (isSavingProduct) return;
                saveProduct();
            });
        }

        // Init Pagination Events
        ['products', 'orders', 'customers'].forEach(section => {
            $(`#${section}PrevBtn`).on('click', () => changePage(section, -1));
            $(`#${section}NextBtn`).on('click', () => changePage(section, 1));
            $(`#${section}PageSize`).on('change', function () {
                paginationState[section].pageSize = parseInt($(this).val());
                paginationState[section].page = 1;
                loadDataForSection(section);
            });
        });
    });
}

// Start initialization
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initAdminDashboard);
} else {
    initAdminDashboard();
}

function switchAdminTab(page) {
    // Update menu active state
    document.querySelectorAll('.admin-menu-item').forEach(menuItem => {
        menuItem.classList.remove('active');
    });
    const activeTab = document.querySelector(`[data-page="${page}"]`);
    if (activeTab) {
        activeTab.classList.add('active');
    }

    // Show/hide pages
    document.querySelectorAll('.admin-page').forEach(pageDiv => {
        pageDiv.classList.add('hidden');
    });
    const activePage = document.getElementById(page + 'Page');
    if (activePage) {
        activePage.classList.remove('hidden');
    }

    // Load data for specific pages
    if (page === 'overview') {
        loadDashboardMetrics();
    } else if (page === 'products') {
        loadProducts();
    } else if (page === 'orders') {
        loadOrders();
    } else if (page === 'customers') {
        loadCustomers();
    }
}

// Dashboard Metrics
function loadDashboardMetrics(period = 'month') {
    callAdminWebMethod('GetDashboardMetrics', { period }, function (response) {
        if (response.d && response.d.success) {
            const data = response.d.data;
            updateMetrics(data);
            updateCharts(data);
            updateTopProducts(data.topProducts);
            updateLowStock(data.lowStockProducts);
        }
    });
}

function updateMetrics(data) {
    const totalSalesEl = document.getElementById('totalSales');
    if (totalSalesEl) totalSalesEl.textContent = formatPrice(data.totalSales);

    const totalOrdersEl = document.getElementById('totalOrders');
    if (totalOrdersEl) totalOrdersEl.textContent = data.totalOrders;

    const pendingOrdersEl = document.getElementById('pendingOrders');
    if (pendingOrdersEl) {
        pendingOrdersEl.textContent = data.pendingOrders + ' en attente';
    }

    const totalCustomersEl = document.getElementById('totalCustomers');
    if (totalCustomersEl) totalCustomersEl.textContent = data.totalCustomers;

    const totalProductsMainEl = document.getElementById('totalProductsMain');
    if (totalProductsMainEl) totalProductsMainEl.textContent = data.totalProducts || '--';

    // Sales change
    const salesChangeEl = document.getElementById('salesChange');
    if (salesChangeEl) {
        const change = data.salesChange || 0;
        if (change > 0) {
            salesChangeEl.innerHTML = `<span class="text-success fw-bold">+${change.toFixed(1)}%</span>`;
        } else if (change < 0) {
            salesChangeEl.innerHTML = `<span class="text-danger fw-bold">${change.toFixed(1)}%</span>`;
        } else {
            salesChangeEl.innerHTML = '<span class="text-muted">0%</span>';
        }
    }
}

function updateCharts(data) {
    // Sales Chart
    const salesCtx = document.getElementById('salesChart');
    if (salesCtx) {
        if (salesChart) {
            salesChart.destroy();
        }
        salesChart = new Chart(salesCtx, {
            type: 'line',
            data: {
                labels: data.chartData.map(d => d.date),
                datasets: [{
                    label: 'Ventes (MAD)',
                    data: data.chartData.map(d => d.sales),
                    borderColor: '#E8967D',
                    backgroundColor: 'rgba(232, 150, 125, 0.1)',
                    tension: 0.4,
                    fill: true
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    x: { grid: { display: false } },
                    y: { border: { display: false } }
                }
            }
        });
    }

    // Orders by Status Chart
    const ordersCtx = document.getElementById('ordersChart');
    if (ordersCtx) {
        if (ordersChart) {
            ordersChart.destroy();
        }
        const statusColors = {
            'Validée': '#ffc107',
            'En préparation': '#fd7e14',
            'Expédiée': '#0d6efd',
            'Livrée': '#198754',
            'Annulée': '#dc3545'
        };
        ordersChart = new Chart(ordersCtx, {
            type: 'doughnut',
            data: {
                labels: data.ordersByStatus.map(s => s.status),
                datasets: [{
                    data: data.ordersByStatus.map(s => s.count),
                    backgroundColor: data.ordersByStatus.map(s => statusColors[s.status] || '#adb5bd'),
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '70%',
                plugins: {
                    legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20 } }
                }
            }
        });
    }
}

function updateTopProducts(products) {
    const container = document.getElementById('topProductsList');
    if (!container) return;

    if (!products || products.length === 0) {
        container.innerHTML = '<div class="text-center py-4 text-muted small">Aucune donnée de vente</div>';
        return;
    }

    const maxRevenue = Math.max(...products.map(p => p.totalRevenue));

    container.innerHTML = products.map((product, index) => {
        const percentage = maxRevenue > 0 ? (product.totalRevenue / maxRevenue) * 100 : 0;
        return `
            <div class="list-item-premium mb-3">
                <div class="d-flex justify-content-between align-items-start mb-2">
                    <div class="d-flex align-items-center gap-3">
                        <div class="rank-circle">${(index + 1).toString().padStart(2, '0')}</div>
                <div>
                            <h6 class="mb-0 fw-bold text-dark" style="font-size: 0.95rem;">${product.name}</h6>
                            <small class="text-muted">${product.totalSold} vendus</small>
                </div>
            </div>
                    <div class="text-end">
                        <div class="fw-bold text-primary-custom">${formatPrice(product.totalRevenue)}</div>
            </div>
        </div>
                <div class="progress" style="height: 6px; background: rgba(0,0,0,0.03); border-radius: 10px;">
                    <div class="progress-bar" role="progressbar" style="width: ${percentage}%; background: linear-gradient(90deg, var(--color-primary), var(--color-secondary)); border-radius: 10px;"></div>
                </div>
            </div>
        `;
    }).join('');
}

function updateLowStock(products) {
    const container = document.getElementById('lowStockList');
    if (!container) return;

    if (!products || products.length === 0) {
        container.innerHTML = '<div class="text-center py-4 text-success small">Tout est en stock ! ✨</div>';
        return;
    }

    container.innerHTML = products.map(product => `
        <div class="alert-item-premium mb-3">
            <div class="d-flex align-items-center gap-3 p-2 rounded-4 hover-bg-light transition-all">
                <div class="stock-icon-box bg-danger bg-opacity-10 text-danger rounded-3 d-flex align-items-center justify-content-center" style="width: 42px; height: 42px;">
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
                </div>
                <div class="flex-grow-1">
                    <h6 class="mb-0 fw-bold text-dark" style="font-size: 0.9rem;">${product.productName}</h6>
                    <small class="text-muted">${product.format}</small>
                </div>
                <div class="text-end">
                    <div class="fw-bold text-danger">${product.stock} <span class="text-muted fw-normal">/ ${product.stockMin}</span></div>
                    <div class="badge bg-danger bg-opacity-10 text-danger border-0" style="font-size: 9px; padding: 3px 6px;">STOCK FAIBLE</div>
                </div>
            </div>
        </div>
    `).join('');
}

// Products Management
let currentProductFilters = {
    category: '',
    status: '' // '', 'true', 'false'
};

function initProductFilters() {
    // Load categories for filter
    loadCategoriesForFilter();

    // Category filter
    $('#productCategoryFilter').on('change', function () {
        currentProductFilters.category = $(this).val();
        paginationState.products.page = 1;
        loadProducts();
    });

    // Status filter tabs
    $(document).on('click', '.product-status-tab', function () {
        const status = $(this).data('status').toString();
        $('.product-status-tab').removeClass('border-secondary-custom text-secondary-custom').addClass('border-transparent text-muted');
        $(this).removeClass('border-transparent text-muted').addClass('border-secondary-custom text-secondary-custom');
        currentProductFilters.status = status;
        paginationState.products.page = 1;
        loadProducts();
    });
}

function loadCategoriesForFilter() {
    callAdminWebMethod('GetCategories', {}, function (res) {
        if (res.d && res.d.success) {
            const select = $('#productCategoryFilter');
            const currentVal = select.val();
            select.html('<option value="">Toutes les catégories</option>' +
                res.d.data.map(c => `<option value="${c.categoryId}">${c.name}</option>`).join(''));
            select.val(currentVal);
        }
    });
}

function loadProducts() {
    const { page, pageSize } = paginationState.products;
    const categoryId = currentProductFilters.category || "";
    const status = currentProductFilters.status || "";

    callAdminWebMethod('GetProducts', {
        pageIndex: page,
        pageSize: pageSize,
        categoryId: categoryId,
        status: status
    }, function (response) {
        if (response.d && response.d.success) {
            // Plus besoin de filtrer côté client - le serveur le fait déjà !
            paginationState.products.total = (response.d.totalCount !== undefined) ? response.d.totalCount : (response.d.total || response.d.data.length);
            console.log('Products loaded, total:', paginationState.products.total);
            displayProducts(response.d.data);
            renderPagination('products');
        } else {
            if (window.adminNotifications) {
                adminNotifications.error(response.d?.message || 'Erreur lors du chargement des produits');
            } else {
                alert('Erreur lors du chargement des produits');
            }
        }
    });
}

function displayProducts(products) {
    const container = document.getElementById('productsList');
    if (!container) return;

    if (products.length === 0) {
        container.innerHTML = '<div class="col-12 text-center py-5"><div class="glass-effect p-5 rounded-4"><h3 class="text-muted">Aucun produit trouvé</h3><p>Commencez par ajouter votre premier produit premium.</p></div></div>';
        return;
    }

    container.innerHTML = products.map(product => {
        const mainImage = product.images && product.images.length > 0 ?
            (product.images.find(img => img.isMain) || product.images[0]) : null;

        let imageUrl = getPlaceholderImage();
        if (mainImage && mainImage.imageUrl) {
            imageUrl = normalizeImageUrl(mainImage.imageUrl);
        }

        const minPrice = product.formats && product.formats.length > 0
            ? Math.min(...product.formats.map(f => f.price))
            : product.basePrice || 0;

        const totalStock = product.formats ? product.formats.reduce((sum, f) => sum + (f.stock || 0), 0) : 0;
        const lowStock = product.formats ? product.formats.some(f => f.stock <= (f.stockMin || 5)) : false;

        return `
            <div class="col-sm-6 col-lg-4 col-xl-3 mb-4">
                <div class="product-card-premium h-100 d-flex flex-column">
                    <!-- Image Section -->
                    <div class="product-image-wrapper">
                        <img src="${imageUrl}" 
                             class="product-image-cover" 
                             alt="${product.name}"
                             onerror="this.src='${getPlaceholderImage()}'; this.classList.add('broken');">
                        
                        <div class="product-overlay-badges">
                            <span class="badge-status ${product.isActive ? 'status-active' : 'status-inactive'}">
                                    ${product.isActive ? 'Actif' : 'Inactif'}
                                </span>
                            ${product.isOrganic ? '<span class="badge-organic">🌱 Bio</span>' : ''}
                            </div>
                        </div>

                    <!-- Content Section -->
                    <div class="product-content-premium flex-grow-1 p-3">
                        <div class="d-flex justify-content-between align-items-start mb-2">
                            <span class="product-category-premium text-uppercase tracking-wider text-muted small fw-bold">
                                ${product.categoryName || 'Non classé'}
                            </span>
                            ${lowStock ? `
                            <span class="badge-stock-low" title="Stock faible: ${totalStock}">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path><line x1="12" y1="9" x2="12" y2="13"></line><line x1="12" y1="17" x2="12.01" y2="17"></line></svg>
                                Stock
                            </span>` : `
                            <span class="badge-stock-ok text-muted small" title="Stock: ${totalStock}">
                                <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><polyline points="20 6 9 17 4 12"></polyline></svg>
                                ${totalStock}
                            </span>`}
                        </div>

                        <h3 class="product-title-premium mb-2 text-dark">${product.name}</h3>
                        <p class="product-desc-premium text-muted mb-3 small line-clamp-2">
                            ${product.description || 'Aucune description disponible pour ce produit.'}
                        </p>
                        
                        <div class="d-flex align-items-end justify-content-between mt-auto pt-2 border-top border-light">
                            <div class="price-block">
                                <span class="d-block text-muted" style="font-size: 0.7rem;">Prix de base</span>
                                <span class="product-price-premium text-primary-custom fw-bold h5 mb-0">${formatPrice(minPrice)}</span>
                            </div>
                            <div class="formats-badge bg-light rounded-pill px-2 py-1 small text-muted">
                                ${product.formats ? product.formats.length : 0} format(s)
                            </div>
                        </div>
                    </div>

                    <!-- Actions Footer -->
                    <div class="product-actions-premium d-flex border-top">
                        <button type="button" onclick="viewProductDetails(${product.productId}); return false;" class="btn-action-premium flex-fill py-2 border-end text-primary hover-primary" style="color: #2D5F3F !important; background-color: transparent;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                            Voir fiche
                        </button>
                        <button type="button" onclick="editProduct(${product.productId}); return false;" class="btn-action-premium flex-fill py-2 border-end text-muted hover-primary" style="color: #6c757d !important; background-color: transparent;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path></svg>
                                Modifier
                            </button>
                        <button type="button" onclick="deleteProduct(${product.productId}); return false;" class="btn-action-premium flex-fill py-2 text-danger hover-danger" style="color: #dc3545 !important; background-color: transparent;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="me-1"><polyline points="3 6 5 6 21 6"></polyline><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path></svg>
                                Supprimer
                            </button>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}

function showProductModal(productId = null) {
    const modalEl = document.getElementById('productModal');
    if (!modalEl) return;

    // Clear all form fields manually (no form.reset() since we removed the form tag)
    document.getElementById('productId').value = '';
    document.getElementById('productName').value = '';
    document.getElementById('productDescription').value = '';
    document.getElementById('productIngredients').value = '';
    document.getElementById('productUsage').value = '';
    document.getElementById('productBasePrice').value = '';
    document.getElementById('productIsOrganic').checked = false;
    document.getElementById('productIsActive').checked = true;
    document.getElementById('productCategory').value = '';
    document.getElementById('productModalTitle').textContent = productId ? 'Modifier le Produit' : 'Nouveau Produit';
    document.getElementById('productImagesList').innerHTML = '';
    document.getElementById('productFormatsList').innerHTML = '';

    loadCategoriesForSelect();

    if (productId) {
        // BUGFIX: Show loading state before opening modal
        document.getElementById('productId').value = productId;

        callAdminWebMethod('GetProducts', { pageIndex: 1, pageSize: 1000, categoryId: '', status: '' }, function (response) {
            if (response.d && response.d.success) {
                // Find method should be robust to type differences (int vs string)
                const product = response.d.data.find(p => p.productId == productId);
                if (product) {
                    // Normalize property names to camelCase (handle both cases)
                    const normalizedProduct = {
                        productId: product.productId || product.ProductId,
                        name: product.name || product.Name || '',
                        description: product.description || product.Description || null,
                        ingredients: product.ingredients || product.Ingredients || null,
                        usage: product.usage || product.Usage || null,
                        basePrice: product.basePrice !== undefined ? product.basePrice : (product.BasePrice !== undefined ? product.BasePrice : 0),
                        isOrganic: product.isOrganic !== undefined ? product.isOrganic : (product.IsOrganic !== undefined ? product.IsOrganic : false),
                        isActive: product.isActive !== undefined ? product.isActive : (product.IsActive !== undefined ? product.IsActive : true),
                        categoryId: product.categoryId || product.CategoryId || null,
                        categoryName: product.categoryName || product.CategoryName || null,
                        images: product.images || product.Images || [],
                        formats: product.formats || product.Formats || []
                    };

                    console.log('Filling form with normalized product:', normalizedProduct);
                    console.log('Product data:', {
                        name: normalizedProduct.name,
                        description: normalizedProduct.description,
                        ingredients: normalizedProduct.ingredients,
                        usage: normalizedProduct.usage,
                        basePrice: normalizedProduct.basePrice,
                        isOrganic: normalizedProduct.isOrganic,
                        categoryId: normalizedProduct.categoryId
                    });

                    // Set productId in hidden field
                    document.getElementById('productId').value = normalizedProduct.productId || '';
                    // Fill Form - Handle null/undefined properly
                    document.getElementById('productName').value = normalizedProduct.name || '';
                    document.getElementById('productDescription').value = (normalizedProduct.description != null && normalizedProduct.description !== undefined) ? normalizedProduct.description : '';
                    document.getElementById('productIngredients').value = (normalizedProduct.ingredients != null && normalizedProduct.ingredients !== undefined) ? normalizedProduct.ingredients : '';
                    document.getElementById('productUsage').value = (normalizedProduct.usage != null && normalizedProduct.usage !== undefined) ? normalizedProduct.usage : '';
                    document.getElementById('productBasePrice').value = (normalizedProduct.basePrice != null && normalizedProduct.basePrice !== undefined) ? normalizedProduct.basePrice : 0;
                    document.getElementById('productIsOrganic').checked = normalizedProduct.isOrganic === true || normalizedProduct.isOrganic === 1 || normalizedProduct.isOrganic === "true";
                    document.getElementById('productIsActive').checked = normalizedProduct.isActive !== undefined ? (normalizedProduct.isActive === true || normalizedProduct.isActive === 1 || normalizedProduct.isActive === "true") : true;

                    const catSelect = document.getElementById('productCategory');
                    if (catSelect) {
                        // Wait a bit for categories to load if needed, or simple set
                        setTimeout(() => {
                            catSelect.value = normalizedProduct.categoryId || '';
                            console.log('Category set to:', normalizedProduct.categoryId);
                        }, 300);
                    }

                    if (normalizedProduct.images && normalizedProduct.images.length > 0) {
                        normalizedProduct.images.forEach(img => {
                            const imgId = img.imageId || img.ImageId;
                            const imgUrl = img.imageUrl || img.ImageUrl;
                            const isMain = img.isMain !== undefined ? img.isMain : (img.IsMain !== undefined ? img.IsMain : false);
                            addImageRow(imgId, imgUrl, isMain);
                        });
                    }
                    if (normalizedProduct.formats && normalizedProduct.formats.length > 0) {
                        normalizedProduct.formats.forEach(f => {
                            const formatId = f.formatId || f.FormatId;
                            const label = f.label || f.Label || '';
                            const price = f.price !== undefined ? f.price : (f.Price !== undefined ? f.Price : '');
                            const stock = f.stock !== undefined ? f.stock : (f.Stock !== undefined ? f.Stock : '');
                            const stockMin = f.stockMin !== undefined ? f.stockMin : (f.StockMin !== undefined ? f.StockMin : '');
                            const expirationDate = f.expirationDate || f.ExpirationDate || '';
                            addFormatRow(formatId, label, price, stock, stockMin, expirationDate);
                        });
                    } else {
                        // Add at least one format row if none exists
                        addFormatRow();
                    }

                    // BUGFIX: Open modal AFTER data is loaded and filled
                    setTimeout(() => {
                        $(modalEl).modal('show');
                        // Bootstrap handles overflow automatically with modal-open class
                    }, 350); // Wait for category select to be set
                } else {
                    console.error('Product not found:', productId);
                    if (window.adminNotifications) {
                        adminNotifications.error('Produit non trouvé');
                    } else {
                        alert('Produit non trouvé');
                    }
                }
            } else {
                console.error('Error loading products:', response);
                if (window.adminNotifications) {
                    adminNotifications.error('Erreur lors du chargement du produit');
                } else {
                    alert('Erreur lors du chargement du produit');
                }
            }
        });
    } else {
        // New product - add empty format row
        addFormatRow();

        // Open modal immediately for new product
        $(modalEl).modal('show');
        // Bootstrap handles overflow automatically with modal-open class
    }
}

function closeProductModal() {
    $('#productModal').modal('hide');
    // Bootstrap will remove modal-open class automatically
}

function addProductImage() {
    const url = document.getElementById('newImageUrl').value;
    if (url) {
        addImageRow(null, url, false);
        document.getElementById('newImageUrl').value = '';
    }
}

function addImageRow(imageId, url, isMain) {
    const container = document.getElementById('productImagesList');
    const div = document.createElement('div');
    div.className = 'd-flex align-items-center gap-2 p-2 bg-white rounded border';
    div.innerHTML = `
        <div style="width:40px;height:40px;" class="bg-light rounded d-flex align-items-center justify-content-center flex-shrink-0 overflow-hidden">
             <img src="${normalizeImageUrl(url)}" class="w-100 h-100 object-fit-cover" onerror="this.style.display='none'">
        </div>
        <input type="text" value="${url}" class="form-control form-control-sm border-0 bg-transparent" readonly data-image-url>
        <div class="form-check form-switch ms-auto">
            <input class="form-check-input" type="checkbox" ${isMain ? 'checked' : ''} data-image-main>
        </div>
        <button type="button" onclick="this.closest('div').remove()" class="btn btn-sm btn-outline-danger border-0">×</button>
        <input type="hidden" value="${imageId || ''}" data-image-id>
    `;
    container.appendChild(div);
}

function addProductFormat() {
    addFormatRow();
}

function addFormatRow(formatId = null, label = '', price = '', stock = '', stockMin = '', expirationDate = '') {
    const container = document.getElementById('productFormatsList');
    const div = document.createElement('div');
    div.className = 'row g-2 p-2 border-bottom';
    div.innerHTML = `
        <div class="col-3">
             <input type="text" placeholder="Format" value="${label}" class="form-control form-control-sm border-0 bg-white" data-format-label required>
        </div>
        <div class="col-2">
             <input type="number" step="0.01" placeholder="Prix" value="${price}" class="form-control form-control-sm border-0 bg-white" data-format-price required>
        </div>
        <div class="col-2">
             <input type="number" placeholder="Stock" value="${stock}" class="form-control form-control-sm border-0 bg-white" data-format-stock>
        </div>
        <div class="col-2">
             <input type="number" placeholder="Min" value="${stockMin}" class="form-control form-control-sm border-0 bg-white" data-format-stock-min>
        </div>
       
        <div class="col-3 d-flex gap-1">
             <input type="date" value="${expirationDate ? expirationDate.split('T')[0] : ''}" class="form-control form-control-sm border-0 bg-white" data-format-expiration>
             <button type="button" onclick="this.closest('.row').remove()" class="btn btn-sm btn-link text-danger p-0">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
             </button>
        </div>
        <input type="hidden" value="${formatId || ''}" data-format-id>
    `;
    container.appendChild(div);
}

// Logic for Save Product
let isSavingProduct = false;
function saveProduct() {
    if (isSavingProduct) return;

    const saveBtn = document.getElementById('saveProductBtn');
    const originalText = saveBtn.textContent;

    // Gather Data
    const productId = document.getElementById('productId').value;
    const categoryId = document.getElementById('productCategory').value;
    const name = document.getElementById('productName').value;
    const basePriceStr = document.getElementById('productBasePrice').value;
    const basePrice = parseFloat(basePriceStr);

    if (!name) {
        if (window.adminNotifications) {
            adminNotifications.warning('Le nom du produit est requis.');
        } else {
            alert('Le nom du produit est requis.');
        }
        return;
    }
    if (isNaN(basePrice) || basePrice <= 0) {
        if (window.adminNotifications) {
            adminNotifications.warning('Veuillez saisir un prix de base valide.');
        } else {
            alert('Veuillez saisir un prix de base valide.');
        }
        return;
    }

    isSavingProduct = true;
    saveBtn.disabled = true;
    saveBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Enregistrement...';

    const images = [];
    document.querySelectorAll('#productImagesList > div').forEach(row => {
        const urlInput = row.querySelector('[data-image-url]');
        const idInput = row.querySelector('[data-image-id]');
        const mainInput = row.querySelector('[data-image-main]');

        if (urlInput && urlInput.value) {
            images.push({
                imageId: idInput ? (idInput.value || null) : null,
                imageUrl: urlInput.value,
                isMain: mainInput ? mainInput.checked : false
            });
        }
    });

    const formats = [];
    let formatsValid = true;
    document.querySelectorAll('#productFormatsList > .row').forEach(row => {
        const lbl = row.querySelector('[data-format-label]').value;
        const prc = parseFloat(row.querySelector('[data-format-price]').value);
        const exp = row.querySelector('[data-format-expiration]').value || null;
        const fid = row.querySelector('[data-format-id]').value || null;

        if (lbl && !isNaN(prc)) {
            formats.push({
                formatId: fid,
                label: lbl,
                price: prc,
                stock: parseInt(row.querySelector('[data-format-stock]').value) || 0,
                stockMin: parseInt(row.querySelector('[data-format-stock-min]').value) || 0,
                expirationDate: exp
            });
        } else if (lbl || !isNaN(prc)) {
            formatsValid = false;
        }
    });

    if (!formatsValid) {
        if (window.adminNotifications) {
            adminNotifications.warning('Veuillez remplir correctement tous les champs des formats ajoutés (Libellé, Prix, Stock).');
        } else {
            alert('Veuillez remplir correctement tous les champs des formats ajoutés (Libellé, Prix, Stock).');
        }
        isSavingProduct = false;
        saveBtn.disabled = false;
        saveBtn.textContent = originalText;
        return;
    }

    const params = {
        productId: productId || null,
        categoryId: categoryId || null,
        name: name,
        description: document.getElementById('productDescription').value,
        ingredients: document.getElementById('productIngredients').value,
        usage: document.getElementById('productUsage').value,
        basePrice: basePrice,
        isOrganic: document.getElementById('productIsOrganic').checked,
        isActive: document.getElementById('productIsActive').checked,
        imagesJson: JSON.stringify(images),
        formatsJson: JSON.stringify(formats)
    };

    callAdminWebMethod('SaveProduct', params, function (response) {
        isSavingProduct = false;
        saveBtn.disabled = false;
        saveBtn.textContent = originalText;

        if (response.d && response.d.success) {
            if (window.adminNotifications) {
                adminNotifications.success('Produit enregistré avec succès !');
            } else {
                alert('Produit enregistré avec succès !');
            }
            closeProductModal();
            loadProducts();
            // Refresh dashboard metrics too
            if (typeof loadDashboardMetrics === 'function') loadDashboardMetrics();
        } else {
            if (window.adminNotifications) {
                adminNotifications.error('Erreur: ' + (response.d?.message || 'Une erreur est survenue lors de la sauvegarde.'));
            } else {
                alert('Erreur: ' + (response.d?.message || 'Une erreur est survenue lors de la sauvegarde.'));
            }
        }
    });
}

function editProduct(id) {
    showProductModal(id);
    return false;
}

function viewProductDetails(productId) {
    console.log('viewProductDetails called with productId:', productId);
    callAdminWebMethod('GetProducts', { pageIndex: 1, pageSize: 1000, categoryId: '', status: '' }, function (response) {
        console.log('GetProducts response:', response);
        if (response.d && response.d.success) {
            // Try both camelCase and PascalCase property names
            const product = response.d.data.find(p =>
                p.productId == productId ||
                p.ProductId == productId ||
                (p.productId && p.productId.toString() === productId.toString()) ||
                (p.ProductId && p.ProductId.toString() === productId.toString())
            );
            console.log('Found product:', product);
            console.log('All product keys:', product ? Object.keys(product) : []);
            console.log('Product fields:', {
                name: product?.name || product?.Name,
                description: product?.description || product?.Description,
                ingredients: product?.ingredients || product?.Ingredients,
                usage: product?.usage || product?.Usage,
                basePrice: product?.basePrice || product?.BasePrice,
                isOrganic: product?.isOrganic || product?.IsOrganic,
                categoryId: product?.categoryId || product?.CategoryId
            });
            if (product) {
                // Normalize property names to camelCase
                const normalizedProduct = {
                    productId: product.productId || product.ProductId,
                    name: product.name || product.Name,
                    description: product.description || product.Description,
                    ingredients: product.ingredients || product.Ingredients,
                    usage: product.usage || product.Usage,
                    basePrice: product.basePrice || product.BasePrice,
                    isOrganic: product.isOrganic !== undefined ? product.isOrganic : (product.IsOrganic !== undefined ? product.IsOrganic : false),
                    isActive: product.isActive !== undefined ? product.isActive : (product.IsActive !== undefined ? product.IsActive : true),
                    categoryId: product.categoryId || product.CategoryId,
                    categoryName: product.categoryName || product.CategoryName,
                    images: product.images || product.Images || [],
                    formats: product.formats || product.Formats || []
                };
                console.log('Normalized product:', normalizedProduct);
                displayProductDetails(normalizedProduct);
            } else {
                console.error('Product not found:', productId);
                if (window.adminNotifications) {
                    adminNotifications.error('Produit non trouvé');
                } else {
                    alert('Produit non trouvé');
                }
            }
        } else {
            console.error('Error loading products:', response);
            if (window.adminNotifications) {
                adminNotifications.error('Erreur lors du chargement des produits');
            } else {
                alert('Erreur lors du chargement des produits');
            }
        }
    });
    return false;
}

function displayProductDetails(product) {
    // Get main image
    const mainImage = product.images && product.images.length > 0
        ? product.images.find(img => img.isMain) || product.images[0]
        : null;
    const imageUrl = mainImage ? normalizeImageUrl(mainImage.imageUrl) : getPlaceholderImage();

    // Build formats HTML
    const formatsHtml = product.formats && product.formats.length > 0
        ? product.formats.map(f => `
            <div class="d-flex justify-content-between align-items-center p-3 bg-light rounded mb-2">
                <div>
                    <strong>${f.label || 'N/A'}</strong>
                    <div class="text-muted small">Stock: ${f.stock || 0} | Min: ${f.stockMin || 0}</div>
                    ${f.expirationDate ? `<div class="text-muted small">Expiration: ${new Date(f.expirationDate).toLocaleDateString('fr-FR')}</div>` : ''}
                </div>
                <div class="text-primary-custom fw-bold">${formatPrice(f.price || 0)}</div>
            </div>
        `).join('')
        : '<p class="text-muted">Aucun format disponible</p>';

    // Build images HTML
    const imagesHtml = product.images && product.images.length > 0
        ? product.images.map(img => `
            <div class="col-6 col-md-4 mb-2 position-relative">
                <img src="${normalizeImageUrl(img.imageUrl)}" class="img-fluid rounded" style="height: 100px; object-fit: cover; width: 100%;" onerror="this.src='${getPlaceholderImage()}'">
                ${img.isMain ? '<span class="badge bg-success position-absolute top-0 start-0 m-1">Principal</span>' : ''}
            </div>
        `).join('')
        : '<p class="text-muted">Aucune image disponible</p>';

    // Populate modal - check if elements exist
    console.log('Populating modal elements...');
    const nameEl = document.getElementById('productDetailsName');
    if (!nameEl) {
        console.error('Modal elements not found');
        if (window.adminNotifications) {
            adminNotifications.error('Erreur: Les éléments de la modal ne sont pas trouvés');
        } else {
            alert('Erreur: Les éléments de la modal ne sont pas trouvés');
        }
        return;
    }

    nameEl.textContent = product.name || 'N/A';
    const categoryEl = document.getElementById('productDetailsCategory');
    const descEl = document.getElementById('productDetailsDescription');
    const ingredientsEl = document.getElementById('productDetailsIngredients');
    const usageEl = document.getElementById('productDetailsUsage');
    const priceEl = document.getElementById('productDetailsBasePrice');
    const organicEl = document.getElementById('productDetailsIsOrganic');
    const activeEl = document.getElementById('productDetailsIsActive');
    const imageEl = document.getElementById('productDetailsMainImage');
    const formatsEl = document.getElementById('productDetailsFormats');
    const imagesEl = document.getElementById('productDetailsImages');

    console.log('Displaying product details:', product);
    console.log('Product values:', {
        ingredients: product.ingredients,
        usage: product.usage,
        basePrice: product.basePrice,
        isOrganic: product.isOrganic
    });

    if (categoryEl) categoryEl.textContent = (product.categoryName != null && product.categoryName !== undefined && product.categoryName !== '') ? product.categoryName : 'Aucune catégorie';
    if (descEl) descEl.textContent = (product.description != null && product.description !== undefined && product.description !== '' && product.description.trim() !== '') ? product.description : 'Aucune description';
    if (ingredientsEl) {
        const ingredientsValue = (product.ingredients != null && product.ingredients !== undefined && product.ingredients !== '') ? product.ingredients : null;
        ingredientsEl.textContent = (ingredientsValue && ingredientsValue.trim() !== '') ? ingredientsValue : 'Non spécifié';
    }
    if (usageEl) {
        const usageValue = (product.usage != null && product.usage !== undefined && product.usage !== '') ? product.usage : null;
        usageEl.textContent = (usageValue && usageValue.trim() !== '') ? usageValue : 'Non spécifié';
    }
    if (priceEl) priceEl.textContent = formatPrice((product.basePrice != null && product.basePrice !== undefined) ? product.basePrice : 0);
    if (organicEl) {
        const isOrganic = product.isOrganic === true || product.isOrganic === 1 || product.isOrganic === "true";
        organicEl.innerHTML = isOrganic
            ? '<span class="badge bg-success">🌱 Bio</span>'
            : '<span class="badge bg-secondary">Non bio</span>';
    }
    if (activeEl) {
        const isActive = product.isActive === true || product.isActive === 1 || product.isActive === "true";
        activeEl.innerHTML = isActive
            ? '<span class="badge bg-success">Actif</span>'
            : '<span class="badge bg-danger">Inactif</span>';
    }
    if (imageEl) imageEl.src = imageUrl;
    if (formatsEl) formatsEl.innerHTML = formatsHtml;
    if (imagesEl) imagesEl.innerHTML = imagesHtml;

    // Show modal using Bootstrap
    const modalElement = document.getElementById('productDetailsModal');
    if (modalElement) {
        console.log('Modal element found, showing...');
        // Check if Bootstrap is available
        if (typeof bootstrap !== 'undefined' && bootstrap.Modal) {
            console.log('Using Bootstrap 5 Modal');
            const modal = new bootstrap.Modal(modalElement);
            modal.show();
        } else if (typeof jQuery !== 'undefined' && jQuery(modalElement).modal) {
            console.log('Using jQuery Bootstrap Modal');
            jQuery(modalElement).modal('show');
        } else {
            console.error('Bootstrap modal not available');
            if (window.adminNotifications) {
                adminNotifications.error('Erreur: Impossible d\'afficher la modal');
            } else {
                alert('Erreur: Impossible d\'afficher la modal');
            }
        }
    } else {
        console.error('Product details modal not found');
        if (window.adminNotifications) {
            adminNotifications.error('Erreur: La modal de détails produit n\'est pas trouvée');
        } else {
            alert('Erreur: La modal de détails produit n\'est pas trouvée');
        }
    }
}

function deleteProduct(id) {
    if (window.adminConfirm) {
        adminConfirm.show('Supprimer ce produit ?', function () {
            callAdminWebMethod('DeleteProduct', { productId: id }, function (res) {
                if (res.d && res.d.success) {
                    if (window.adminNotifications) {
                        adminNotifications.success('Produit supprimé avec succès');
                    }
                    loadProducts();
                } else {
                    if (window.adminNotifications) {
                        adminNotifications.error('Erreur lors de la suppression');
                    } else {
                        alert('Erreur suppression');
                    }
                }
            });
        });
    } else {
        if (confirm('Supprimer ce produit ?')) {
            callAdminWebMethod('DeleteProduct', { productId: id }, function (res) {
                if (res.d && res.d.success) loadProducts();
                else alert('Erreur suppression');
            });
        }
    }
    return false;
}

function loadCategoriesForSelect() {
    callAdminWebMethod('GetCategories', {}, function (res) {
        if (res.d && res.d.success) {
            const select = document.getElementById('productCategory');
            const val = select.value;
            select.innerHTML = '<option value="">Aucune</option>' + res.d.data.map(c => `<option value="${c.categoryId}">${c.name}</option>`).join('');
            select.value = val;
        }
    });
}


// Orders
let currentOrderStatus = 'Toutes';
function initOrderEvents() {
    $(document).on('click', '.order-tab', function () {
        const status = $(this).data('status');
        $('.order-tab').removeClass('border-secondary-custom text-secondary-custom').addClass('border-transparent text-muted');
        $(this).removeClass('border-transparent text-muted').addClass('border-secondary-custom text-secondary-custom');
        currentOrderStatus = status;
        paginationState.orders.page = 1; // Reset page
        loadOrders(status, $('#orderSearch').val());
    });

    $('#orderSearch').on('input', function () {
        paginationState.orders.page = 1; // Reset page
        loadOrders(currentOrderStatus, $(this).val());
    });
}

function loadOrders(status = 'Toutes', search = '') {
    const { page, pageSize } = paginationState.orders;
    // Reset page if filters changed (handled by caller usually, but let's be safe if needed)
    // Actually simpler to just use current state

    callAdminWebMethod('GetOrders', { statusFilter: status, searchTerm: search, pageIndex: page, pageSize: pageSize }, function (res) {
        if (res.d && res.d.success) {
            paginationState.orders.total = (res.d.totalCount !== undefined) ? res.d.totalCount : res.d.data.length;
            console.log('Orders loaded, total:', paginationState.orders.total);
            displayOrders(res.d.data);
            renderPagination('orders');
        }
    });
}

function displayOrders(orders) {
    const list = document.getElementById('ordersList');
    if (!orders || orders.length === 0) {
        list.innerHTML = '<tr><td colspan="6" class="text-center py-5 text-muted">Aucune commande</td></tr>';
        return;
    }

    const statusBadges = {
        'Validée': 'bg-warning text-dark',
        'En préparation': 'bg-info text-dark',
        'Expédiée': 'bg-primary text-white',
        'Livrée': 'bg-success text-white',
        'Annulée': 'bg-danger text-white'
    };

    list.innerHTML = orders.map(o => {
        const isCancelled = o.status === 'Annulée';
        const cancellationInfo = isCancelled && o.cancellationReason ?
            `<div class="mt-2 p-2 rounded bg-danger bg-opacity-10 border-start border-danger border-3">
                <div class="small fw-semibold text-danger mb-1">Motif d'annulation:</div>
                <div class="small text-dark">${o.cancellationReason}</div>
                ${o.cancelledAt ? `<div class="small text-muted mt-1"><i>Annulée le: ${o.cancelledAt}</i></div>` : ''}
            </div>` : '';

        return `
        <tr class="align-middle">
            <td class="fw-bold">#${o.orderId}</td>
            <td>
                <div class="fw-medium">${o.customerName}</div>
                ${cancellationInfo}
            </td>
            <td class="text-muted small">${o.createdAt}</td>
            <td class="fw-bold text-primary-custom">${formatPrice(o.totalTTC)}</td>
            <td><span class="badge ${statusBadges[o.status] || 'bg-secondary'} rounded-pill">${o.status}</span></td>
            <td class="text-end">
                <button type="button" onclick="viewOrderDetails(${o.orderId}); return false;" class="btn btn-sm btn-light text-secondary-custom fw-bold">Détails</button>
            </td>
        </tr>
        `;
    }).join('');
}

let currentOrderData = null;
function viewOrderDetails(id) {
    callAdminWebMethod('GetOrderDetails', { orderId: id }, function (res) {
        if (res.d && res.d.success) {
            currentOrderData = res.d.data;
            displayOrderDetails(res.d.data);
            currentOrderData = res.d.data;
            displayOrderDetails(res.d.data);
            $('#orderModal').modal('show');
        }
    });
}
function closeOrderModal() { $('#orderModal').modal('hide'); }

function displayOrderDetails(order) {
    document.getElementById('orderModalTitle').textContent = `Commande #${order.orderId}`;
    document.getElementById('orderDetailStatus').textContent = order.status;
    document.getElementById('updateStatusSelect').value = order.status;

    // Cancellation info
    const cancellationInfo = document.getElementById('orderCancellationInfo');
    if (order.status === 'Annulée' && order.cancellationReason) {
        cancellationInfo.classList.remove('d-none');
        document.getElementById('orderCancellationReason').textContent = order.cancellationReason;
        if (order.cancelledAt) {
            document.getElementById('orderCancelledAt').textContent = `Annulée le: ${order.cancelledAt}`;
        } else {
            document.getElementById('orderCancelledAt').textContent = '';
        }
    } else {
        cancellationInfo.classList.add('d-none');
    }

    // Customer
    if (order.customer) {
        document.getElementById('orderCustomerName').textContent = order.customer.name;
        document.getElementById('orderCustomerEmail').textContent = order.customer.email;
        document.getElementById('orderCustomerPhone').textContent = order.customer.phone;
    }

    // Shipping Information - BUG FIX: Was missing!
    if (order.shipping) {
        document.getElementById('orderRecipientName').textContent = order.shipping.recipient || 'Non spécifié';
        document.getElementById('orderShippingAddress').textContent = order.shipping.address || 'Non spécifié';
        document.getElementById('orderShippingZip').textContent = order.shipping.zip || '';
        document.getElementById('orderShippingCity').textContent = order.shipping.city || '';
    }

    // Items
    document.getElementById('orderItemsList').innerHTML = order.items.map(i => `
        <tr>
            <td>
                <div class="d-flex align-items-center gap-2">
                    <img src="${normalizeImageUrl(i.imageUrl)}" class="rounded" style="width:30px;height:30px;object-fit:cover;">
                    <span>${i.productName}</span>
                    </div>
                </td>
            <td>${i.formatLabel}</td>
            <td class="text-center">${i.quantity}</td>
            <td class="text-end text-muted">${formatPrice(i.unitPrice)}</td>
            <td class="text-end fw-bold">${formatPrice(i.unitPrice * i.quantity)}</td>
            </tr>
        `).join('');

    document.getElementById('orderSubtotal').textContent = formatPrice(order.totalHT);
    document.getElementById('orderShippingFee').textContent = formatPrice(order.deliveryFee);
    document.getElementById('orderTotal').textContent = formatPrice(order.totalTTC);
    document.getElementById('orderTrackingNumber').value = order.trackingNumber || '';
}

function updateOrderStatusFunc() {
    if (!currentOrderData) return;
    const status = document.getElementById('updateStatusSelect').value;
    const tracking = document.getElementById('orderTrackingNumber').value;
    callAdminWebMethod('UpdateOrderStatus', { orderId: currentOrderData.orderId, status: status, trackingNumber: tracking }, function (res) {
        if (res.d && res.d.success) {
            if (window.adminNotifications) {
                adminNotifications.success('Statut de commande mis à jour avec succès !');
            } else {
                alert('Mis à jour !');
            }
            viewOrderDetails(currentOrderData.orderId);
            loadOrders(currentOrderStatus);
        } else {
            if (window.adminNotifications) {
                adminNotifications.error('Erreur lors de la mise à jour: ' + (res.d?.message || 'Erreur inconnue'));
            }
        }
    });
}

function saveTracking() { updateOrderStatusFunc(); }


// Customers
let currentCustomerStatusFilter = ''; // '', 'true', 'false'

function initCustomerEvents() {
    $('#customerSearch').on('input', function () {
        paginationState.customers.page = 1; // Reset page
        loadCustomers($(this).val());
    });

    // Status filter tabs
    $(document).on('click', '.customer-status-tab', function () {
        const status = $(this).data('status').toString();
        $('.customer-status-tab').removeClass('border-secondary-custom text-secondary-custom').addClass('border-transparent text-muted');
        $(this).removeClass('border-transparent text-muted').addClass('border-secondary-custom text-secondary-custom');
        currentCustomerStatusFilter = status;
        paginationState.customers.page = 1;
        loadCustomers($('#customerSearch').val());
    });
}

function loadCustomers(search = '') {
    const { page, pageSize } = paginationState.customers;
    const statusFilter = currentCustomerStatusFilter || "";

    callAdminWebMethod('GetCustomers', {
        searchTerm: search,
        statusFilter: statusFilter,
        pageIndex: page,
        pageSize: pageSize
    }, function (res) {
        if (res.d && res.d.success) {
            // Plus besoin de filtrer côté client - le serveur le fait déjà !
            paginationState.customers.total = (res.d.totalCount !== undefined) ? res.d.totalCount : res.d.data.length;
            console.log('Customers loaded, total:', paginationState.customers.total);
            const list = document.getElementById('customersList');
            if (!res.d.data.length && paginationState.customers.page === 1) {
                list.innerHTML = '<tr><td colspan="6" class="text-center py-5">Aucun client</td></tr>';
                renderPagination('customers');
                return;
            }
            displayCustomers(res.d.data);
            renderPagination('customers');
        }
    });
}

function displayCustomers(customers) {
    const list = document.getElementById('customersList');
    if (!customers || customers.length === 0) {
        // If empty but page > 1, maybe we should go back? Handled by rendering logic mostly
        if (paginationState.customers.page > 1) {
            // list.innerHTML = '<tr><td colspan="6" class="text-center py-5">Page vide</td></tr>';
        } else {
            list.innerHTML = '<tr><td colspan="6" class="text-center py-5">Aucun client</td></tr>';
        }
        return;
    }

    // ... rest of display logic (moved out of inline for clarity if needed, but here simple replacement)
    // Re-verify Step 6 code, display logic was inline. I need to keep it inline or extract it.
    // The previous code had it inline inside successful callback. Let's keep structure but since I replaced `loadCustomers` block completely...
    // I need to provide `displayCustomers` or inline it back.
    // The snippet below is NOT full replacement, only `loadCustomers`. 
    // Wait, original `loadCustomers` had inline display logic. I should probably separate it or include it.
    // I will use a separate function `displayCustomers` to align with others pattern.

    list.innerHTML = customers.map(c => `
                <tr class="align-middle">
                    <td>
                        <div class="d-flex align-items-center gap-2">
                            <div class="rounded-circle bg-light d-flex align-items-center justify-content-center text-primary-custom fw-bold" style="width:32px;height:32px;">
                                ${c.fullName ? c.fullName[0] : '?'}
                        </div>
                            <span class="fw-medium">${c.fullName}</span>
                    </div>
                </td>
                    <td>${c.email}</td>
                    <td>${c.phone || '--'}</td>
                    <td class="text-center">${c.orderCount}</td>
                    <td class="text-end fw-bold text-success">${formatPrice(c.totalSpent)}</td>
                    <td class="text-center">
                        <button type="button" onclick="toggleCustomerStatus(${c.id}, ${!c.isActive}); return false;" class="btn btn-sm ${c.isActive ? 'btn-outline-danger' : 'btn-outline-success'} rounded-pill px-3">
                            ${c.isActive ? 'Bloquer' : 'Activer'}
                    </button>
                </td>
            </tr>
        `).join('');
}

function toggleCustomerStatus(id, isActive) {
    const action = isActive ? "activer" : "bloquer";
    const actionPast = isActive ? "activé" : "bloqué";

    if (window.adminConfirm) {
        adminConfirm.show(`Voulez-vous vraiment ${action} ce client ?`, function () {
            callAdminWebMethod('ToggleCustomerStatus', { userId: id, isActive: isActive }, function (res) {
                if (res.d && res.d.success) {
                    if (window.adminNotifications) {
                        adminNotifications.success(`Client ${actionPast} avec succès`);
                    }
                    loadCustomers($('#customerSearch').val());
                } else {
                    if (window.adminNotifications) {
                        adminNotifications.error('Erreur: ' + (res.d?.message || 'Une erreur est survenue'));
                    } else {
                        alert('Erreur: ' + (res.d?.message || 'Une erreur est survenue'));
                    }
                }
            });
        });
    } else {
        if (!confirm(`Voulez-vous vraiment ${action} ce client ?`)) return;
        callAdminWebMethod('ToggleCustomerStatus', { userId: id, isActive: isActive }, function (res) {
            if (res.d && res.d.success) {
                loadCustomers($('#customerSearch').val());
            } else {
                alert('Erreur: ' + (res.d?.message || 'Une erreur est survenue'));
            }
        });
    }
}


// Utils
function formatPrice(p) { return new Intl.NumberFormat('fr-MA', { style: 'currency', currency: 'MAD' }).format(p || 0); }
function normalizeImageUrl(url) {
    if (!url) return getPlaceholderImage();
    if (url.startsWith('http')) return url;
    if (url.startsWith('data:')) return url;

    // Handle ~/ path from ASP.NET
    if (url.startsWith('~/')) {
        url = url.substring(2);
    }

    // Ensure it starts with / to be relative to root
    if (!url.startsWith('/')) {
        // If it's a common path like Images/ it doesn't need prefix
        if (!url.toLowerCase().startsWith('images/')) {
            url = '/Images/Products/' + url;
        } else {
            url = '/' + url;
        }
    }

    return url;
}

function getPlaceholderImage() {
    return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300";
}

// Pagination Logic
function changePage(section, delta) {
    const state = paginationState[section];
    const totalNum = parseInt(state.total) || 0;
    const maxPage = Math.ceil(totalNum / state.pageSize);
    const newPage = state.page + delta;

    if (newPage >= 1 && newPage <= maxPage) {
        paginationState[section].page = newPage;
        loadDataForSection(section);
    }
}

function loadDataForSection(section) {
    if (section === 'products') loadProducts();
    else if (section === 'orders') {
        const search = $('#orderSearch').val() || '';
        loadOrders(currentOrderStatus || 'Toutes', search);
    }
    else if (section === 'customers') {
        const search = $('#customerSearch').val() || '';
        loadCustomers(search);
    }
}

function renderPagination(section) {
    const state = paginationState[section];
    const { page, pageSize, total } = state;
    const totalNum = parseInt(total) || 0;
    const maxPage = Math.max(1, Math.ceil(totalNum / pageSize));
    console.log(`Rendering pagination for ${section}: Page ${page}/${maxPage}, Total ${totalNum}`);

    // Update buttons
    $(`#${section}PrevBtn`).prop('disabled', page <= 1);
    $(`#${section}NextBtn`).prop('disabled', page >= maxPage);

    // Update Summary
    const start = (page - 1) * pageSize + 1;
    const end = Math.min(page * pageSize, total);
    let summaryText = "";
    if (total === 0) summaryText = "Aucun résultat";
    else summaryText = `${start}-${end} sur ${total}`;

    $(`#${section}Summary`).text(summaryText);

    // Page Numbers
    const container = document.getElementById(`${section}PageNumbers`);
    if (container) {
        container.innerHTML = `<span class="badge bg-light text-dark border">${page} / ${maxPage}</span>`;
    }
}

function callAdminWebMethod(method, params, cb) {
    console.log('callAdminWebMethod:', method, params);
    jQuery.ajax({
        type: 'POST',
        url: adminServiceUrl + '/' + method,
        data: JSON.stringify(params),
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            console.log('WebMethod success:', method, response);
            if (cb) cb(response);
        },
        error: function (xhr, status, error) {
            console.error('WebMethod error:', method, {
                status: status,
                error: error,
                responseText: xhr.responseText,
                statusCode: xhr.status
            });

            // Try to parse error response
            let errorMessage = 'Une erreur est survenue';
            try {
                if (xhr.responseText) {
                    const errorResponse = JSON.parse(xhr.responseText);
                    if (errorResponse.Message) {
                        errorMessage = errorResponse.Message;
                    }
                }
            } catch (e) {
                // If parsing fails, use default message
            }

            if (window.adminNotifications) {
                adminNotifications.error('Erreur ' + xhr.status + ': ' + errorMessage);
            } else {
                alert('Erreur ' + xhr.status + ': ' + errorMessage);
            }
            if (cb) cb({ d: { success: false, message: errorMessage } });
        }
    });
}

// Make global
window.loadOrders = loadOrders;
window.loadProducts = loadProducts;
window.saveProduct = saveProduct;
window.closeProductModal = closeProductModal;
window.showProductModal = showProductModal;
window.switchAdminTab = switchAdminTab;
window.updateOrderStatusFunc = updateOrderStatusFunc;
window.closeOrderModal = closeOrderModal;
window.addProductImage = addProductImage;
window.addProductFormat = addProductFormat;
window.toggleCustomerStatus = toggleCustomerStatus;
window.editProduct = editProduct;
window.deleteProduct = deleteProduct;
window.viewProductDetails = viewProductDetails;
window.viewOrderDetails = viewOrderDetails;  // CRITICAL: Export order details function
window.saveTracking = saveTracking;
