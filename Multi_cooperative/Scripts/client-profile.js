// Service URL
const serviceUrl = 'ClientProfileService.asmx';

// Wait for jQuery and DOM to be ready
function initClientProfile() {
    if (typeof jQuery === 'undefined') {
        setTimeout(initClientProfile, 100);
        return;
    }

    jQuery(document).ready(function ($) {
        // Initialize tabs
        const tabs = document.querySelectorAll('.profile-tab');
        tabs.forEach(tab => {
            tab.addEventListener('click', function () {
                const tabName = this.dataset.tab;
                switchTab(tabName);
            });
        });

        // Load initial data
        loadAddresses();

        // Load orders after a small delay to ensure DOM is ready
        setTimeout(function () {
            if (typeof loadOrders === 'function') {
                loadOrders();
            } else {
                console.error('loadOrders function not found');
            }
        }, 100);

        // Search and filter handlers for orders
        const searchOrder = document.getElementById('searchOrder');
        const filterOrderStatus = document.getElementById('filterOrderStatus');
        const filterOrderDate = document.getElementById('filterOrderDate');

        if (searchOrder) {
            searchOrder.addEventListener('input', debounce(function () {
                if (typeof loadOrders === 'function') {
                    loadOrders();
                }
            }, 300));
        }
        if (filterOrderStatus) {
            filterOrderStatus.addEventListener('change', function () {
                if (typeof loadOrders === 'function') {
                    loadOrders();
                }
            });
        }
        if (filterOrderDate) {
            filterOrderDate.addEventListener('change', function () {
                if (typeof loadOrders === 'function') {
                    loadOrders();
                }
            });
        }

        // Form handlers
        const addressForm = document.getElementById('addressForm');
        if (addressForm) {
            addressForm.addEventListener('submit', function (e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Address form submit event');
                saveAddress();
                return false;
            });
        }

        const cancelOrderForm = document.getElementById('cancelOrderForm');
        if (cancelOrderForm) {
            cancelOrderForm.addEventListener('submit', function (e) {
                e.preventDefault();
                confirmCancelOrder();
            });
        }
    });
}

// Start initialization
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initClientProfile);
} else {
    initClientProfile();
}

function switchTab(tabName) {
    // Update tab buttons
    document.querySelectorAll('.profile-tab').forEach(tab => {
        tab.classList.remove('active', 'bg-[#E8967D]', 'text-white');
        tab.classList.add('text-gray-700');
    });
    const activeTab = document.querySelector(`[data-tab="${tabName}"]`);
    if (activeTab) {
        activeTab.classList.add('active', 'bg-[#E8967D]', 'text-white');
        activeTab.classList.remove('text-gray-700');
    }

    // Show/hide tab content
    document.querySelectorAll('.profile-tab-content').forEach(content => {
        content.classList.add('hidden');
    });
    const activeContent = document.getElementById(tabName + 'Tab');
    if (activeContent) {
        activeContent.classList.remove('hidden');
    }
}

// Orders Functions with filters
function loadOrders() {
    const search = document.getElementById('searchOrder')?.value || '';
    const status = document.getElementById('filterOrderStatus')?.value || '';
    const dateFilter = document.getElementById('filterOrderDate')?.value || '';

    console.log('Loading orders with filters:', { search, status, dateFilter });

    callWebMethod('GetOrders', {}, function (response) {
        if (response.d && response.d.success) {
            let orders = response.d.data || [];
            console.log('Total orders before filter:', orders.length);

            // Apply filters
            if (search) {
                const searchLower = search.toLowerCase();
                orders = orders.filter(o =>
                    o.orderId.toString().toLowerCase().includes(searchLower) ||
                    (o.trackingNumber && o.trackingNumber.toLowerCase().includes(searchLower))
                );
                console.log('After search filter:', orders.length);
            }
            if (status) {
                orders = orders.filter(o => o.status === status);
                console.log('After status filter:', orders.length);
            }
            if (dateFilter) {
                const now = new Date();
                let startDate = new Date();
                switch (dateFilter) {
                    case 'week':
                        startDate.setDate(now.getDate() - 7);
                        break;
                    case 'month':
                        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                        break;
                    case 'year':
                        startDate = new Date(now.getFullYear(), 0, 1);
                        break;
                }
                orders = orders.filter(o => {
                    try {
                        // Try different date formats
                        let orderDate;
                        if (o.createdAt && o.createdAt.includes('/')) {
                            const parts = o.createdAt.split(' ')[0].split('/');
                            orderDate = new Date(parts[2], parts[1] - 1, parts[0]);
                        } else if (o.createdAt) {
                            orderDate = new Date(o.createdAt);
                        } else {
                            return true;
                        }
                        return orderDate >= startDate;
                    } catch (e) {
                        console.error('Date parsing error:', e);
                        return true; // Keep if date parsing fails
                    }
                });
                console.log('After date filter:', orders.length);
            }

            console.log('Final orders count:', orders.length);
            displayOrders(orders);
        } else {
            console.error('Error loading orders:', response.d?.message);
            const container = document.getElementById('ordersList');
            if (container) {
                container.innerHTML = '<p class="text-gray-600 text-center py-8">Erreur lors du chargement des commandes</p>';
            }
        }
    });
}

