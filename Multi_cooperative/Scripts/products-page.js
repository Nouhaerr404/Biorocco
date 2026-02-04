// Scripts/products-page.js

// Gestion du changement de vue
document.addEventListener('DOMContentLoaded', function () {
    console.log('DOM chargé - initialisation des filtres');

    // Initialiser la vue sauvegardée
    const savedViewMode = localStorage.getItem('productViewMode') || 'grid';
    setViewMode(savedViewMode);

    // Boutons de changement de vue
    const gridViewBtn = document.getElementById('gridView');
    const listViewBtn = document.getElementById('listView');
    const productsContainer = document.querySelector('.grid');

    if (gridViewBtn && listViewBtn && productsContainer) {
        gridViewBtn.addEventListener('click', function () {
            console.log('Changement en vue grille');
            setViewMode('grid');
        });

        listViewBtn.addEventListener('click', function () {
            console.log('Changement en vue liste');
            setViewMode('list');
        });
    }

    // Filtres par prix - CORRIGÉ
    const priceMin = document.getElementById('priceMin');
    const priceMax = document.getElementById('priceMax');
    const priceMinValue = document.getElementById('priceMinValue');
    const priceMaxValue = document.getElementById('priceMaxValue');

    if (priceMin && priceMax && priceMinValue && priceMaxValue) {
        console.log('Initialisation des filtres de prix');

        // Initialiser les prix min/max depuis les produits
        initPriceFilters();

        // Mettre à jour les valeurs affichées
        priceMin.addEventListener('input', function () {
            priceMinValue.textContent = this.value + ' MAD';
            filterProducts();
        });

        priceMax.addEventListener('input', function () {
            priceMaxValue.textContent = this.value + ' MAD';
            filterProducts();
        });
    }

    // Filtres par catégorie - CORRIGÉ
    const categoryFilters = document.querySelectorAll('.category-filter');
    console.log('Filtres de catégorie trouvés:', categoryFilters.length);

    categoryFilters.forEach(filter => {
        filter.addEventListener('change', function () {
            console.log('Filtre catégorie changé:', this.value, this.checked);
            filterProducts();
        });
    });

    // Filtrer au chargement initial
    setTimeout(filterProducts, 100);
});

function initPriceFilters() {
    const priceMin = document.getElementById('priceMin');
    const priceMax = document.getElementById('priceMax');
    const priceMinValue = document.getElementById('priceMinValue');
    const priceMaxValue = document.getElementById('priceMaxValue');

    if (!priceMin || !priceMax) return;

    // Trouver les prix min/max réels des produits
    const productCards = document.querySelectorAll('.product-card');
    const prices = Array.from(productCards)
        .map(card => {
            const priceText = card.querySelector('.product-price')?.textContent;
            if (priceText) {
                return parseFloat(priceText.replace(' MAD', '').replace(',', '.'));
            }
            return 0;
        })
        .filter(price => !isNaN(price) && price > 0);

    if (prices.length > 0) {
        const minPrice = Math.floor(Math.min(...prices));
        const maxPrice = Math.ceil(Math.max(...prices));

        console.log('Prix min/max trouvés:', minPrice, maxPrice);

        // Mettre à jour les curseurs
        priceMin.min = minPrice;
        priceMin.max = maxPrice;
        priceMin.value = minPrice;

        priceMax.min = minPrice;
        priceMax.max = maxPrice;
        priceMax.value = maxPrice;

        // Mettre à jour les valeurs affichées
        if (priceMinValue) priceMinValue.textContent = minPrice + ' MAD';
        if (priceMaxValue) priceMaxValue.textContent = maxPrice + ' MAD';
    }
}

