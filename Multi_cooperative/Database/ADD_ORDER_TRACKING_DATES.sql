-- Script pour ajouter les colonnes de suivi des dates de statut des commandes
-- À exécuter sur la base de données existante

-- Ajouter les colonnes pour les dates de suivi
ALTER TABLE Orders
ADD ValidatedAt DATETIME NULL,
    InPreparationAt DATETIME NULL,
    ShippedAt DATETIME NULL,
    DeliveredAt DATETIME NULL;

-- Optionnel: Mettre à jour les commandes existantes selon leur statut actuel
-- Si une commande a le statut "Validée", mettre la date de création comme ValidatedAt
UPDATE Orders 
SET ValidatedAt = CreatedAt 
WHERE Status = 'Validée' AND ValidatedAt IS NULL;

-- Si une commande a le statut "En préparation", mettre la date de création comme InPreparationAt
UPDATE Orders 
SET InPreparationAt = CreatedAt 
WHERE Status = 'En préparation' AND InPreparationAt IS NULL;

-- Si une commande a le statut "Expédiée", mettre la date de création comme ShippedAt
UPDATE Orders 
SET ShippedAt = CreatedAt 
WHERE Status = 'Expédiée' AND ShippedAt IS NULL;

-- Si une commande a le statut "Livrée", mettre la date de création comme DeliveredAt
UPDATE Orders 
SET DeliveredAt = CreatedAt 
WHERE Status = 'Livrée' AND DeliveredAt IS NULL;