// Addresses Functions
function loadAddresses() {
    callWebMethod('GetAddresses', {}, function (response) {
        if (response.d && response.d.success) {
            displayAddresses(response.d.data);
        } else {
            console.error('Error loading addresses:', response.d?.message);
        }
    });
}

function displayAddresses(addresses) {
    const container = document.getElementById('addressesList');
    if (!container) return;

    if (addresses.length === 0) {
        container.innerHTML = `
            <div class="col-span-2 text-center py-12">
                <svg xmlns="http://www.w3.org/2000/svg" class="mx-auto h-16 w-16 text-gray-400 mb-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                <p class="text-gray-600 text-lg mb-2">Aucune adresse enregistrée</p>
                <p class="text-gray-500 text-sm">Ajoutez une adresse pour faciliter vos commandes</p>
            </div>
        `;
        return;
    }

    container.innerHTML = addresses.map(address => `
        <div class="bg-white border-2 ${address.isDefault ? 'border-[#E8967D] shadow-lg' : 'border-gray-200'} rounded-2xl p-5 hover:shadow-xl transition-all duration-300 transform hover:-translate-y-1" style="animation: fadeInUp 0.4s ease-out;">
            ${address.isDefault ? `
                <div class="inline-flex items-center gap-2 bg-gradient-to-r from-[#E8967D] to-[#d8856d] text-white text-xs font-semibold px-3 py-1.5 rounded-full mb-3 shadow-md">
                    <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                    Adresse par défaut
                </div>
            ` : ''}
            <div class="flex items-start gap-3 mb-4">
                <div class="bg-[#E8967D] bg-opacity-10 p-3 rounded-xl">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#E8967D" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                        <circle cx="12" cy="10" r="3"></circle>
                    </svg>
                </div>
                <div class="flex-1">
                    <h3 class="font-bold text-[#2D5F3F] text-lg mb-2">${address.fullName || 'N/A'}</h3>
                    <p class="text-gray-700 mb-2 flex items-start gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="mt-0.5 text-gray-500">
                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                            <circle cx="12" cy="10" r="3"></circle>
                        </svg>
                        <span>${address.addressLine || ''}</span>
                    </p>
                    <p class="text-gray-700 mb-2">${address.postalCode || ''} ${address.city || ''}</p>
                    <p class="text-gray-600 text-sm flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-500">
                            <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
                        </svg>
                        ${address.phone || 'N/A'}
                    </p>
                </div>
            </div>
            <div class="flex gap-2 pt-4 border-t border-gray-100">
                <button onclick="editAddress(${address.addressId}); return false;" class="flex-1 px-4 py-2.5 bg-blue-50 text-blue-600 rounded-xl hover:bg-blue-100 transition-colors font-medium text-sm flex items-center justify-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                    </svg>
                    Modifier
                </button>
                <button onclick="deleteAddress(${address.addressId}); return false;" class="flex-1 px-4 py-2.5 bg-red-50 text-red-600 rounded-xl hover:bg-red-100 transition-colors font-medium text-sm flex items-center justify-center gap-2">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                    </svg>
                    Supprimer
                </button>
            </div>
        </div>
    `).join('');
}

