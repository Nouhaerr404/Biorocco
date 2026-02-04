# ?? STRUCTURE DE LA TABLE ORDERS REQUISE

Selon votre code de profil (`ClientProfileService.asmx.cs`), voici ce qu'il faut dans votre table `Orders` :

## ? Colonnes OBLIGATOIRES

```sql
CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY(1,1),
    UserId INT NOT NULL,
    AddressId INT NOT NULL,
    ShippingId INT NOT NULL,
    
    -- Informations de base
    Status NVARCHAR(50) NOT NULL,           -- 'Validée', 'En préparation', 'Expédiée', 'Livrée', 'Annulée'
    TotalTTC DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50),             -- 'Carte Bancaire', etc.
    TrackingNumber NVARCHAR(100) NULL,      -- Numéro de suivi (DHL, Maroc Poste)
    
    -- Dates de progression du statut
    CreatedAt DATETIME NOT NULL,            -- Date de création
    ValidatedAt DATETIME NULL,              -- Date validation
    InPreparationAt DATETIME NULL,          -- Date passage en préparation
    ShippedAt DATETIME NULL,                -- Date d'expédition
    DeliveredAt DATETIME NULL,              -- Date de livraison
    
    -- Annulation
    CancellationReason NVARCHAR(500) NULL,
    CancelledAt DATETIME NULL,
    
    FOREIGN KEY (UserId) REFERENCES Users(UserId),
    FOREIGN KEY (AddressId) REFERENCES Addresses(AddressId),
    FOREIGN KEY (ShippingId) REFERENCES ShippingMethods(ShippingId)
);
```

## ?? CYCLE DE VIE D'UNE COMMANDE

```
1. Client clique "PAIEMENT" ? Checkout.aspx
   ?? INSERT INTO Orders avec :
      ?? Status = 'Validée'
      ?? CreatedAt = NOW()
      ?? ValidatedAt = NOW()  ? On remplit à la création
      ?? InPreparationAt = NULL (à faire par admin)

2. Admin valide la commande
   ?? UPDATE Orders SET InPreparationAt = NOW() WHERE OrderId = ?

3. Admin expédie la commande
   ?? UPDATE Orders SET ShippedAt = NOW(), TrackingNumber = 'DHL123...', Status = 'Expédiée'

4. Livreur confirme la livraison
   ?? UPDATE Orders SET DeliveredAt = NOW(), Status = 'Livrée'
```

## ?? TABLEAU DE PROGRESSION

| Étape | Status | Colonne Date | Affichage dans Profil |
|-------|--------|--------------|----------------------|
| 1 | Validée | ValidatedAt | ? Commande validée |
| 2 | En préparation | InPreparationAt | ?? En préparation |
| 3 | Expédiée | ShippedAt | ?? Expédiée (avec TrackingNumber) |
| 4 | Livrée | DeliveredAt | ? Livrée |

## ?? SQL POUR VÉRIFIER VOTRE TABLE

```sql
-- Vérifier les colonnes
SELECT COLUMN_NAME, DATA_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Orders'
ORDER BY ORDINAL_POSITION;

-- Vérifier une commande
SELECT 
    OrderId, Status, CreatedAt, ValidatedAt, 
    InPreparationAt, ShippedAt, DeliveredAt, 
    TrackingNumber, CancellationReason
FROM Orders 
WHERE OrderId = 1;
```

## ? PROBLÈME ACTUEL RÉSOLU

**Votre `Checkout.aspx.cs` utilise maintenant :**
```csharp
INSERT INTO Orders (..., ValidatedAt) 
VALUES (..., GETDATE())
```

? Cela remplit `ValidatedAt` à la création, ce qui correspond au **statut "Validée"** dans le profil.

## ?? PROCHAINE ÉTAPE

Vous devez créer une **fonction admin** pour mettre à jour les statuts :

```csharp
// Dans AdminDashboardService.asmx.cs
public object UpdateOrderStatus(int orderId, string newStatus)
{
    using (SqlConnection conn = Database.Database.GetConnection())
    {
        conn.Open();
        
        string columnToUpdate = "";
        if (newStatus == "En préparation")
            columnToUpdate = "InPreparationAt = GETDATE()";
        else if (newStatus == "Expédiée")
            columnToUpdate = "ShippedAt = GETDATE()";
        else if (newStatus == "Livrée")
            columnToUpdate = "DeliveredAt = GETDATE()";
        
        string sql = $@"UPDATE Orders 
                       SET Status = @Status, {columnToUpdate}
                       WHERE OrderId = @OrderId";
        
        using (SqlCommand cmd = new SqlCommand(sql, conn))
        {
            cmd.Parameters.AddWithValue("@Status", newStatus);
            cmd.Parameters.AddWithValue("@OrderId", orderId);
            cmd.ExecuteNonQuery();
        }
    }
}
```

