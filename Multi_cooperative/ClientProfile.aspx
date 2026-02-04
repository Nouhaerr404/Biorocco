<%@ Page Title="Mon Profil - BIOROCCO" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ClientProfile.aspx.cs" Inherits="Multi_cooperative.ClientProfile" %>
    <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

        <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
            <style>
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(20px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                .profile-tab-content {
                    animation: fadeInUp 0.4s ease-out;
                }

                .order-card {
                    animation: fadeInUp 0.4s ease-out;
                }
            </style>
            <uc:Header runat="server" />
            <div class="min-h-screen bg-[#F5F1E8] py-8" style="margin-top: 100px;">
                <div class="container mx-auto px-4">
                    <h1 class="text-3xl text-[#2D5F3F] mb-6">Mon Profil</h1>

                    <!-- Navigation Tabs -->
                    <div class="bg-white rounded-lg shadow-sm mb-6">
                        <div class="flex border-b border-gray-200">
                            <button type="button"
                                class="profile-tab px-6 py-4 font-medium text-gray-700 hover:text-[#E8967D] border-b-2 border-transparent hover:border-[#E8967D] transition-colors active"
                                data-tab="commandes">
                                Historique des Commandes
                            </button>
                            <button type="button"
                                class="profile-tab px-6 py-4 font-medium text-gray-700 hover:text-[#E8967D] border-b-2 border-transparent hover:border-[#E8967D] transition-colors"
                                data-tab="suivi">
                                Suivi d'une Commande
                            </button>
                            <button type="button"
                                class="profile-tab px-6 py-4 font-medium text-gray-700 hover:text-[#E8967D] border-b-2 border-transparent hover:border-[#E8967D] transition-colors"
                                data-tab="adresses">
                                Mes Adresses
                            </button>
                        </div>
                    </div>

                    <!-- Gestion des Adresses -->
                    <div id="adressesTab" class="profile-tab-content hidden">
                        <div class="bg-white rounded-lg shadow-sm p-6">
                            <div class="flex justify-between items-center mb-6">
                                <h2 class="text-2xl text-[#2D5F3F]">Mes Adresses</h2>
                                <button type="button"
                                    class="px-6 py-3 bg-gradient-to-r from-[#E8967D] to-[#d8856d] text-white rounded-xl hover:shadow-lg transition-all font-medium flex items-center gap-2 transform hover:-translate-y-0.5"
                                    onclick="showAddAddressModal(); return false;">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <line x1="12" y1="5" x2="12" y2="19"></line>
                                        <line x1="5" y1="12" x2="19" y2="12"></line>
                                    </svg>
                                    Ajouter une Adresse
                                </button>
                            </div>

                            <div id="addressesList" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <!-- Les adresses seront chargées dynamiquement -->
                            </div>
                        </div>
                    </div>

                    <!-- Historique des Commandes -->
                    <div id="commandesTab" class="profile-tab-content">
                        <div class="bg-white rounded-lg shadow-sm p-6">
                            <h2 class="text-2xl text-[#2D5F3F] mb-6">Historique des Commandes</h2>

                            <!-- Filtres -->
                            <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
                                <input type="text" id="searchOrder" placeholder="Rechercher par numéro de commande..."
                                    class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D]">
                                <select id="filterOrderStatus"
                                    class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D]">
                                    <option value="">Tous les statuts</option>
                                    <option value="Validée">Validée</option>
                                    <option value="En préparation">En préparation</option>
                                    <option value="Expédiée">Expédiée</option>
                                    <option value="Livrée">Livrée</option>
                                    <option value="Annulée">Annulée</option>
                                </select>
                                <select id="filterOrderDate"
                                    class="px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D]">
                                    <option value="">Toutes les dates</option>
                                    <option value="week">7 derniers jours</option>
                                    <option value="month">Ce mois</option>
                                    <option value="year">Cette année</option>
                                </select>
                            </div>

                            <div id="ordersList" class="space-y-6">
                                <!-- Les commandes seront chargées dynamiquement -->
                            </div>
                        </div>
                    </div>

                    <!-- Suivi d'une Commande -->
                    <div id="suiviTab" class="profile-tab-content hidden">
                        <div class="bg-white rounded-lg shadow-sm p-6">
                            <h2 class="text-2xl text-[#2D5F3F] mb-6">Suivi d'une Commande</h2>

                            <div class="mb-6">
                                <label class="block text-gray-700 mb-2">Numéro de commande ou numéro de suivi</label>
                                <div class="flex gap-2">
                                    <input type="text" id="trackingInput"
                                        placeholder="Entrez le numéro de commande ou de suivi..."
                                        class="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D]">
                                    <button type="button" onclick="trackOrder()"
                                        class="px-6 py-2 bg-[#E8967D] text-white rounded-lg hover:bg-[#d8856d] transition-colors">
                                        Rechercher
                                    </button>
                                </div>
                            </div>

                            <div id="trackingResult" class="space-y-6">
                                <!-- Résultat du suivi -->
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal Adresse - Redessiné pour éviter le header et garantir la visibilité -->
            <div id="addressModal" class="fixed inset-0 bg-black/50 backdrop-blur-sm hidden z-[9999] overflow-y-auto"
                style="display: none;">
                <div class="flex items-start justify-center min-h-screen pt-32 pb-10 px-4">
                    <div class="bg-white rounded-3xl shadow-2xl max-w-2xl w-full border border-gray-200 overflow-hidden"
                        style="animation: fadeInUp 0.4s ease-out;">

                        <!-- Header Simple et Clair -->
                        <div class="px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
                            <div>
                                <h3 class="text-2xl font-bold text-[#2D5F3F]" id="addressModalTitle">Gestion de
                                    l'adresse</h3>
                                <p class="text-sm text-gray-500 mt-1">Veuillez renseigner vos informations de livraison
                                </p>
                            </div>
                            <button type="button" onclick="closeAddressModal(); return false;"
                                class="text-gray-400 hover:text-red-500 p-2 transition-colors">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"
                                    fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                    stroke-linejoin="round">
                                    <line x1="18" y1="6" x2="6" y2="18"></line>
                                    <line x1="6" y1="6" x2="18" y2="18"></line>
                                </svg>
                            </button>
                        </div>

                        <div id="addressForm">
                            <input type="hidden" id="addressId">

                            <div class="p-8 space-y-6">
                                <!-- Ligne 1: Nom et Téléphone -->
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div class="space-y-2">
                                        <label class="block text-sm font-bold text-gray-700">Nom & Prénom <span
                                                class="text-red-500">*</span></label>
                                        <input type="text" id="addressFullName" required
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#E8967D] focus:outline-none transition-all"
                                            placeholder="Ex: Mohammed Saber">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="block text-sm font-bold text-gray-700">Téléphone <span
                                                class="text-red-500">*</span></label>
                                        <input type="tel" id="addressPhone" required
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#E8967D] focus:outline-none transition-all"
                                            placeholder="Ex: 06 12 34 56 78">
                                    </div>
                                </div>

                                <!-- Ligne 2: Adresse -->
                                <div class="space-y-2">
                                    <label class="block text-sm font-bold text-gray-700">Adresse complète <span
                                            class="text-red-500">*</span></label>
                                    <textarea id="addressLine" required rows="2"
                                        class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#E8967D] focus:outline-none transition-all resize-none"
                                        placeholder="N°, Rue, Quartier..."></textarea>
                                </div>

                                <!-- Ligne 3: Ville et Code Postal -->
                                <div class="grid grid-cols-2 gap-6">
                                    <div class="space-y-2">
                                        <label class="block text-sm font-bold text-gray-700">Ville <span
                                                class="text-red-500">*</span></label>
                                        <input type="text" id="addressCity" required
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#E8967D] focus:outline-none transition-all"
                                            placeholder="Ex: Casablanca">
                                    </div>
                                    <div class="space-y-2">
                                        <label class="block text-sm font-bold text-gray-700">Code Postal <span
                                                class="text-red-500">*</span></label>
                                        <input type="text" id="addressPostalCode" required
                                            class="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:border-[#E8967D] focus:outline-none transition-all"
                                            placeholder="Ex: 20000">
                                    </div>
                                </div>

                                <!-- Option Par Défaut -->
                                <div class="flex items-center gap-3 p-4 bg-gray-50 rounded-xl border border-gray-100">
                                    <input type="checkbox" id="addressIsDefault"
                                        class="w-5 h-5 accent-[#2D5F3F] cursor-pointer">
                                    <label for="addressIsDefault"
                                        class="text-sm font-bold text-[#2D5F3F] cursor-pointer">
                                        Définir comme adresse par défaut
                                    </label>
                                </div>
                            </div>

                            <!-- Footer: Boutons mieux proportionnés -->
                            <div class="px-8 py-6 bg-gray-50 border-t border-gray-100 flex flex-col md:flex-row gap-3">
                                <button type="button" onclick="closeAddressModal(); return false;"
                                    class="flex-1 px-6 py-3 border-2 border-gray-300 text-gray-600 rounded-xl font-bold hover:bg-gray-100 transition-all">
                                    Annuler
                                </button>
                                <button type="button" onclick="saveAddress(); return false;"
                                    class="flex-[2] px-8 py-3 bg-[#E8967D] text-white rounded-xl font-bold hover:bg-[#d8856d] shadow-lg shadow-orange-100 transition-all flex items-center justify-center gap-2">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24"
                                        fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"
                                        stroke-linejoin="round">
                                        <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z">
                                        </path>
                                        <polyline points="17 21 17 13 7 13 7 21"></polyline>
                                        <polyline points="7 3 7 8 15 8"></polyline>
                                    </svg>
                                    Enregistrer l'adresse
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Modal Annulation Commande -->
            <div id="cancelOrderModal"
                class="fixed inset-0 bg-black bg-opacity-50 hidden items-center justify-center z-50"
                style="display: none;">
                <div class="bg-white rounded-2xl shadow-2xl p-6 max-w-2xl w-full mx-4"
                    style="animation: fadeInUp 0.3s ease-out;">
                    <div class="flex justify-between items-center mb-4">
                        <h3 class="text-2xl font-bold text-[#2D5F3F]">Annuler la Commande</h3>
                        <button type="button" onclick="closeCancelOrderModal(); return false;"
                            class="text-gray-500 hover:text-gray-700 transition-colors p-2 hover:bg-gray-100 rounded-full">
                            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                                    d="M6 18L18 6M6 6l12 12" />
                            </svg>
                        </button>
                    </div>
                    <form id="cancelOrderForm">
                        <input type="hidden" id="cancelOrderId">
                        <div class="mb-4">
                            <label class="block text-gray-700 mb-2">Raison de l'annulation</label>
                            <textarea id="cancelReason" rows="4"
                                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D]"
                                required placeholder="Veuillez indiquer la raison de l'annulation..."></textarea>
                        </div>
                        <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
                            <p class="text-sm text-yellow-800">
                                <strong>Note :</strong> Le remboursement sera effectué automatiquement selon votre mode
                                de paiement initial.
                            </p>
                        </div>
                        <div class="flex justify-end gap-4">
                            <button type="button" onclick="closeCancelOrderModal(); return false;"
                                class="px-6 py-3 border border-gray-300 rounded-xl hover:bg-gray-100 transition-colors font-medium text-gray-700"
                                style="background-color: #ffffff !important; color: #374151 !important; border-color: #d1d5db !important;">Annuler</button>
                            <button type="submit"
                                class="px-6 py-3 rounded-xl transition-all font-medium shadow-md hover:shadow-lg transform hover:-translate-y-0.5"
                                style="background: linear-gradient(to right, #ef4444, #dc2626) !important; color: #ffffff !important; border: none !important;">Confirmer
                                l'annulation</button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Client Profile Script -->
            <script src='<%= ResolveUrl("~/Scripts/client-profile.js") %>'></script>
        </asp:Content>