function showAddAddressModal() {
    const modal = document.getElementById('addressModal');
    if (!modal) return;

    document.getElementById('addressModalTitle').textContent = 'Ajouter une Adresse';
    document.getElementById('addressId').value = '';
    document.getElementById('addressFullName').value = '';
    document.getElementById('addressPhone').value = '';
    document.getElementById('addressCity').value = '';
    document.getElementById('addressLine').value = '';
    document.getElementById('addressPostalCode').value = '';
    document.getElementById('addressIsDefault').checked = false;

    modal.style.display = 'flex';
    modal.classList.remove('hidden');
}

function editAddress(addressId) {
    const modal = document.getElementById('addressModal');
    if (!modal) return;

    callWebMethod('GetAddresses', {}, function (response) {
        if (response.d && response.d.success) {
            const address = response.d.data.find(a => a.addressId == addressId);
            if (address) {
                document.getElementById('addressModalTitle').textContent = 'Modifier l\'Adresse';
                document.getElementById('addressId').value = address.addressId || '';
                document.getElementById('addressFullName').value = address.fullName || '';
                document.getElementById('addressPhone').value = address.phone || '';
                document.getElementById('addressCity').value = address.city || '';
                document.getElementById('addressLine').value = address.addressLine || '';
                document.getElementById('addressPostalCode').value = address.postalCode || '';
                document.getElementById('addressIsDefault').checked = address.isDefault || false;

                modal.style.display = 'flex';
                modal.classList.remove('hidden');
            }
        }
    });
    return false;
}

function closeAddressModal() {
    const modal = document.getElementById('addressModal');
    if (!modal) return;

    modal.style.display = 'none';
    modal.classList.add('hidden');
    modal.classList.remove('flex');

    // Reset form
    document.getElementById('addressId').value = '';
    document.getElementById('addressFullName').value = '';
    document.getElementById('addressPhone').value = '';
    document.getElementById('addressCity').value = '';
    document.getElementById('addressLine').value = '';
    document.getElementById('addressPostalCode').value = '';
    document.getElementById('addressIsDefault').checked = false;
}

function saveAddress() {
    console.log('saveAddress called');

    const addressIdEl = document.getElementById('addressId');
    const fullNameEl = document.getElementById('addressFullName');
    const phoneEl = document.getElementById('addressPhone');
    const cityEl = document.getElementById('addressCity');
    const addressLineEl = document.getElementById('addressLine');
    const postalCodeEl = document.getElementById('addressPostalCode');
    const isDefaultEl = document.getElementById('addressIsDefault');

    if (!addressIdEl || !fullNameEl || !phoneEl || !cityEl || !addressLineEl || !postalCodeEl || !isDefaultEl) {
        console.error('Form elements not found');
        alert('Erreur: Les champs du formulaire ne sont pas trouvés');
        return false;
    }

    const addressId = addressIdEl.value;
    const fullName = fullNameEl.value.trim();
    const phone = phoneEl.value.trim();
    const city = cityEl.value.trim();
    const addressLine = addressLineEl.value.trim();
    const postalCode = postalCodeEl.value.trim();
    const isDefault = isDefaultEl.checked;

    console.log('Form values:', { addressId, fullName, phone, city, addressLine, postalCode, isDefault });

    if (!fullName || !phone || !city || !addressLine || !postalCode) {
        alert('Veuillez remplir tous les champs obligatoires');
        return false;
    }

    console.log('Calling SaveAddress web method...');
    callWebMethod('SaveAddress', {
        addressId: addressId ? parseInt(addressId) : null,
        fullName: fullName,
        phone: phone,
        city: city,
        addressLine: addressLine,
        postalCode: postalCode,
        isDefault: isDefault
    }, function (response) {
        console.log('SaveAddress response:', response);
        if (response.d && response.d.success) {
            alert(response.d.message || 'Adresse enregistrée avec succès');
            closeAddressModal();
            loadAddresses();
        } else {
            alert('Erreur: ' + (response.d?.message || 'Erreur inconnue'));
        }
    });

    return false;
}

