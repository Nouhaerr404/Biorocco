-- Script SQL pour vérifier la structure de la table Products
-- Exécutez cette requête dans SQL Server Management Studio ou via votre outil de base de données

-- Vérifier si les colonnes existent
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Products'
ORDER BY ORDINAL_POSITION;

-- Vérifier la structure complète
EXEC sp_columns 'Products';

-- Si les colonnes n'existent pas, ajoutez-les avec cette requête:
/*
ALTER TABLE Products
ADD Ingredients NVARCHAR(MAX) NULL,
    Usage NVARCHAR(MAX) NULL,
    BasePrice DECIMAL(10,2) NULL,
    IsOrganic BIT DEFAULT 0;
*/

-- Vérifier un produit spécifique pour voir ses valeurs
-- SELECT ProductId, Name, Description, Ingredients, Usage, BasePrice, IsOrganic 
-- FROM Products 
-- WHERE ProductId = 1016;

