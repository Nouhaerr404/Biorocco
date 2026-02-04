<%@ Page Title="Accueil - BIOROCCO" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="Default.aspx.cs" Inherits="Multi_cooperative._Default" %>
    <%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

        <asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
            <style>
                /* ===== VARIABLES ET RESET ===== */
                :root {
                    --primary: #E8967D;
                    --secondary: #2D5F3F;
                    --light: #F5F1E8;
                    --dark: #1a1a1a;
                    --border-radius: 12px;
                    --box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
                    --transition: all 0.3s ease;
                }

                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: 'Lora', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    color: #333;
                    background-color: #fff;
                    line-height: 1.6;
                    overflow-x: hidden;
                }

                h1,
                h2,
                h3,
                h4,
                h5,
                h6 {
                    font-family: 'Raleway', sans-serif;
                    font-weight: 600;
                }

                .container {
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 0 20px;
                }

                .btn {
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    padding: 12px 30px;
                    border-radius: 50px;
                    font-weight: 600;
                    text-decoration: none;
                    border: none;
                    cursor: pointer;
                    transition: var(--transition);
                    font-family: 'Raleway', sans-serif;
                }

                .btn-primary {
                    background-color: var(--primary);
                    color: white;
                }

                .btn-primary:hover {
                    background-color: #d87c62;
                    transform: translateY(-2px);
                    box-shadow: 0 10px 20px rgba(232, 150, 125, 0.2);
                }

                .btn-secondary {
                    background-color: var(--secondary);
                    color: white;
                }

                .btn-secondary:hover {
                    background-color: #244d33;
                    transform: translateY(-2px);
                }

                /* ===== SECTION NOTRE HISTOIRE ===== */
                .histoire-section {
                    background: linear-gradient(rgba(0, 0, 0, 0.6), rgba(0, 0, 0, 0.6)),
                        url('https://plus.unsplash.com/premium_photo-1675237625910-e5d354c03987?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D');
                    background-size: cover;
                    background-position: center;
                    background-attachment: fixed;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    color: white;
                    position: relative;
                    overflow: hidden;
                    padding-top: 200px;
                    margin-top: 0;
                }

                .histoire-section:before {
                    content: '';
                    position: absolute;
                    bottom: 0;
                    left: 0;
                    width: 100%;
                    height: 150px;
                    background: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1440 320'%3E%3Cpath fill='%23ffffff' fill-opacity='1' d='M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,192C672,181,768,139,864,138.7C960,139,1056,181,1152,181.3C1248,181,1344,139,1392,117.3L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z'%3E%3C/path%3E%3C/svg%3E") no-repeat;
                    background-size: cover;
                }

                .histoire-content {
                    position: relative;
                    z-index: 2;
                    text-align: center;
                    max-width: 1200px;
                    margin: 0 auto;
                    padding: 40px 20px;
                }

                .histoire-header {
                    margin-bottom: 60px;
                }

                .histoire-header .subtitle {
                    color: var(--primary);
                    font-size: 1.1rem;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    margin-bottom: 15px;
                    font-weight: 600;
                }

                .histoire-header .title {
                    font-size: 3.5rem;
                    color: white;
                    margin-bottom: 15px;
                    line-height: 1.2;
                    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
                }

                .histoire-header .tagline {
                    font-size: 1.2rem;
                    color: rgba(255, 255, 255, 0.9);
                    margin-bottom: 30px;
                    line-height: 1.8;
                    max-width: 800px;
                    margin-left: auto;
                    margin-right: auto;
                }

                .histoire-body {
                    background: rgba(255, 255, 255, 0.9);
                    border-radius: var(--border-radius);
                    padding: 50px;
                    color: #333;
                    box-shadow: var(--box-shadow);
                    max-width: 1000px;
                    margin: 0 auto;
                }

                .histoire-intro {
                    text-align: center;
                    margin-bottom: 40px;
                }

                .histoire-intro h3 {
                    color: var(--secondary);
                    font-size: 1.8rem;
                    margin-bottom: 20px;
                }

                .histoire-intro p {
                    font-size: 1.1rem;
                    color: #555;
                    line-height: 1.8;
                }

                .histoire-details {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 40px;
                    margin-bottom: 40px;
                }

                .histoire-mission h4 {
                    color: var(--secondary);
                    font-size: 1.5rem;
                    margin-bottom: 20px;
                }

                .histoire-mission p {
                    font-size: 1.1rem;
                    color: #555;
                    line-height: 1.8;
                    margin-bottom: 20px;
                }

                .histoire-image-container {
                    position: relative;
                    border-radius: var(--border-radius);
                    overflow: hidden;
                    box-shadow: var(--box-shadow);
                    height: 100%;
                    min-height: 300px;
                }

                .histoire-image {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    transition: transform 0.5s ease;
                }

                .histoire-image:hover {
                    transform: scale(1.05);
                }

                .histoire-image-overlay {
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: linear-gradient(to bottom, rgba(45, 95, 63, 0.2), rgba(232, 150, 125, 0.3));
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 20px;
                }

                .image-caption {
                    color: white;
                    text-align: center;
                    text-shadow: 1px 1px 3px rgba(0, 0, 0, 0.5);
                }

                .image-caption h4 {
                    font-size: 1.5rem;
                    margin-bottom: 10px;
                    color: white;
                }

                .image-caption p {
                    font-size: 1rem;
                    opacity: 0.9;
                }

                .histoire-stats {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 20px;
                    background: var(--secondary);
                    border-radius: var(--border-radius);
                    padding: 30px;
                    margin-top: 40px;
                    color: white;
                }

                .histoire-stat {
                    text-align: center;
                }

                .histoire-stat .number {
                    font-size: 2.5rem;
                    font-weight: 700;
                    color: var(--primary);
                    margin-bottom: 5px;
                }

                .histoire-stat .label {
                    font-size: 1rem;
                    color: rgba(255, 255, 255, 0.9);
                }

                /* ===== SECTION STATISTIQUES ===== */
                .stats-section {
                    background-color: var(--light);
                    padding: 80px 0;
                    position: relative;
                }

                .stats-container {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                    gap: 30px;
                }

                .stat-item {
                    text-align: center;
                    padding: 30px;
                    background: white;
                    border-radius: var(--border-radius);
                    box-shadow: var(--box-shadow);
                    transition: var(--transition);
                }

                .stat-item:hover {
                    transform: translateY(-10px);
                    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                }

                .stat-number {
                    font-size: 3rem;
                    font-weight: 700;
                    color: var(--primary);
                    display: block;
                    margin-bottom: 10px;
                }

                .stat-label {
                    font-size: 1.1rem;
                    color: var(--secondary);
                    font-weight: 600;
                }

                /* ===== SECTION PRODUITS ===== */
                .products-section {
                    padding: 100px 0;
                    background: white;
                }

                .section-title {
                    text-align: center;
                    margin-bottom: 50px;
                }

                .section-title h2 {
                    font-size: 2.5rem;
                    color: var(--primary);
                    margin-bottom: 15px;
                }

                .section-title p {
                    color: #666;
                    font-size: 1.1rem;
                    max-width: 600px;
                    margin: 0 auto;
                }

                /* Tabs Navigation */
                .tabs-nav {
                    display: flex;
                    justify-content: center;
                    gap: 15px;
                    margin-bottom: 40px;
                    flex-wrap: wrap;
                }

                .tab-btn {
                    padding: 12px 30px;
                    border-radius: 50px;
                    border: 2px solid var(--light);
                    background: white;
                    color: var(--secondary);
                    font-weight: 600;
                    cursor: pointer;
                    transition: var(--transition);
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    font-family: 'Raleway', sans-serif;
                }

                .tab-btn:hover,
                .tab-btn.active {
                    background: var(--primary);
                    color: white;
                    border-color: var(--primary);
                }

                /* Correction pour les boutons ASP.NET */
                .tab-btn input[type="submit"] {
                    background: none;
                    border: none;
                    color: inherit;
                    font: inherit;
                    cursor: pointer;
                    width: 100%;
                    height: 100%;
                }

                /* Products Grid */
                .products-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                    gap: 30px;
                    margin-top: 30px;
                }

                .product-card {
                    background: white;
                    border-radius: var(--border-radius);
                    overflow: hidden;
                    box-shadow: var(--box-shadow);
                    transition: var(--transition);
                    position: relative;
                }

                .product-card:hover {
                    transform: translateY(-10px);
                    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
                }

                .product-image {
                    height: 250px;
                    width: 100%;
                    object-fit: cover;
                    transition: transform 0.5s ease;
                }

                .product-card:hover .product-image {
                    transform: scale(1.05);
                }

                .product-badge {
                    position: absolute;
                    top: 15px;
                    left: 15px;
                    background: var(--primary);
                    color: white;
                    padding: 5px 15px;
                    border-radius: 20px;
                    font-size: 0.8rem;
                    font-weight: 600;
                    z-index: 2;
                }

                .wishlist-btn {
                    position: absolute;
                    top: 15px;
                    right: 15px;
                    background: rgba(255, 255, 255, 0.9);
                    backdrop-filter: blur(10px);
                    border: none;
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    transition: var(--transition);
                    z-index: 2;
                }

                .wishlist-btn:hover {
                    background: var(--primary);
                    color: white;
                }

                .product-info {
                    padding: 20px;
                }

                .product-title {
                    font-size: 1.2rem;
                    color: var(--secondary);
                    margin-bottom: 10px;
                    min-height: 56px;
                }

                .product-rating {
                    display: flex;
                    align-items: center;
                    gap: 5px;
                    margin-bottom: 15px;
                }

                .star {
                    color: #FFD700;
                }

                .rating-number {
                    color: #666;
                    font-size: 0.9rem;
                }

                .product-price {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-top: 15px;
                }

                .price {
                    font-size: 1.5rem;
                    font-weight: 700;
                    color: var(--primary);
                }

                /* Correction pour le bouton Add to Cart */
                .add-to-cart {
                    background: var(--primary);
                    color: white;
                    border: none;
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    transition: var(--transition);
                    font-size: 16px;
                }

                .add-to-cart:hover {
                    background: var(--secondary);
                    transform: scale(1.1);
                }

                .add-to-cart:disabled {
                    opacity: 0.6;
                    cursor: not-allowed;
                }

                /* ===== SECTION SOLUTIONS NATURELLES ===== */
                .solutions-section {
                    padding: 100px 0;
                    background: linear-gradient(135deg, #F9F5F0 0%, #FFF8F3 100%);
                    position: relative;
                    overflow: hidden;
                }

                .solutions-section:before {
                    content: '';
                    position: absolute;
                    top: 0;
                    left: 0;
                    right: 0;
                    bottom: 0;
                    background: url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" viewBox="0 0 100 100"><path fill="%232D5F3F" opacity="0.03" d="M50,0 C77.614,0 100,22.386 100,50 C100,77.614 77.614,100 50,100 C22.386,100 0,77.614 0,50 C0,22.386 22.386,0 50,0 Z M50,10 C27.909,10 10,27.909 10,50 C10,72.091 27.909,90 50,90 C72.091,90 90,72.091 90,50 C90,27.909 72.091,10 50,10 Z"></path></svg>');
                }

                .solutions-content {
                    display: grid;
                    grid-template-columns: 1fr 1fr;
                    gap: 60px;
                    align-items: center;
                    position: relative;
                    z-index: 1;
                }

                .solutions-text {
                    text-align: left;
                }

                .solutions-subtitle {
                    color: var(--primary);
                    font-size: 1.1rem;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                    margin-bottom: 15px;
                }

                .solutions-title {
                    font-size: 2.8rem;
                    color: var(--secondary);
                    margin-bottom: 20px;
                    line-height: 1.2;
                }

                .solutions-description {
                    font-size: 1.2rem;
                    color: #666;
                    margin-bottom: 30px;
                    line-height: 1.8;
                }

                .solutions-features {
                    list-style: none;
                    margin-bottom: 30px;
                }

                .solutions-features li {
                    margin-bottom: 15px;
                    padding-left: 30px;
                    position: relative;
                    color: var(--secondary);
                    font-size: 1.1rem;
                }

                .solutions-features li:before {
                    content: '✓';
                    position: absolute;
                    left: 0;
                    color: var(--primary);
                    font-weight: bold;
                    font-size: 1.2rem;
                }

                .solutions-image-container {
                    position: relative;
                }

                .solutions-image {
                    width: 100%;
                    height: 500px;
                    object-fit: cover;
                    border-radius: var(--border-radius);
                    box-shadow: var(--box-shadow);
                    animation: float 6s ease-in-out infinite;
                }

                .floating-element {
                    position: absolute;
                    animation: float 3s ease-in-out infinite;
                }

                .floating-1 {
                    top: -30px;
                    right: -30px;
                    background: var(--primary);
                    width: 80px;
                    height: 80px;
                    border-radius: 50%;
                    animation-delay: 0.5s;
                }

                .floating-2 {
                    bottom: 40px;
                    left: -40px;
                    background: var(--secondary);
                    width: 60px;
                    height: 60px;
                    border-radius: 20px;
                    animation-delay: 1s;
                }

                .floating-3 {
                    top: 40%;
                    right: -20px;
                    background: #FFD700;
                    width: 40px;
                    height: 40px;
                    border-radius: 50%;
                    animation-delay: 1.5s;
                }

                /* ===== SECTION TÉMOIGNAGES ===== */
                .testimonials-section {
                    padding: 100px 0;
                    background: white;
                }

                .testimonial-slider {
                    position: relative;
                    max-width: 800px;
                    margin: 0 auto;
                }

                .testimonial-card {
                    background: white;
                    border-radius: var(--border-radius);
                    padding: 40px;
                    box-shadow: var(--box-shadow);
                    position: relative;
                    overflow: hidden;
                }

                .quote-icon {
                    position: absolute;
                    top: 20px;
                    right: 20px;
                    font-size: 60px;
                    color: var(--light);
                    opacity: 0.3;
                }

                .rating-stars {
                    display: flex;
                    gap: 5px;
                    margin-bottom: 20px;
                    justify-content: center;
                }

                .testimonial-text {
                    font-size: 1.2rem;
                    font-style: italic;
                    text-align: center;
                    margin-bottom: 30px;
                    color: var(--secondary);
                }

                .testimonial-author {
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 15px;
                }

                .author-image {
                    width: 60px;
                    height: 60px;
                    border-radius: 50%;
                    object-fit: cover;
                    border: 3px solid var(--primary);
                }

                .author-info {
                    text-align: left;
                }

                .author-name {
                    font-weight: 600;
                    color: var(--secondary);
                }

                .author-location {
                    color: #666;
                    font-size: 0.9rem;
                }

                .slider-controls {
                    display: flex;
                    justify-content: center;
                    gap: 20px;
                    margin-top: 40px;
                }

                .slider-btn {
                    background: white;
                    border: 2px solid var(--light);
                    width: 50px;
                    height: 50px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    cursor: pointer;
                    transition: var(--transition);
                }

                .slider-btn:hover {
                    background: var(--primary);
                    color: white;
                    border-color: var(--primary);
                }

                .slider-dots {
                    display: flex;
                    justify-content: center;
                    gap: 10px;
                    margin-top: 20px;
                }

                .dot {
                    width: 12px;
                    height: 12px;
                    border-radius: 50%;
                    background: #ddd;
                    cursor: pointer;
                    transition: var(--transition);
                }

                .dot.active {
                    background: var(--primary);
                    width: 30px;
                    border-radius: 10px;
                }

                .trust-indicators {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                    gap: 30px;
                    margin-top: 60px;
                }

                .trust-item {
                    text-align: center;
                    padding: 30px;
                    background: white;
                    border-radius: var(--border-radius);
                    box-shadow: var(--box-shadow);
                }

                .trust-number {
                    font-size: 2.5rem;
                    font-weight: 700;
                    color: var(--primary);
                    margin-bottom: 10px;
                }

                .trust-label {
                    color: var(--secondary);
                    font-weight: 600;
                }

                /* ===== SECTION NEWSLETTER ===== */
                .newsletter-section {
                    padding: 80px 0;
                    background: linear-gradient(135deg, var(--primary) 0%, #f5c8ba 100%);
                    color: white;
                }

                .newsletter-content {
                    text-align: center;
                    max-width: 600px;
                    margin: 0 auto;
                }

                .newsletter-title {
                    font-size: 2.5rem;
                    margin-bottom: 20px;
                    color: white;
                }

                .newsletter-description {
                    margin-bottom: 30px;
                    opacity: 0.9;
                }

                .newsletter-form {
                    display: flex;
                    gap: 10px;
                    max-width: 500px;
                    margin: 0 auto;
                }

                .newsletter-input {
                    flex: 1;
                    padding: 15px 25px;
                    border: none;
                    border-radius: 50px;
                    font-size: 1rem;
                }

                .newsletter-btn {
                    padding: 15px 30px;
                    background: var(--secondary);
                    color: white;
                    border: none;
                    border-radius: 50px;
                    cursor: pointer;
                    font-weight: 600;
                    transition: var(--transition);
                }

                .newsletter-btn:hover {
                    background: #244d33;
                }

                /* ===== ANIMATIONS ===== */
                @keyframes fadeInUp {
                    from {
                        opacity: 0;
                        transform: translateY(30px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                @keyframes fadeIn {
                    from {
                        opacity: 0;
                    }

                    to {
                        opacity: 1;
                    }
                }

                .product-card {
                    animation: fadeInUp 0.5s ease backwards;
                }

                .animate-fade-in-up {
                    animation: fadeInUp 0.6s ease forwards;
                }

                .animate-delay-1 {
                    animation-delay: 0.2s;
                }

                .animate-delay-2 {
                    animation-delay: 0.4s;
                }

                .animate-delay-3 {
                    animation-delay: 0.6s;
                }

                @keyframes float {
                    0% {
                        transform: translateY(0px);
                    }

                    50% {
                        transform: translateY(-15px);
                    }

                    100% {
                        transform: translateY(0px);
                    }
                }

                .floating {
                    animation: float 3s ease-in-out infinite;
                }

                @keyframes pulse {
                    0% {
                        transform: scale(1);
                    }

                    50% {
                        transform: scale(1.05);
                    }

                    100% {
                        transform: scale(1);
                    }
                }

                /* ===== RESPONSIVE ===== */
                @media (max-width: 768px) {
                    .histoire-header .title {
                        font-size: 2.5rem;
                    }

                    .histoire-header .tagline {
                        font-size: 1.1rem;
                    }

                    .histoire-body {
                        padding: 30px;
                    }

                    .histoire-details {
                        grid-template-columns: 1fr;
                        gap: 30px;
                    }

                    .histoire-image-container {
                        min-height: 250px;
                        order: 2;
                    }

                    .histoire-mission {
                        order: 1;
                    }

                    .solutions-content {
                        grid-template-columns: 1fr;
                        text-align: center;
                    }

                    .solutions-text {
                        text-align: center;
                    }

                    .solutions-image {
                        height: 400px;
                    }

                    .tabs-nav {
                        flex-direction: column;
                        align-items: center;
                    }

                    .tab-btn {
                        width: 100%;
                        max-width: 300px;
                    }

                    .products-grid {
                        grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
                    }

                    .newsletter-form {
                        flex-direction: column;
                    }

                    .newsletter-input,
                    .newsletter-btn {
                        width: 100%;
                    }
                }

                @media (max-width: 480px) {
                    .histoire-header .title {
                        font-size: 2rem;
                    }

                    .histoire-header .tagline {
                        font-size: 1rem;
                    }

                    .histoire-intro h3 {
                        font-size: 1.5rem;
                    }

                    .section-title h2 {
                        font-size: 2rem;
                    }

                    .solutions-title {
                        font-size: 2.2rem;
                    }

                    .products-grid {
                        grid-template-columns: 1fr;
                    }

                    .testimonial-card {
                        padding: 20px;
                    }

                    .histoire-stats {
                        grid-template-columns: 1fr;
                    }
                }

                /* Pour centrer le texte dans la section histoire-mission */
                .histoire-mission {
                    text-align: center;
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    height: 100%;
                }

                /* Pour retirer les espaces en haut et en bas de l'image */
                .histoire-image-container {
                    height: 100%;
                    margin: 0;
                    padding: 0;
                    border-radius: var(--border-radius);
                    overflow: hidden;
                }

                .histoire-image {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    display: block;
                }
            </style>

            <!-- Appel du Header -->
            <uc:Header ID="Header1" runat="server" />

            <div class="min-h-screen bg-white">
                <!-- Section Notre Histoire -->
                <section class="histoire-section" id="histoire">
                    <div class="container">
                        <div class="histoire-content">
                            <div class="histoire-header">
                                <div class="subtitle animate__animated animate__fadeIn animate__delay-1s">COOPÉRATIVE
                                    SOLIDAIRE DU MAROC</div>
                                <h1 class="title animate__animated animate__fadeInUp">Trésors Du Terroir Marocain</h1>
                                <p class="tagline animate__animated animate__fadeIn animate__delay-2s">
                                    Découvrez l'authenticité de nos produits 100% naturels : huile d'argan, miels rares,
                                    amandes, crèmes et bienfaits.
                                </p>
                                <div class="animate__animated animate__fadeInUp animate__delay-3s">
                                    <a href="#produits" class="btn btn-primary me-3"><i
                                            class="fas fa-shopping-basket me-2"></i> Découvrir nos produits</a>
                                    <a href="#solutions" class="btn btn-secondary"><i class="fas fa-spa me-2"></i> Nos
                                        solutions</a>
                                </div>
                            </div>

                            <div class="histoire-body animate__animated animate__fadeInUp">
                                <div class="histoire-details">
                                    <div class="histoire-mission">
                                        <h4>NOTRE HISTOIRE</h4>
                                        <h4 style="color: var(--primary); margin-bottom: 15px;">Une Tradition Millénaire
                                        </h4>
                                        <p>
                                            Fondée en 2005, notre coopérative perpétue les savoir-faire ancestraux du
                                            Maroc.
                                            Nous rassemblons plus de 200 producteurs répartis dans les régions du Souss,
                                            de l'Atlas et du Rif.
                                        </p>
                                    </div>

                                    <div class="histoire-image-container">
                                        <img src="https://images.unsplash.com/photo-1631447661435-b86ae5ecd564?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                                            alt="Producteurs marocains travaillant dans les champs d'arganiers"
                                            class="histoire-image">
                                        <div class="histoire-image-overlay">
                                            <div class="image-caption">
                                                <h4>Nos Valeurs</h4>
                                                <p>Authenticité • Durabilité • Solidarité</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                            </div>
                        </div>
                    </div>
                </section>

                <!-- Section Statistiques -->
                <section class="stats-section">
                    <div class="container">
                        <div class="stats-container">
                            <div class="stat-item floating">
                                <span class="stat-number" data-count="200">0</span>
                                <span class="stat-label">Coopérateurs</span>
                            </div>
                            <div class="stat-item floating" style="animation-delay: 0.2s;">
                                <span class="stat-number" data-count="100">0</span>
                                <span class="stat-label">% Bio</span>
                            </div>
                            <div class="stat-item floating" style="animation-delay: 0.4s;">
                                <span class="stat-number" data-count="15">0</span>
                                <span class="stat-label">Régions</span>
                            </div>
                            <div class="stat-item floating" style="animation-delay: 0.6s;">
                                <span class="stat-number" data-count="25">0</span>
                                <span class="stat-label">Prix & Distinctions</span>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Section Produits -->
                <section class="products-section" id="produits">
                    <div class="container">
                        <div class="section-title">
                            <h2>Nos Produits</h2>
                            <p>Découvrez notre sélection de produits naturels et bio</p>
                        </div>

                        <!-- Tabs Navigation -->
                        <div class="tabs-nav">
                            <asp:Button ID="btnTabNew" runat="server" CssClass="tab-btn active" CommandArgument="new"
                                OnClick="TabButton_Click" Text="Nouveaux Produits" />

                            <asp:Button ID="btnTabTrending" runat="server" CssClass="tab-btn" CommandArgument="trending"
                                OnClick="TabButton_Click" Text="Les Plus Recherchés" />
                        </div>

                        <!-- Products Grid -->
                        <div class="products-grid" id="products-grid">
                            <div class="col-span-full text-center py-5" id="loadingProducts" style="display: none;">
                                <div
                                    style="display: inline-block; width: 50px; height: 50px; border: 4px solid var(--light); border-top-color: var(--primary); border-radius: 50%; animation: spin 1s linear infinite;">
                                </div>
                                <p style="margin-top: 15px; color: var(--secondary); font-weight: 500;">Chargement des
                                    produits...</p>
                            </div>
                            <asp:Repeater ID="rptProductsGrid" runat="server"
                                OnItemDataBound="rptProductsGrid_ItemDataBound">
                                <ItemTemplate>
                                    <div class="product-card animate-fade-in-up">
                                        <asp:Label ID="lblBadge" runat="server" CssClass="product-badge"
                                            Text='<%# Eval("Badge") %>'></asp:Label>



                                        <img src='<%# GetImageUrl(Eval("ImageUrl")) %>' alt='<%# Eval("Name") %>'
                                            class="product-image">

                                        <div class="product-info">
                                            <h3 class="product-title">
                                                <%# Eval("Name") %>
                                            </h3>
                                            <div class="product-rating">
                                                <%# GetStarRating(Eval("AvgRating")) %>
                                                    <span class="rating-number">(<%# Eval("AvgRating", "{0:F1}" ) %>
                                                            )</span>
                                            </div>
                                            <div class="product-price">
                                                <span class="price">
                                                    <%# GetFormattedPrice(Eval("Price")) %>
                                                </span>
                                                <asp:Button ID="btnAddToCart" runat="server" CssClass="add-to-cart"
                                                    CommandArgument='<%# Eval("ProductId") %>'
                                                    OnClick="btnAddToCart_Click" Text="🛒" UseSubmitBehavior="false"
                                                    OnClientClick='<%# "return addToCartHome(" + Eval("ProductId") + ");" %>' />
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <!-- Message si aucun produit -->
                            <asp:Panel ID="pnlNoProducts" runat="server" Visible="false"
                                CssClass="col-span-full text-center py-12" style="display: none;">
                                <div class="text-gray-500">
                                    <i class="fas fa-box-open text-5xl mb-4"></i>
                                    <p class="text-xl">Aucun produit disponible</p>
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </section>

                <!-- Section Solutions Naturelles -->
                <section class="solutions-section" id="solutions">
                    <div class="container">
                        <div class="solutions-content">
                            <div class="solutions-text">
                                <div class="solutions-subtitle animate-fade-in-up">Nos solutions naturelles</div>
                                <h2 class="solutions-title animate-fade-in-up animate-delay-1">"Osez le Naturel"</h2>
                                <p class="solutions-description animate-fade-in-up animate-delay-2">
                                    Inspirée par les recettes traditionnelles Marocaines, notre marque réinvente
                                    nos rituels de beauté les plus anciens pour les remettre au goût du jour.
                                </p>
                                <ul class="solutions-features animate-fade-in-up animate-delay-3">
                                    <li>Formulations 100% naturelles et biologiques</li>
                                    <li>Recettes traditionnelles réinterprétées</li>
                                    <li>Ingrédients locaux et équitables</li>
                                    <li>Respect des savoir-faire ancestraux</li>
                                    <li>Efficacité prouvée par des générations</li>
                                </ul>
                                <a href="Products.aspx" class="btn btn-primary animate-fade-in-up animate-delay-3">
                                    <i class="fas fa-leaf me-2"></i> Découvrir nos solutions
                                </a>
                            </div>
                            <div class="solutions-image-container animate-fade-in-up animate-delay-2">
                                <img src="https://images.unsplash.com/photo-1694539181840-a8bf5b855b68?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
                                    alt="Produits naturels marocains" class="solutions-image">
                                <div class="floating-element floating-1"></div>
                                <div class="floating-element floating-2"></div>
                                <div class="floating-element floating-3"></div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Section Témoignages -->
                <section class="testimonials-section" id="temoignages">
                    <div class="container">
                        <div class="section-title">
                            <h2>Ce Que Disent Nos Clients</h2>
                            <p>Découvrez les avis authentiques de notre communauté</p>
                        </div>

                        <div class="testimonial-slider">
                            <!-- Le slider sera chargé dynamiquement par JavaScript -->
                        </div>
                    </div>
                </section>

                <!-- Section Newsletter -->
                <section class="newsletter-section" id="contact">
                    <div class="container">
                        <div class="newsletter-content">
                            <h2 class="newsletter-title">Restez Informés</h2>
                            <p class="newsletter-description">
                                Inscrivez-vous à notre newsletter pour recevoir nos nouveautés, offres spéciales
                                et actualités de la coopérative.
                            </p>

                            <div class="newsletter-form">
                                <asp:TextBox ID="txtNewsletterEmail" runat="server" CssClass="newsletter-input"
                                    placeholder="Votre adresse email" TextMode="Email"></asp:TextBox>
                                <asp:Button ID="btnSubscribe" runat="server" CssClass="newsletter-btn" Text="S'inscrire"
                                    OnClick="btnSubscribe_Click" />
                            </div>

                            <asp:Label ID="lblNewsletterMessage" runat="server" CssClass="newsletter-message"
                                style="display: none; color: white; margin-top: 10px;"></asp:Label>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Appel du Footer -->

            <script>
                // Données des témoignages
                const testimonialsData = [
                    {
                        id: 1,
                        name: 'Fatima Zahra',
                        location: 'Casablanca',
                        rating: 5,
                        text: 'Les produits BIOROCCO ont transformé ma routine beauté ! L\'huile d\'argan est d\'une qualité exceptionnelle et ma peau n\'a jamais été aussi éclatante.',
                        image: 'https://plus.unsplash.com/premium_photo-1718570253383-68418c73ac60?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8Z2VucyUyMG1hcm9jYWluc3xlbnwwfHwwfHx8MA%3D%3D',
                        color: '#E8967D',
                    },
                    {
                        id: 2,
                        name: 'Karim Bennani',
                        location: 'Marrakech',
                        rating: 5,
                        text: 'Livraison rapide et produits authentiques. Le savon beldi est exactement comme celui que j\'utilisais au hammam traditionnel. Merci BIOROCCO !',
                        image: 'https://images.unsplash.com/photo-1673709149285-def61e3f8c37?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8Z2VucyUyMG1hcm9jYWluc3xlbnwwfHwwfHx8MA%3D%3D',
                        color: '#2D5F3F',
                    },
                    {
                        id: 3,
                        name: 'Ahmed Idrissi',
                        location: 'Rabat',
                        rating: 5,
                        text: 'Je recommande à 100% ! Les crèmes à base de rose du Maroc sentent divinement bon et sont très efficaces. Mon investissement beauté préféré.',
                        image: 'https://images.unsplash.com/photo-1520123704147-ed3a34036262?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8Z2VucyUyMG1hcm9jYWluc3xlbnwwfHwwfHx8MA%3D%3D',
                        color: '#F5F1E8',
                    }
                ];

                // Service URL
                const homeServiceUrl = '<%= ResolveUrl("~/HomeService.asmx") %>';

                // Fonction pour charger les produits par type via AJAX (SANS RELOAD)
                function loadProductsByType(tabType, buttonElement) {
                    // Empêcher le comportement par défaut si c'est un lien
                    if (event) {
                        event.preventDefault();
                        event.stopPropagation();
                    }

                    // Mettre à jour les tabs actifs avec animation
                    document.querySelectorAll('.tab-btn').forEach(btn => {
                        btn.classList.remove('active');
                        btn.style.transform = 'scale(0.95)';
                    });

                    if (buttonElement) {
                        buttonElement.classList.add('active');
                        buttonElement.style.transform = 'scale(1)';
                    }

                    // Afficher le loader avec animation
                    const productsGrid = document.getElementById('products-grid');
                    const loadingDiv = document.getElementById('loadingProducts');
                    const noProductsDiv = document.getElementById('<%= pnlNoProducts.ClientID %>');
                    const repeater = productsGrid.querySelector('asp\\:repeater, [id*="rptProductsGrid"]');

                    // Cacher le repeater ASP.NET
                    if (repeater) {
                        repeater.style.display = 'none';
                    }

                    if (loadingDiv) {
                        loadingDiv.style.display = 'block';
                        loadingDiv.style.animation = 'fadeIn 0.3s ease';
                    }
                    if (noProductsDiv) noProductsDiv.style.display = 'none';

                    // Fade out avec animation fluide
                    productsGrid.style.opacity = '0.3';
                    productsGrid.style.transform = 'translateY(10px)';
                    productsGrid.style.transition = 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)';

                    // Appel AJAX
                    jQuery.ajax({
                        type: 'POST',
                        url: homeServiceUrl + '/GetProductsByType',
                        data: JSON.stringify({ tabType: tabType }),
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function (response) {
                            if (loadingDiv) {
                                loadingDiv.style.display = 'none';
                            }

                            if (response.d && response.d.success && response.d.data) {
                                // Rendre les produits avec animation
                                renderProducts(response.d.data);

                                // Animation d'entrée fluide
                                setTimeout(() => {
                                    productsGrid.style.opacity = '1';
                                    productsGrid.style.transform = 'translateY(0)';
                                }, 50);
                            } else {
                                productsGrid.innerHTML = '<div class="col-span-full text-center py-12" style="animation: fadeIn 0.5s ease;"><div class="text-gray-500"><i class="fas fa-box-open text-5xl mb-4"></i><p class="text-xl">Aucun produit disponible</p></div></div>';
                                productsGrid.style.opacity = '1';
                                productsGrid.style.transform = 'translateY(0)';
                            }
                        },
                        error: function (xhr, status, error) {
                            if (loadingDiv) loadingDiv.style.display = 'none';
                            console.error('Erreur lors du chargement des produits:', error);
                            productsGrid.innerHTML = '<div class="col-span-full text-center py-12" style="animation: fadeIn 0.5s ease;"><div class="text-danger"><i class="fas fa-exclamation-triangle text-5xl mb-4"></i><p class="text-xl">Erreur lors du chargement</p></div></div>';
                            productsGrid.style.opacity = '1';
                            productsGrid.style.transform = 'translateY(0)';
                        }
                    });

                    return false; // Empêcher tout postback
                }

                // Fonction pour rendre les produits avec animations fluides
                function renderProducts(products) {
                    const productsGrid = document.getElementById('products-grid');
                    const isLoggedIn = <%= Session["UserId"] != null ? "true" : "false" %>;

                    if (!products || products.length === 0) {
                        productsGrid.innerHTML = '<div class="col-span-full text-center py-12" style="animation: fadeIn 0.5s ease;"><div class="text-gray-500"><i class="fas fa-box-open text-5xl mb-4"></i><p class="text-xl">Aucun produit disponible</p></div></div>';
                        return;
                    }

                    let html = '';
                    products.forEach((product, index) => {
                        const imageUrl = product.imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300';
                        const price = parseFloat(product.price || 0).toFixed(2);
                        const rating = parseFloat(product.avgRating || 4.5).toFixed(1);
                        const stars = generateStars(parseFloat(rating));
                        const badgeColor = product.badge === 'Nouveau' ? '#E8967D' : '#2D5F3F';
                        const animationDelay = index * 0.1; // Délai progressif pour chaque carte

                        html += `
                    <div class="product-card animate-fade-in-up" style="animation-delay: ${animationDelay}s; opacity: 0;">
                        <div class="product-badge" style="background-color: ${badgeColor};">${product.badge}</div>
                        <button class="wishlist-btn" onclick="toggleWishlist(this); return false;">
                            <i class="far fa-heart"></i>
                        </button>
                        <img src="${imageUrl}" alt="${product.name}" class="product-image" onerror="this.src='https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300'">
                        <div class="product-info">
                            <h3 class="product-title">${product.name}</h3>
                            <div class="product-rating">
                                ${stars}
                                <span class="rating-number">(${rating})</span>
                            </div>
                            <div class="product-price">
                                <span class="price">${price} MAD</span>
                                <button class="add-to-cart" onclick="addToCartHome(${product.productId}); return false;" ${!isLoggedIn ? 'disabled' : ''}>🛒</button>
                            </div>
                        </div>
                    </div>
                `;
                    });

                    productsGrid.innerHTML = html;

                    // Animer l'apparition des cartes une par une
                    const cards = productsGrid.querySelectorAll('.product-card');
                    cards.forEach((card, index) => {
                        setTimeout(() => {
                            card.style.opacity = '1';
                            card.style.transform = 'translateY(0)';
                        }, index * 50);
                    });
                }

                // Fonction pour ajouter au panier depuis la page d'accueil
                function addToCartHome(productId) {
                    // Vérifier si l'utilisateur est connecté
                    const isLoggedIn = <%= Session["UserId"] != null ? "true" : "false" %>;

                    if (!isLoggedIn) {
                        // Rediriger vers la page de login
                        window.location.href = 'Login.aspx?returnUrl=' + encodeURIComponent(window.location.pathname);
                        return false;
                    }

                    // Appel AJAX pour ajouter au panier
                    jQuery.ajax({
                        type: 'POST',
                        url: '<%= ResolveUrl("~/Default.aspx/AddToCartAjax") %>',
                        data: JSON.stringify({ productId: productId }),
                        contentType: 'application/json; charset=utf-8',
                        dataType: 'json',
                        success: function (response) {
                            if (response.d && response.d.success) {
                                showNotification('Produit ajouté au panier avec succès', 'success');
                            } else {
                                showNotification('Erreur lors de l\'ajout au panier', 'error');
                            }
                        },
                        error: function () {
                            showNotification('Erreur lors de l\'ajout au panier', 'error');
                        }
                    });

                    return false;
                }

                // Fonction pour basculer les favoris
                function toggleWishlist(button) {
                    const icon = button.querySelector('i');
                    if (icon.classList.contains('far')) {
                        icon.classList.remove('far');
                        icon.classList.add('fas');
                        button.style.color = '#E8967D';
                        showNotification('Ajouté aux favoris', 'success');
                    } else {
                        icon.classList.remove('fas');
                        icon.classList.add('far');
                        button.style.color = '';
                        showNotification('Retiré des favoris', 'info');
                    }
                }

                // Fonction pour générer les étoiles
                function generateStars(rating) {
                    let stars = '';
                    for (let i = 1; i <= 5; i++) {
                        if (i <= rating) {
                            stars += '<i class="fas fa-star star"></i>';
                        } else {
                            stars += '<i class="far fa-star star"></i>';
                        }
                    }
                    return stars;
                }

                // Fonction pour initialiser le slider des témoignages
                function initTestimonialSlider() {
                    const slider = document.querySelector('.testimonial-slider');
                    if (!slider) return;

                    let currentSlide = 0;

                    function showSlide(index) {
                        const testimonial = testimonialsData[index];
                        slider.innerHTML = `
                    <div class="testimonial-card" style="background-color: ${testimonial.color}">
                        <div class="quote-icon">
                            <i class="fas fa-quote-right"></i>
                        </div>
                        <div class="rating-stars">
                            ${generateStars(testimonial.rating)}
                        </div>
                        <p class="testimonial-text" style="color: ${testimonial.color === '#F5F1E8' ? '#2D5F3F' : 'white'}">
                            "${testimonial.text}"
                        </p>
                        <div class="testimonial-author">
                            <img src="${testimonial.image}" alt="${testimonial.name}" class="author-image">
                            <div class="author-info">
                                <div class="author-name" style="color: ${testimonial.color === '#F5F1E8' ? '#2D5F3F' : 'white'}">
                                    ${testimonial.name}
                                </div>
                                <div class="author-location" style="color: ${testimonial.color === '#F5F1E8' ? '#666' : 'rgba(255,255,255,0.8)'}">
                                    ${testimonial.location}
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="slider-controls">
                        <button class="slider-btn prev-slide">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <div class="slider-dots">
                            ${testimonialsData.map((_, i) => `
                                <span class="dot ${i === currentSlide ? 'active' : ''}" data-index="${i}"></span>
                            `).join('')}
                        </div>
                        <button class="slider-btn next-slide">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    </div>
                    <div class="trust-indicators">
                        <div class="trust-item">
                            <div class="trust-number">10K+</div>
                            <div class="trust-label">Avis Vérifiés</div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-number">4.9/5</div>
                            <div class="trust-label">Note Moyenne</div>
                        </div>
                        <div class="trust-item">
                            <div class="trust-number">98%</div>
                            <div class="trust-label">Satisfaction Client</div>
                        </div>
                    </div>
                `;

                        // Ajouter les event listeners
                        const prevBtn = slider.querySelector('.prev-slide');
                        const nextBtn = slider.querySelector('.next-slide');
                        const dots = slider.querySelectorAll('.dot');

                        if (prevBtn) {
                            prevBtn.addEventListener('click', () => {
                                currentSlide = (currentSlide - 1 + testimonialsData.length) % testimonialsData.length;
                                showSlide(currentSlide);
                            });
                        }

                        if (nextBtn) {
                            nextBtn.addEventListener('click', () => {
                                currentSlide = (currentSlide + 1) % testimonialsData.length;
                                showSlide(currentSlide);
                            });
                        }

                        dots.forEach(dot => {
                            dot.addEventListener('click', () => {
                                currentSlide = parseInt(dot.dataset.index);
                                showSlide(currentSlide);
                            });
                        });
                    }

                    showSlide(currentSlide);

                    // Auto-slide
                    setInterval(() => {
                        currentSlide = (currentSlide + 1) % testimonialsData.length;
                        showSlide(currentSlide);
                    }, 5000);
                }

                // Fonction pour animer les compteurs
                function animateCounter(element) {
                    const target = parseInt(element.getAttribute('data-count'));
                    const increment = target / 100;
                    let current = 0;

                    const timer = setInterval(() => {
                        current += increment;
                        element.textContent = Math.round(current);

                        if (current >= target) {
                            element.textContent = target;
                            clearInterval(timer);
                        }
                    }, 20);
                }

                // Initialisation complète
                document.addEventListener('DOMContentLoaded', function () {
                    console.log('Page d\'accueil initialisée');

                    // Initialiser le slider des témoignages
                    initTestimonialSlider();

                    // Initialiser les tabs - charger les produits par défaut si pas encore chargés
                    const activeTab = document.querySelector('.tab-btn.active');
                    if (activeTab && activeTab.dataset.tab) {
                        // Les produits sont déjà chargés côté serveur, pas besoin de recharger
                    }

                    // Animation des compteurs dans la section Notre Histoire
                    const histoireSection = document.getElementById('histoire');
                    if (histoireSection) {
                        const histoireObserver = new IntersectionObserver((entries) => {
                            entries.forEach(entry => {
                                if (entry.isIntersecting) {
                                    const counters = document.querySelectorAll('.histoire-stat .number');
                                    counters.forEach(counter => {
                                        animateCounter(counter);
                                    });
                                    histoireObserver.unobserve(entry.target);
                                }
                            });
                        }, { threshold: 0.3 });

                        histoireObserver.observe(histoireSection);
                    }

                    // Animation des compteurs dans la section statistiques
                    const observer = new IntersectionObserver((entries) => {
                        entries.forEach(entry => {
                            if (entry.isIntersecting) {
                                const statNumber = entry.target.querySelector('.stat-number');
                                if (statNumber) {
                                    animateCounter(statNumber);
                                    observer.unobserve(entry.target);
                                }
                            }
                        });
                    }, { threshold: 0.5 });

                    // Observer tous les éléments de statistiques
                    document.querySelectorAll('.stat-item').forEach(item => {
                        observer.observe(item);
                    });

                    // Smooth scroll pour les ancres internes
                    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
                        anchor.addEventListener('click', function (e) {
                            const href = this.getAttribute('href');
                            if (href === '#' || href.startsWith('#!')) return;

                            e.preventDefault();
                            const targetId = href;
                            const targetElement = document.querySelector(targetId);

                            if (targetElement) {
                                window.scrollTo({
                                    top: targetElement.offsetTop - 80,
                                    behavior: 'smooth'
                                });
                            }
                        });
                    });
                });

                // Fonction pour afficher les notifications
                function showNotification(message, type) {
                    // Créer une div de notification
                    const notification = document.createElement('div');
                    notification.className = `notification ${type}`;
                    notification.textContent = message;

                    // Styles de base
                    notification.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 15px 25px;
                border-radius: 8px;
                color: white;
                font-weight: 500;
                z-index: 10000;
                animation: slideIn 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            `;

                    // Couleurs selon le type
                    if (type === 'success') {
                        notification.style.backgroundColor = '#2D5F3F';
                    } else if (type === 'info') {
                        notification.style.backgroundColor = '#E8967D';
                    } else if (type === 'error') {
                        notification.style.backgroundColor = '#dc3545';
                    }

                    // Ajouter au DOM
                    document.body.appendChild(notification);

                    // Supprimer après 3 secondes
                    setTimeout(() => {
                        if (notification.parentNode) {
                            notification.parentNode.removeChild(notification);
                        }
                    }, 3000);
                }

                // Ajouter les styles CSS pour l'animation
                const style = document.createElement('style');
                style.textContent = `
            @keyframes slideIn {
                from {
                    transform: translateX(100%);
                    opacity: 0;
                }
                to {
                    transform: translateX(0);
                    opacity: 1;
                }
            }
            
            @keyframes fadeOut {
                from {
                    opacity: 1;
                }
                to {
                    opacity: 0;
                }
            }
            
            @keyframes fa-spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            
            @keyframes spin {
                0% { transform: rotate(0deg); }
                100% { transform: rotate(360deg); }
            }
            
            .notification {
                position: fixed;
                top: 20px;
                right: 20px;
                padding: 15px 25px;
                border-radius: 8px;
                color: white;
                font-weight: 500;
                z-index: 10000;
                animation: slideIn 0.3s ease, fadeOut 0.3s ease 2.7s forwards;
                box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            }
            
            .notification.success {
                background-color: #2D5F3F;
            }
            
            .notification.info {
                background-color: #E8967D;
            }
            
            .notification.error {
                background-color: #dc3545;
            }
        `;
                document.head.appendChild(style);
            </script>

            <!-- Liens CSS externes -->
            <link
                href="https://fonts.googleapis.com/css?family=Raleway:100,100i,200,200i,300,300i,400,400i,500,500i,600,600i,700,700i,800,800i,900,900i"
                rel="stylesheet" />
            <link href="https://fonts.googleapis.com/css?family=Lora:400,400i,700,700i" rel="stylesheet" />
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/animate.css/4.1.1/animate.min.css">
            <!-- jQuery pour AJAX -->
            <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

        </asp:Content>