function deleteAddress(addressId) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cette adresse ?')) {
        return;
    }

    callWebMethod('DeleteAddress', { addressId }, function (response) {
        if (response.d && response.d.success) {
            alert(response.d.message);
            loadAddresses();
        } else {
            alert('Erreur: ' + (response.d?.message || 'Erreur inconnue'));
        }
    });
}

// Orders Functions - Cette fonction est définie plus haut avec les filtres

function displayOrders(orders) {
    const container = document.getElementById('ordersList');
    if (!container) return;

    if (orders.length === 0) {
        container.innerHTML = '<p class="text-gray-600 text-center py-8">Aucune commande trouvée</p>';
        return;
    }

    // Debug: Log orders data
    console.log('=== ORDERS DATA ===');
    console.log('Orders:', orders);
    orders.forEach((order, index) => {
        console.log(`Order ${index + 1}:`, {
            orderId: order.orderId,
            status: order.status,
            canCancel: order.canCancel,
            canCancelType: typeof order.canCancel
        });
    });

    container.innerHTML = orders.map(order => {
        const statusInfo = getStatusInfo(order.status);

        // Debug: Log each order's canCancel value
        console.log(`Order #${order.orderId}: status="${order.status}", canCancel=${order.canCancel}, type=${typeof order.canCancel}`);

        // Ensure canCancel is a boolean (handle string "true"/"false" from JSON)
        const canCancel = order.canCancel === true || order.canCancel === "true" || order.canCancel === 1;
        console.log(`Order #${order.orderId}: canCancel converted to boolean: ${canCancel}`);
        const estimatedDelivery = order.trackingNumber ?
            `Livraison estimée: ${calculateEstimatedDelivery(order.createdAt, order.shipping.estimatedDays)}` :
            '';

        return `
            <div class="bg-white border-2 border-gray-200 rounded-2xl p-6 shadow-md hover:shadow-xl transition-all duration-300 order-card">
                <div class="flex justify-between items-start mb-4">
                    <div>
                        <h3 class="text-lg font-semibold text-[#2D5F3F]">Commande #${order.orderId}</h3>
                        <p class="text-sm text-gray-600">${order.createdAt}</p>
                    </div>
                    <div class="flex items-center gap-2">
                        <span class="px-4 py-2 rounded-full text-sm font-semibold ${statusInfo.class} flex items-center gap-2 shadow-sm">
                            ${statusInfo.icon ? `<span>${statusInfo.icon}</span>` : ''}
                            ${order.status}
                        </span>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                    <div>
                        <h4 class="font-medium text-gray-700 mb-2">Adresse de livraison</h4>
                        <p class="text-sm text-gray-600">${order.address.fullName}</p>
                        <p class="text-sm text-gray-600">${order.address.addressLine}</p>
                        <p class="text-sm text-gray-600">${order.address.postalCode} ${order.address.city}</p>
                    </div>
                    <div>
                        <h4 class="font-medium text-gray-700 mb-2">Informations</h4>
                        <p class="text-sm text-gray-600">Méthode de paiement: ${order.paymentMethod}</p>
                        <p class="text-sm text-gray-600">Livraison: ${order.shipping.methodName}</p>
                        ${order.trackingNumber ? `<p class="text-sm text-gray-600">Suivi: <strong>${order.trackingNumber}</strong></p>` : ''}
                    </div>
                </div>

                <div class="mb-4">
                    <h4 class="font-semibold text-gray-800 mb-3 flex items-center gap-2">
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-[#E8967D]">
                            <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                            <line x1="3" y1="6" x2="21" y2="6"></line>
                            <path d="M16 10a4 4 0 0 1-8 0"></path>
                        </svg>
                        Articles
                    </h4>
                    <div class="space-y-2 bg-gray-50 rounded-xl p-4">
                        ${order.items.map(item => `
                            <div class="flex justify-between items-center py-2 px-3 bg-white rounded-lg shadow-sm">
                                <span class="text-sm text-gray-700">
                                    <span class="font-medium">${item.productName}</span>
                                    <span class="text-gray-500">(${item.format})</span>
                                    <span class="text-gray-400">x ${item.quantity}</span>
                                </span>
                                <span class="font-semibold text-[#2D5F3F]">${formatPrice(item.unitPrice * item.quantity)}</span>
                            </div>
                        `).join('')}
                    </div>
                </div>

                <div class="mb-4 pt-4 border-t border-gray-200">
                    <button onclick="toggleTracking(${order.orderId}); return false;" class="w-full flex justify-between items-center py-2 hover:bg-gray-50 rounded-lg transition-colors group px-2">
                        <h4 class="font-semibold text-gray-800 flex items-center gap-2">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-[#E8967D]">
                                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                            </svg>
                            Suivi de la commande
                        </h4>
                        <div id="chevron-${order.orderId}" class="transition-transform duration-300">
                            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-gray-400">
                                <polyline points="6 9 12 15 18 9"></polyline>
                            </svg>
                        </div>
                    </button>
                    <div id="tracking-content-${order.orderId}" class="max-h-0 overflow-hidden transition-all duration-300 ease-in-out" style="max-height: 0px;">
                        <div class="pt-4 space-y-3">
                            ${getOrderTrackingSteps(order)}
                        </div>
                    </div>
                </div>

                <div class="flex justify-between items-center pt-4 border-t border-gray-200">
                    <div>
                        <p class="text-sm text-gray-600">Total TTC</p>
                        <p class="text-xl font-bold text-[#2D5F3F]">${formatPrice(order.totalTTC)}</p>
                    </div>
                    ${canCancel ? `
                        <button onclick="showCancelOrderModal(${order.orderId}); return false;" class="px-6 py-3 rounded-xl transition-all font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5 flex items-center gap-2" style="background: linear-gradient(to right, #ef4444, #dc2626) !important; color: #ffffff !important; border: none !important;">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <circle cx="12" cy="12" r="10"></circle>
                                <line x1="12" y1="8" x2="12" y2="12"></line>
                                <line x1="12" y1="16" x2="12.01" y2="16"></line>
                            </svg>
                            <span style="color: #ffffff !important; font-weight: 600 !important;">Annuler la commande</span>
                        </button>
                    ` : ''}
                    ${order.cancellationReason ? `
                        <div class="bg-red-50 border-2 border-red-200 rounded-xl p-4">
                            <div class="flex items-start gap-3">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="flex-shrink-0 mt-0.5">
                                    <circle cx="12" cy="12" r="10"></circle>
                                    <line x1="12" y1="8" x2="12" y2="12"></line>
                                    <line x1="12" y1="16" x2="12.01" y2="16"></line>
                                </svg>
                                <div>
                                    <p class="font-semibold text-red-700 mb-2">Commande annulée</p>
                                    <p class="text-sm text-red-600 mb-1"><strong>Annulée le:</strong> ${order.cancelledAt || 'N/A'}</p>
                                    <p class="text-sm text-red-600"><strong>Raison:</strong> ${order.cancellationReason}</p>
                                </div>
                            </div>
                        </div>
                    ` : ''}
                </div>
            </div>
        `;
    }).join('');
}

