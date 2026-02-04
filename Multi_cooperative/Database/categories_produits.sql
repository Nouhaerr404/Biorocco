use AppEcommerce;
-- Catégories
INSERT INTO Categories (Name, Description) VALUES
('Miel', 'Miels biologiques de différentes fleurs et régions'),
('Huiles', 'Huiles végétales et essentielles naturelles'),
('Savons', 'Savons artisanaux aux ingrédients naturels'),
('Dattes', 'Dattes biologiques de qualité premium'),
('Crèmes', 'Crèmes hydratantes et produits de soin'),
('Epices', 'Épices et mélanges orientaux'),
('Coffrets', 'Coffrets cadeaux et assemblages spéciaux');
-- Produits Miel
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(1, 'Miel d''Acacia', 'Miel liquide doré au goût délicat', '100% miel d''acacia', 'Idéal pour sucrer les boissons et pâtisseries', 1, 12.50, 1),
(1, 'Miel de Lavande', 'Miel crémeux au parfum floral', '100% miel de lavande', 'Parfait avec les fromages et desserts', 1, 14.00, 1),
(1, 'Miel de Thym', 'Miel puissant aux propriétés antiseptiques', '100% miel de thym', 'Pour renforcer le système immunitaire', 1, 16.00, 1),
(1, 'Miel de Forêt', 'Miel foncé riche en minéraux', 'Mélange de miels de forêt', 'Tonique naturel, riche en antioxydants', 1, 13.50, 1),
(1, 'Miel de Romarin', 'Miel clair au goût subtil', '100% miel de romarin', 'Aide à la digestion, bon pour le foie', 1, 15.00, 1),
(1, 'Miel d''Eucalyptus', 'Miel aux notes mentholées', '100% miel d''eucalyptus', 'Soulage les maux de gorge et toux', 1, 14.50, 1),
(1, 'Miel de Montagne', 'Miel polyfloral des hautes altitudes', 'Mélange de fleurs de montagne', 'Énergisant naturel', 1, 17.00, 1),
(1, 'Miel de Citronnier', 'Miel léger et parfumé', '100% miel de citronnier', 'Apaisant, aide à trouver le sommeil', 1, 15.50, 1),
(1, 'Miel de Tournesol', 'Miel doré au goût doux', '100% miel de tournesol', 'Idéal pour les enfants', 1, 11.00, 1),
(1, 'Miel de Jujubier', 'Miel rare aux notes caramélisées', '100% miel de jujubier', 'Délicieux en cuisine orientale', 1, 18.50, 1);

