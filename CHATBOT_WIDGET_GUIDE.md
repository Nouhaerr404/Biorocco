# 🤖 Chatbot Widget - Guide d'Utilisation

## 🎯 Vue d'ensemble

Le **Chatbot Widget** est un assistant virtuel flottant intégré sur toutes les pages du site Multi_cooperative. Il permet aux utilisateurs de poser des questions et d'obtenir des réponses instantanées grâce à l'intelligence artificielle via n8n.

---

## 🚀 Démarrage Rapide

### Installation
Le widget est **automatiquement chargé** sur toutes les pages via `Site.Master`. Aucune configuration supplémentaire n'est nécessaire !

### Fichiers Requis
```
Multi_cooperative/
├── ChatbotService.asmx          # Service web
├── ChatbotService.asmx.cs       # Logique backend
├── Scripts/
│   └── chatbot-widget.js        # Logique frontend
├── Content/
│   └── chatbot-widget.css       # Styles
└── Site.Master                  # Intégration globale
```

---

## 💡 Utilisation

### Pour les Utilisateurs

1. **Ouvrir le chat**
   - Cliquez sur l'icône flottante 💬 en bas à droite
   - Le widget s'ouvre avec un message de bienvenue

2. **Poser une question**
   - Tapez votre message dans le champ de saisie
   - Appuyez sur **Enter** ou cliquez sur l'icône ✈️

3. **Recevoir la réponse**
   - Un indicateur de frappe (3 points) s'affiche
   - La réponse du bot apparaît en quelques secondes

4. **Gérer la fenêtre**
   - **Réduire** : Cliquez sur ➖ (garde la fenêtre ouverte mais réduite)
   - **Fermer** : Cliquez sur ✖️ (ferme complètement le widget)

---

## 🎨 Personnalisation

### Modifier les Couleurs

**Fichier** : `Content/chatbot-widget.css`

```css
/* Gradient principal du bot */
background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);

/* Changer pour un autre gradient */
background: linear-gradient(135deg, #FF6B6B 0%, #4ECDC4 100%);
```

### Modifier la Position

```css
/* Position par défaut */
#chatbot-toggle {
    bottom: 30px;
    right: 30px;
}

/* Exemple : Coin inférieur gauche */
#chatbot-toggle {
    bottom: 30px;
    left: 30px;  /* au lieu de right */
}
```

### Modifier la Taille

```css
/* Taille par défaut */
#chatbot-window {
    width: 380px;
    height: 550px;
}

/* Exemple : Plus grand */
#chatbot-window {
    width: 450px;
    height: 650px;
}
```

---

## 🔧 Configuration Backend

### Changer l'URL du Webhook n8n

**Fichier** : `ChatbotService.asmx.cs`

```csharp
// Ligne 44-47
var response = client.PostAsync(
    "https://jihanelhamdaoui.app.n8n.cloud/webhook/chatbot1",  // ← Modifier ici
    content
).Result;
```

### Ajouter un Timeout

```csharp
using (var client = new HttpClient())
{
    client.Timeout = TimeSpan.FromSeconds(30);  // Timeout de 30 secondes
    
    // ... reste du code
}
```

### Ajouter des Headers Personnalisés

```csharp
var content = new StringContent(
    JsonConvert.SerializeObject(body),
    Encoding.UTF8,
    "application/json"
);

// Ajouter un header d'authentification
client.DefaultRequestHeaders.Add("Authorization", "Bearer YOUR_TOKEN");
```

---

## 🎭 Personnaliser les Messages

### Message de Bienvenue

**Fichier** : `Scripts/chatbot-widget.js`

```javascript
// Ligne 47
addBotMessage("👋 Bonjour ! Je suis votre assistant virtuel. Comment puis-je vous aider aujourd'hui ?");

// Personnaliser
addBotMessage("🎉 Bienvenue ! Posez-moi vos questions sur nos produits !");
```

### Messages d'Erreur

```javascript
// Ligne 158
addBotMessage("❌ Désolé, une erreur s'est produite. Veuillez réessayer.");

// Personnaliser
addBotMessage("😔 Oups ! Quelque chose s'est mal passé. Réessayez dans un instant.");
```

---

## 🎯 Fonctionnalités Avancées

### Ajouter un Historique Local

```javascript
// Sauvegarder les messages dans localStorage
function saveMessage(message, isUser) {
    let history = JSON.parse(localStorage.getItem('chatHistory') || '[]');
    history.push({
        message: message,
        isUser: isUser,
        timestamp: new Date().toISOString()
    });
    localStorage.setItem('chatHistory', JSON.stringify(history));
}

// Charger l'historique au démarrage
function loadHistory() {
    let history = JSON.parse(localStorage.getItem('chatHistory') || '[]');
    history.forEach(item => {
        if (item.isUser) {
            addUserMessage(item.message);
        } else {
            addBotMessage(item.message);
        }
    });
}
```

### Ajouter des Suggestions Rapides

```javascript
function addQuickReplies() {
    const suggestions = [
        "Quels sont vos produits ?",
        "Comment passer commande ?",
        "Politique de retour ?"
    ];
    
    const container = document.createElement('div');
    container.className = 'quick-replies';
    
    suggestions.forEach(text => {
        const btn = document.createElement('button');
        btn.textContent = text;
        btn.onclick = () => {
            document.getElementById('chatbot-input').value = text;
            sendMessage();
        };
        container.appendChild(btn);
    });
    
    document.getElementById('chatbot-messages').appendChild(container);
}
```