function getOrderTrackingSteps(order) {
    const steps = [
        {
            label: 'Commande validée',
            date: order.validatedAt,
            icon: '✓',
            color: 'text-yellow-700',
            bgColor: 'bg-yellow-50',
            borderColor: 'border-yellow-200'
        },
        {
            label: 'En préparation',
            date: order.inPreparationAt,
            icon: '⚙',
            color: 'text-orange-700',
            bgColor: 'bg-orange-50',
            borderColor: 'border-orange-200'
        },
        {
            label: 'Expédiée',
            date: order.shippedAt,
            icon: '📦',
            color: 'text-blue-700',
            bgColor: 'bg-blue-50',
            borderColor: 'border-blue-200'
        },
        {
            label: 'Livrée',
            date: order.deliveredAt,
            icon: '✓',
            color: 'text-green-700',
            bgColor: 'bg-green-50',
            borderColor: 'border-green-200'
        }
    ];

    const currentStatus = order.status;
    const statusOrder = ['Validée', 'En préparation', 'Expédiée', 'Livrée'];
    const currentStatusIndex = statusOrder.indexOf(currentStatus);

    return steps.map((step, index) => {
        const isCompleted = step.date !== null && step.date !== undefined;
        const isCurrent = currentStatusIndex === index && isCompleted;
        const isPending = !isCompleted && currentStatusIndex >= index;

        return `
            <div class="flex items-center gap-4 ${isCurrent ? step.bgColor + ' ring-2 ring-offset-2 ring-[#E8967D]' : (isCompleted ? step.bgColor : 'bg-gray-50')} p-4 rounded-xl border-2 ${isCompleted ? step.borderColor : 'border-gray-200'} transition-all duration-300 ${isCurrent ? 'shadow-lg transform scale-105' : ''}">
                <div class="flex-shrink-0 w-10 h-10 rounded-full ${isCompleted ? step.bgColor : 'bg-gray-200'} ${isCompleted ? step.borderColor : 'border-gray-300'} border-2 flex items-center justify-center ${isCompleted ? step.color : 'text-gray-400'} font-bold text-lg ${isCurrent ? 'ring-2 ring-offset-2 ring-[#E8967D]' : ''}">
                    ${isCompleted ? step.icon : (index + 1)}
                </div>
                <div class="flex-1">
                    <p class="font-semibold ${isCurrent ? step.color + ' text-lg' : (isCompleted ? step.color : 'text-gray-500')}">${step.label}${isCurrent ? ' (En cours)' : ''}</p>
                    ${isCompleted ? `<p class="text-xs ${isCurrent ? 'font-medium' : ''} text-gray-600 mt-1">${step.date}</p>` : '<p class="text-xs text-gray-400 mt-1">En attente</p>'}
                </div>
            </div>
        `;
    }).join('');
}