-- Images pour Miel
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(1, 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&auto=format&fit=crop', 1),
(2, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w-800&auto=format&fit=crop', 1),
(3, 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&auto=format&fit=crop', 1),
(4, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800&auto=format&fit=crop', 1),
(5, 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&auto=format&fit=crop', 1),
(6, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800&auto=format&fit=crop', 1),
(7, 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&auto=format&fit=crop', 1),
(8, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800&auto=format&fit=crop', 1),
(9, 'https://images.unsplash.com/photo-1587049352851-8d4e89133924?w=800&auto=format&fit=crop', 1),
(10, 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=800&auto=format&fit=crop', 1);

-- Formats pour Miel
INSERT INTO ProductFormats (ProductId, Label, Price, Stock, StockMin) VALUES
(1, '250g', 8.50, 100, 20),
(1, '500g', 12.50, 80, 15),
(1, '1kg', 22.00, 50, 10),
(2, '250g', 9.00, 120, 20),
(2, '500g', 14.00, 90, 15),
(3, '250g', 10.00, 70, 15),
(3, '500g', 16.00, 60, 10);

-- Produits Huiles
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(2, 'Huile d''Argan', 'Huile précieuse pour peau et cheveux', '100% huile d''argan vierge', 'Hydratation intense visage et corps', 1, 35.00, 1),
(2, 'Huile d''Olive Vierge Extra', 'Huile d''olive fruitée', '100% olives biologiques', 'Cuisine et soins de la peau', 1, 18.00, 1),
(2, 'Huile d''Amande Douce', 'Huile nourrissante et apaisante', '100% huile d''amande douce', 'Soins bébé et massage', 1, 15.00, 1),
(2, 'Huile de Nigelle', 'Huile aux multiples vertus', '100% huile de cumin noir', 'Renforce le système immunitaire', 1, 28.00, 1),
(2, 'Huile de Jojoba', 'Huile légère non grasse', '100% huile de jojoba', 'Régule la production de sébum', 1, 22.00, 1),
(2, 'Huile de Ricin', 'Huile fortifiante pour cheveux', '100% huile de ricin', 'Favorise la pousse des cheveux', 1, 12.00, 1),
(2, 'Huile de Lavande', 'Huile essentielle apaisante', '100% huile essentielle de lavande', 'Relaxante, aide au sommeil', 1, 25.00, 1),
(2, 'Huile de Menthe Poivrée', 'Huile rafraîchissante', '100% huile essentielle de menthe', 'Soulage les maux de tête', 1, 20.00, 1),
(2, 'Huile de Rose Musquée', 'Huile régénérante', '100% huile de rose musquée', 'Atténue les cicatrices et rides', 1, 40.00, 1),
(2, 'Huile de Neem', 'Huile purifiante', '100% huile de neem', 'Problèmes de peau, anti-parasitaire', 1, 19.00, 1);

-- Images pour Huiles
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(11, 'https://images.unsplash.com/photo-1533050487297-09b450131914?w=800&auto=format&fit=crop', 1),
(12, 'https://images.unsplash.com/photo-1600271772470-bd22a9eea1d3?w=800&auto=format&fit=crop', 1),
(13, 'https://images.unsplash.com/photo-1533050487297-09b450131914?w=800&auto=format&fit=crop', 1),
(14, 'https://images.unsplash.com/photo-1600271772470-bd22a9eea1d3?w=800&auto=format&fit=crop', 1),
(15, 'https://images.unsplash.com/photo-1533050487297-09b450131914?w=800&auto=format&fit=crop', 1),
(16, 'https://images.unsplash.com/photo-1600271772470-bd22a9eea1d3?w=800&auto=format&fit=crop', 1),
(17, 'https://images.unsplash.com/photo-1533050487297-09b450131914?w=800&auto=format&fit=crop', 1),
(18, 'https://images.unsplash.com/photo-1600271772470-bd22a9eea1d3?w=800&auto=format&fit=crop', 1),
(19, 'https://images.unsplash.com/photo-1533050487297-09b450131914?w=800&auto=format&fit=crop', 1),
(20, 'https://images.unsplash.com/photo-1600271772470-bd22a9eea1d3?w=800&auto=format&fit=crop', 1);


-- Produits Savons
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(3, 'Savon d''Alep', 'Savon traditionnel au laurier', 'Huile d''olive, huile de laurier', 'Peaux sensibles, problèmes cutanés', 1, 6.50, 1),
(3, 'Savon au Miel', 'Savon nourrissant et adoucissant', 'Miel, huile d''amande, lait de chèvre', 'Hydratation intense', 1, 5.50, 1),
(3, 'Savon au Charbon Actif', 'Savon purifiant', 'Charbon actif, huile de tea tree', 'Peaux grasses et acnéiques', 1, 7.00, 1),
(3, 'Savon à l''Argan', 'Savon anti-âge', 'Huile d''argan, vitamine E', 'Peaux matures et sèches', 1, 8.00, 1),
(3, 'Savon à la Lavande', 'Savon relaxant', 'Lavande, huile d''olive', 'Apaisant, parfum frais', 1, 5.00, 1),
(3, 'Savon au Neem', 'Savon antibactérien', 'Huile de neem, curcuma', 'Problèmes de peau, eczéma', 1, 6.00, 1),
(3, 'Savon au Café', 'Savon gommant', 'Marc de café, huile de coco', 'Gommage corporel, anticellulite', 1, 6.50, 1),
(3, 'Savon à l''Aloe Vera', 'Savon hydratant', 'Gel d''aloe vera, huile d''avocat', 'Soulage les coups de soleil', 1, 5.50, 1),
(3, 'Savon au Lait d''Ânesse', 'Savon régénérant', 'Lait d''ânesse, miel', 'Peaux délicates, anti-âge', 1, 9.00, 1),
(3, 'Savon à l''Orange', 'Savon tonifiant', 'Huile essentielle d''orange, argile', 'Revitalise la peau', 1, 5.00, 1);

-- Images pour Savons
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(21, 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=800&auto=format&fit=crop', 1),
(22, 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=800&auto=format&fit=crop', 1),
(23, 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=800&auto=format&fit=crop', 1),
(24, 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=800&auto=format&fit=crop', 1),
(25, 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=800&auto=format&fit=crop', 1),
(26, 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=800&auto=format&fit=crop', 1),
(27, 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=800&auto=format&fit=crop', 1),
(28, 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=800&auto=format&fit=crop', 1),
(29, 'https://images.unsplash.com/photo-1596464716127-f2a82984de30?w=800&auto=format&fit=crop', 1),
(30, 'https://images.unsplash.com/photo-1600857062241-98e5dba7f214?w=800&auto=format&fit=crop', 1);


-- Produits Dattes
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(4, 'Dattes Medjool', 'Dattes charnues et moelleuses', '100% dattes Medjool', 'Snack énergétique, pâtisserie', 1, 25.00, 1),
(4, 'Dattes Deglet Nour', 'Dattes semi-sèches dorées', '100% dattes Deglet Nour', 'Cuisine salée et sucrée', 1, 18.00, 1),
(4, 'Dattes Ajwa', 'Dattes noires premium', '100% dattes Ajwa', 'Hautes qualités nutritionnelles', 1, 40.00, 1),
(4, 'Dattes Sukkari', 'Dattes très sucrées', '100% dattes Sukkari', 'Sucre naturel, énergie rapide', 1, 28.00, 1),
(4, 'Dattes farcies aux amandes', 'Dattes fourrées délicieuses', 'Dattes, amandes', 'Cadeau idéal, dessert raffiné', 1, 32.00, 1),
(4, 'Pâte de dattes', 'Pâte sucrée naturelle', '100% dattes mixées', 'Alternative au sucre, tartines', 1, 15.00, 1),
(4, 'Dattes Mabroom', 'Dattes allongées tendres', '100% dattes Mabroom', 'Consommation directe', 1, 26.00, 1),
(4, 'Dattes Khudri', 'Dattes fermes et sucrées', '100% dattes Khudri', 'Longue conservation', 1, 22.00, 1),
(4, 'Dattes Safawi', 'Dattes noires brillantes', '100% dattes Safawi', 'Riche en fibres', 1, 30.00, 1),
(4, 'Mélange de dattes', 'Assortiment de qualité', 'Mélange de 5 variétés', 'Découverte des saveurs', 1, 35.00, 1);

-- Images pour Dattes
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(31, 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=800&auto=format&fit=crop', 1),
(32, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop', 1),
(33, 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=800&auto=format&fit=crop', 1),
(34, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop', 1),
(35, 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=800&auto=format&fit=crop', 1),
(36, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop', 1),
(37, 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=800&auto=format&fit=crop', 1),
(38, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop', 1),
(39, 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=800&auto=format&fit=crop', 1),
(40, 'https://images.unsplash.com/photo-1544787219-7f47ccb76574?w=800&auto=format&fit=crop', 1);


-- Produits Crèmes
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(5, 'Crème Visage Argan', 'Crème hydratante anti-âge', 'Argan, vitamine E, aloe vera', 'Soin quotidien visage', 1, 45.00, 1),
(5, 'Crème Corps au Miel', 'Crème nourrissante', 'Miel, beurre de karité, amande', 'Hydratation corps quotidienne', 1, 28.00, 1),
(5, 'Crème Mains Répair', 'Crème réparatrice intense', 'Bourrache, calendula, cire d''abeille', 'Mains sèches et abîmées', 1, 15.00, 1),
(5, 'Crème Anti-Rougeurs', 'Apaisante peaux sensibles', 'Camomille, réglisse, avoine', 'Calme les irritations', 1, 38.00, 1),
(5, 'Crème Nuit Régénérante', 'Soin nocturne intensif', 'Rose musquée, huile d''onagre', 'Régénération pendant le sommeil', 1, 50.00, 1),
(5, 'Crème Contour des Yeux', 'Lissant anti-cernes', 'Caféine, vitamine K, hyaluronique', 'Atténue cernes et poches', 1, 35.00, 1),
(5, 'Crème Pieds Secs', 'Réparatrice pieds crevassés', 'Urée, beurre de cacao, menthol', 'Pieds très secs', 1, 18.00, 1),
(5, 'Crème Solaire Visage SPF 50', 'Protection minérale', 'Oxyde de zinc, huile de karanja', 'Protection UVA/UVB', 1, 32.00, 1),
(5, 'Crème Gommant Corps', 'Exfoliant hydratant', 'Noix, sucre brun, huile de coco', 'Gommage 1-2 fois/semaine', 1, 25.00, 1),
(5, 'Crème Après-Soleil', 'Apaisante et réparatrice', 'Aloe vera, lavande, calendula', 'Après exposition au soleil', 1, 22.00, 1);

-- Images pour Crèmes
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(41, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(42, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(43, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(44, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(45, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(46, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(47, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(48, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(49, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1),
(50, 'https://images.unsplash.com/photo-1556228578-9c360e1d458b?w=800&auto=format&fit=crop', 1);



-- Produits Epices
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(6, 'Safran Filaments', 'Safran premium iranien', '100% stigmates de Crocus', 'Riz, plats mijotés, pâtisseries', 1, 120.00, 1),
(6, 'Cumin Moulu', 'Cumin intense et aromatique', '100% cumin moulu', 'Tajines, viandes, légumes', 1, 8.00, 1),
(6, 'Curcuma en Poudre', 'Curcuma bio vibrant', '100% curcuma racine', 'Currys, sauces, boissons santé', 1, 10.00, 1),
(6, 'Cannelle Bâtons', 'Cannelle de Ceylan entière', '100% écorce de cannelle', 'Infusions, plats sucrés', 1, 12.00, 1),
(6, 'Ras el Hanout', 'Mélange traditionnel marocain', '27 épices sélectionnées', 'Tajines, couscous, viandes', 1, 15.00, 1),
(6, 'Gingembre Moulu', 'Gingembre piquant et chaud', '100% gingembre moulu', 'Biscuits, plats asiatiques', 1, 9.00, 1),
(6, 'Paprika Fumé', 'Paprika doux fumé', 'Piments fumés et moulus', 'Viandes, soupes, sauces', 1, 11.00, 1),
(6, 'Cardamome Noire', 'Cardamome intense', '100% gousses de cardamome', 'Café, desserts, plats indiens', 1, 25.00, 1),
(6, 'Sumac en Poudre', 'Sumac acidulé', '100% baies de sumac moulues', 'Salades, viandes grillées', 1, 14.00, 1),
(6, 'Mélange Baharat', 'Mélange d''épices orientales', 'Cumin, coriandre, cannelle...', 'Viandes, soupes, légumes', 1, 16.00, 1);

-- Images pour Epices
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(51, 'https://images.unsplash.com/photo-1596040033221-a1f4f8a6d0f9?w=800&auto=format&fit=crop', 1),
(52, 'https://images.unsplash.com/photo-1586201375761-83865001e311?w=800&auto=format&fit=crop', 1),
(53, 'https://images.unsplash.com/photo-1596040033221-a1f4f8a6d0f9?w=800&auto=format&fit=crop', 1),
(54, 'https://images.unsplash.com/photo-1586201375761-83865001e311?w=800&auto=format&fit=crop', 1),
(55, 'https://images.unsplash.com/photo-1596040033221-a1f4f8a6d0f9?w=800&auto=format&fit=crop', 1),
(56, 'https://images.unsplash.com/photo-1586201375761-83865001e311?w=800&auto=format&fit=crop', 1),
(57, 'https://images.unsplash.com/photo-1596040033221-a1f4f8a6d0f9?w=800&auto=format&fit=crop', 1),
(58, 'https://images.unsplash.com/photo-1586201375761-83865001e311?w=800&auto=format&fit=crop', 1),
(59, 'https://images.unsplash.com/photo-1596040033221-a1f4f8a6d0f9?w=800&auto=format&fit=crop', 1),
(60, 'https://images.unsplash.com/photo-1586201375761-83865001e311?w=800&auto=format&fit=crop', 1);


-- Produits Coffrets
INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive) VALUES
(7, 'Coffret Découverte Miel', '4 miels sélectionnés', 'Miel d''acacia, lavande, thym, forêt', 'Cadeau idéal pour découvrir', 1, 45.00, 1),
(7, 'Coffret Bien-être', 'Huiles essentielles de base', 'Lavande, menthe, tea tree, eucalyptus', 'Armoire à pharmacie naturelle', 1, 65.00, 1),
(7, 'Coffret Hammam', 'Rituel complet hammam', 'Savon noir, gant kessa, ghassoul', 'Soin traditionnel à la maison', 1, 55.00, 1),
(7, 'Coffret Gourmand Dattes', 'Assortiment de dattes', 'Medjool, Deglet Nour, Ajwa, fourrées', 'Cadeau gourmand raffiné', 1, 75.00, 1),
(7, 'Coffret Beauté Argan', 'Soins complets à l''argan', 'Huile, savon, crème visage', 'Routine beauté premium', 1, 85.00, 1),
(7, 'Coffret Épices Orientales', '8 épices indispensables', 'Safran, cumin, curcuma, cannelle...', 'Pour cuisine orientale', 1, 60.00, 1),
(7, 'Coffret Maman & Bébé', 'Produits doux et naturels', 'Huile d''amande, savon doux, crème', 'Soins sécurité bébé', 1, 70.00, 1),
(7, 'Coffret Massage Relaxant', 'Huiles et accessoires massage', 'Huile d''amande, huile essentielle lavande', 'Soin détente à deux', 1, 50.00, 1),
(7, 'Coffret Cuisine Marocaine', 'Épices et accessoires', 'Ras el hanout, safran, tajine miniature', 'Initiation cuisine marocaine', 1, 90.00, 1),
(7, 'Coffret Luxe Miel Rare', 'Miels rares d''exception', 'Miel de jujubier, de manuka, de sapin', 'Cadeau d''affaire haut de gamme', 1, 150.00, 1);

-- Images pour Coffrets
INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES
(61, 'https://images.unsplash.com/photo-1599459182570-2e7d1c5c81f1?w=800&auto=format&fit=crop', 1),
(62, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop', 1),
(63, 'https://images.unsplash.com/photo-1599459182570-2e7d1c5c81f1?w=800&auto=format&fit=crop', 1),
(64, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop', 1),
(65, 'https://images.unsplash.com/photo-1599459182570-2e7d1c5c81f1?w=800&auto=format&fit=crop', 1),
(66, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop', 1),
(67, 'https://images.unsplash.com/photo-1599459182570-2e7d1c5c81f1?w=800&auto=format&fit=crop', 1),
(68, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop', 1),
(69, 'https://images.unsplash.com/photo-1599459182570-2e7d1c5c81f1?w=800&auto=format&fit=crop', 1),
(70, 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&auto=format&fit=crop', 1);