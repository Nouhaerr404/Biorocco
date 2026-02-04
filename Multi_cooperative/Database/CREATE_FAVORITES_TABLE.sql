-- Table pour les produits favoris
CREATE TABLE Favorites (
    FavoriteId INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    ProductId INT NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (UserId) REFERENCES Users(UserId) ON DELETE CASCADE,
    FOREIGN KEY (ProductId) REFERENCES Products(ProductId) ON DELETE CASCADE,
    UNIQUE(UserId, ProductId) -- Un utilisateur ne peut ajouter un produit qu'une seule fois
);

-- Index pour améliorer les performances
CREATE INDEX IX_Favorites_UserId ON Favorites(UserId);
CREATE INDEX IX_Favorites_ProductId ON Favorites(ProductId);