function toggleTracking(orderId) {
    const content = document.getElementById(`tracking-content-${orderId}`);
    const chevron = document.getElementById(`chevron-${orderId}`);
    if (!content || !chevron) return;

    if (content.style.maxHeight && content.style.maxHeight !== '0px') {
        content.style.maxHeight = '0px';
        chevron.style.transform = 'rotate(0deg)';
    } else {
        content.style.maxHeight = content.scrollHeight + 'px';
        chevron.style.transform = 'rotate(180deg)';
    }
}

function getStatusInfo(status) {
    const statusMap = {
        'Validée': { class: 'bg-yellow-50 text-yellow-700 border border-yellow-200', icon: '✓' },
        'En préparation': { class: 'bg-orange-50 text-orange-700 border border-orange-200', icon: '⚙' },
        'Expédiée': { class: 'bg-blue-50 text-blue-700 border border-blue-200', icon: '📦' },
        'Livrée': { class: 'bg-green-50 text-green-700 border border-green-200', icon: '✓' },
        'Annulée': { class: 'bg-red-50 text-red-700 border border-red-200', icon: '✕' }
    };
    return statusMap[status] || { class: 'bg-gray-50 text-gray-700 border border-gray-200', icon: '○' };
}

function showCancelOrderModal(orderId) {
    const modal = document.getElementById('cancelOrderModal');
    if (!modal) return;

    document.getElementById('cancelOrderId').value = orderId;
    document.getElementById('cancelReason').value = '';

    modal.style.display = 'flex';
    modal.classList.remove('hidden');
    modal.classList.add('flex');
    return false;
}

function closeCancelOrderModal() {
    const modal = document.getElementById('cancelOrderModal');
    if (!modal) return;

    modal.style.display = 'none';
    modal.classList.add('hidden');
    modal.classList.remove('flex');

    document.getElementById('cancelOrderId').value = '';
    document.getElementById('cancelReason').value = '';
}

function confirmCancelOrder() {
    const orderId = parseInt(document.getElementById('cancelOrderId').value);
    const reason = document.getElementById('cancelReason').value.trim();

    if (!reason) {
        alert('Veuillez indiquer la raison de l\'annulation');
        return false;
    }

    if (!confirm('Êtes-vous sûr de vouloir annuler cette commande ?')) {
        return false;
    }

    callWebMethod('CancelOrder', { orderId, reason }, function (response) {
        if (response.d && response.d.success) {
            alert(response.d.message || 'Commande annulée avec succès');
            closeCancelOrderModal();
            loadOrders();
        } else {
            alert('Erreur: ' + (response.d?.message || 'Erreur inconnue'));
        }
    });

    return false;
}

