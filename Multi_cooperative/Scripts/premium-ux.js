/* PREMIUM UX JAVASCRIPT */
document.addEventListener('DOMContentLoaded', function () {
    // 1. Initialize Reveal on Scroll
    initRevealOnScroll();

    // 2. Initialize Scroll Progress Bar
    initScrollProgress();

    // 3. Add Page Fade-in
    document.body.classList.add('page-load-fade');

    // 4. Parallax Effect for Hero sections
    initHeroParallax();

    // 5. Magnetic Buttons (subtle)
    initMagneticButtons();
});

function initRevealOnScroll() {
    const reveals = document.querySelectorAll('.reveal, .reveal-left, .reveal-right');

    const revealObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('active');
                // Optional: stop observing after reveal
                // revealObserver.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.15,
        rootMargin: "0px 0px -50px 0px"
    });

    reveals.forEach(reveal => {
        revealObserver.observe(reveal);
    });
}

function initScrollProgress() {
    const progressBar = document.createElement('div');
    progressBar.className = 'scroll-progress';
    document.body.appendChild(progressBar);

    window.addEventListener('scroll', () => {
        const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
        const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (winScroll / height) * 100;
        progressBar.style.width = scrolled + "%";
    });
}

function initHeroParallax() {
    const heroes = document.querySelectorAll('.histoire-section, .solutions-section');

    window.addEventListener('scroll', () => {
        const scrolled = window.pageYOffset;
        heroes.forEach(hero => {
            const speed = 0.4;
            const yPos = scrolled * speed;
            // Only apply if in view roughly
            const rect = hero.getBoundingClientRect();
            if (rect.top < window.innerHeight && rect.bottom > 0) {
                const img = hero.querySelector('img');
                if (img) {
                    img.style.transform = `translateY(${yPos * 0.1}px) scale(1.05)`;
                }
            }
        });
    });
}

function initMagneticButtons() {
    const buttons = document.querySelectorAll('.btn-premium');

    buttons.forEach(btn => {
        btn.addEventListener('mousemove', (e) => {
            const rect = btn.getBoundingClientRect();
            const x = e.clientX - rect.left - rect.width / 2;
            const y = e.clientY - rect.top - rect.height / 2;

            btn.style.transform = `translate(${x * 0.2}px, ${y * 0.2}px)`;
        });

        btn.addEventListener('mouseleave', () => {
            btn.style.transform = `translate(0px, 0px)`;
        });
    });
}

// Global Smooth Image Loading
const images = document.querySelectorAll('img');
images.forEach(img => {
    img.style.opacity = '0';
    img.style.transition = 'opacity 1s ease-in-out';
    img.onload = () => {
        img.style.opacity = '1';
    };
    // If cached
    if (img.complete) {
        img.style.opacity = '1';
    }
});
