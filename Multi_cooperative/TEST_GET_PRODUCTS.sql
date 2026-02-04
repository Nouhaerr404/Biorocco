-- Test direct de la requête utilisée dans GetProducts
-- Exécutez cette requête pour vérifier si les colonnes existent et si les données sont récupérées

-- Vérifier la structure de la table
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'Products'
ORDER BY ORDINAL_POSITION;

-- Test de la requête exacte utilisée dans GetProducts (sans pagination)
SELECT TOP 5 
    p.ProductId, 
    p.Name, 
    p.Description, 
    p.Ingredients, 
    p.Usage, 
    p.BasePrice, 
    p.IsOrganic, 
    p.IsActive, 
    p.CreatedAt,
    c.CategoryId, 
    c.Name as CategoryName
FROM Products p
LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
ORDER BY p.CreatedAt DESC;

-- Vérifier un produit spécifique (remplacez 1016 par un ProductId qui existe)
SELECT 
    ProductId,
    Name,
    Description,
    Ingredients,
    Usage,
    BasePrice,
    IsOrganic,
    IsActive
FROM Products
WHERE ProductId = 1016;