---

## 📱 Responsive Design

Le widget s'adapte automatiquement aux différentes tailles d'écran :

### Desktop (> 768px)
- Fenêtre : 380x550px
- Position : Coin inférieur droit
- Icône : 60x60px

### Tablette (480px - 768px)
- Fenêtre : Largeur adaptée avec marges
- Position : Coin inférieur droit
- Icône : 56x56px

### Mobile (< 480px)
- Fenêtre : Plein écran (100vw x 100vh)
- Position : Couvre tout l'écran
- Icône : 56x56px

---

## 🐛 Débogage

### Activer les Logs Console

```javascript
// Ajouter au début de chatbot-widget.js
const DEBUG = true;

function log(message, data) {
    if (DEBUG) {
        console.log('[Chatbot]', message, data || '');
    }
}

// Utiliser dans le code
log('Message envoyé:', message);
log('Réponse reçue:', data);
```

### Tester le Service Web

Ouvrez dans le navigateur :
```
http://localhost:PORT/ChatbotService.asmx
```

Vous verrez la page de test du service web avec la méthode `GetBotResponse`.

### Vérifier la Connexion n8n

```javascript
// Test direct dans la console du navigateur
fetch('https://jihanelhamdaoui.app.n8n.cloud/webhook/chatbot1', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message: 'test' })
})
.then(r => r.json())
.then(d => console.log('n8n response:', d));
```

---

## 🔒 Sécurité

### Protection XSS
Tous les messages sont automatiquement échappés :
```javascript
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}
```

### HTTPS Obligatoire
Le webhook n8n utilise HTTPS pour sécuriser les communications.

### Rate Limiting (Recommandé)
Ajoutez une limitation de requêtes côté serveur :

```csharp
private static DateTime lastRequest = DateTime.MinValue;
private const int MIN_INTERVAL_SECONDS = 2;

[WebMethod]
public string GetBotResponse(string message)
{
    // Vérifier l'intervalle entre les requêtes
    if ((DateTime.Now - lastRequest).TotalSeconds < MIN_INTERVAL_SECONDS)
    {
        return "Veuillez patienter avant d'envoyer un nouveau message.";
    }
    lastRequest = DateTime.Now;
    
    // ... reste du code
}
```

---

## 📊 Analytics (Optionnel)

### Tracker les Questions

```javascript
function trackQuestion(message) {
    // Google Analytics
    if (typeof gtag !== 'undefined') {
        gtag('event', 'chatbot_question', {
            'question': message,
            'timestamp': new Date().toISOString()
        });
    }
}

// Appeler dans sendMessage()
trackQuestion(message);
```

---

## 🎨 Thèmes Alternatifs

### Thème Sombre

```css
#chatbot-window {
    background: #1a1a1a;
    color: #ffffff;
}

#chatbot-body {
    background: #2d2d2d;
}

.bot-message .message-content {
    background: #3a3a3a;
    color: #ffffff;
    border-color: #4a4a4a;
}
```

### Thème Minimaliste

```css
#chatbot-toggle {
    background: #000000;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

#chatbot-header {
    background: #000000;
}

.bot-message .message-content {
    background: #f5f5f5;
    border: none;
}
```

---

## 🚀 Performance

### Optimisations Appliquées
- ✅ Chargement asynchrone
- ✅ Pas de dépendances lourdes
- ✅ CSS optimisé avec transitions GPU
- ✅ Scroll virtuel pour longs historiques

### Taille des Fichiers
- JavaScript : ~6.5 KB
- CSS : ~7.8 KB
- **Total** : ~14.3 KB (minifié)

---

## 📞 Support

### Problèmes Courants

**Le widget ne s'affiche pas**
- Vérifiez que `chatbot-widget.css` est chargé
- Vérifiez que `chatbot-widget.js` est chargé
- Ouvrez la console pour voir les erreurs

**Les messages ne s'envoient pas**
- Vérifiez que `ChatbotService.asmx` est accessible
- Testez l'URL du webhook n8n
- Vérifiez la connexion internet

**Le style est cassé**
- Vérifiez que Font Awesome est chargé
- Vérifiez qu'il n'y a pas de conflits CSS
- Inspectez l'élément dans les DevTools

---

## 📝 Changelog

### Version 2.0 (2025-12-28)
- ✨ Migration vers widget flottant
- ✨ Disponible sur toutes les pages
- ✨ Design premium avec animations
- ✨ Responsive complet
- ✨ Service web dédié (ChatbotService.asmx)

### Version 1.0
- Page dédiée chatbot.aspx
- Connexion n8n webhook
- Interface basique

---

## 🎉 Conclusion

Le **Chatbot Widget** offre une expérience utilisateur moderne et fluide. Il est facile à personnaliser et à étendre selon vos besoins !

Pour toute question ou suggestion, consultez la documentation complète dans `MIGRATION_CHATBOT_WIDGET.md`.

---

*Guide créé le : 2025-12-28*  
*Version : 2.0*
