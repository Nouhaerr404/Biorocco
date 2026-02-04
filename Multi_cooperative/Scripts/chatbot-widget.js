// ============================================
// 🤖 Chatbot Widget - Floating Assistant
// ============================================

(function () {
    'use strict';

    // État du chatbot
    let isChatOpen = false;
    let isMinimized = false;

    // Initialisation au chargement du DOM
    document.addEventListener('DOMContentLoaded', function () {
        initChatbot();
    });

    function initChatbot() {
        // --- CORRECTIF : Déplacer le widget à la racine du body ---
        const widgetWrapper = document.getElementById('chatbot-widget');
        if (widgetWrapper && widgetWrapper.parentElement !== document.body) {
            document.body.appendChild(widgetWrapper);
        }
        // -----------------------------------------------------------

        // Le widget est déjà dans le DOM (injecté par Site.Master)
        const chatWidget = document.getElementById('chatbot-widget');
        const chatToggle = document.getElementById('chatbot-toggle');
        const chatClose = document.getElementById('chatbot-close');
        const chatMinimize = document.getElementById('chatbot-minimize');
        const chatSend = document.getElementById('chatbot-send');
        const chatInput = document.getElementById('chatbot-input');

        if (!chatWidget || !chatToggle) {
            console.warn('Chatbot widget elements not found');
            return;
        }

        // Event Listeners
        chatToggle.addEventListener('click', toggleChat);
        chatClose.addEventListener('click', closeChat);
        chatMinimize.addEventListener('click', minimizeChat);
        chatSend.addEventListener('click', sendMessage);

        // Envoyer avec Enter
        chatInput.addEventListener('keypress', function (e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        // Message de bienvenue
        addBotMessage("👋 Bonjour ! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd'hui ?");
    }

    function toggleChat() {
        const chatWindow = document.getElementById('chatbot-window');
        const chatToggle = document.getElementById('chatbot-toggle');

        isChatOpen = !isChatOpen;

        if (isChatOpen) {
            chatWindow.classList.add('active');
            chatToggle.classList.add('hidden');
            isMinimized = false;

            // Focus sur l'input
            setTimeout(() => {
                document.getElementById('chatbot-input').focus();
            }, 300);
        } else {
            chatWindow.classList.remove('active');
            chatToggle.classList.remove('hidden');
        }
    }

    function closeChat() {
        const chatWindow = document.getElementById('chatbot-window');
        const chatToggle = document.getElementById('chatbot-toggle');

        chatWindow.classList.remove('active');
        chatToggle.classList.remove('hidden');
        isChatOpen = false;
        isMinimized = false;
    }

    function minimizeChat() {
        const chatBody = document.getElementById('chatbot-body');
        const chatFooter = document.getElementById('chatbot-footer');
        const chatWindow = document.getElementById('chatbot-window');

        isMinimized = !isMinimized;

        if (isMinimized) {
            chatBody.style.display = 'none';
            chatFooter.style.display = 'none';
            chatWindow.classList.add('minimized');
        } else {
            chatBody.style.display = 'flex';
            chatFooter.style.display = 'block';
            chatWindow.classList.remove('minimized');
        }
    }

    function sendMessage() {
        const input = document.getElementById('chatbot-input');
        const message = input.value.trim();

        if (!message) return;

        // Afficher le message de l'utilisateur
        addUserMessage(message);

        // Vider l'input
        input.value = '';

        // Afficher l'indicateur de frappe
        showTypingIndicator();

        // Appeler le backend
        fetch('/ChatbotService.asmx/GetBotResponse', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ message: message })
        })
            .then(response => response.json())
            .then(data => {
                hideTypingIndicator();

                let botMessage = '';

                // Gérer la réponse du WebMethod ASP.NET
                if (data.d) {
                    data = data.d;
                }

                // Extraire le message
                if (typeof data === 'string') {
                    botMessage = data;
                } else if (typeof data === 'object') {
                    if (data.response) botMessage = data.response;
                    else if (data.output) botMessage = data.output;
                    else botMessage = JSON.stringify(data);
                }

                // Tenter de parser si c'est encore du JSON stringifié
                try {
                    let parsed = JSON.parse(botMessage);
                    if (parsed.response) botMessage = parsed.response;
                } catch (e) {
                    // Ce n'est pas du JSON, on garde le message tel quel
                }

                addBotMessage(botMessage);
            })
            .catch(error => {
                hideTypingIndicator();
                console.error('Chatbot error:', error);
                addBotMessage("❌ Désolé, une erreur s'est produite. Veuillez réessayer.");
            });
    }

    function addUserMessage(message) {
        const messagesContainer = document.getElementById('chatbot-messages');

        const messageDiv = document.createElement('div');
        messageDiv.className = 'chatbot-message user-message';
        messageDiv.innerHTML = `
            <div class="message-content">
                <p>${escapeHtml(message)}</p>
            </div>
            <div class="message-avatar">
                <i class="fas fa-user"></i>
            </div>
        `;

        messagesContainer.appendChild(messageDiv);
        scrollToBottom();
    }

    function addBotMessage(message) {
        const messagesContainer = document.getElementById('chatbot-messages');

        // 1. Sécurité : Échapper le code HTML d'abord
        let formattedMessage = escapeHtml(message);

        // 2. Formatage : Convertir \n en <br>
        formattedMessage = formattedMessage.replace(/\n/g, '<br />');

        // 3. Formatage : Convertir **gras** en <b>gras</b>
        formattedMessage = formattedMessage.replace(/\*\*(.*?)\*\*/g, '<b>$1</b>');

        const messageDiv = document.createElement('div');
        messageDiv.className = 'chatbot-message bot-message';
        messageDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <p>${formattedMessage}</p>
            </div>
        `;

        messagesContainer.appendChild(messageDiv);
        scrollToBottom();
    }

    function showTypingIndicator() {
        const messagesContainer = document.getElementById('chatbot-messages');

        const typingDiv = document.createElement('div');
        typingDiv.id = 'typing-indicator';
        typingDiv.className = 'chatbot-message bot-message typing-indicator';
        typingDiv.innerHTML = `
            <div class="message-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div class="message-content">
                <div class="typing-dots">
                    <span></span>
                    <span></span>
                    <span></span>
                </div>
            </div>
        `;

        messagesContainer.appendChild(typingDiv);
        scrollToBottom();
    }

    function hideTypingIndicator() {
        const typingIndicator = document.getElementById('typing-indicator');
        if (typingIndicator) {
            typingIndicator.remove();
        }
    }

    function scrollToBottom() {
        const messagesContainer = document.getElementById('chatbot-messages');
        messagesContainer.scrollTop = messagesContainer.scrollHeight;
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

})();
