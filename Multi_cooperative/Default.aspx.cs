using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Services;
using System.Web.Script.Services;

namespace Multi_cooperative
{
    public partial class _Default : Page
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public static object AddToCartAjax(int productId)
        {
            try
            {
                var session = System.Web.HttpContext.Current.Session;
                if (session["UserId"] == null)
                {
                    return new { success = false, message = "Non connecté" };
                }

                int userId = Convert.ToInt32(session["UserId"]);
                
                // Utiliser la même logique que AddToCart
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    // 1. Vérifier si l'utilisateur a déjà un panier actif
                    string getCartQuery = @"
                        SELECT CartId FROM Cart 
                        WHERE UserId = @userId ";

                    SqlCommand getCartCmd = new SqlCommand(getCartQuery, conn);
                    getCartCmd.Parameters.AddWithValue("@userId", userId);

                    conn.Open();
                    object cartIdObj = getCartCmd.ExecuteScalar();

                    int cartId;
                    if (cartIdObj == null)
                    {
                        // Créer un nouveau panier
                        string createCartQuery = "INSERT INTO Cart (UserId) OUTPUT INSERTED.CartId VALUES (@userId)";
                        SqlCommand createCartCmd = new SqlCommand(createCartQuery, conn);
                        createCartCmd.Parameters.AddWithValue("@userId", userId);
                        cartId = (int)createCartCmd.ExecuteScalar();
                    }
                    else
                    {
                        cartId = (int)cartIdObj;
                    }

                    // 2. Récupérer le premier format disponible pour ce produit
                    string getFormatQuery = @"
                        SELECT TOP 1 FormatId, Price 
                        FROM ProductFormats 
                        WHERE ProductId = @productId AND Stock > 0 
                        ORDER BY Price ASC";

                    SqlCommand getFormatCmd = new SqlCommand(getFormatQuery, conn);
                    getFormatCmd.Parameters.AddWithValue("@productId", productId);

                    SqlDataReader formatReader = getFormatCmd.ExecuteReader();

                    if (formatReader.Read())
                    {
                        int formatId = formatReader.GetInt32(0);
                        decimal unitPrice = formatReader.GetDecimal(1);
                        formatReader.Close();

                        // 3. Vérifier si le produit est déjà dans le panier
                        string checkItemQuery = @"
                            SELECT CartItemId, Quantity 
                            FROM CartItems 
                            WHERE CartId = @cartId AND ProductId = @productId AND FormatId = @formatId";

                        SqlCommand checkItemCmd = new SqlCommand(checkItemQuery, conn);
                        checkItemCmd.Parameters.AddWithValue("@cartId", cartId);
                        checkItemCmd.Parameters.AddWithValue("@productId", productId);
                        checkItemCmd.Parameters.AddWithValue("@formatId", formatId);

                        SqlDataReader itemReader = checkItemCmd.ExecuteReader();

                        if (itemReader.Read())
                        {
                            // Mettre à jour la quantité
                            int existingId = itemReader.GetInt32(0);
                            int existingQty = itemReader.GetInt32(1);
                            itemReader.Close();

                            string updateQuery = "UPDATE CartItems SET Quantity = @quantity WHERE CartItemId = @cartItemId";
                            SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                            updateCmd.Parameters.AddWithValue("@quantity", existingQty + 1);
                            updateCmd.Parameters.AddWithValue("@cartItemId", existingId);
                            updateCmd.ExecuteNonQuery();
                        }
                        else
                        {
                            itemReader.Close();

                            // Ajouter un nouvel item
                            string insertQuery = @"
                                INSERT INTO CartItems (CartId, ProductId, FormatId, Quantity, UnitPrice) 
                                VALUES (@cartId, @productId, @formatId, 1, @unitPrice)";

                            SqlCommand insertCmd = new SqlCommand(insertQuery, conn);
                            insertCmd.Parameters.AddWithValue("@cartId", cartId);
                            insertCmd.Parameters.AddWithValue("@productId", productId);
                            insertCmd.Parameters.AddWithValue("@formatId", formatId);
                            insertCmd.Parameters.AddWithValue("@unitPrice", unitPrice);
                            insertCmd.ExecuteNonQuery();
                        }

                        return new { success = true, message = "Produit ajouté au panier" };
                    }
                    else
                    {
                        formatReader.Close();
                        return new { success = false, message = "Aucun format disponible pour ce produit" };
                    }
                }
            }
            catch (Exception ex)
            {
                return new { success = false, message = ex.Message };
            }
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Charger les produits par défaut (nouveaux)
                LoadProducts("new");
                UpdateActiveTab("new");
            }
            else
            {
                // Conserver le tab actif après postback
                string currentTab = ViewState["CurrentTab"] as string ?? "new";
                UpdateActiveTab(currentTab);
            }
        }

        private void LoadProducts(string tabType = "new")
        {
            try
            {
                string query = "";

                // Requête différente selon le tab sélectionné
                switch (tabType)
                {
                    case "trending":
                        // Les plus recherchés
                        query = @"
                            SELECT TOP 12
                                p.ProductId,
                                p.Name,
                                p.Description,
                                p.IsOrganic,
                                c.Name as CategoryName,
                                COALESCE(
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId AND IsMain = 1),
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId),
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300'
                                ) as ImageUrl,
                                COALESCE(
                                    (SELECT MIN(Price) FROM ProductFormats 
                                     WHERE ProductId = p.ProductId AND Price > 0),
                                    p.BasePrice,
                                    99.99
                                ) as Price,
                                ISNULL(
                                    (SELECT AVG(CAST(Rating AS FLOAT)) 
                                     FROM Reviews WHERE ProductId = p.ProductId),
                                    4.5
                                ) as AvgRating,
                                'Tendances' as Badge,
                                ISNULL(
                                    (SELECT COUNT(*) FROM CartItems ci 
                                     INNER JOIN Cart c ON ci.CartId = c.CartId 
                                     WHERE ci.ProductId = p.ProductId),
                                    0
                                ) as CartCount
                            FROM Products p
                            INNER JOIN Categories c ON p.CategoryId = c.CategoryId
                            WHERE p.IsActive = 1
                            ORDER BY CartCount DESC, p.CreatedAt DESC";
                        break;

                    case "popular":
                        // Les plus populaires (par notes)
                        query = @"
                            SELECT TOP 12
                                p.ProductId,
                                p.Name,
                                p.Description,
                                p.IsOrganic,
                                c.Name as CategoryName,
                                COALESCE(
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId AND IsMain = 1),
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId),
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300'
                                ) as ImageUrl,
                                COALESCE(
                                    (SELECT MIN(Price) FROM ProductFormats 
                                     WHERE ProductId = p.ProductId AND Price > 0),
                                    p.BasePrice,
                                    99.99
                                ) as Price,
                                ISNULL(
                                    (SELECT AVG(CAST(Rating AS FLOAT)) 
                                     FROM Reviews WHERE ProductId = p.ProductId),
                                    4.5
                                ) as AvgRating,
                                'Populaire' as Badge
                            FROM Products p
                            INNER JOIN Categories c ON p.CategoryId = c.CategoryId
                            WHERE p.IsActive = 1
                            AND EXISTS (SELECT 1 FROM Reviews r WHERE r.ProductId = p.ProductId)
                            ORDER BY 
                                (SELECT AVG(CAST(Rating AS FLOAT)) FROM Reviews WHERE ProductId = p.ProductId) DESC,
                                (SELECT COUNT(*) FROM Reviews WHERE ProductId = p.ProductId) DESC";
                        break;

                    default: // "new" - Nouveaux produits
                        query = @"
                            SELECT TOP 12
                                p.ProductId,
                                p.Name,
                                p.Description,
                                p.IsOrganic,
                                c.Name as CategoryName,
                                COALESCE(
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId AND IsMain = 1),
                                    (SELECT TOP 1 ImageUrl FROM ProductImages 
                                     WHERE ProductId = p.ProductId),
                                    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300'
                                ) as ImageUrl,
                                COALESCE(
                                    (SELECT MIN(Price) FROM ProductFormats 
                                     WHERE ProductId = p.ProductId AND Price > 0),
                                    p.BasePrice,
                                    99.99
                                ) as Price,
                                ISNULL(
                                    (SELECT AVG(CAST(Rating AS FLOAT)) 
                                     FROM Reviews WHERE ProductId = p.ProductId),
                                    4.5
                                ) as AvgRating,
                                'Nouveau' as Badge
                            FROM Products p
                            INNER JOIN Categories c ON p.CategoryId = c.CategoryId
                            WHERE p.IsActive = 1
                            ORDER BY p.CreatedAt DESC";
                        break;
                }

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Stocker le type de tab dans ViewState pour le postback
                    ViewState["CurrentTab"] = tabType;

                    // Lier les données au Repeater
                    rptProductsGrid.DataSource = dt;
                    rptProductsGrid.DataBind();

                    // Afficher ou cacher le message si aucun produit
                    pnlNoProducts.Visible = dt.Rows.Count == 0;

                    System.Diagnostics.Debug.WriteLine($"Produits chargés ({tabType}): {dt.Rows.Count}");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Erreur LoadProducts({tabType}): " + ex.Message);
                pnlNoProducts.Visible = true;
            }
        }

        // Gestionnaire pour les tabs
        protected void TabButton_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            string tabType = btn.CommandArgument;
            LoadProducts(tabType);
            UpdateActiveTab(tabType);
        }

        private void UpdateActiveTab(string activeTab)
        {
            // Réinitialiser tous les tabs
            btnTabNew.CssClass = "tab-btn";
            btnTabTrending.CssClass = "tab-btn";

            // Activer le tab sélectionné
            switch (activeTab)
            {
                case "new":
                    btnTabNew.CssClass = "tab-btn active";
                    break;
                case "trending":
                    btnTabTrending.CssClass = "tab-btn active";
                    break;
                
            }
        }

        // Méthodes helper pour le formatage
        protected string GetImageUrl(object imageUrl)
        {
            if (imageUrl == null || imageUrl == DBNull.Value || string.IsNullOrEmpty(imageUrl.ToString()))
            {
                return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300";
            }
            return imageUrl.ToString();
        }

        protected string GetFormattedPrice(object price)
        {
            if (price == null || price == DBNull.Value)
                return "99.99 MAD";

            decimal priceValue;
            if (decimal.TryParse(price.ToString(), out priceValue))
            {
                return priceValue.ToString("N2") + " MAD";
            }

            return "99.99 MAD";
        }

        protected string GetStarRating(object rating)
        {
            if (rating == null || rating == DBNull.Value)
                return "<i class='fas fa-star star'></i><i class='fas fa-star star'></i><i class='fas fa-star star'></i><i class='fas fa-star star'></i><i class='fas fa-star star'></i>";

            double avgRating = 0;
            double.TryParse(rating.ToString(), out avgRating);

            string stars = "";
            for (int i = 1; i <= 5; i++)
            {
                if (i <= Math.Floor(avgRating))
                {
                    stars += "<i class='fas fa-star star'></i>";
                }
                else if (i == Math.Ceiling(avgRating) && avgRating % 1 >= 0.5)
                {
                    stars += "<i class='fas fa-star-half-alt star'></i>";
                }
                else
                {
                    stars += "<i class='far fa-star star'></i>";
                }
            }

            return stars;
        }

        protected void rptProductsGrid_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;

                // Trouver le bouton Ajouter au panier
                Button btnAddToCart = (Button)e.Item.FindControl("btnAddToCart");
                if (btnAddToCart != null)
                {
                    btnAddToCart.CommandArgument = rowView["ProductId"].ToString();
                }

                // Trouver le label du badge
                Label lblBadge = (Label)e.Item.FindControl("lblBadge");
                if (lblBadge != null && rowView["Badge"] != DBNull.Value)
                {
                    lblBadge.Text = rowView["Badge"].ToString();

                    // Changer la couleur selon le badge
                    switch (lblBadge.Text)
                    {
                        case "Nouveau":
                            lblBadge.Style["background-color"] = "#E8967D";
                            break;
                        case "Tendances":
                            lblBadge.Style["background-color"] = "#2D5F3F";
                            break;
                        case "Populaire":
                            lblBadge.Style["background-color"] = "#FFD700";
                            lblBadge.Style["color"] = "#333";
                            break;
                    }
                }
            }
        }

        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            Button btn = (Button)sender;
            int productId = Convert.ToInt32(btn.CommandArgument);

            // Vérifier si l'utilisateur est connecté
            if (Session["UserId"] == null)
            {
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            int userId = Convert.ToInt32(Session["UserId"]);

            // Logique pour ajouter au panier
            AddToCart(userId, productId);

            // Message de succès
            ScriptManager.RegisterStartupScript(this, GetType(), "AddToCartSuccess",
                "showNotification('Produit ajouté au panier avec succès', 'success');", true);
        }

        private void AddToCart(int userId, int productId)
        {
            try
            {
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    // 1. Vérifier si l'utilisateur a déjà un panier actif
                    string getCartQuery = @"
                        SELECT CartId FROM Cart 
                        WHERE UserId = @userId ";

                    SqlCommand getCartCmd = new SqlCommand(getCartQuery, conn);
                    getCartCmd.Parameters.AddWithValue("@userId", userId);

                    conn.Open();
                    object cartIdObj = getCartCmd.ExecuteScalar();

                    int cartId;
                    if (cartIdObj == null)
                    {
                        // Créer un nouveau panier
                        string createCartQuery = "INSERT INTO Cart (UserId) OUTPUT INSERTED.CartId VALUES (@userId)";
                        SqlCommand createCartCmd = new SqlCommand(createCartQuery, conn);
                        createCartCmd.Parameters.AddWithValue("@userId", userId);
                        cartId = (int)createCartCmd.ExecuteScalar();
                    }
                    else
                    {
                        cartId = (int)cartIdObj;
                    }

                    // 2. Récupérer le premier format disponible pour ce produit
                    string getFormatQuery = @"
                        SELECT TOP 1 FormatId, Price 
                        FROM ProductFormats 
                        WHERE ProductId = @productId AND Stock > 0 
                        ORDER BY Price ASC";

                    SqlCommand getFormatCmd = new SqlCommand(getFormatQuery, conn);
                    getFormatCmd.Parameters.AddWithValue("@productId", productId);

                    SqlDataReader formatReader = getFormatCmd.ExecuteReader();

                    if (formatReader.Read())
                    {
                        int formatId = formatReader.GetInt32(0);
                        decimal unitPrice = formatReader.GetDecimal(1);
                        formatReader.Close();

                        // 3. Vérifier si le produit est déjà dans le panier
                        string checkItemQuery = @"
                            SELECT CartItemId, Quantity 
                            FROM CartItems 
                            WHERE CartId = @cartId AND ProductId = @productId AND FormatId = @formatId";

                        SqlCommand checkItemCmd = new SqlCommand(checkItemQuery, conn);
                        checkItemCmd.Parameters.AddWithValue("@cartId", cartId);
                        checkItemCmd.Parameters.AddWithValue("@productId", productId);
                        checkItemCmd.Parameters.AddWithValue("@formatId", formatId);

                        SqlDataReader itemReader = checkItemCmd.ExecuteReader();

                        if (itemReader.Read())
                        {
                            // Mettre à jour la quantité
                            int existingId = itemReader.GetInt32(0);
                            int existingQty = itemReader.GetInt32(1);
                            itemReader.Close();

                            string updateQuery = "UPDATE CartItems SET Quantity = @quantity WHERE CartItemId = @cartItemId";
                            SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                            updateCmd.Parameters.AddWithValue("@quantity", existingQty + 1);
                            updateCmd.Parameters.AddWithValue("@cartItemId", existingId);
                            updateCmd.ExecuteNonQuery();
                        }
                        else
                        {
                            itemReader.Close();

                            // Ajouter un nouvel item
                            string insertQuery = @"
                                INSERT INTO CartItems (CartId, ProductId, FormatId, Quantity, UnitPrice) 
                                VALUES (@cartId, @productId, @formatId, 1, @unitPrice)";

                            SqlCommand insertCmd = new SqlCommand(insertQuery, conn);
                            insertCmd.Parameters.AddWithValue("@cartId", cartId);
                            insertCmd.Parameters.AddWithValue("@productId", productId);
                            insertCmd.Parameters.AddWithValue("@formatId", formatId);
                            insertCmd.Parameters.AddWithValue("@unitPrice", unitPrice);
                            insertCmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        formatReader.Close();
                        throw new Exception("Aucun format disponible pour ce produit");
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur AddToCart: " + ex.Message);
                ScriptManager.RegisterStartupScript(this, GetType(), "AddToCartError",
                    "showNotification('Erreur lors de l\\'ajout au panier: " + ex.Message.Replace("'", "\\'") + "', 'error');", true);
            }
        }

        // Gestionnaire pour la newsletter
        protected void btnSubscribe_Click(object sender, EventArgs e)
        {
            try
            {
                if (!string.IsNullOrEmpty(txtNewsletterEmail.Text))
                {
                    // Enregistrer l'email (vous pouvez créer une table Newsletter)
                    string query = @"
                        IF NOT EXISTS (SELECT 1 FROM Newsletter WHERE Email = @email)
                        BEGIN
                            INSERT INTO Newsletter (Email, CreatedAt) 
                            VALUES (@email, GETDATE())
                        END";

                    using (SqlConnection conn = Database.Database.GetConnection())
                    {
                        SqlCommand cmd = new SqlCommand(query, conn);
                        cmd.Parameters.AddWithValue("@email", txtNewsletterEmail.Text);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }

                    lblNewsletterMessage.Text = "Merci pour votre inscription à notre newsletter !";
                    lblNewsletterMessage.Style["color"] = "white";
                    lblNewsletterMessage.Style["display"] = "block";

                    // Vider le champ email
                    txtNewsletterEmail.Text = "";

                    System.Diagnostics.Debug.WriteLine($"Newsletter inscription: {txtNewsletterEmail.Text}");
                }
            }
            catch (Exception ex)
            {
                lblNewsletterMessage.Text = "Une erreur est survenue. Veuillez réessayer.";
                lblNewsletterMessage.Style["color"] = "#ffcccc";
                lblNewsletterMessage.Style["display"] = "block";
                System.Diagnostics.Debug.WriteLine("Erreur newsletter: " + ex.Message);
            }
        }
    }
}