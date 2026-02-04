// Client-side product filtering without page refresh
let allProducts = [];

// Store all products on page load
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(() => {
        // Get all product cards
        const productCards = document.querySelectorAll('.product-card');
        allProducts = Array.from(productCards).map(card => {
            return {
                element: card.cloneNode(true),
                badge: card.querySelector('.product-badge')?.textContent || '',
                name: card.querySelector('.product-title')?.textContent || '',
                rating: parseFloat(card.querySelector('.rating-number')?.textContent.replace('(', '').replace(')', '') || '0'),
                price: parseFloat(card.querySelector('.price')?.textContent.replace(/[^\d.,-]/g, '').replace(',', '.') || '0'),
                html: card.outerHTML
            };
        });
        console.log('Products loaded:', allProducts.length);
    }, 500);
});

function filterProducts(filterType) {
    // Update active tab styling
    document.querySelectorAll('.tab-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    document.querySelector(`[data-filter="${filterType}"]`).classList.add('active');

    const productsGrid = document.getElementById('products-grid');
    if (!productsGrid || allProducts.length === 0) {
        console.warn('No products to filter');
        return;
    }

    let filteredProducts = [...allProducts];

    // Filter and sort based on type
    switch (filterType) {
        case 'new':
            // Show products with "Nouveau" badge first
            filteredProducts.sort((a, b) => {
                const aIsNew = a.badge.toLowerCase().includes('nouveau');
                const bIsNew = b.badge.toLowerCase().includes('nouveau');
                if (aIsNew && !bIsNew) return -1;
                if (!aIsNew && bIsNew) return 1;
                return b.rating - a.rating; // Then by rating
            });
            break;

        case 'trending':
            // Sort by rating (highest first)
            filteredProducts.sort((a, b) => b.rating - a.rating);
            break;

        case 'popular':
            // Sort by rating with slight randomization
            filteredProducts.sort((a, b) => {
                const scoreA = a.rating + (Math.random() * 0.3);
                const scoreB = b.rating + (Math.random() * 0.3);
                return scoreB - scoreA;
            });
            break;
    }

    // Clear grid with smooth fade
    productsGrid.style.opacity = '0';
    productsGrid.style.transition = 'opacity 0.3s ease';

    setTimeout(() => {
        // Clear existing products
        productsGrid.innerHTML = '';

        // Add filtered products
        filteredProducts.forEach((product, index) => {
            // Create element from HTML
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = product.html;
            const clone = tempDiv.firstElementChild;

            clone.style.opacity = '0';
            clone.style.animation = 'none';
            clone.classList.add('animate-fade-in-up');
            clone.style.animationDelay = `${index * 0.05}s`;

            productsGrid.appendChild(clone);

            // Trigger animation
            setTimeout(() => {
                clone.style.opacity = '1';
                clone.style.animation = 'fadeInUp 0.6s ease forwards';
            }, 50);
        });

        // Fade in the grid
        productsGrid.style.opacity = '1';
    }, 300);
}

// Make function globally accessible
window.filterProducts = filterProducts;