function calculateEstimatedDelivery(createdAt, estimatedDays) {
    const date = new Date(createdAt.split(' ')[0].split('/').reverse().join('-'));
    date.setDate(date.getDate() + estimatedDays);
    return date.toLocaleDateString('fr-FR');
}

function trackOrder() {
    const trackingInput = document.getElementById('trackingInput');
    if (!trackingInput || !trackingInput.value) {
        alert('Veuillez entrer un numéro de commande ou de suivi');
        return;
    }

    const searchValue = trackingInput.value.trim();
    const container = document.getElementById('trackingResult');
    if (!container) return;

    container.innerHTML = '<p class="text-gray-600">Recherche en cours...</p>';

    callWebMethod('GetOrders', {}, function (response) {
        if (response.d && response.d.success) {
            // Search by order ID or tracking number
            const order = response.d.data.find(o =>
                o.orderId.toString() === searchValue ||
                (o.trackingNumber && o.trackingNumber.toLowerCase() === searchValue.toLowerCase())
            );

            if (!order) {
                container.innerHTML = `
                    <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                        <p class="text-red-800">Aucune commande trouvée avec ce numéro.</p>
                    </div>
                `;
                return;
            }

            // Display tracking details
            const statusInfo = getStatusInfo(order.status);

            // Ensure canCancel is a boolean (handle string "true"/"false" from JSON)
            const canCancel = order.canCancel === true || order.canCancel === "true" || order.canCancel === 1;
            console.log(`TrackOrder - Order #${order.orderId}: status="${order.status}", canCancel=${order.canCancel}, converted=${canCancel}`);

            const steps = [
                { status: 'Validée', iconClass: 'bg-yellow-400', label: 'Commande validée', active: ['Validée', 'En préparation', 'Expédiée', 'Livrée'].includes(order.status) },
                { status: 'En préparation', iconClass: 'bg-orange-400', label: 'En préparation', active: ['En préparation', 'Expédiée', 'Livrée'].includes(order.status) },
                { status: 'Expédiée', iconClass: 'bg-blue-400', label: 'Expédiée', active: ['Expédiée', 'Livrée'].includes(order.status) },
                { status: 'Livrée', iconClass: 'bg-green-400', label: 'Livrée', active: order.status === 'Livrée' }
            ];

            container.innerHTML = `
                <div class="bg-white border border-gray-200 rounded-lg p-6">
                    <div class="flex justify-between items-start mb-6">
                        <div>
                            <h3 class="text-2xl font-semibold text-[#2D5F3F]">Commande #${order.orderId}</h3>
                            <p class="text-sm text-gray-600 mt-1">Passée le ${order.createdAt}</p>
                        </div>
                        <div class="text-right">
                            <span class="px-4 py-2 rounded-full text-sm font-medium ${statusInfo.class}">${order.status}</span>
                        </div>
                    </div>

                    <!-- Timeline -->
                    <div class="mb-6">
                        <h4 class="font-medium text-gray-700 mb-4">Suivi de la commande</h4>
                        <div class="space-y-4">
                            ${steps.map((step, index) => `
                                <div class="flex items-center gap-4">
                                    <div class="flex-shrink-0 flex flex-col items-center">
                                        <div class="w-10 h-10 rounded-full flex items-center justify-center ${step.active ? step.iconClass + ' text-white' : 'bg-gray-200 text-gray-500'}">
                                            ${step.active ? '<svg class="w-6 h-6" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/></svg>' : '<div class="w-4 h-4 rounded-full bg-gray-400"></div>'}
                                        </div>
                                        ${index < steps.length - 1 ? `<div class="w-0.5 h-8 ${step.active ? step.iconClass : 'bg-gray-200'}"></div>` : ''}
                                    </div>
                                    <div class="flex-1">
                                        <p class="font-medium ${step.active ? 'text-[#2D5F3F]' : 'text-gray-500'}">${step.label}</p>
                                        ${step.status === order.status ? `<p class="text-sm text-gray-600">Statut actuel</p>` : ''}
                                    </div>
                                </div>
                            `).join('')}
                        </div>
                    </div>

                    ${order.trackingNumber ? `
                    <div class="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
                        <p class="text-sm text-blue-800">
                            <strong>Numéro de suivi:</strong> ${order.trackingNumber}
                        </p>
                    </div>
                    ` : ''}

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-4">
                        <div>
                            <h4 class="font-medium text-gray-700 mb-2">Adresse de livraison</h4>
                            <p class="text-sm text-gray-600">${order.address.fullName}</p>
                            <p class="text-sm text-gray-600">${order.address.addressLine}</p>
                            <p class="text-sm text-gray-600">${order.address.postalCode} ${order.address.city}</p>
                        </div>
                        <div>
                            <h4 class="font-medium text-gray-700 mb-2">Informations</h4>
                            <p class="text-sm text-gray-600">Méthode de paiement: ${order.paymentMethod}</p>
                            <p class="text-sm text-gray-600">Livraison: ${order.shipping.methodName}</p>
                            <p class="text-sm text-gray-600">Délai estimé: ${order.shipping.estimatedDays} jours</p>
                            ${order.trackingNumber ? `<p class="text-sm text-gray-600">Suivi: <strong>${order.trackingNumber}</strong></p>` : ''}
                        </div>
                    </div>

                    <div class="mb-4">
                        <h4 class="font-medium text-gray-700 mb-2">Articles commandés</h4>
                        <div class="space-y-2">
                            ${order.items.map(item => `
                                <div class="flex justify-between text-sm bg-gray-50 p-2 rounded">
                                    <span>${item.productName} (${item.format}) x ${item.quantity}</span>
                                    <span class="font-medium">${formatPrice(item.unitPrice * item.quantity)}</span>
                                </div>
                            `).join('')}
                        </div>
                    </div>

                    <div class="pt-4 border-t border-gray-200">
                        <div class="flex justify-between items-center">
                            <div>
                                <p class="text-sm text-gray-600">Total TTC</p>
                                <p class="text-2xl font-bold text-[#2D5F3F]">${formatPrice(order.totalTTC)}</p>
                            </div>
                            ${canCancel ? `
                                <button onclick="showCancelOrderModal(${order.orderId})" class="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors">
                                    Annuler la commande
                                </button>
                            ` : ''}
                        </div>
                    </div>
                </div>
            `;
        } else {
            container.innerHTML = `
                <div class="bg-red-50 border border-red-200 rounded-lg p-4">
                    <p class="text-red-800">Erreur lors de la recherche.</p>
                </div>
            `;
        }
    });
}

