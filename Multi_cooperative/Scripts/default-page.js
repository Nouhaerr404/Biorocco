// Hero Slider
let currentSlide = 0;
const slides = document.querySelectorAll('.hero-slide');
const dots = document.querySelectorAll('.hero-dot');

function showSlide(index) {
    slides.forEach((slide, i) => {
        slide.style.opacity = i === index ? '1' : '0';
    });
    dots.forEach((dot, i) => {
        if (i === index) {
            dot.classList.remove('w-3', 'bg-white/50');
            dot.classList.add('w-8', 'bg-white');
        } else {
            dot.classList.remove('w-8', 'bg-white');
            dot.classList.add('w-3', 'bg-white/50');
        }
    });
}

function nextSlide() {
    currentSlide = (currentSlide + 1) % slides.length;
    showSlide(currentSlide);
}

function prevSlide() {
    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
    showSlide(currentSlide);
}

document.getElementById('nextSlide')?.addEventListener('click', nextSlide);
document.getElementById('prevSlide')?.addEventListener('click', prevSlide);

dots.forEach((dot, index) => {
    dot.addEventListener('click', () => {
        currentSlide = index;
        showSlide(currentSlide);
    });
});

// Auto-advance slides
setInterval(nextSlide, 5000);

// Categories
const categories = [
    { name: 'Soins Visage', image: 'https://images.unsplash.com/photo-1715702129041-ff31d547e498?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Soins Corps', image: 'https://images.unsplash.com/photo-1724486292273-f07aa9080d8f?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Huiles Naturelles', image: 'https://images.unsplash.com/photo-1608571424634-58ae03e6edcf?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Parfums', image: 'https://images.unsplash.com/photo-1610547939489-73202bc6afda?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Savons Traditionnels', image: 'https://images.unsplash.com/photo-1723391874756-f7e0ea10dc6c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Masques & Gommages', image: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Sérums', image: 'https://images.unsplash.com/photo-1715750968540-841103c78d47?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Crèmes Hydratantes', image: 'https://images.unsplash.com/photo-1763503836825-97f5450d155a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Produits Capillaires', image: 'https://images.unsplash.com/photo-1610595426075-eed5a3f521ee?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' },
    { name: 'Eaux Florales', image: 'https://images.unsplash.com/photo-1688233944728-9e8439cfae14?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080' }
];

const categoriesContainer = document.getElementById('categoriesContainer');
if (categoriesContainer) {
    categories.forEach(cat => {
        const categoryCard = document.createElement('div');
        categoryCard.className = 'group relative flex-shrink-0 w-80 h-80 rounded-2xl overflow-hidden cursor-pointer shadow-lg hover:shadow-2xl transition-shadow duration-300';
        categoryCard.innerHTML = `
            <div class="absolute inset-0 bg-cover bg-center transition-transform duration-500 group-hover:scale-110" style="background-image: url('${cat.image}')"></div>
            <div class="absolute inset-0 bg-gradient-to-t from-black/70 via-black/30 to-transparent"></div>
            <div class="absolute inset-0 flex flex-col justify-end p-6">
                <h3 class="text-white text-2xl mb-3">${cat.name}</h3>
                <div class="flex items-center space-x-2 text-white">
                    <span class="text-sm">Découvrir</span>
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                    </svg>
                </div>
            </div>
        `;
        categoryCard.addEventListener('click', () => window.location.href = 'Products.aspx');
        categoriesContainer.appendChild(categoryCard);
    });
}

// Products
const products = {
    new: [
        { id: 1, name: "Huile d'Argan Pure", price: "149 DH", image: "https://images.unsplash.com/photo-1608571424634-58ae03e6edcf?w=400", rating: 4.9 },
        { id: 4, name: "Eau de Rose Pure", price: "89 DH", image: "https://images.unsplash.com/photo-1643379850623-7eb6442cd262?w=400", rating: 5.0 },
        { id: 11, name: "Crème Hydratante", price: "179 DH", image: "https://images.unsplash.com/photo-1763503836825-97f5450d155a?w=400", rating: 4.7 }
    ],
    trending: [
        { id: 3, name: "Crème Visage Bio", price: "199 DH", image: "https://images.unsplash.com/photo-1715702129041-ff31d547e498?w=400", rating: 4.7 },
        { id: 5, name: "Masque d'Argile", price: "119 DH", image: "https://images.unsplash.com/photo-1589234145872-22379e4a25da?w=400", rating: 4.6 },
        { id: 9, name: "Gommage Corps Bio", price: "139 DH", image: "https://images.unsplash.com/photo-1668025757022-a75458371576?w=400", rating: 4.5 },
        { id: 12, name: "Eau Florale Rose", price: "99 DH", image: "https://images.unsplash.com/photo-1688233944728-9e8439cfae14?w=400", rating: 4.8 }
    ],
    popular: [
        { id: 2, name: "Savon Noir Beldi", price: "79 DH", image: "https://images.unsplash.com/photo-1723391874756-f7e0ea10dc6c?w=400", rating: 4.8 },
        { id: 6, name: "Sérum Anti-Âge", price: "249 DH", image: "https://images.unsplash.com/photo-1761864293818-603c23655cee?w=400", rating: 4.9 },
        { id: 7, name: "Lotion Corps Argan", price: "169 DH", image: "https://images.unsplash.com/photo-1724486292273-f07aa9080d8f?w=400", rating: 4.8 },
        { id: 10, name: "Huile Capillaire", price: "159 DH", image: "https://images.unsplash.com/photo-1610595426075-eed5a3f521ee?w=400", rating: 4.9 }
    ]
};

let activeTab = 'new';

function renderProducts(tab) {
    const grid = document.getElementById('productsGrid');
    if (!grid) return;

    grid.innerHTML = '';
    const tabProducts = products[tab] || [];

    tabProducts.forEach(product => {
        const productCard = document.createElement('div');
        productCard.className = 'bg-white rounded-2xl overflow-hidden shadow-md hover:shadow-xl transition-all duration-300 group';
        productCard.innerHTML = `
            <div class="relative h-64 overflow-hidden">
                <img src="${product.image}" alt="${product.name}" class="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110" />
                <button class="absolute top-4 right-4 p-2 bg-white/90 backdrop-blur-sm rounded-full hover:bg-[#E8967D] hover:text-white transition-colors">
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
                    </svg>
                </button>
                <div class="absolute top-4 left-4 px-3 py-1 bg-[#E8967D] text-white text-xs rounded-full">Nouveau</div>
            </div>
            <div class="p-5">
                <h3 class="text-lg mb-2 text-gray-800 group-hover:text-[#E8967D] transition-colors">${product.name}</h3>
                <div class="flex items-center space-x-2 mb-3">
                    ${Array(5).fill(0).map((_, i) =>
            `<svg class="w-4 h-4 ${i < Math.floor(product.rating) ? 'text-yellow-400 fill-yellow-400' : 'text-gray-300'}" fill="currentColor" viewBox="0 0 20 20">
                            <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                        </svg>`
        ).join('')}
                    <span class="text-sm text-gray-600">(${product.rating})</span>
                </div>
                <div class="flex items-center justify-between">
                    <span class="text-2xl text-[#E8967D]">${product.price}</span>
                    <button class="p-3 bg-[#E8967D] text-white rounded-full hover:shadow-lg transition-all">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z" />
                        </svg>
                    </button>
                </div>
            </div>
        `;
        grid.appendChild(productCard);
    });
}

document.querySelectorAll('.product-tab').forEach(tab => {
    tab.addEventListener('click', () => {
        activeTab = tab.dataset.tab;
        document.querySelectorAll('.product-tab').forEach(t => {
            t.classList.remove('bg-[#E8967D]', 'text-white', 'shadow-lg');
            t.classList.add('bg-gray-100', 'text-gray-700');
        });
        tab.classList.remove('bg-gray-100', 'text-gray-700');
        tab.classList.add('bg-[#E8967D]', 'text-white', 'shadow-lg');
        renderProducts(activeTab);
    });
});

renderProducts(activeTab);

// Testimonials
const testimonials = [
    { name: 'Fatima Zahra', location: 'Casablanca', rating: 5, text: "Les produits BIOROCCO ont transformé ma routine beauté ! L'huile d'argan est d'une qualité exceptionnelle et ma peau n'a jamais été aussi éclatante.", image: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&h=150&fit=crop', color: '#E8967D' },
    { name: 'Karim Bennani', location: 'Marrakech', rating: 5, text: "Livraison rapide et produits authentiques. Le savon beldi est exactement comme celui que j'utilisais au hammam traditionnel. Merci BIOROCCO !", image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&h=150&fit=crop', color: '#2D5F3F' },
    { name: 'Sanaa Idrissi', location: 'Rabat', rating: 5, text: 'Je recommande à 100% ! Les crèmes à base de rose du Maroc sentent divinement bon et sont très efficaces. Mon investissement beauté préféré.', image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop', color: '#F5F1E8' }
];

let currentTestimonial = 0;

function showTestimonial(index) {
    const content = document.getElementById('testimonialContent');
    const testimonial = testimonials[index];
    const textColor = testimonial.color === '#F5F1E8' ? '#2D5F3F' : '#ffffff';

    if (content) {
        content.innerHTML = `
            <div class="rounded-3xl shadow-2xl p-8 md:p-12 relative overflow-hidden" style="background-color: ${testimonial.color}">
                <div class="relative z-10">
                    <div class="flex gap-1 mb-6 justify-center">
                        ${Array(testimonial.rating).fill(0).map(() =>
            `<svg class="w-6 h-6 fill-current" style="color: ${textColor}" fill="currentColor" viewBox="0 0 20 20">
                                <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
                            </svg>`
        ).join('')}
                    </div>
                    <p class="text-lg md:text-xl text-center mb-8 leading-relaxed italic" style="color: ${textColor}">"${testimonial.text}"</p>
                    <div class="flex items-center justify-center gap-4">
                        <img src="${testimonial.image}" alt="${testimonial.name}" class="w-16 h-16 rounded-full object-cover border-4" style="border-color: ${textColor}" />
                        <div class="text-left">
                            <div style="color: ${textColor}">${testimonial.name}</div>
                            <div class="text-sm opacity-80" style="color: ${textColor}">${testimonial.location}</div>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }

    // Update dots
    const dotsContainer = document.getElementById('testimonialDots');
    if (dotsContainer) {
        dotsContainer.innerHTML = testimonials.map((_, i) =>
            `<button type="button" class="testimonial-dot h-3 rounded-full transition-all duration-300 ${i === index ? 'w-8 bg-[#E8967D]' : 'w-3 bg-gray-300 hover:bg-gray-400'}" data-index="${i}"></button>`
        ).join('');

        dotsContainer.querySelectorAll('.testimonial-dot').forEach(dot => {
            dot.addEventListener('click', () => {
                currentTestimonial = parseInt(dot.dataset.index);
                showTestimonial(currentTestimonial);
            });
        });
    }
}

document.getElementById('nextTestimonial')?.addEventListener('click', () => {
    currentTestimonial = (currentTestimonial + 1) % testimonials.length;
    showTestimonial(currentTestimonial);
});

document.getElementById('prevTestimonial')?.addEventListener('click', () => {
    currentTestimonial = (currentTestimonial - 1 + testimonials.length) % testimonials.length;
    showTestimonial(currentTestimonial);
});

showTestimonial(0);
setInterval(() => {
    currentTestimonial = (currentTestimonial + 1) % testimonials.length;
    showTestimonial(currentTestimonial);
}, 5000);


$.ajax({
    type: "POST",
    url: "Chatbot.aspx/GetBotResponse",
    data: JSON.stringify({ message: "bonjour" }),
    contentType: "application/json; charset=utf-8",
    dataType: "json",
    success: function (response) {
        console.log(response.d);
    },
    error: function (err) {
        console.error(err);
    }
});

