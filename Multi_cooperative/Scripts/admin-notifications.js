// Scripts/admin-notifications.js
// Système de notifications modernes pour l'admin

class AdminNotifications {
    constructor() {
        this.container = null;
        this.init();
    }

    init() {
        // Créer le conteneur de notifications
        if (!document.getElementById('adminNotificationsContainer')) {
            const container = document.createElement('div');
            container.id = 'adminNotificationsContainer';
            container.style.cssText = `
                position: fixed;
                top: 20px;
                right: 20px;
                z-index: 10000;
                display: flex;
                flex-direction: column;
                gap: 12px;
                max-width: 400px;
            `;
            document.body.appendChild(container);
            this.container = container;
        } else {
            this.container = document.getElementById('adminNotificationsContainer');
        }
    }

    show(message, type = 'info', duration = 4000) {
        const notification = document.createElement('div');
        notification.className = `admin-notification admin-notification-${type}`;
        notification.style.cssText = `
            background: white;
            border-radius: 12px;
            padding: 16px 20px;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
            display: flex;
            align-items: center;
            gap: 12px;
            animation: slideInRight 0.3s ease-out;
            border-left: 4px solid;
            min-width: 300px;
        `;

        // Couleurs selon le type
        const colors = {
            success: { border: '#10b981', icon: '✓', bg: '#d1fae5' },
            error: { border: '#ef4444', icon: '✕', bg: '#fee2e2' },
            warning: { border: '#f59e0b', icon: '⚠', bg: '#fef3c7' },
            info: { border: '#3b82f6', icon: 'ℹ', bg: '#dbeafe' }
        };

        const config = colors[type] || colors.info;
        notification.style.borderLeftColor = config.border;

        // Icône
        const icon = document.createElement('div');
        icon.style.cssText = `
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: ${config.bg};
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            color: ${config.border};
            flex-shrink: 0;
        `;
        icon.textContent = config.icon;

        // Message
        const messageEl = document.createElement('div');
        messageEl.style.cssText = 'flex: 1; color: #1f2937; font-size: 14px; line-height: 1.5;';
        messageEl.textContent = message;

        // Bouton fermer
        const closeBtn = document.createElement('button');
        closeBtn.innerHTML = '×';
        closeBtn.style.cssText = `
            background: none;
            border: none;
            font-size: 24px;
            color: #9ca3af;
            cursor: pointer;
            padding: 0;
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            line-height: 1;
        `;
        closeBtn.onclick = () => this.remove(notification);

        notification.appendChild(icon);
        notification.appendChild(messageEl);
        notification.appendChild(closeBtn);
        this.container.appendChild(notification);

        // Auto-remove
        if (duration > 0) {
            setTimeout(() => this.remove(notification), duration);
        }

        return notification;
    }

    remove(notification) {
        notification.style.animation = 'slideOutRight 0.3s ease-out';
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
        }, 300);
    }

    success(message, duration) {
        return this.show(message, 'success', duration);
    }

    error(message, duration) {
        return this.show(message, 'error', duration);
    }

    warning(message, duration) {
        return this.show(message, 'warning', duration);
    }

    info(message, duration) {
        return this.show(message, 'info', duration);
    }
}

// Système de confirmation moderne
class AdminConfirm {
    static show(message, onConfirm, onCancel) {
        // Créer overlay
        const overlay = document.createElement('div');
        overlay.style.cssText = `
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.5);
            z-index: 10001;
            display: flex;
            align-items: center;
            justify-content: center;
            animation: fadeIn 0.2s;
        `;

        // Créer modal
        const modal = document.createElement('div');
        modal.style.cssText = `
            background: white;
            border-radius: 16px;
            padding: 24px;
            max-width: 400px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            animation: scaleIn 0.2s;
        `;

        // Icône warning
        const icon = document.createElement('div');
        icon.style.cssText = `
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: #fef3c7;
            color: #f59e0b;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin: 0 auto 16px;
        `;
        icon.textContent = '⚠';

        // Message
        const messageEl = document.createElement('div');
        messageEl.style.cssText = 'text-align: center; color: #1f2937; margin-bottom: 24px; font-size: 16px;';
        messageEl.textContent = message;

        // Boutons
        const buttons = document.createElement('div');
        buttons.style.cssText = 'display: flex; gap: 12px; justify-content: center;';

        const cancelBtn = document.createElement('button');
        cancelBtn.textContent = 'Annuler';
        cancelBtn.style.cssText = `
            padding: 10px 24px;
            border: 1px solid #e5e7eb;
            background: white;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            color: #6b7280;
        `;
        cancelBtn.onclick = () => {
            document.body.removeChild(overlay);
            if (onCancel) onCancel();
        };

        const confirmBtn = document.createElement('button');
        confirmBtn.textContent = 'Confirmer';
        confirmBtn.style.cssText = `
            padding: 10px 24px;
            border: none;
            background: #ef4444;
            color: white;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
        `;
        confirmBtn.onclick = () => {
            document.body.removeChild(overlay);
            if (onConfirm) onConfirm();
        };

        buttons.appendChild(cancelBtn);
        buttons.appendChild(confirmBtn);

        modal.appendChild(icon);
        modal.appendChild(messageEl);
        modal.appendChild(buttons);
        overlay.appendChild(modal);
        document.body.appendChild(overlay);

        // Fermer en cliquant sur l'overlay
        overlay.onclick = (e) => {
            if (e.target === overlay) {
                document.body.removeChild(overlay);
                if (onCancel) onCancel();
            }
        };
    }
}

// CSS pour les animations
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    @keyframes scaleIn {
        from {
            transform: scale(0.9);
            opacity: 0;
        }
        to {
            transform: scale(1);
            opacity: 1;
        }
    }
`;
document.head.appendChild(style);

// Instance globale
window.adminNotifications = new AdminNotifications();
window.adminConfirm = AdminConfirm;