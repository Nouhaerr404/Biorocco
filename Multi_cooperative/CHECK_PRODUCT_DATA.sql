-- Vérifier les valeurs réelles d'un produit dans la base de données
-- Remplacez 1016 par le ProductId que vous testez

SELECT 
    ProductId,
    Name,
    Description,
    Ingredients,
    Usage,
    BasePrice,
    IsOrganic,
    IsActive,
    CASE WHEN Ingredients IS NULL THEN 'NULL' ELSE 'NOT NULL (' + CAST(LEN(Ingredients) AS VARCHAR) + ' chars)' END as IngredientsStatus,
    CASE WHEN Usage IS NULL THEN 'NULL' ELSE 'NOT NULL (' + CAST(LEN(Usage) AS VARCHAR) + ' chars)' END as UsageStatus,
    CASE WHEN BasePrice IS NULL THEN 'NULL' ELSE 'NOT NULL (' + CAST(BasePrice AS VARCHAR) + ')' END as BasePriceStatus
FROM Products
WHERE ProductId = 1016;

-- Si vous voyez NULL pour ces colonnes, alors les données n'ont pas été sauvegardées
-- Si vous voyez NOT NULL avec des valeurs, alors le problème est dans la récupération/JSON

