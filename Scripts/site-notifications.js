window.showNotification = function (message, type) {
    try {
        type = type || 'info';
        var colors = {
            success: '#10b981',
            error: '#ef4444',
            info: '#3b82f6'
        };
        var bg = colors[type] || colors.info;
        var el = document.createElement('div');
        el.textContent = message || '';
        el.style.position = 'fixed';
        el.style.right = '20px';
        el.style.top = '20px';
        el.style.zIndex = 99999;
        el.style.background = bg;
        el.style.color = '#fff';
        el.style.padding = '10px 14px';
        el.style.borderRadius = '8px';
        el.style.boxShadow = '0 6px 18px rgba(0,0,0,0.12)';
        el.style.fontFamily = 'Segoe UI, Roboto, Arial, sans-serif';
        el.style.fontSize = '14px';
        document.body.appendChild(el);
        setTimeout(function () { el.style.transition = 'opacity 250ms'; el.style.opacity = '0'; }, 2200);
        setTimeout(function () { if (el.parentNode) el.parentNode.removeChild(el); }, 2500);
    } catch (e) {
        // fallback silencieux
        try { console.warn('showNotification fallback', e); } catch (_) {}
    }
};