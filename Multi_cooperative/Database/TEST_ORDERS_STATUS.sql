-- Script pour créer des commandes de test avec différents statuts
-- À exécuter pour tester l'affichage du bouton "Annuler"

-- Remplacez @UserId par l'ID d'un utilisateur existant dans votre base de données
-- Remplacez @AddressId par l'ID d'une adresse existante
-- Remplacez @ShippingId par l'ID d'une méthode de livraison existante

-- 1. Commande avec statut "Validée" - LE BOUTON "ANNULER" DOIT S'AFFICHER
INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalHT, TotalTTC, DeliveryFee, PaymentMethod, CreatedAt)
VALUES (@UserId, @AddressId, @ShippingId, 'Validée', 100.00, 120.00, 10.00, 'Carte bancaire', GETDATE());

-- 2. Commande avec statut "En préparation" - LE BOUTON "ANNULER" DOIT S'AFFICHER
INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalHT, TotalTTC, DeliveryFee, PaymentMethod, CreatedAt)
VALUES (@UserId, @AddressId, @ShippingId, 'En préparation', 150.00, 180.00, 15.00, 'Espèces', GETDATE());

-- 3. Commande avec statut "Expédiée" - LE BOUTON "ANNULER" NE DOIT PAS S'AFFICHER
INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalHT, TotalTTC, DeliveryFee, PaymentMethod, TrackingNumber, CreatedAt, ShippedAt)
VALUES (@UserId, @AddressId, @ShippingId, 'Expédiée', 200.00, 240.00, 20.00, 'Carte bancaire', 'TRACK123456', GETDATE(), GETDATE());

-- 4. Commande avec statut "Livrée" - LE BOUTON "ANNULER" NE DOIT PAS S'AFFICHER
INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalHT, TotalTTC, DeliveryFee, PaymentMethod, TrackingNumber, CreatedAt, ShippedAt, DeliveredAt)
VALUES (@UserId, @AddressId, @ShippingId, 'Livrée', 250.00, 300.00, 25.00, 'Carte bancaire', 'TRACK789012', GETDATE(), DATEADD(day, -2, GETDATE()), DATEADD(day, -1, GETDATE()));

-- 5. Commande avec statut "Annulée" - LE BOUTON "ANNULER" NE DOIT PAS S'AFFICHER
INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalHT, TotalTTC, DeliveryFee, PaymentMethod, CancellationReason, CancelledAt, CreatedAt)
VALUES (@UserId, @AddressId, @ShippingId, 'Annulée', 80.00, 96.00, 8.00, 'Carte bancaire', 'Changement d''avis', DATEADD(day, -1, GETDATE()), DATEADD(day, -2, GETDATE()));

-- Pour tester avec un utilisateur spécifique, utilisez cette requête pour obtenir les IDs :
-- SELECT UserId FROM Users WHERE Email = 'email@example.com';
-- SELECT AddressId FROM Addresses WHERE UserId = @UserId;
-- SELECT ShippingId FROM ShippingMethods;

