<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Footer.ascx.cs" Inherits="Multi_cooperative.Footer" %>

<footer class="footer">
    <div class="container">
        <div class="footer-grid">
            <div class="footer-column reveal">
                <h4 style="font-weight: 800; letter-spacing: 2px;">BIOROCCO</h4>
                <p style="color: rgba(255, 255, 255, 0.7); line-height: 1.8;">Coopérative marocaine de produits naturels et bio. Engagement, qualité et tradition héritée de nos ancêtres.</p>
                <div class="social-icons">
                    <a href="#" class="social-icon glass-effect"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" class="social-icon glass-effect"><i class="fab fa-instagram"></i></a>
                    <a href="#" class="social-icon glass-effect"><i class="fab fa-twitter"></i></a>
                    <a href="#" class="social-icon glass-effect"><i class="fab fa-whatsapp"></i></a>
                </div>
            </div>
            
            <div class="footer-column reveal delay-100">
                <h4>Navigation</h4>
                <ul class="footer-links">
                    <li><a href="Default.aspx#histoire">Notre Histoire</a></li>
                    <li><a href="Products.aspx">Nos Produits</a></li>
                    <li><a href="Default.aspx#solutions">Solutions Naturelles</a></li>
                    <li><a href="Default.aspx#contact">Contact</a></li>
                </ul>
            </div>
            
            <div class="footer-column">
                <h4>Catégories</h4>
                <ul class="footer-links">
                    <li><a href="#">Huiles Essentielles</a></li>
                    <li><a href="#">Huiles Végétales</a></li>
                    <li><a href="#">Savons Naturels</a></li>
                    <li><a href="#">Crèmes & Soins</a></li>
                    <li><a href="#">Coiffets Cadeau</a></li>
                </ul>
            </div>
            
            <div class="footer-column">
                <h4>Contact</h4>
                <ul class="footer-links">
                    <li><i class="fas fa-map-marker-alt me-2"></i> Route d'Agadir, Essaouira</li>
                    <li><i class="fas fa-phone me-2"></i> +212 5 XX XX XX XX</li>
                    <li><i class="fas fa-envelope me-2"></i> contact@biorocco.ma</li>
                </ul>
            </div>
        </div>
        
        <div class="copyright">
            <p>&copy; <%: DateTime.Now.Year %> BIOROCCO - Coopérative Marocaine. Tous droits réservés.</p>
            <p>
                <a href="#" class="text-white-60 me-3">Mentions légales</a>
                <a href="#" class="text-white-60 me-3">Politique de confidentialité</a>
                <a href="#" class="text-white-60">Conditions générales</a>
            </p>
        </div>
    </div>
</footer>

<style>
    /* ===== FOOTER STYLES ===== */
    .footer {
        background: #2D5F3F;
        color: white;
        padding: 60px 0 30px;
    }
    
    .footer-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 40px;
        margin-bottom: 40px;
    }
    
    .footer-column h4 {
        color: #E8967D;
        margin-bottom: 25px;
        font-size: 1.1rem;
        text-transform: uppercase;
        font-weight: 700;
        letter-spacing: 1.5px;
    }
    
    .footer-links {
        list-style: none;
        padding: 0;
        margin: 0;
    }
    
    .footer-links li {
        margin-bottom: 12px;
        display: flex;
        align-items: center;
    }
    
    .footer-links a {
        color: rgba(255, 255, 255, 0.6);
        text-decoration: none;
        transition: all 0.3s ease;
    }
    
    .footer-links a:hover {
        color: white;
        transform: translateX(5px);
    }
    
    .social-icons {
        display: flex;
        gap: 12px;
        margin-top: 25px;
    }
    
    .social-icon {
        width: 44px;
        height: 44px;
        background: rgba(255, 255, 255, 0.05);
        border: 1px solid rgba(255, 255, 255, 0.1);
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        color: white;
        text-decoration: none;
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .social-icon:hover {
        background: #E8967D;
        color: white;
        transform: translateY(-5px) rotate(8deg);
        box-shadow: 0 10px 20px rgba(232, 150, 125, 0.3);
    }
    
    .copyright {
        text-align: center;
        padding-top: 30px;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
        color: rgba(255, 255, 255, 0.6);
        font-size: 0.9rem;
    }
    
    .copyright a {
        color: rgba(255, 255, 255, 0.6);
        text-decoration: none;
        transition: var(--transition);
    }
    
    .copyright a:hover {
        color: var(--primary);
    }
    
    .text-white-60 {
        color: rgba(255, 255, 255, 0.6) !important;
    }
    
    .me-2 {
        margin-right: 0.5rem;
    }
    
    .me-3 {
        margin-right: 1rem;
    }
</style>