using System;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    public partial class ProductDetail : System.Web.UI.Page
    {
        // Dans Page_Load, ajoute l'appel à LoadRecommendations
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string productId = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(productId))
                {
                    LoadProductDetails(productId);
                    LoadProductImages(productId);

                    // --- AJOUTE CETTE LIGNE ---
                    LoadRecommendations(productId);
                }
                else { Response.Redirect("Products.aspx"); }
            }
        }

        // --- AJOUTE CETTE MÉTHODE DANS LA CLASSE ---
        private void LoadRecommendations(string currentProductId)
        {
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                // REQUÊTE INTELLIGENTE :
                // 1. Trouve la catégorie du produit actuel
                // 2. Sélectionne 3 autres produits de cette catégorie
                // 3. Si pas assez de produits, complète avec des produits populaires
                string sql = @"
            SELECT TOP 3 p.ProductId, p.Name, p.BasePrice as Price, img.ImageUrl
            FROM Products p
            LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
            WHERE p.CategoryId = (SELECT CategoryId FROM Products WHERE ProductId = @CurrentId)
              AND p.ProductId != @CurrentId
              AND p.IsActive = 1";

                if (Session["UserId"] != null)
                {
                    sql += @" AND p.ProductId NOT IN (
                        SELECT ci.ProductId 
                        FROM CartItems ci
                        JOIN Cart c ON ci.CartId = c.CartId
                        WHERE c.UserId = @UserId
                      )";
                }

                sql += " ORDER BY NEWID()"; // NEWID() mélange les résultats à chaque fois

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@CurrentId", currentProductId);
                    if (Session["UserId"] != null)
                    {
                        cmd.Parameters.AddWithValue("@UserId", (int)Session["UserId"]);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Si on a moins de 3 produits (ou 0), on remplit avec n'importe quels produits actifs
                    // pour ne pas laisser la zone vide
                    if (dt.Rows.Count < 3)
                    {
                        string sqlFallback = @"
                    SELECT TOP 3 p.ProductId, p.Name, p.BasePrice as Price, img.ImageUrl
                    FROM Products p
                    LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
                    WHERE p.ProductId != @CurrentId AND p.IsActive = 1";
                    if (Session["UserId"] != null)
                {
                            sqlFallback += @" AND p.ProductId NOT IN (
                                        SELECT ci.ProductId 
                                        FROM CartItems ci
                                        JOIN Cart c ON ci.CartId = c.CartId
                                        WHERE c.UserId = @UserId
                                      )";
                        }
                        sqlFallback += " ORDER BY NEWID()";

                        using (SqlCommand cmdFallback = new SqlCommand(sqlFallback, conn))
                        {
                            cmdFallback.Parameters.AddWithValue("@CurrentId", currentProductId);
                            if (Session["UserId"] != null)
                            {
                                cmdFallback.Parameters.AddWithValue("@UserId", (int)Session["UserId"]);
                            }
                            SqlDataAdapter daFb = new SqlDataAdapter(cmdFallback);
                            DataTable dtFb = new DataTable();
                            daFb.Fill(dtFb);

                            // On utilise le résultat de secours si le premier est vide
                            if (dt.Rows.Count == 0) dt = dtFb;
                        }
                    }

                    rptRecommendations.DataSource = dt;
                    rptRecommendations.DataBind();
                }
            }
        }

        private void LoadProductImages(string productId)
        {
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string q = "SELECT ImageUrl, IsMain FROM ProductImages WHERE ProductId = @Id ORDER BY IsMain DESC, ImageId ASC";
                using (SqlCommand cmd = new SqlCommand(q, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", productId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        bool first = true;
                        while (rdr.Read())
                        {
                            string url = rdr["ImageUrl"] != DBNull.Value ? rdr["ImageUrl"].ToString() : null;
                            if (string.IsNullOrEmpty(url)) continue;

                            if (url.StartsWith("/")) url = "~" + url;
                            else if (!url.StartsWith("~") && !url.StartsWith("http", StringComparison.OrdinalIgnoreCase)) url = "~/" + url.TrimStart('/');

                            string resolved = ResolveUrl(url);

                            var img = new Image();
                            img.Attributes["data-src"] = resolved;
                            img.ImageUrl = resolved;
                            img.Style["width"] = "60px";
                            img.Style["height"] = "60px";
                            img.Style["object-fit"] = "cover";
                            img.Style["border"] = "1px solid #ddd";
                            img.Style["cursor"] = "pointer";
                            img.Style["margin-right"] = "5px";

                            phThumbs.Controls.Add(img);

                            if (first && string.IsNullOrEmpty(imgMain.ImageUrl))
                            {
                                imgMain.ImageUrl = resolved;
                            }
                            first = false;
                        }
                    }
                }
            }
        }

        private void LoadProductDetails(string productId)
        {
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                string queryProduct = @"
                    SELECT p.Name, p.Description, p.Ingredients, p.Usage, p.IsOrganic, 
                           c.Name as CategoryName, 
                           img.ImageUrl
                    FROM Products p
                    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
                    LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
                    WHERE p.ProductId = @Id";

                using (SqlCommand cmd = new SqlCommand(queryProduct, conn))
                {
                    cmd.Parameters.AddWithValue("@Id", productId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            litProductName.Text = rdr["Name"].ToString();
                            litDescription.Text = rdr["Description"].ToString();
                            litIngredients.Text = rdr["Ingredients"].ToString();
                            litUsage.Text = rdr["Usage"].ToString();
                            litCategory.Text = rdr["CategoryName"].ToString();

                            string dbImg = rdr["ImageUrl"] != DBNull.Value ? rdr["ImageUrl"].ToString() : "~/Images/bg_auth.jpg";
                            imgMain.ImageUrl = ResolveUrl(dbImg);
                        }
                    }
                }

                string queryFormats = "SELECT FormatId, Label, Price FROM ProductFormats WHERE ProductId = @Id";
                using (SqlCommand cmdFormat = new SqlCommand(queryFormats, conn))
                {
                    cmdFormat.Parameters.AddWithValue("@Id", productId);
                    SqlDataAdapter da = new SqlDataAdapter(cmdFormat);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    ddlFormats.DataSource = dt;
                    ddlFormats.DataTextField = "Label";
                    ddlFormats.DataValueField = "FormatId";
                    ddlFormats.DataBind();
                    
                    // CORRECTION : Sélectionner automatiquement le premier format
                    if (ddlFormats.Items.Count > 0)
                    {
                        ddlFormats.SelectedIndex = 0;
                    }
                }
            }
            UpdatePrice();
        }

        protected void ddlFormats_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdatePrice();
        }

        private void UpdatePrice()
        {
            if (ddlFormats.SelectedValue == "") return;
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = "SELECT Price FROM ProductFormats WHERE FormatId = @FId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@FId", ddlFormats.SelectedValue);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                        lblPrice.Text = Convert.ToDecimal(result).ToString("N2");
                }
            }
        }


        // Bouton 1 : AJOUTER AU PANIER
        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                string returnUrl = Server.UrlEncode(Request.Url.PathAndQuery);
                Response.Redirect("Login.aspx?ReturnUrl=" + returnUrl);
                return;
            }

            // 1. Ajouter à la base de données
            ProcessCartAddition();

            // 2. Charger les items du panier dans le Repeater Sidebar
            LoadSideCart();

            // 3. Ouvrir la sidebar via Javascript
            ScriptManager.RegisterStartupScript(this, this.GetType(), "OpenCart", "openCart();", true);
        }

        private void LoadSideCart()
        {
            int userId = (int)Session["UserId"];
            decimal subTotal = 0;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                // ⚠️ SEULE MODIFICATION : Ajout de l'alias "o." devant CartId dans la sous-requête
                string sql = @"
            SELECT ci.CartItemId, ci.Quantity, ci.UnitPrice, (ci.Quantity * ci.UnitPrice) as TotalPrice,
                   p.Name, f.Label, img.ImageUrl
            FROM CartItems ci
            JOIN Cart c ON ci.CartId = c.CartId
            JOIN Products p ON ci.ProductId = p.ProductId
            JOIN ProductFormats f ON ci.FormatId = f.FormatId
            LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
            WHERE c.UserId = @UserId";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptCartItems.DataSource = dt;
                    rptCartItems.DataBind();

                    if (dt.Rows.Count == 0)
                        lblEmptyCart.Visible = true;
                    else
                        lblEmptyCart.Visible = false;

                    // Calculer le sous-total
                    foreach (DataRow row in dt.Rows)
                    {
                        subTotal += Convert.ToDecimal(row["TotalPrice"]);
                    }
                }
            }
            litSubTotal.Text = subTotal.ToString("N2");
        }
        private void LoadRecommendations()
        {
            // Charge 3 produits au hasard pour la colonne de gauche
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = @"SELECT TOP 3 p.ProductId, p.Name, p.BasePrice as Price, img.ImageUrl 
                               FROM Products p 
                               LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
                               WHERE p.IsActive = 1 ORDER BY NEWID()"; // NEWID() = Random

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);
                    rptRecommendations.DataSource = dt;
                    rptRecommendations.DataBind();
                }
            }
        }

        // Permet de supprimer un item depuis la sidebar
        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int cartItemId = Convert.ToInt32(e.CommandArgument);
            string command = e.CommandName;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                if (command == "Remove")
                {
                    string sql = "DELETE FROM CartItems WHERE CartItemId = @Id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", cartItemId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (command == "Increase")
                {
                    string sql = "UPDATE CartItems SET Quantity = Quantity + 1 WHERE CartItemId = @Id";
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", cartItemId);
                        cmd.ExecuteNonQuery();
                    }
                }
                else if (command == "Decrease")
                {
                    // Vérifier la quantité actuelle
                    string checkSql = "SELECT Quantity FROM CartItems WHERE CartItemId = @Id";
                    int currentQty = 0;
                    using (SqlCommand cmdCheck = new SqlCommand(checkSql, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Id", cartItemId);
                        object res = cmdCheck.ExecuteScalar();
                        if (res != null) currentQty = (int)res;
                    }

                    if (currentQty > 1)
                    {
                        string sql = "UPDATE CartItems SET Quantity = Quantity - 1 WHERE CartItemId = @Id";
                        using (SqlCommand cmd = new SqlCommand(sql, conn))
                        {
                            cmd.Parameters.AddWithValue("@Id", cartItemId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }

            // 1. On recharge les données visuelles
            LoadSideCart();

            // 2. LA CORRECTION MAGIQUE EST ICI :
            // On force le navigateur à relancer la fonction JS 'openCart()' une fois le travail fini.
            ScriptManager.RegisterStartupScript(this, this.GetType(), "KeepCartOpen", "openCart();", true);
        }



        // Bouton 2 : ACHETER MAINTENANT
        protected void btnBuyNow_Click(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                string returnUrl = Server.UrlEncode(Request.Url.PathAndQuery);
                Response.Redirect("Login.aspx?ReturnUrl=" + returnUrl);
                return;
            }

            ProcessCartAddition();
            Response.Redirect("Checkout.aspx"); // Redirection vers le paiement
        }

        private void ProcessCartAddition()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== ProcessCartAddition START ===");

                int userId = (int)Session["UserId"];
                int productId = int.Parse(Request.QueryString["id"]);
                int formatId = int.Parse(ddlFormats.SelectedValue);

                System.Diagnostics.Debug.WriteLine($"UserId: {userId}, ProductId: {productId}, FormatId: {formatId}");

                // Récupérer la quantité (1 par défaut si champ caché/vide)
                int qty = 1;
                if (!string.IsNullOrEmpty(txtQuantity.Text))
                {
                    int.TryParse(txtQuantity.Text, out qty);
                }

                System.Diagnostics.Debug.WriteLine($"Quantité à ajouter: {qty}");

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // 1. Récupérer ou Créer le Panier (Cart)
                    int cartId = 0;
                    string checkCart = "SELECT CartId FROM Cart WHERE UserId = @UserId";
                    using (SqlCommand cmd = new SqlCommand(checkCart, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            cartId = (int)result;
                            System.Diagnostics.Debug.WriteLine($"Cart existant trouvé: {cartId}");
                        }
                        else
                        {
                            string createCart = "INSERT INTO Cart (UserId) OUTPUT INSERTED.CartId VALUES (@UserId)";
                            using (SqlCommand cmdCreate = new SqlCommand(createCart, conn))
                            {
                                cmdCreate.Parameters.AddWithValue("@UserId", userId);
                                cartId = (int)cmdCreate.ExecuteScalar();
                                System.Diagnostics.Debug.WriteLine($"Nouveau Cart créé: {cartId}");
                            }
                        }
                    }

                    // 2. Vérifier si le PRODUIT + FORMAT existe déjà
                    string checkExisting = @"
                SELECT CartItemId, Quantity 
                FROM CartItems 
                WHERE CartId = @CartId 
                AND ProductId = @ProdId 
                AND FormatId = @FormatId";

                    using (SqlCommand cmdCheck = new SqlCommand(checkExisting, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@CartId", cartId);
                        cmdCheck.Parameters.AddWithValue("@ProdId", productId);
                        cmdCheck.Parameters.AddWithValue("@FormatId", formatId);

                        using (SqlDataReader reader = cmdCheck.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // ✅ Le produit existe déjà → AUGMENTER LA QUANTITÉ
                                int existingCartItemId = reader.GetInt32(0);
                                int currentQty = reader.GetInt32(1);
                                reader.Close();

                                System.Diagnostics.Debug.WriteLine($"Item existe: CartItemId={existingCartItemId}, Qté={currentQty}");

                                string updateQty = @"
                            UPDATE CartItems 
                            SET Quantity = Quantity + @Qty 
                            WHERE CartItemId = @CartItemId";

                                using (SqlCommand cmdUpdate = new SqlCommand(updateQty, conn))
                                {
                                    cmdUpdate.Parameters.AddWithValue("@Qty", qty);
                                    cmdUpdate.Parameters.AddWithValue("@CartItemId", existingCartItemId);
                                    int rowsAffected = cmdUpdate.ExecuteNonQuery();
                                    System.Diagnostics.Debug.WriteLine($"✅ Quantité mise à jour. Rows affected: {rowsAffected}");
                                }
                            }
                            else
                            {
                                // ✅ Nouveau produit → INSÉRER
                                reader.Close();
                                System.Diagnostics.Debug.WriteLine("Nouvel item à insérer");

                                // D'abord récupérer le prix
                                string getPriceQuery = "SELECT Price FROM ProductFormats WHERE FormatId = @FormatId";
                                decimal unitPrice = 0;

                                using (SqlCommand cmdPrice = new SqlCommand(getPriceQuery, conn))
                                {
                                    cmdPrice.Parameters.AddWithValue("@FormatId", formatId);
                                    object priceObj = cmdPrice.ExecuteScalar();
                                    if (priceObj != null)
                                    {
                                        unitPrice = Convert.ToDecimal(priceObj);
                                        System.Diagnostics.Debug.WriteLine($"Prix trouvé: {unitPrice}");
                                    }
                                }

                                string insertNew = @"
                            INSERT INTO CartItems (CartId, ProductId, FormatId, Quantity, UnitPrice)
                            VALUES (@CartId, @ProdId, @FormatId, @Qty, @UnitPrice)";

                                using (SqlCommand cmdInsert = new SqlCommand(insertNew, conn))
                                {
                                    cmdInsert.Parameters.AddWithValue("@CartId", cartId);
                                    cmdInsert.Parameters.AddWithValue("@ProdId", productId);
                                    cmdInsert.Parameters.AddWithValue("@FormatId", formatId);
                                    cmdInsert.Parameters.AddWithValue("@Qty", qty);
                                    cmdInsert.Parameters.AddWithValue("@UnitPrice", unitPrice);
                                    int rowsAffected = cmdInsert.ExecuteNonQuery();
                                    System.Diagnostics.Debug.WriteLine($"✅ Nouvel item inséré. Rows affected: {rowsAffected}");
                                }
                            }
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine("=== ProcessCartAddition END ===");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"❌ ERREUR ProcessCartAddition: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"StackTrace: {ex.StackTrace}");
                throw;
            }
        }
    }
}