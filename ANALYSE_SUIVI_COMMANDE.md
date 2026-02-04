# ANALYSE COMPLÈTE DU SYSTÈME DE SUIVI DE COMMANDE

## ?? VUE GLOBALE

Le système de suivi de commande dans votre application utilise une architecture **3 niveaux** :
1. **Base de données (SQL Server)** - Stocke les données
2. **Backend (C# Web Service)** - Récupère et modifie les données
3. **Frontend (JavaScript)** - Affiche les données à l'utilisateur

---

## ??? TABLES DE BASE DE DONNÉES IMPLIQUÉES

### 1. **Table `Orders` (Table Principale)**
C'est la table maîtresse qui contient toutes les informations de la commande.

**Colonnes importantes :**
```
OrderId           ? ID unique de la commande
UserId            ? ID de l'utilisateur qui a passé la commande
Status            ? État actuel (Validée, En préparation, Expédiée, Livrée, Annulée)
TotalTTC          ? Prix total TTC
PaymentMethod     ? Méthode de paiement utilisée
CreatedAt         ? Date de création
TrackingNumber    ? Numéro de suivi de livraison
CancellationReason ? Raison si annulée
CancelledAt       ? Date d'annulation

--- COLONNES DE SUIVI (Importantes pour l'affichage du statut) ---
ValidatedAt       ? Date/heure quand la commande a été validée
InPreparationAt   ? Date/heure quand elle est passée en préparation
ShippedAt         ? Date/heure quand elle a été expédiée
DeliveredAt       ? Date/heure quand elle a été livrée
```

### 2. **Table `OrderItems` (Articles de la commande)**
Chaque commande peut avoir plusieurs articles (produits).

**Colonnes :**
```
OrderItemId       ? ID unique de la ligne
OrderId           ? Lien vers la commande
ProductId         ? ID du produit
FormatId          ? ID du format (taille, volume, etc.)
Quantity          ? Quantité commandée
UnitPrice         ? Prix unitaire au moment de la commande
```

### 3. **Table `Addresses` (Adresses de livraison)**
Stocke les adresses des utilisateurs.

**Colonnes :**
```
AddressId         ? ID unique
UserId            ? ID de l'utilisateur
FullName          ? Nom du destinataire
Phone             ? Téléphone
City              ? Ville
AddressLine       ? Adresse complète
PostalCode        ? Code postal
IsDefault         ? Si c'est l'adresse par défaut
```

### 4. **Table `ShippingMethods` (Méthodes de livraison)**
Définit les options de livraison disponibles.

**Colonnes :**
```
ShippingId        ? ID unique
MethodName        ? Nom de la méthode (Standart, Express, etc.)
EstimatedDays    ? Délai estimé en jours
```

---

## ?? LOGIQUE DU BACKEND (ClientProfileService.asmx.cs)

### Fonction Principale : `GetOrders()`

C'est la fonction qui **récupère TOUTES les commandes d'un utilisateur**.

**Ce qu'elle fait :**

```
1. VÉRIFICATION
   ?? Vérifie que l'utilisateur est authentifié (Session["UserId"])
   ?? Si non ? Retourne une erreur

2. JOINTURE AVEC LA BD
   ?? Récupère les commandes depuis Orders
   ?? Jointure avec Addresses pour obtenir l'adresse de livraison
   ?? Jointure avec ShippingMethods pour obtenir la méthode de livraison
   ?? Filtre par UserId de l'utilisateur connecté

3. EXTRACTION DES DONNÉES
   ?? Pour CHAQUE commande trouvée :
   ?  ?? Récupère OrderId, Status, TotalTTC, PaymentMethod
   ?  ?? Récupère les dates de progression (ValidatedAt, InPreparationAt, etc.)
   ?  ?? Calcule le flag "canCancel" :
   ?  ?   ?? TRUE si Status ? "Expédiée", "Livrée", "Annulée"
   ?  ?? Récupère les articles (OrderItems) avec une nouvelle requête
   ?
   ?? Pour CHAQUE article de la commande :
      ?? Récupère le nom du produit
      ?? Récupère le format (label)
      ?? Récupère la quantité et le prix unitaire
      ?? Ajoute cela à la liste des articles

4. RETOUR
   ?? Retourne un objet JSON avec succès = true et données
```

**Exemple de requête SQL utilisée :**

```sql
SELECT o.OrderId, o.Status, o.TotalTTC, o.PaymentMethod, o.CreatedAt, 
       o.TrackingNumber, o.CancellationReason, o.CancelledAt,
       o.ValidatedAt, o.InPreparationAt, o.ShippedAt, o.DeliveredAt,
       a.FullName, a.City, a.AddressLine, a.PostalCode,
       s.MethodName, s.EstimatedDays
FROM Orders o
INNER JOIN Addresses a ON o.AddressId = a.AddressId
INNER JOIN ShippingMethods s ON o.ShippingId = s.ShippingId
WHERE o.UserId = @UserId
ORDER BY o.CreatedAt DESC
```

---

## ?? LOGIQUE DU FRONTEND (client-profile.js)

### Fonction : `loadOrders()`

**Ce qu'elle fait :**

```
1. RÉCUPÈRE LES FILTRES DU FORMULAIRE
   ?? searchOrder ? Recherche par ID commande ou numéro de suivi
   ?? filterOrderStatus ? Filtre par statut (Validée, Expédiée, etc.)
   ?? filterOrderDate ? Filtre par date (semaine, mois, année)

2. APPELLE LE WEB SERVICE
   ?? Envoie une requête AJAX à ClientProfileService.asmx/GetOrders

3. APPLIQUE LES FILTRES (côté JavaScript)
   ?? Filtre de recherche :
   ?  ?? Compare l'input avec orderId ou trackingNumber
   ?
   ?? Filtre de statut :
   ?  ?? Garde seulement les commandes avec le statut sélectionné
   ?
   ?? Filtre de date :
      ?? "week" ? Commandes des 7 derniers jours
      ?? "month" ? Commandes du mois courant
      ?? "year" ? Commandes de l'année courante

4. APPELLE displayOrders()
   ?? Affiche les commandes filtrées à l'écran
```

### Fonction : `displayOrders(orders)`

**Ce qu'elle fait :**

```
POUR CHAQUE commande :

1. CRÉE UN CONTENEUR HTML avec :
   ?? Numéro de commande (#OrderId)
   ?? Date de création
   ?? BADGE DE STATUT
   ?  ?? Validée ? Jaune
   ?  ?? En préparation ? Orange
   ?  ?? Expédiée ? Bleu
   ?  ?? Livrée ? Vert
   ?  ?? Annulée ? Rouge
   ?
   ?? ADRESSE DE LIVRAISON (depuis Address)
   ?  ?? Nom
   ?  ?? Adresse
   ?  ?? Code postal
   ?  ?? Ville
   ?
   ?? INFORMATIONS
   ?  ?? Méthode de paiement
   ?  ?? Méthode de livraison
   ?  ?? Numéro de suivi (s'il existe)
   ?
   ?? LISTE DES ARTICLES
   ?  ?? Nom du produit
   ?  ?? Format
   ?  ?? Quantité
   ?  ?? Prix total de l'article
   ?
   ?? TIMELINE DE SUIVI
   ?  ?? Étape 1 : Commande validée ? Date : ValidatedAt
   ?  ?? Étape 2 : En préparation ? Date : InPreparationAt
   ?  ?? Étape 3 : Expédiée ? Date : ShippedAt
   ?  ?? Étape 4 : Livrée ? Date : DeliveredAt
   ?
   ?? PRIX TOTAL
   ?
   ?? BOUTON "Annuler"
      ?? Affiché SEULEMENT si canCancel = true
```

---

## ?? FLUX COMPLET : Du panier à la commande

### 1. **Depuis le Checkout.aspx**
L'utilisateur remplit le formulaire d'achat et clique "PAYER"

```
Checkout.aspx
    ?
Récupère les données du panier (CartItems)
    ?
Récupère l'adresse sélectionnée (AddressId)
    ?
Récupère la méthode de livraison (ShippingId)
    ?
CRÉE UNE NOUVELLE COMMANDE DANS LA BD
    ?
INSERT INTO Orders (
    UserId,
    Status = "Validée",  ? État initial
    TotalTTC,
    PaymentMethod,
    AddressId,
    ShippingId,
    CreatedAt = GETDATE(),
    ValidatedAt = GETDATE()  ? On enregistre maintenant
)
    ?
CRÉE LES ARTICLES
    ?
Pour chaque produit du panier :
    INSERT INTO OrderItems (
        OrderId,
        ProductId,
        FormatId,
        Quantity,
        UnitPrice
    )
    ?
SUPPRIME LE PANIER (CartItems)
    ?
La commande est créée !
```

---

## ?? CYCLE DE VIE D'UNE COMMANDE (États de progression)

```
CRÉÉE (Validée)
    ? [Admin valide le paiement]
    ? ValidatedAt = NOW()
    ? Status = "Validée"
    ?
EN PRÉPARATION
    ? [Admin commence à préparer]
    ? InPreparationAt = NOW()
    ? Status = "En préparation"
    ?
EXPÉDIÉE
    ? [Admin envoie le colis]
    ? ShippedAt = NOW()
    ? TrackingNumber = "XXXX..." (Numéro DHL/Maroc Poste)
    ? Status = "Expédiée"
    ?
LIVRÉE
    ? [Livreur confirme la livraison]
    ? DeliveredAt = NOW()
    ? Status = "Livrée"
    ?
FIN
```

**Cas spécial : Annulation**
```
À TOUT MOMENT AVANT "Expédiée"
    ? [Client ou admin annule]
    ? Status = "Annulée"
    ? CancellationReason = "Raison saisie"
    ? CancelledAt = NOW()
    ?
REMBOURSEMENT INITIÉ
```

---

## ?? POUR LANCER UNE COMMANDE : CE QU'IL FAUT FAIRE

Vous devez créer une fonction qui :

### **1. Récupère les données du panier**
```
De la table CartItems :
?? ProductId
?? FormatId
?? Quantity
?? UnitPrice
?? CartId (pour identifier l'utilisateur)
```

### **2. Calcule le total**
```
TotalTTC = SUM(Quantity × UnitPrice) + FraisExpédition + Taxes
```

### **3. Insère une nouvelle commande**
```
INSERT INTO Orders (
    UserId = Session["UserId"],
    Status = "Validée",
    TotalTTC = [Calculé],
    PaymentMethod = [Sélectionné par l'utilisateur],
    AddressId = [Adresse de livraison sélectionnée],
    ShippingId = [Méthode de livraison sélectionnée],
    CreatedAt = GETDATE(),
    ValidatedAt = GETDATE()
)
```

### **4. Insère les articles**
```
Pour chaque produit dans le panier :
    INSERT INTO OrderItems (
        OrderId = [L'ID créé à l'étape 3],
        ProductId = [Du panier],
        FormatId = [Du panier],
        Quantity = [Du panier],
        UnitPrice = [Du panier]
    )
```

### **5. Vide le panier**
```
DELETE FROM CartItems WHERE CartId = [L'ID du panier de l'utilisateur]
```

### **6. Retourne la confirmation**
```
Retourne OrderId et les infos de la commande à l'utilisateur
```

---

## ?? EXEMPLE CONCRET

### **Scénario : Un client achète 2 produits**

**AVANT :**
- CartItems contient :
  - Produit 1 : Format "500ml", Qty 2, Prix 100 Dh
  - Produit 2 : Format "250ml", Qty 1, Prix 80 Dh

**PROCESSUS :**

```
1. Client clique "PAIEMENT"
   ?? Appelle Checkout.aspx

2. Checkout.aspx récupère :
   ?? UserId = 5 (de Session)
   ?? AddressId = 10 (sélectionné)
   ?? ShippingId = 2 (Express)
   ?? Total = (100×2) + (80×1) = 280 Dh

3. INSERT INTO Orders :
   ?? OrderId = 1001 (auto-généré)
   ?? UserId = 5
   ?? Status = 'Validée'
   ?? TotalTTC = 280
   ?? PaymentMethod = 'Carte bancaire'
   ?? AddressId = 10
   ?? ShippingId = 2
   ?? CreatedAt = 2024-01-15 14:30:00
   ?? ValidatedAt = 2024-01-15 14:30:00

4. INSERT INTO OrderItems (2 lignes) :
   Ligne 1 :
   ?? OrderId = 1001
   ?? ProductId = 5
   ?? FormatId = 3
   ?? Quantity = 2
   ?? UnitPrice = 100

   Ligne 2 :
   ?? OrderId = 1001
   ?? ProductId = 7
   ?? FormatId = 2
   ?? Quantity = 1
   ?? UnitPrice = 80

5. DELETE FROM CartItems WHERE CartId = [CartId du client]

6. Confirmation affichée à l'utilisateur
   ?? "Commande #1001 créée avec succès"
```

**APRÈS :**
- Dans ClientProfile, la commande 1001 s'affiche :
  - Status = "Validée"
  - Timeline = Étape 1 complétée
  - Articles = 2 items listés
  - Adresse = 10 (récupérée)
  - Livraison = "Express"

---

## ?? POINTS CLÉS À RETENIR

1. **La table Orders est le centre** de tout
2. **Les dates (ValidatedAt, InPreparationAt, etc.) pilotent l'affichage de la timeline**
3. **Le Status détermine quels boutons sont affichés** (comme "Annuler")
4. **Le canCancel est calculé** : Si Status ? ["Expédiée", "Livrée", "Annulée"] ? FALSE sinon ? TRUE
5. **Les articles sont stockés séparément** dans OrderItems (une ligne par article)
6. **Le TrackingNumber s'ajoute** quand la commande est expédiée

---

## ??? POUR AMÉLIORER LE SYSTÈME À L'AVENIR

**Vous pouvez ajouter :**
1. **Notifications email** à chaque changement de statut
2. **Historique d'état** (table OrderHistory)
3. **Remboursements partiels**
4. **Codes promo et réductions**
5. **Intégration avec un API de livraison** (DHL, Maroc Poste)
6. **Facture PDF générée**
7. **Retours/Réclamations**

---

**Fin de l'analyse** ?