function setViewMode(mode) {
    const gridViewBtn = document.getElementById('gridView');
    const listViewBtn = document.getElementById('listView');
    const productsContainer = document.querySelector('.grid');

    if (!productsContainer) return;

    // Mettre à jour les boutons
    if (mode === 'grid') {
        if (gridViewBtn) {
            gridViewBtn.classList.add('bg-[#E8967D]', 'text-white');
            gridViewBtn.classList.remove('text-gray-600', 'hover:bg-gray-100');
        }
        if (listViewBtn) {
            listViewBtn.classList.remove('bg-[#E8967D]', 'text-white');
            listViewBtn.classList.add('text-gray-600', 'hover:bg-gray-100');
        }

        // Changer le layout
        productsContainer.classList.remove('grid-cols-1');
        productsContainer.classList.add('grid-cols-1', 'md:grid-cols-2', 'lg:grid-cols-3', 'xl:grid-cols-4');

        // Changer le style des cartes pour vue grille
        const productCards = productsContainer.querySelectorAll('.product-card');
        productCards.forEach(card => {
            card.classList.remove('flex', 'items-start');
            card.classList.add('flex-col');

            // Réinitialiser les styles de l'image
            const imgContainer = card.querySelector('.relative');
            if (imgContainer) {
                imgContainer.classList.remove('w-1/3', 'h-64');
                imgContainer.classList.add('h-48');
            }

            const infoContainer = card.querySelector('.p-4');
            if (infoContainer) {
                infoContainer.classList.remove('flex-1');
            }
        });

        // Sauvegarder la préférence
        localStorage.setItem('productViewMode', 'grid');
    } else {
        if (listViewBtn) {
            listViewBtn.classList.add('bg-[#E8967D]', 'text-white');
            listViewBtn.classList.remove('text-gray-600', 'hover:bg-gray-100');
        }
        if (gridViewBtn) {
            gridViewBtn.classList.remove('bg-[#E8967D]', 'text-white');
            gridViewBtn.classList.add('text-gray-600', 'hover:bg-gray-100');
        }

        // Changer le layout
        productsContainer.classList.remove('grid-cols-1', 'md:grid-cols-2', 'lg:grid-cols-3', 'xl:grid-cols-4');
        productsContainer.classList.add('grid-cols-1');

        // Changer le style des cartes pour vue liste
        const productCards = productsContainer.querySelectorAll('.product-card');
        productCards.forEach(card => {
            card.classList.add('flex', 'items-start');
            card.classList.remove('flex-col');

            // Pour la vue liste, ajuster l'image
            const imgContainer = card.querySelector('.relative');
            if (imgContainer) {
                imgContainer.classList.remove('h-48');
                imgContainer.classList.add('w-1/3', 'h-64');
            }

            const infoContainer = card.querySelector('.p-4');
            if (infoContainer) {
                infoContainer.classList.add('flex-1');
            }
        });

        // Sauvegarder la préférence
        localStorage.setItem('productViewMode', 'list');
    }
}

// Filtrage des produits côté client - CORRIGÉ
function filterProducts() {
    console.log('Filtrage des produits...');

    const priceMin = document.getElementById('priceMin') ? parseFloat(document.getElementById('priceMin').value) : 0;
    const priceMax = document.getElementById('priceMax') ? parseFloat(document.getElementById('priceMax').value) : 300;

    // Récupérer les catégories sélectionnées
    const selectedCategories = [];
    document.querySelectorAll('.category-filter:checked').forEach(checkbox => {
        selectedCategories.push(checkbox.value);
    });

    console.log('Catégories sélectionnées:', selectedCategories);
    console.log('Prix min/max:', priceMin, priceMax);

    // Filtrer les produits
    const productCards = document.querySelectorAll('.product-card');
    let visibleCount = 0;

    productCards.forEach(card => {
        // Récupérer le prix depuis l'attribut data-price
        const productPrice = parseFloat(card.getAttribute('data-price') || 0);

        // Récupérer la catégorie depuis l'attribut data-category
        const productCategory = card.getAttribute('data-category') || '';

        console.log('Produit:', productCategory, 'Prix:', productPrice);

        let showProduct = true;

        // Filtrer par prix
        if (productPrice < priceMin || productPrice > priceMax) {
            showProduct = false;
            console.log('Filtré par prix:', productPrice, 'hors de', priceMin, '-', priceMax);
        }

        // Filtrer par catégorie (si des catégories sont sélectionnées)
        if (selectedCategories.length > 0 && !selectedCategories.includes(productCategory)) {
            showProduct = false;
            console.log('Filtré par catégorie:', productCategory, 'pas dans', selectedCategories);
        }

        // Afficher ou cacher le produit
        if (showProduct) {
            card.style.display = '';
            visibleCount++;
        } else {
            card.style.display = 'none';
        }
    });

    console.log('Produits visibles:', visibleCount);

    // Mettre à jour le compteur
    updateProductCount(visibleCount);
}

function updateProductCount(count) {
    // Mettre à jour le label ASP.NET
    const lblProductCount = document.getElementById('<%= lblProductCount.ClientID %>');
    if (lblProductCount) {
        lblProductCount.textContent = count + ' produits';
    }

    // Mettre à jour aussi les éléments avec la classe product-count
    document.querySelectorAll('.text-gray-600.font-medium').forEach(el => {
        if (el.textContent.includes('produits')) {
            el.textContent = count + ' produits';
        }
    });
}