// Make functions globally accessible
window.trackOrder = trackOrder;
window.showCancelOrderModal = showCancelOrderModal;
window.closeCancelOrderModal = closeCancelOrderModal;
window.saveAddress = saveAddress;
window.showAddAddressModal = showAddAddressModal;
window.editAddress = editAddress;
window.closeAddressModal = closeAddressModal;
window.deleteAddress = deleteAddress;
window.toggleTracking = toggleTracking;

function formatPrice(price) {
    return new Intl.NumberFormat('fr-MA', { style: 'currency', currency: 'MAD' }).format(price);
}

// Utility Functions
function callWebMethod(methodName, params, callback) {
    if (typeof jQuery === 'undefined') {
        console.error('jQuery is not loaded');
        alert('Erreur: jQuery n\'est pas chargé');
        return;
    }

    console.log('callWebMethod:', methodName, params);
    const data = JSON.stringify(params);

    jQuery.ajax({
        type: 'POST',
        url: serviceUrl + '/' + methodName,
        data: data,
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            console.log('WebMethod success response:', response);
            if (callback) callback(response);
        },
        error: function (xhr, status, error) {
            console.error('AJAX Error:', error, xhr);
            console.error('Response text:', xhr.responseText);
            alert('Une erreur est survenue. Veuillez réessayer. Erreur: ' + error);
        }
    });
}

function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

