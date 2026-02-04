using Multi_cooperative.Database;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Multi_cooperative
{
    public partial class Products : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCategories();
                BindProducts();
                LoadCartItems();
                LoadRecommendations();
            }
        }

        private void BindCategories()
        {
            try
            {
                string query = "SELECT CategoryId, Name FROM Categories WHERE Name IS NOT NULL ORDER BY Name";

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    ddlCategory.Items.Clear();
                    ddlCategory.Items.Add(new ListItem("Toutes les catégories", ""));

                    while (reader.Read())
                    {
                        ddlCategory.Items.Add(new ListItem(
                            reader["Name"].ToString(),
                            reader["CategoryId"].ToString()
                        ));
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur lors du chargement des catégories: " + ex.Message);
            }
        }

        public int CurrentPage
        {
            get { return (int)(ViewState["CurrentPage"] ?? 1); }
            set { ViewState["CurrentPage"] = value; }
        }

        public int PageSize
        {
            get { return int.Parse(ddlPageSize.SelectedValue); }
        }

        private void BindProducts()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== DÉBUT BindProducts ===");

                // Build initial part of the query
                string baseQuery = @"
                    FROM Products p
                    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
                    WHERE p.IsActive = 1";

                List<SqlParameter> parameters = new List<SqlParameter>();

                // Add filters to baseQuery
                if (!string.IsNullOrEmpty(txtSearch?.Text))
                {
                    baseQuery += " AND (p.Name LIKE @search OR p.Description LIKE @search OR c.Name LIKE @search)";
                    parameters.Add(new SqlParameter("@search", "%" + txtSearch.Text.Trim() + "%"));
                }

                if (!string.IsNullOrEmpty(ddlCategory?.SelectedValue))
                {
                    baseQuery += " AND c.CategoryId = @categoryId";
                    parameters.Add(new SqlParameter("@categoryId", ddlCategory.SelectedValue));
                }

                // Add Price filters - we use hfPriceMin/Max updated by JS
                decimal minPrice = 0, maxPrice = 5000;
                if (decimal.TryParse(hfPriceMin.Value, out minPrice))
                {
                    baseQuery += " AND EXISTS (SELECT 1 FROM ProductFormats WHERE ProductId = p.ProductId AND Price >= @minPrice)";
                    parameters.Add(new SqlParameter("@minPrice", minPrice));
                }
                if (decimal.TryParse(hfPriceMax.Value, out maxPrice))
                {
                    baseQuery += " AND EXISTS (SELECT 1 FROM ProductFormats WHERE ProductId = p.ProductId AND Price <= @maxPrice)";
                    parameters.Add(new SqlParameter("@maxPrice", maxPrice));
                }

                // 1. Get Total Count
                int totalCount = 0;
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmdCount = new SqlCommand("SELECT COUNT(*) " + baseQuery, conn);
                    foreach (var param in parameters) cmdCount.Parameters.Add(new SqlParameter(param.ParameterName, param.Value));
                    conn.Open();
                    totalCount = (int)cmdCount.ExecuteScalar();
                }

                // 2. Get Paged Data
                string orderBy = "";
                switch (ddlSort?.SelectedValue)
                {
                    case "price-asc":
                        orderBy = "ISNULL((SELECT MIN(Price) FROM ProductFormats WHERE ProductId = p.ProductId), p.BasePrice) ASC";
                        break;
                    case "price-desc":
                        orderBy = "ISNULL((SELECT MAX(Price) FROM ProductFormats WHERE ProductId = p.ProductId), p.BasePrice) DESC";
                        break;
                    case "rating":
                        orderBy = "ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Reviews WHERE ProductId = p.ProductId), 0) DESC";
                        break;
                    default:
                        orderBy = "p.CreatedAt DESC";
                        break;
                }

                string dataQuery = $@"
                    SELECT 
                        p.ProductId, p.Name, p.Description, p.IsOrganic, p.BasePrice,
                        c.Name as CategoryName, c.CategoryId,
                        COALESCE(
                            (SELECT TOP 1 ImageUrl FROM ProductImages WHERE ProductId = p.ProductId AND IsMain = 1),
                            (SELECT TOP 1 ImageUrl FROM ProductImages WHERE ProductId = p.ProductId),
                            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300'
                        ) as ImageUrl,
                        ISNULL((SELECT MIN(Price) FROM ProductFormats WHERE ProductId = p.ProductId AND Price > 0), ISNULL(p.BasePrice, 0)) as MinPrice,
                        ISNULL((SELECT MAX(Price) FROM ProductFormats WHERE ProductId = p.ProductId), ISNULL(p.BasePrice, 0)) as MaxPrice,
                        ISNULL((SELECT AVG(CAST(Rating AS FLOAT)) FROM Reviews WHERE ProductId = p.ProductId), 0) as AvgRating,
                        ISNULL((SELECT COUNT(*) FROM Reviews WHERE ProductId = p.ProductId), 0) as ReviewCount
                    {baseQuery}
                    ORDER BY {orderBy}
                    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand(dataQuery, conn);
                    foreach (var param in parameters) cmd.Parameters.Add(new SqlParameter(param.ParameterName, param.Value));
                    cmd.Parameters.AddWithValue("@Offset", (CurrentPage - 1) * PageSize);
                    cmd.Parameters.AddWithValue("@PageSize", PageSize);

                    conn.Open();
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Update UI
                    litTotalCount.Text = totalCount.ToString();
                    litStartRange.Text = totalCount == 0 ? "0" : ((CurrentPage - 1) * PageSize + 1).ToString();
                    litEndRange.Text = Math.Min(CurrentPage * PageSize, totalCount).ToString();
                    lblProductCount.Text = totalCount + " produit(s)";
                    
                    rptProducts.DataSource = dt;
                    rptProducts.DataBind();
                    pnlNoProducts.Visible = totalCount == 0;
                    paginationContainer.Visible = totalCount > 0;

                    // Update Pagination Buttons
                    UpdatePagination(totalCount);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ERREUR dans BindProducts: " + ex.Message);
                lblProductCount.Text = "Erreur de chargement";
                pnlNoProducts.Visible = true;
                paginationContainer.Visible = false;
            }
        }

        private void UpdatePagination(int totalCount)
        {
            int totalPages = (int)Math.Ceiling((double)totalCount / PageSize);
            btnPrev.Enabled = CurrentPage > 1;
            btnNext.Enabled = CurrentPage < totalPages;

            List<int> pages = new List<int>();
            // Show up to 5 surrounding pages
            int start = Math.Max(1, CurrentPage - 2);
            int end = Math.Min(totalPages, start + 4);
            if (end - start < 4) start = Math.Max(1, end - 4);

            for (int i = start; i <= end; i++) pages.Add(i);

            rptPageNumbers.DataSource = pages;
            rptPageNumbers.DataBind();
        }

        protected void btnPrev_Click(object sender, EventArgs e)
        {
            if (CurrentPage > 1)
            {
                CurrentPage--;
                BindProducts();
                UpdatePanel1.Update();
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            int totalCount = int.Parse(litTotalCount.Text);
            int totalPages = (int)Math.Ceiling((double)totalCount / PageSize);
            if (CurrentPage < totalPages)
            {
                CurrentPage++;
                BindProducts();
                UpdatePanel1.Update();
            }
        }

        protected void btnPage_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentPage = int.Parse(btn.CommandArgument);
            BindProducts();
            UpdatePanel1.Update();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindProducts();
            UpdatePanel1.Update();
        }

        protected void btnApplyPriceFilter_Click(object sender, EventArgs e)
        {
            CurrentPage = 1;
            BindProducts();
            UpdatePanel1.Update();
        }

        /// <summary>
        /// Charge les items du panier dans la sidebar - VERSION SIMPLIFIÉE
        /// </summary>
        private void LoadCartItems()
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("=== LoadCartItems appelé ===");

                if (Session["UserId"] == null)
                {
                    System.Diagnostics.Debug.WriteLine("Pas d'utilisateur connecté");
                    lblEmptyCart.Visible = true;
                    rptCartItems.Visible = false;
                    litSubTotal.Text = "0.00";
                    return;
                }

                int userId = Convert.ToInt32(Session["UserId"]);
                System.Diagnostics.Debug.WriteLine($"UserId: {userId}");

                decimal subTotal = 0;

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Requête SQL IDENTIQUE à ProductDetail
                    string sql = @"
                        SELECT ci.CartItemId, ci.Quantity, ci.UnitPrice, (ci.Quantity * ci.UnitPrice) as TotalPrice,
                               p.Name, f.Label, img.ImageUrl
                        FROM CartItems ci
                        JOIN Cart c ON ci.CartId = c.CartId
                        JOIN Products p ON ci.ProductId = p.ProductId
                        JOIN ProductFormats f ON ci.FormatId = f.FormatId
                        LEFT JOIN ProductImages img ON p.ProductId = img.ProductId AND img.IsMain = 1
                        WHERE c.UserId = @UserId
                        ORDER BY ci.CartItemId DESC";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        System.Diagnostics.Debug.WriteLine($"Nombre d'items dans le panier: {dt.Rows.Count}");

                        rptCartItems.DataSource = dt;
                        rptCartItems.DataBind();

                        if (dt.Rows.Count > 0)
                        {
                            rptCartItems.Visible = true;
                            lblEmptyCart.Visible = false;

                            // Calculer le sous-total
                            foreach (DataRow row in dt.Rows)
                            {
                                subTotal += Convert.ToDecimal(row["TotalPrice"]);
                                System.Diagnostics.Debug.WriteLine($"Produit: {row["Name"]}, Qté: {row["Quantity"]}, Prix: {row["TotalPrice"]}");
                            }
                        }
                        else
                        {
                            rptCartItems.Visible = false;
                            lblEmptyCart.Visible = true;
                        }
                    }
                }

                litSubTotal.Text = subTotal.ToString("N2");
                System.Diagnostics.Debug.WriteLine($"Sous-total: {subTotal:N2}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ERREUR LoadCartItems: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("StackTrace: " + ex.StackTrace);
                lblEmptyCart.Visible = true;
                litSubTotal.Text = "0.00";
            }
        }

        /// <summary>
        /// Charge les produits recommandés pour la sidebar
        /// </summary>
        private void LoadRecommendations()
        {
            try
            {
                string query = @"
                    SELECT TOP 5
                        p.ProductId,
                        p.Name,
                        COALESCE(
                            (SELECT TOP 1 ImageUrl FROM ProductImages WHERE ProductId = p.ProductId AND IsMain = 1),
                            (SELECT TOP 1 ImageUrl FROM ProductImages WHERE ProductId = p.ProductId),
                            '~/Images/placeholder.png'
                        ) as ImageUrl,
                        ISNULL(
                            (SELECT MIN(Price) FROM ProductFormats WHERE ProductId = p.ProductId),
                            p.BasePrice
                        ) as Price
                    FROM Products p
                    WHERE p.IsActive = 1";
                    if (Session["UserId"] != null)
        {
                    query += @" AND p.ProductId NOT IN (
                        SELECT ci.ProductId 
                        FROM CartItems ci
                        JOIN Cart c ON ci.CartId = c.CartId
                        WHERE c.UserId = @UserId
                      )";
                }

                query += " ORDER BY NEWID()";

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand(query, conn);
                    if (Session["UserId"] != null)
                    {
                        cmd.Parameters.AddWithValue("@UserId", Convert.ToInt32(Session["UserId"]));
                    }
                    conn.Open();

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptRecommendations.DataSource = dt;
                    rptRecommendations.DataBind();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur LoadRecommendations: " + ex.Message);
            }
        }

        /// <summary>
        /// Gère les actions du repeater du panier - CORRIGÉ
        /// </summary>
        protected void rptCartItems_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"=== rptCartItems_ItemCommand: {e.CommandName} ===");

                int cartItemId = Convert.ToInt32(e.CommandArgument);

                switch (e.CommandName)
                {
                    case "Increase":
                        UpdateCartItemQuantity(cartItemId, 1);
                        break;

                    case "Decrease":
                        UpdateCartItemQuantity(cartItemId, -1);
                        break;

                    case "Remove":
                        RemoveCartItem(cartItemId);
                        break;
                }

                // Recharger le panier
                LoadCartItems();

                // Forcer la mise à jour de l'UpdatePanel
                updCartSidebar.Update();

                // IMPORTANT : Garder la sidebar ouverte
                ScriptManager.RegisterStartupScript(this, GetType(), "KeepCartOpen",
                    "setTimeout(function() { openCart(); }, 100);", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ERREUR rptCartItems_ItemCommand: " + ex.Message);
            }
        }

        /// <summary>
        /// Met à jour la quantité d'un item du panier
        /// </summary>
        private void UpdateCartItemQuantity(int cartItemId, int change)
        {
            try
            {
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    string getQtyQuery = "SELECT Quantity FROM CartItems WHERE CartItemId = @cartItemId";
                    SqlCommand getQtyCmd = new SqlCommand(getQtyQuery, conn);
                    getQtyCmd.Parameters.AddWithValue("@cartItemId", cartItemId);

                    conn.Open();
                    object qtyObj = getQtyCmd.ExecuteScalar();

                    if (qtyObj != null)
                    {
                        int currentQty = Convert.ToInt32(qtyObj);
                        int newQty = currentQty + change;

                        if (newQty <= 0)
                        {
                            RemoveCartItem(cartItemId);
                        }
                        else
                        {
                            string updateQuery = "UPDATE CartItems SET Quantity = @quantity WHERE CartItemId = @cartItemId";
                            SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                            updateCmd.Parameters.AddWithValue("@quantity", newQty);
                            updateCmd.Parameters.AddWithValue("@cartItemId", cartItemId);
                            updateCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur UpdateCartItemQuantity: " + ex.Message);
            }
        }

        /// <summary>
        /// Supprime un item du panier
        /// </summary>
        private void RemoveCartItem(int cartItemId)
        {
            try
            {
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    string query = "DELETE FROM CartItems WHERE CartItemId = @cartItemId";
                    SqlCommand cmd = new SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@cartItemId", cartItemId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur RemoveCartItem: " + ex.Message);
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindProducts();
        }

        protected void ddlCategory_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindProducts();
        }

        protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindProducts();
        }

        /// <summary>
        /// Ajoute un produit au panier et ouvre la sidebar - CORRIGÉ
        /// </summary>
        protected void btnAddToCart_Click(object sender, EventArgs e)
        {
            System.Diagnostics.Debug.WriteLine("=== btnAddToCart_Click appelé ===");

            Button btn = (Button)sender;
            int productId = Convert.ToInt32(btn.CommandArgument);

            System.Diagnostics.Debug.WriteLine($"ProductId: {productId}");

            if (Session["UserId"] == null)
            {
                System.Diagnostics.Debug.WriteLine("Utilisateur non connecté - Redirection");
                Response.Redirect("~/Login.aspx?returnUrl=" + Server.UrlEncode(Request.Url.PathAndQuery));
                return;
            }

            int userId = Convert.ToInt32(Session["UserId"]);
            System.Diagnostics.Debug.WriteLine($"UserId: {userId}");

            try
            {
                // 1. Ajouter au panier
                AddToCart(userId, productId);
                System.Diagnostics.Debug.WriteLine("Produit ajouté au panier");

                // 2. Recharger le panier
                LoadCartItems();
                System.Diagnostics.Debug.WriteLine("Panier rechargé");

                // 3. Forcer la mise à jour de l'UpdatePanel
                updCartSidebar.Update();
                System.Diagnostics.Debug.WriteLine("UpdatePanel mis à jour");

                // 4. Ouvrir la sidebar
                ScriptManager.RegisterStartupScript(this, GetType(), "OpenCartAfterAdd",
                    "setTimeout(function() { console.log('Ouverture sidebar'); openCart(); }, 150);", true);

                System.Diagnostics.Debug.WriteLine("Script d'ouverture enregistré");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ERREUR btnAddToCart_Click: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("StackTrace: " + ex.StackTrace);
                ScriptManager.RegisterStartupScript(this, GetType(), "AddToCartError",
                    "alert('Erreur lors de l\\'ajout au panier: " + ex.Message.Replace("'", "\\'") + "');", true);
            }
        }

        protected void rptProducts_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView rowView = (DataRowView)e.Item.DataItem;
                Button btnAddToCart = (Button)e.Item.FindControl("btnAddToCart");
                if (btnAddToCart != null)
                {
                    btnAddToCart.CommandArgument = rowView["ProductId"].ToString();
                }
            }
        }

        /// <summary>
        /// Ajoute un produit au panier - CORRIGÉ pour fusionner les doublons
        /// </summary>
        private void AddToCart(int userId, int productId)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"=== AddToCart: UserId={userId}, ProductId={productId} ===");

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // 1. Récupérer ou créer le panier - SIMPLIFIÉ
                    string getCartQuery = "SELECT CartId FROM Cart WHERE UserId = @userId";

                    SqlCommand getCartCmd = new SqlCommand(getCartQuery, conn);
                    getCartCmd.Parameters.AddWithValue("@userId", userId);

                    object cartIdObj = getCartCmd.ExecuteScalar();
                    int cartId;

                    if (cartIdObj == null)
                    {
                        System.Diagnostics.Debug.WriteLine("Création d'un nouveau panier");
                        string createCartQuery = "INSERT INTO Cart (UserId) OUTPUT INSERTED.CartId VALUES (@userId)";
                        SqlCommand createCartCmd = new SqlCommand(createCartQuery, conn);
                        createCartCmd.Parameters.AddWithValue("@userId", userId);
                        cartId = (int)createCartCmd.ExecuteScalar();
                        System.Diagnostics.Debug.WriteLine($"Nouveau CartId: {cartId}");
                    }
                    else
                    {
                        cartId = (int)cartIdObj;
                        System.Diagnostics.Debug.WriteLine($"CartId existant: {cartId}");
                    }

                    // 2. Récupérer le premier format disponible
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

                        System.Diagnostics.Debug.WriteLine($"Format trouvé: FormatId={formatId}, Prix={unitPrice}");

                        // 3. ⚠️ CORRECTION IMPORTANTE : Vérifier si PRODUIT + FORMAT existe déjà
                        string checkItemQuery = @"
                    SELECT CartItemId, Quantity 
                    FROM CartItems 
                    WHERE CartId = @cartId 
                    AND ProductId = @productId 
                    AND FormatId = @formatId";

                        SqlCommand checkItemCmd = new SqlCommand(checkItemQuery, conn);
                        checkItemCmd.Parameters.AddWithValue("@cartId", cartId);
                        checkItemCmd.Parameters.AddWithValue("@productId", productId);
                        checkItemCmd.Parameters.AddWithValue("@formatId", formatId);

                        SqlDataReader itemReader = checkItemCmd.ExecuteReader();

                        if (itemReader.Read())
                        {
                            // ✅ Le produit avec ce format existe déjà → AUGMENTER LA QUANTITÉ
                            int existingId = itemReader.GetInt32(0);
                            int existingQty = itemReader.GetInt32(1);
                            itemReader.Close();

                            System.Diagnostics.Debug.WriteLine($"⚠️ PRODUIT EXISTE DÉJÀ - CartItemId={existingId}, Qté actuelle={existingQty}");

                            string updateQuery = "UPDATE CartItems SET Quantity = Quantity + 1 WHERE CartItemId = @cartItemId";
                            SqlCommand updateCmd = new SqlCommand(updateQuery, conn);
                            updateCmd.Parameters.AddWithValue("@cartItemId", existingId);
                            updateCmd.ExecuteNonQuery();

                            System.Diagnostics.Debug.WriteLine($"✅ Quantité mise à jour: {existingQty} → {existingQty + 1}");
                        }
                        else
                        {
                            // ✅ Nouveau produit → INSÉRER
                            itemReader.Close();

                            System.Diagnostics.Debug.WriteLine("➕ Insertion d'un nouvel item");

                            string insertQuery = @"
                        INSERT INTO CartItems (CartId, ProductId, FormatId, Quantity, UnitPrice) 
                        VALUES (@cartId, @productId, @formatId, 1, @unitPrice)";

                            SqlCommand insertCmd = new SqlCommand(insertQuery, conn);
                            insertCmd.Parameters.AddWithValue("@cartId", cartId);
                            insertCmd.Parameters.AddWithValue("@productId", productId);
                            insertCmd.Parameters.AddWithValue("@formatId", formatId);
                            insertCmd.Parameters.AddWithValue("@unitPrice", unitPrice);
                            insertCmd.ExecuteNonQuery();

                            System.Diagnostics.Debug.WriteLine("✅ Nouvel item inséré avec succès");
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
                System.Diagnostics.Debug.WriteLine("❌ ERREUR AddToCart: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("StackTrace: " + ex.StackTrace);
                throw;
            }
        }

        // ========== MÉTHODES HELPER ==========

        protected string GetImageUrl(object imageUrl)
        {
            if (imageUrl == null || imageUrl == DBNull.Value || string.IsNullOrEmpty(imageUrl.ToString()))
            {
                return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=400&h=300";
            }
            return imageUrl.ToString();
        }

        protected string GetShortDescription(object description)
        {
            if (description == null || description == DBNull.Value)
                return string.Empty;

            string desc = description.ToString();
            return desc.Length > 100 ? desc.Substring(0, 100) + "..." : desc;
        }

        protected string GetFormattedPrice(object price)
        {
            if (price == null || price == DBNull.Value)
                return "0.00 MAD";

            decimal priceValue;
            if (decimal.TryParse(price.ToString(), out priceValue))
            {
                return priceValue.ToString("N2") + " MAD";
            }

            return "0.00 MAD";
        }

        protected string GetStarRating(object rating)
        {
            if (rating == null || rating == DBNull.Value)
                return "<span class='text-gray-300'>★★★★★</span>";

            double avgRating = 0;
            double.TryParse(rating.ToString(), out avgRating);

            string stars = "";
            for (int i = 1; i <= 5; i++)
            {
                if (i <= Math.Floor(avgRating))
                {
                    stars += "<span class='text-yellow-400'>★</span>";
                }
                else if (i == Math.Ceiling(avgRating) && avgRating % 1 >= 0.5)
                {
                    stars += "<span class='text-yellow-400'>½</span>";
                }
                else
                {
                    stars += "<span class='text-gray-300'>☆</span>";
                }
            }

            return stars;
        }

        protected bool HasMultiplePrices(object minPrice, object maxPrice)
        {
            if (minPrice == null || maxPrice == null ||
                minPrice == DBNull.Value || maxPrice == DBNull.Value)
                return false;

            decimal min, max;
            if (decimal.TryParse(minPrice.ToString(), out min) &&
                decimal.TryParse(maxPrice.ToString(), out max))
            {
                return min != max && max > min;
            }

            return false;
        }
    }
}