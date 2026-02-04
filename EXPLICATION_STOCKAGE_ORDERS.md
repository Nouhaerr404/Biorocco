# ?? EXPLICATION : COMMENT VOUS STOCKEZ DANS ORDERS

## ?? DANS VOTRE CODE `Checkout.aspx.cs`

### **Ligne Clé (Ligne 126-132)**

```csharp
string sqlOrder = @"
    INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalTTC, PaymentMethod, CreatedAt, ValidatedAt) 
    OUTPUT INSERTED.OrderId 
    VALUES (@UserId, @AddressId, @ShippingId, 'Validée', @Total, 'Carte Bancaire', GETDATE(), GETDATE())";
```

---

## ?? DÉCOMPOSITION

### **1. Les Colonnes que vous REMPLISSEZ**

```
INSERT INTO Orders (
    UserId,              ? ID de l'utilisateur (depuis Session)
    AddressId,           ? ID de l'adresse sélectionnée (dropdown)
    ShippingId,          ? ID du mode de livraison (dropdown)
    Status,              ? État de la commande (TEXTE)
    TotalTTC,            ? Montant total (depuis lblTotalTTC)
    PaymentMethod,       ? Méthode de paiement (TEXTE)
    CreatedAt,           ? Date/heure de création (FONCTION BD)
    ValidatedAt          ? Date/heure de validation (FONCTION BD) ? IMPORTANT
)
```

### **2. Les Valeurs que vous INSÉREZ**

```sql
VALUES (
    @UserId,                        ? Paramètre C# : (int)Session["UserId"]
    @AddressId,                     ? Paramètre C# : int.Parse(ddlAddresses.SelectedValue)
    @ShippingId,                    ? Paramètre C# : int.Parse(ddlShipping.SelectedValue)
    'Validée',                      ? VALEUR TEXTE DIRECTE
    @Total,                         ? Paramètre C# : decimal.Parse(lblTotalTTC.Text)
    'Carte Bancaire',               ? VALEUR TEXTE DIRECTE
    GETDATE(),                      ? FONCTION SQL : date/heure MAINTENANT
    GETDATE()                       ? FONCTION SQL : date/heure MAINTENANT ?
)
```

---

## ? VALIDAT AT : DÉTAILS IMPORTANTS

### **Ce que vous INSÉREZ :**

```csharp
ValidatedAt = GETDATE()  // Date/heure du MOMENT où vous créez la commande
```

### **Exemple Concret :**

```
Si vous cliquez sur "CONFIRMER ET PAYER" le 15 janvier 2024 à 14:30:45

Alors dans la BD, vous stockez :
?? CreatedAt    = 2024-01-15 14:30:45.123
?? ValidatedAt  = 2024-01-15 14:30:45.123  ? IDENTIQUE
?? InPreparationAt = NULL                   ? Pas encore remplie
?? ShippedAt    = NULL                      ? Pas encore remplie
?? DeliveredAt  = NULL                      ? Pas encore remplie
```

---

## ?? TABLEAU RÉCAPITULATIF

| Colonne | Valeur | Source | Type |
|---------|--------|--------|------|
| **UserId** | 5 | `Session["UserId"]` | INT |
| **AddressId** | 10 | `ddlAddresses.SelectedValue` | INT |
| **ShippingId** | 2 | `ddlShipping.SelectedValue` | INT |
| **Status** | "Validée" | Texte direct | NVARCHAR(50) |
| **TotalTTC** | 285.50 | `lblTotalTTC.Text` | DECIMAL(10,2) |
| **PaymentMethod** | "Carte Bancaire" | Texte direct | NVARCHAR(50) |
| **CreatedAt** | 2024-01-15 14:30:45 | `GETDATE()` (SQL) | DATETIME |
| **ValidatedAt** | 2024-01-15 14:30:45 | `GETDATE()` (SQL) | DATETIME |
| **InPreparationAt** | NULL | Rien (= non remplie) | DATETIME |
| **ShippedAt** | NULL | Rien (= non remplie) | DATETIME |
| **DeliveredAt** | NULL | Rien (= non remplie) | DATETIME |

---

## ?? COMMENT LES PARAMÈTRES C# SONT PASSÉS

```csharp
using (SqlCommand cmd = new SqlCommand(sqlOrder, conn))
{
    // Ligne 135 : Passer l'ID utilisateur
    cmd.Parameters.AddWithValue("@UserId", userId);
    
    // Ligne 136 : Passer l'ID adresse
    cmd.Parameters.AddWithValue("@AddressId", addressId);
    
    // Ligne 137 : Passer l'ID expédition
    cmd.Parameters.AddWithValue("@ShippingId", shippingId);
    
    // Ligne 138 : Passer le montant total
    cmd.Parameters.AddWithValue("@Total", totalAmount);
    
    // Exécuter et récupérer l'ID généré
    newOrderId = (int)cmd.ExecuteScalar();
}
```

---

## ?? CE QUI SE PASSE APRÈS

```csharp
// Après l'INSERT, vous récupérez :
newOrderId = (int)cmd.ExecuteScalar();
// C'est l'ID auto-généré de la nouvelle commande
// Exemple : newOrderId = 42
```

Puis à la ligne 167, vous redirigez l'utilisateur :
```csharp
Response.Redirect("OrderSuccess.aspx?orderId=" + newOrderId);
// Redirection vers : OrderSuccess.aspx?orderId=42
```

Et dans `OrderSuccess.aspx.cs`, vous affichez :
```csharp
string id = Request.QueryString["orderId"];  // "42"
lblOrderNumber.Text = id;                    // Affiche "42"
```

---

## ?? RÉSUMÉ SIMPLE

**Quand le client clique "CONFIRMER ET PAYER" :**

1. ? Vous LISEZ les valeurs :
   - UserId (de la Session)
   - AddressId (du dropdown)
   - ShippingId (du dropdown)
   - TotalTTC (du label)

2. ? Vous INSÉREZ dans Orders :
   - Status = "Validée" (toujours pareil)
   - ValidatedAt = **MAINTENANT** (date/heure du clic)
   - CreatedAt = **MAINTENANT** (date/heure du clic)
   - Les autres dates (InPreparationAt, ShippedAt, DeliveredAt) = **NULL**

3. ? Vous RÉCUPÉREZ l'OrderId généré

4. ? Vous REDIRIGEZ vers OrderSuccess

---

## ?? IMPORTANT

**ValidatedAt est remplie À LA CRÉATION, pas après !**

- ? Ce n'est PAS remplie par un admin qui valide
- ? C'est remplie AUTOMATIQUEMENT au moment du clic "PAIEMENT"

Si vous voulez que l'admin valide APRÈS, vous devez créer une fonction séparée dans `AdminDashboardService.asmx.cs` :

```csharp
[WebMethod]
public object UpdateOrderStatus(int orderId, string newStatus)
{
    string sql = @"UPDATE Orders 
                  SET Status = @Status, 
                      InPreparationAt = GETDATE()  ? Pour passer EN PRÉPARATION
                  WHERE OrderId = @OrderId";
    // ...
}
```

