-- Script SQL pour insérer des catégories de test
-- Exécutez ce script dans votre base de données si vous voulez avoir des catégories pour tester

-- Vérifier et insérer des catégories si elles n'existent pas
IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Huiles')
BEGIN
    INSERT INTO Categories (Name, Description) 
    VALUES ('Huiles', 'Huiles végétales et d''olive biologiques');
END

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Miels')
BEGIN
    INSERT INTO Categories (Name, Description) 
    VALUES ('Miels', 'Miels artisanaux de différentes fleurs');
END

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Fruits Secs')
BEGIN
    INSERT INTO Categories (Name, Description) 
    VALUES ('Fruits Secs', 'Amandes, noix, dattes et autres fruits secs');
END

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Cosmétiques')
BEGIN
    INSERT INTO Categories (Name, Description) 
    VALUES ('Cosmétiques', 'Savons et produits cosmétiques naturels');
END

IF NOT EXISTS (SELECT 1 FROM Categories WHERE Name = 'Épicerie')
BEGIN
    INSERT INTO Categories (Name, Description) 
    VALUES ('Épicerie', 'Produits alimentaires divers');
END

-- Vérifier les catégories insérées
SELECT CategoryId, Name, Description FROM Categories ORDER BY Name;

