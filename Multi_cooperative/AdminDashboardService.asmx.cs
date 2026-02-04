using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using System.Web.Script.Serialization;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [ScriptService]
    public class AdminDashboardService : WebService
    {
        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetDashboardMetrics(string period = "month")
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            var metrics = new Dictionary<string, object>();

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                // Date range based on period
                DateTime startDate, endDate = DateTime.Now;
                switch (period)
                {
                    case "day":
                        startDate = DateTime.Today;
                        break;
                    case "week":
                        startDate = DateTime.Today.AddDays(-7);
                        break;
                    case "month":
                        startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                        break;
                    case "year":
                        startDate = new DateTime(DateTime.Today.Year, 1, 1);
                        break;
                    default:
                        startDate = new DateTime(DateTime.Today.Year, DateTime.Today.Month, 1);
                        break;
                }

                // Sales metrics
                string salesQuery = @"SELECT 
                    ISNULL(SUM(TotalTTC), 0) as TotalSales,
                    COUNT(*) as TotalOrders,
                    ISNULL(SUM(CASE WHEN Status = 'En attente' THEN 1 ELSE 0 END), 0) as PendingOrders
                    FROM Orders 
                    WHERE CreatedAt >= @StartDate AND CreatedAt <= @EndDate";

                using (SqlCommand cmd = new SqlCommand(salesQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            metrics["totalSales"] = (decimal)reader["TotalSales"];
                            metrics["totalOrders"] = (int)reader["TotalOrders"];
                            metrics["pendingOrders"] = (int)reader["PendingOrders"];
                        }
                    }
                }

                // Previous period comparison
                DateTime prevStartDate = startDate.AddDays(-(endDate - startDate).Days);
                DateTime prevEndDate = startDate;

                string prevSalesQuery = @"SELECT ISNULL(SUM(TotalTTC), 0) as TotalSales
                    FROM Orders 
                    WHERE CreatedAt >= @StartDate AND CreatedAt < @EndDate";

                decimal prevSales = 0;
                using (SqlCommand cmd = new SqlCommand(prevSalesQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", prevStartDate);
                    cmd.Parameters.AddWithValue("@EndDate", prevEndDate);
                    var result = cmd.ExecuteScalar();
                    if (result != DBNull.Value)
                        prevSales = (decimal)result;
                }

                decimal currentSales = (decimal)metrics["totalSales"];
                decimal salesChange = prevSales > 0 ? ((currentSales - prevSales) / prevSales) * 100 : 0;
                metrics["salesChange"] = Math.Round(salesChange, 2);

                // Total customers
                string customersQuery = "SELECT COUNT(*) FROM Users WHERE Role = 'Client' AND IsActive = 1";
                using (SqlCommand cmd = new SqlCommand(customersQuery, conn))
                {
                    metrics["totalCustomers"] = (int)cmd.ExecuteScalar();
                }

                // Total categories
                string categoriesQuery = "SELECT COUNT(*) FROM Categories";
                using (SqlCommand cmd = new SqlCommand(categoriesQuery, conn))
                {
                    metrics["totalCategories"] = (int)cmd.ExecuteScalar();
                }

                // Total products
                string productsQuery = "SELECT COUNT(*) FROM Products WHERE IsActive = 1";
                using (SqlCommand cmd = new SqlCommand(productsQuery, conn))
                {
                    metrics["totalProducts"] = (int)cmd.ExecuteScalar();
                }

                // Top products
                string topProductsQuery = @"SELECT TOP 10 
                    p.ProductId, p.Name, 
                    SUM(oi.Quantity) as TotalSold,
                    SUM(oi.Quantity * oi.UnitPrice) as TotalRevenue
                    FROM OrderItems oi
                    INNER JOIN Products p ON oi.ProductId = p.ProductId
                    INNER JOIN Orders o ON oi.OrderId = o.OrderId
                    WHERE o.CreatedAt >= @StartDate AND o.CreatedAt <= @EndDate
                    GROUP BY p.ProductId, p.Name
                    ORDER BY TotalSold DESC";

                var topProducts = new List<object>();
                using (SqlCommand cmd = new SqlCommand(topProductsQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            topProducts.Add(new Dictionary<string, object>
                            {
                                { "productId", (int)reader["ProductId"] },
                                { "name", reader["Name"].ToString() },
                                { "totalSold", (int)reader["TotalSold"] },
                                { "totalRevenue", (decimal)reader["TotalRevenue"] }
                            });
                        }
                    }
                }
                metrics["topProducts"] = topProducts;

                // Sales chart data (last 30 days)
                var chartData = new List<object>();
                for (int i = 29; i >= 0; i--)
                {
                    DateTime date = DateTime.Today.AddDays(-i);
                    string dayQuery = @"SELECT ISNULL(SUM(TotalTTC), 0) as Sales, COUNT(*) as Orders
                        FROM Orders 
                        WHERE CAST(CreatedAt AS DATE) = @Date";

                    decimal daySales = 0;
                    int dayOrders = 0;
                    using (SqlCommand cmd = new SqlCommand(dayQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Date", date.Date);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                daySales = (decimal)reader["Sales"];
                                dayOrders = (int)reader["Orders"];
                            }
                        }
                    }

                    chartData.Add(new Dictionary<string, object>
                    {
                        { "date", date.ToString("dd/MM") },
                        { "sales", daySales },
                        { "orders", dayOrders }
                    });
                }
                metrics["chartData"] = chartData;

                // Orders by status
                string ordersByStatusQuery = @"SELECT Status, COUNT(*) as Count
                    FROM Orders
                    WHERE CreatedAt >= @StartDate AND CreatedAt <= @EndDate
                    GROUP BY Status";

                var ordersByStatus = new List<object>();
                using (SqlCommand cmd = new SqlCommand(ordersByStatusQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@StartDate", startDate);
                    cmd.Parameters.AddWithValue("@EndDate", endDate);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ordersByStatus.Add(new Dictionary<string, object>
                            {
                                { "status", reader["Status"].ToString() },
                                { "count", (int)reader["Count"] }
                            });
                        }
                    }
                }
                metrics["ordersByStatus"] = ordersByStatus;

                // Low stock alerts
                string lowStockQuery = @"SELECT p.ProductId, p.Name, pf.Label, pf.Stock, pf.StockMin
                    FROM ProductFormats pf
                    INNER JOIN Products p ON pf.ProductId = p.ProductId
                    WHERE pf.Stock <= pf.StockMin AND p.IsActive = 1";

                var lowStockProducts = new List<object>();
                using (SqlCommand cmd = new SqlCommand(lowStockQuery, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            lowStockProducts.Add(new Dictionary<string, object>
                            {
                                { "productId", (int)reader["ProductId"] },
                                { "productName", reader["Name"].ToString() },
                                { "format", reader["Label"].ToString() },
                                { "stock", (int)reader["Stock"] },
                                { "stockMin", (int)reader["StockMin"] }
                            });
                        }
                    }
                }
                metrics["lowStockProducts"] = lowStockProducts;
            }

            return new Dictionary<string, object> { { "success", true }, { "data", metrics } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message }, { "stackTrace", ex.StackTrace } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetProducts(int pageIndex = 1, int pageSize = 12, string categoryId = "", string status = "")
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                var products = new List<object>();
                int totalCount = 0;

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Construire la clause WHERE dynamiquement
                    var whereConditions = new List<string>();
                    var parameters = new Dictionary<string, object>();

                    if (!string.IsNullOrEmpty(categoryId))
                    {
                        whereConditions.Add("p.CategoryId = @CategoryId");
                        parameters["@CategoryId"] = int.Parse(categoryId);
                    }

                    if (!string.IsNullOrEmpty(status))
                    {
                        bool isActive = status == "true";
                        whereConditions.Add("p.IsActive = @IsActive");
                        parameters["@IsActive"] = isActive;
                    }

                    string whereClause = whereConditions.Count > 0 
                        ? "WHERE " + string.Join(" AND ", whereConditions)
                        : "";

                    // Count total avec filtres
                    string countQuery = $"SELECT COUNT(*) FROM Products p {whereClause}";
                    using (SqlCommand cmdCount = new SqlCommand(countQuery, conn))
                    {
                        foreach (var param in parameters)
                        {
                            cmdCount.Parameters.AddWithValue(param.Key, param.Value);
                        }
                        totalCount = (int)cmdCount.ExecuteScalar();
                    }

                    // Get paged products avec filtres - Include all fields including Ingredients, Usage, BasePrice, IsOrganic
                    string query = $@"SELECT p.ProductId, p.Name, p.Description, p.Ingredients, p.Usage, 
                                    p.BasePrice, p.IsOrganic, p.IsActive, p.CreatedAt,
                                    c.CategoryId, c.Name as CategoryName
                                    FROM Products p
                                    LEFT JOIN Categories c ON p.CategoryId = c.CategoryId
                                    {whereClause}
                                    ORDER BY p.CreatedAt DESC
                                    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        foreach (var param in parameters)
                        {
                            cmd.Parameters.AddWithValue(param.Key, param.Value);
                        }
                        cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize);
                        cmd.Parameters.AddWithValue("@PageSize", pageSize);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                int productId = (int)reader["ProductId"];
                                
                                // Get images
                                var images = new List<object>();
                                using (SqlConnection conn2 = Database.Database.GetConnection())
                                {
                                    conn2.Open();
                                    string imagesQuery = "SELECT ImageId, ImageUrl, IsMain FROM ProductImages WHERE ProductId = @ProductId";
                                    using (SqlCommand imgCmd = new SqlCommand(imagesQuery, conn2))
                                    {
                                        imgCmd.Parameters.AddWithValue("@ProductId", productId);
                                        using (SqlDataReader imgReader = imgCmd.ExecuteReader())
                                        {
                                            while (imgReader.Read())
                                            {
                                                images.Add(new Dictionary<string, object>
                                                {
                                                    { "imageId", (int)imgReader["ImageId"] },
                                                    { "imageUrl", imgReader["ImageUrl"].ToString() },
                                                    { "isMain", (bool)imgReader["IsMain"] }
                                                });
                                            }
                                        }
                                    }
                                }

                                // Get formats
                                var formats = new List<object>();
                                using (SqlConnection conn3 = Database.Database.GetConnection())
                                {
                                    conn3.Open();
                                    string formatsQuery = @"SELECT FormatId, Label, Price, Stock, StockMin, ExpirationDate
                                        FROM ProductFormats WHERE ProductId = @ProductId";
                                    using (SqlCommand fmtCmd = new SqlCommand(formatsQuery, conn3))
                                    {
                                        fmtCmd.Parameters.AddWithValue("@ProductId", productId);
                                        using (SqlDataReader fmtReader = fmtCmd.ExecuteReader())
                                        {
                                            while (fmtReader.Read())
                                            {
                                                formats.Add(new Dictionary<string, object>
                                                {
                                                    { "formatId", (int)fmtReader["FormatId"] },
                                                    { "label", fmtReader["Label"].ToString() },
                                                    { "price", (decimal)fmtReader["Price"] },
                                                    { "stock", (int)fmtReader["Stock"] },
                                                    { "stockMin", (int)fmtReader["StockMin"] },
                                                    { "expirationDate", fmtReader["ExpirationDate"] == DBNull.Value ? null : ((DateTime)fmtReader["ExpirationDate"]).ToString("yyyy-MM-dd") }
                                                });
                                            }
                                        }
                                    }
                                }

                                // Read all fields including Ingredients, Usage, BasePrice, IsOrganic
                                try
                                {
                                    string name = reader["Name"].ToString();
                                    string description = reader["Description"] == DBNull.Value ? null : reader["Description"].ToString();
                                    
                                    // Try to read optional fields - catch exceptions if columns don't exist
                                    string ingredients = null;
                                    string usage = null;
                                    decimal basePrice = 0;
                                    bool isOrganic = false;
                                    
                                    // Read ntext columns - they need special handling
                                    try 
                                    { 
                                        int ingredientsOrdinal = reader.GetOrdinal("Ingredients");
                                        if (!reader.IsDBNull(ingredientsOrdinal))
                                        {
                                            ingredients = reader.GetString(ingredientsOrdinal);
                                        }
                                        else
                                        {
                                            ingredients = null;
                                        }
                                    }
                                    catch (Exception ex) 
                                    { 
                                        System.Diagnostics.Debug.WriteLine($"Error reading Ingredients for product {productId}: {ex.Message}");
                                        System.Diagnostics.Debug.WriteLine($"Stack: {ex.StackTrace}");
                                        ingredients = null; 
                                    }
                                    
                                    try 
                                    { 
                                        int usageOrdinal = reader.GetOrdinal("Usage");
                                        if (!reader.IsDBNull(usageOrdinal))
                                        {
                                            usage = reader.GetString(usageOrdinal);
                                        }
                                        else
                                        {
                                            usage = null;
                                        }
                                    }
                                    catch (Exception ex) 
                                    { 
                                        System.Diagnostics.Debug.WriteLine($"Error reading Usage for product {productId}: {ex.Message}");
                                        System.Diagnostics.Debug.WriteLine($"Stack: {ex.StackTrace}");
                                        usage = null; 
                                    }
                                    
                                    try { basePrice = reader["BasePrice"] == DBNull.Value ? 0 : (decimal)reader["BasePrice"]; }
                                    catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"Error reading BasePrice for product {productId}: {ex.Message}"); }
                                    
                                    try { isOrganic = reader["IsOrganic"] == DBNull.Value ? false : (bool)reader["IsOrganic"]; }
                                    catch (Exception ex) { System.Diagnostics.Debug.WriteLine($"Error reading IsOrganic for product {productId}: {ex.Message}"); }
                                    
                                    bool isActive = (bool)reader["IsActive"];
                                    int? categoryIdValue = reader["CategoryId"] == DBNull.Value ? null : (int?)reader["CategoryId"];
                                    string categoryName = reader["CategoryName"] == DBNull.Value ? null : reader["CategoryName"].ToString();
                                    
                                    System.Diagnostics.Debug.WriteLine($"Product {productId}: Name='{name}', Ingredients='{ingredients}', Usage='{usage}', BasePrice={basePrice}, IsOrganic={isOrganic}");
                                    
                                    // Create dictionary - explicitly include null values as empty strings or null
                                    var productDict = new Dictionary<string, object>
                                    {
                                        { "productId", productId },
                                        { "name", name ?? "" },
                                        { "description", description ?? (object)null },
                                        { "ingredients", ingredients ?? (object)null },
                                        { "usage", usage ?? (object)null },
                                        { "basePrice", basePrice },
                                        { "isOrganic", isOrganic },
                                        { "isActive", isActive },
                                        { "createdAt", ((DateTime)reader["CreatedAt"]).ToString("dd/MM/yyyy") },
                                        { "categoryId", categoryIdValue ?? (object)null },
                                        { "categoryName", categoryName ?? (object)null },
                                        { "images", images },
                                        { "formats", formats }
                                    };
                                    
                                    System.Diagnostics.Debug.WriteLine($"Product {productId} - Raw values before dict: ingredients='{ingredients ?? "NULL"}', usage='{usage ?? "NULL"}', basePrice={basePrice}, isOrganic={isOrganic}");
                                    System.Diagnostics.Debug.WriteLine($"Product {productId} dictionary keys: {string.Join(", ", productDict.Keys)}");
                                    System.Diagnostics.Debug.WriteLine($"Product {productId} dictionary - ingredients: '{productDict["ingredients"] ?? "NULL"}', type: {productDict["ingredients"]?.GetType()?.Name ?? "null"}");
                                    System.Diagnostics.Debug.WriteLine($"Product {productId} dictionary - usage: '{productDict["usage"] ?? "NULL"}', type: {productDict["usage"]?.GetType()?.Name ?? "null"}");
                                    System.Diagnostics.Debug.WriteLine($"Product {productId} dictionary - basePrice: {productDict["basePrice"]}, type: {productDict["basePrice"]?.GetType()?.Name}");
                                    
                                    products.Add(productDict);
                                }
                                catch (Exception ex)
                                {
                                    System.Diagnostics.Debug.WriteLine($"Error processing product {productId}: {ex.Message}");
                                    System.Diagnostics.Debug.WriteLine($"Stack trace: {ex.StackTrace}");
                                    // Don't re-throw, just skip this product and continue
                                    // We'll still add basic product info if possible
                                    try
                                    {
                                        products.Add(new Dictionary<string, object>
                                        {
                                            { "productId", productId },
                                            { "name", reader["Name"].ToString() },
                                            { "description", reader["Description"] == DBNull.Value ? null : reader["Description"].ToString() },
                                            { "ingredients", null },
                                            { "usage", null },
                                            { "basePrice", 0 },
                                            { "isOrganic", false },
                                            { "isActive", (bool)reader["IsActive"] },
                                            { "createdAt", ((DateTime)reader["CreatedAt"]).ToString("dd/MM/yyyy") },
                                            { "categoryId", reader["CategoryId"] == DBNull.Value ? null : (int?)reader["CategoryId"] },
                                            { "categoryName", reader["CategoryName"] == DBNull.Value ? null : reader["CategoryName"].ToString() },
                                            { "images", images },
                                            { "formats", formats }
                                        });
                                    }
                                    catch
                                    {
                                        // If even basic info fails, skip this product entirely
                                    }
                                }
                            }
                        }
                    }
                }

                return new Dictionary<string, object> { 
                    { "success", true }, 
                    { "data", products },
                    { "totalCount", totalCount },
                    { "pageIndex", pageIndex },
                    { "pageSize", pageSize }
                };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetCategories()
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            var categories = new List<object>();

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string query = "SELECT CategoryId, Name, Description FROM Categories ORDER BY Name";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            categories.Add(new Dictionary<string, object>
                            {
                                { "categoryId", (int)reader["CategoryId"] },
                                { "name", reader["Name"].ToString() },
                                { "description", reader["Description"] == DBNull.Value ? null : reader["Description"].ToString() }
                            });
                        }
                    }
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "data", categories } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object SaveProduct(object productId, object categoryId, string name, string description, string ingredients, string usage, bool isOrganic, decimal basePrice, bool isActive, string imagesJson = null, string formatsJson = null)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine($"[SaveProduct] === METHOD CALLED AT {DateTime.Now:HH:mm:ss.fff} ===");
                System.Diagnostics.Debug.WriteLine($"[SaveProduct] Thread ID: {System.Threading.Thread.CurrentThread.ManagedThreadId}");
                System.Diagnostics.Debug.WriteLine($"[SaveProduct] Name: {name}, Price: {basePrice}");
                
                // Convert object parameters to nullable ints
                int? productIdValue = null;
                if (productId != null && productId.ToString() != "" && productId.ToString() != "null")
                {
                    int temp;
                    if (int.TryParse(productId.ToString(), out temp))
                        productIdValue = temp;
                }
                
                int? categoryIdValue = null;
                if (categoryId != null && categoryId.ToString() != "" && categoryId.ToString() != "null")
                {
                    int temp;
                    if (int.TryParse(categoryId.ToString(), out temp))
                        categoryIdValue = temp;
                }
                
                System.Diagnostics.Debug.WriteLine("=== SaveProduct Called ===");
                System.Diagnostics.Debug.WriteLine($"productId type: {productId?.GetType()}, value: {productId}");
                System.Diagnostics.Debug.WriteLine($"categoryId type: {categoryId?.GetType()}, value: {categoryId}");
                System.Diagnostics.Debug.WriteLine($"name: {name}");
                System.Diagnostics.Debug.WriteLine($"basePrice: {basePrice}");
                System.Diagnostics.Debug.WriteLine($"Converted - productIdValue: {productIdValue}, categoryIdValue: {categoryIdValue}");
                System.Diagnostics.Debug.WriteLine($"imagesJson length: {imagesJson?.Length ?? 0}, formatsJson length: {formatsJson?.Length ?? 0}");
                
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                {
                    System.Diagnostics.Debug.WriteLine("Authentication failed");
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };
                }
                
                if (string.IsNullOrEmpty(name))
                {
                    System.Diagnostics.Debug.WriteLine("Name is empty");
                    return new Dictionary<string, object> { { "success", false }, { "message", "Le nom du produit est requis" } };
                }
                
                if (basePrice <= 0)
                {
                    System.Diagnostics.Debug.WriteLine($"Invalid basePrice: {basePrice}");
                    return new Dictionary<string, object> { { "success", false }, { "message", "Le prix doit être supérieur à 0" } };
                }

            int newProductId = 0;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                if (productIdValue.HasValue && productIdValue.Value > 0)
                {
                    // Update
                    string query = @"UPDATE Products 
                                    SET CategoryId = @CategoryId, Name = @Name, Description = @Description,
                                        Ingredients = @Ingredients, Usage = @Usage, IsOrganic = @IsOrganic,
                                        BasePrice = @BasePrice, IsActive = @IsActive
                                    WHERE ProductId = @ProductId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProductId", productIdValue.Value);
                        cmd.Parameters.AddWithValue("@CategoryId", categoryIdValue.HasValue ? (object)categoryIdValue.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? DBNull.Value : (object)description);
                        cmd.Parameters.AddWithValue("@Ingredients", string.IsNullOrEmpty(ingredients) ? DBNull.Value : (object)ingredients);
                        cmd.Parameters.AddWithValue("@Usage", string.IsNullOrEmpty(usage) ? DBNull.Value : (object)usage);
                        cmd.Parameters.AddWithValue("@IsOrganic", isOrganic);
                        cmd.Parameters.AddWithValue("@BasePrice", basePrice);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);
                        cmd.ExecuteNonQuery();
                    }
                    newProductId = productIdValue.Value;
                }
                else
                {
                    // Insert
                    string query = @"INSERT INTO Products (CategoryId, Name, Description, Ingredients, Usage, IsOrganic, BasePrice, IsActive, CreatedAt)
                                    VALUES (@CategoryId, @Name, @Description, @Ingredients, @Usage, @IsOrganic, @BasePrice, @IsActive, GETDATE());
                                    SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CategoryId", categoryIdValue.HasValue ? (object)categoryIdValue.Value : DBNull.Value);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? DBNull.Value : (object)description);
                        cmd.Parameters.AddWithValue("@Ingredients", string.IsNullOrEmpty(ingredients) ? DBNull.Value : (object)ingredients);
                        cmd.Parameters.AddWithValue("@Usage", string.IsNullOrEmpty(usage) ? DBNull.Value : (object)usage);
                        cmd.Parameters.AddWithValue("@IsOrganic", isOrganic);
                        cmd.Parameters.AddWithValue("@BasePrice", basePrice);
                        cmd.Parameters.AddWithValue("@IsActive", isActive);
                        newProductId = Convert.ToInt32(cmd.ExecuteScalar());
                    }
                }

                // Save images
                if (!string.IsNullOrEmpty(imagesJson) && imagesJson != "[]")
                {
                    try
                    {
                        System.Diagnostics.Debug.WriteLine($"Deserializing imagesJson: {imagesJson}");
                        var serializer = new JavaScriptSerializer();
                        var imagesList = serializer.Deserialize<List<Dictionary<string, object>>>(imagesJson);
                        System.Diagnostics.Debug.WriteLine($"Deserialized {imagesList.Count} images");
                        
                        foreach (var img in imagesList)
                        {
                            int? imgId = img.ContainsKey("imageId") && img["imageId"] != null ? Convert.ToInt32(img["imageId"]) : (int?)null;
                            string imgUrl = img.ContainsKey("imageUrl") ? img["imageUrl"].ToString() : "";
                            bool isMain = img.ContainsKey("isMain") && Convert.ToBoolean(img["isMain"]);

                            if (!string.IsNullOrEmpty(imgUrl))
                            {
                                if (imgId.HasValue && imgId.Value > 0)
                                {
                                    string updateQuery = @"UPDATE ProductImages SET ImageUrl = @ImageUrl, IsMain = @IsMain WHERE ImageId = @ImageId";
                                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                                    {
                                        cmd.Parameters.AddWithValue("@ImageId", imgId.Value);
                                        cmd.Parameters.AddWithValue("@ImageUrl", imgUrl);
                                        cmd.Parameters.AddWithValue("@IsMain", isMain);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    if (isMain)
                                    {
                                        string updateQuery = "UPDATE ProductImages SET IsMain = 0 WHERE ProductId = @ProductId";
                                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                                        {
                                            cmd.Parameters.AddWithValue("@ProductId", newProductId);
                                            cmd.ExecuteNonQuery();
                                        }
                                    }
                                    string insertQuery = @"INSERT INTO ProductImages (ProductId, ImageUrl, IsMain) VALUES (@ProductId, @ImageUrl, @IsMain)";
                                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                                    {
                                        cmd.Parameters.AddWithValue("@ProductId", newProductId);
                                        cmd.Parameters.AddWithValue("@ImageUrl", imgUrl);
                                        cmd.Parameters.AddWithValue("@IsMain", isMain);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue
                        System.Diagnostics.Debug.WriteLine("Error saving images: " + ex.Message);
                    }
                }

                // Save formats
                if (!string.IsNullOrEmpty(formatsJson) && formatsJson != "[]")
                {
                    try
                    {
                        System.Diagnostics.Debug.WriteLine($"Deserializing formatsJson: {formatsJson}");
                        var serializer = new JavaScriptSerializer();
                        var formatsList = serializer.Deserialize<List<Dictionary<string, object>>>(formatsJson);
                        System.Diagnostics.Debug.WriteLine($"Deserialized {formatsList.Count} formats");
                        
                        foreach (var fmt in formatsList)
                        {
                            int? fmtId = fmt.ContainsKey("formatId") && fmt["formatId"] != null ? Convert.ToInt32(fmt["formatId"]) : (int?)null;
                            string label = fmt.ContainsKey("label") ? fmt["label"].ToString() : "";
                            decimal price = fmt.ContainsKey("price") ? Convert.ToDecimal(fmt["price"]) : 0;
                            int stock = fmt.ContainsKey("stock") ? Convert.ToInt32(fmt["stock"]) : 0;
                            int stockMin = fmt.ContainsKey("stockMin") ? Convert.ToInt32(fmt["stockMin"]) : 0;
                            string expirationDate = fmt.ContainsKey("expirationDate") ? fmt["expirationDate"]?.ToString() : null;

                            if (!string.IsNullOrEmpty(label) && price > 0)
                            {
                                if (fmtId.HasValue && fmtId.Value > 0)
                                {
                                    string updateQuery = @"UPDATE ProductFormats SET Label = @Label, Price = @Price, Stock = @Stock, StockMin = @StockMin, ExpirationDate = @ExpirationDate WHERE FormatId = @FormatId";
                                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                                    {
                                        cmd.Parameters.AddWithValue("@FormatId", fmtId.Value);
                                        cmd.Parameters.AddWithValue("@Label", label);
                                        cmd.Parameters.AddWithValue("@Price", price);
                                        cmd.Parameters.AddWithValue("@Stock", stock);
                                        cmd.Parameters.AddWithValue("@StockMin", stockMin);
                                        cmd.Parameters.AddWithValue("@ExpirationDate", string.IsNullOrEmpty(expirationDate) ? DBNull.Value : (object)DateTime.Parse(expirationDate));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else
                                {
                                    string insertQuery = @"INSERT INTO ProductFormats (ProductId, Label, Price, Stock, StockMin, ExpirationDate) VALUES (@ProductId, @Label, @Price, @Stock, @StockMin, @ExpirationDate)";
                                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                                    {
                                        cmd.Parameters.AddWithValue("@ProductId", newProductId);
                                        cmd.Parameters.AddWithValue("@Label", label);
                                        cmd.Parameters.AddWithValue("@Price", price);
                                        cmd.Parameters.AddWithValue("@Stock", stock);
                                        cmd.Parameters.AddWithValue("@StockMin", stockMin);
                                        cmd.Parameters.AddWithValue("@ExpirationDate", string.IsNullOrEmpty(expirationDate) ? DBNull.Value : (object)DateTime.Parse(expirationDate));
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        // Log error but continue
                        System.Diagnostics.Debug.WriteLine("Error saving formats: " + ex.Message);
                    }
                }
            }

            System.Diagnostics.Debug.WriteLine($"SaveProduct completed successfully: newProductId={newProductId}");
            return new Dictionary<string, object> { { "success", true }, { "message", "Produit enregistré avec succès" }, { "productId", newProductId } };
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"SaveProduct error: {ex.Message}\nStackTrace: {ex.StackTrace}");
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message + " | " + ex.StackTrace } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object DeleteProduct(int productId)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string query = "UPDATE Products SET IsActive = 0 WHERE ProductId = @ProductId";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ProductId", productId);
                    cmd.ExecuteNonQuery();
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Produit supprimé avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object SaveCategory(int? categoryId, string name, string description)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                if (categoryId.HasValue && categoryId.Value > 0)
                {
                    // Update
                    string query = "UPDATE Categories SET Name = @Name, Description = @Description WHERE CategoryId = @CategoryId";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CategoryId", categoryId.Value);
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? DBNull.Value : (object)description);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Insert
                    string query = "INSERT INTO Categories (Name, Description) VALUES (@Name, @Description)";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Description", string.IsNullOrEmpty(description) ? DBNull.Value : (object)description);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Catégorie enregistrée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object DeleteCategory(int categoryId)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string query = "DELETE FROM Categories WHERE CategoryId = @CategoryId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CategoryId", categoryId);
                    cmd.ExecuteNonQuery();
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Catégorie supprimée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object SaveProductFormat(int? formatId, int productId, string label, decimal price, int stock, int stockMin, string expirationDate)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                if (formatId.HasValue && formatId.Value > 0)
                {
                    // Update
                    string query = @"UPDATE ProductFormats 
                                    SET Label = @Label, Price = @Price, Stock = @Stock, StockMin = @StockMin,
                                        ExpirationDate = @ExpirationDate
                                    WHERE FormatId = @FormatId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@FormatId", formatId.Value);
                        cmd.Parameters.AddWithValue("@Label", label);
                        cmd.Parameters.AddWithValue("@Price", price);
                        cmd.Parameters.AddWithValue("@Stock", stock);
                        cmd.Parameters.AddWithValue("@StockMin", stockMin);
                        cmd.Parameters.AddWithValue("@ExpirationDate", string.IsNullOrEmpty(expirationDate) ? DBNull.Value : (object)DateTime.Parse(expirationDate));
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Insert
                    string query = @"INSERT INTO ProductFormats (ProductId, Label, Price, Stock, StockMin, ExpirationDate)
                                    VALUES (@ProductId, @Label, @Price, @Stock, @StockMin, @ExpirationDate)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProductId", productId);
                        cmd.Parameters.AddWithValue("@Label", label);
                        cmd.Parameters.AddWithValue("@Price", price);
                        cmd.Parameters.AddWithValue("@Stock", stock);
                        cmd.Parameters.AddWithValue("@StockMin", stockMin);
                        cmd.Parameters.AddWithValue("@ExpirationDate", string.IsNullOrEmpty(expirationDate) ? DBNull.Value : (object)DateTime.Parse(expirationDate));
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Format enregistré avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object DeleteProductFormat(int formatId)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string query = "DELETE FROM ProductFormats WHERE FormatId = @FormatId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@FormatId", formatId);
                    cmd.ExecuteNonQuery();
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Format supprimé avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object SaveProductImage(int? imageId, int productId, string imageUrl, bool isMain)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                // If this is main image, unset others
                if (isMain)
                {
                    string updateQuery = "UPDATE ProductImages SET IsMain = 0 WHERE ProductId = @ProductId";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProductId", productId);
                        cmd.ExecuteNonQuery();
                    }
                }

                if (imageId.HasValue && imageId.Value > 0)
                {
                    // Update
                    string query = @"UPDATE ProductImages 
                                    SET ImageUrl = @ImageUrl, IsMain = @IsMain
                                    WHERE ImageId = @ImageId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ImageId", imageId.Value);
                        cmd.Parameters.AddWithValue("@ImageUrl", imageUrl);
                        cmd.Parameters.AddWithValue("@IsMain", isMain);
                        cmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    // Insert
                    string query = @"INSERT INTO ProductImages (ProductId, ImageUrl, IsMain)
                                    VALUES (@ProductId, @ImageUrl, @IsMain)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@ProductId", productId);
                        cmd.Parameters.AddWithValue("@ImageUrl", imageUrl);
                        cmd.Parameters.AddWithValue("@IsMain", isMain);
                        cmd.ExecuteNonQuery();
                    }
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Image enregistrée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object DeleteProductImage(int imageId)
        {
            try
            {
                if (Session["AdminLoggedIn"] == null || (bool)Session["AdminLoggedIn"] == false)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string query = "DELETE FROM ProductImages WHERE ImageId = @ImageId";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@ImageId", imageId);
                    cmd.ExecuteNonQuery();
                }
            }

            return new Dictionary<string, object> { { "success", true }, { "message", "Image supprimée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }
        [WebMethod(EnableSession = true)]
        public object GetOrders(string statusFilter = "Toutes", string searchTerm = "", int pageIndex = 1, int pageSize = 10)
        {
            if (Session["AdminLoggedIn"] == null) return new Dictionary<string, object> { { "success", false }, { "message", "Non autorisé" } };

            try
            {
                var orders = new List<Dictionary<string, object>>();
                int totalCount = 0;

                using (var conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Base filters
                    string filterClause = "WHERE 1=1";
                    if (statusFilter != "Toutes") filterClause += " AND o.Status = @status";
                    if (!string.IsNullOrEmpty(searchTerm)) filterClause += " AND (u.FullName LIKE @search OR CAST(o.OrderId AS NVARCHAR) LIKE @search)";

                    // Count
                    string countQuery = $@"SELECT COUNT(*) 
                                          FROM Orders o
                                          JOIN Users u ON o.UserId = u.UserId 
                                          {filterClause}";
                    
                    using (var countCmd = new System.Data.SqlClient.SqlCommand(countQuery, conn))
                    {
                        if (statusFilter != "Toutes") countCmd.Parameters.AddWithValue("@status", statusFilter);
                        if (!string.IsNullOrEmpty(searchTerm)) countCmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                        totalCount = (int)countCmd.ExecuteScalar();
                    }

                    // Paged Data
                    string query = $@"
                        SELECT o.OrderId, o.UserId, o.TotalTTC, o.Status, o.CreatedAt, 
                               o.CancellationReason, o.CancelledAt,
                               u.FullName as CustomerName
                        FROM Orders o
                        JOIN Users u ON o.UserId = u.UserId
                        {filterClause}
                        ORDER BY o.CreatedAt DESC
                        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    var cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                    if (statusFilter != "Toutes") cmd.Parameters.AddWithValue("@status", statusFilter);
                    if (!string.IsNullOrEmpty(searchTerm)) cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                    
                    cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string cancellationReason = reader["CancellationReason"] != DBNull.Value ? reader["CancellationReason"].ToString() : null;
                            string cancelledAt = reader["CancelledAt"] != DBNull.Value ? Convert.ToDateTime(reader["CancelledAt"]).ToString("dd/MM/yyyy HH:mm") : null;
                            
                            orders.Add(new Dictionary<string, object> {
                                { "orderId", reader["OrderId"] },
                                { "customerName", reader["CustomerName"] },
                                { "totalTTC", reader["TotalTTC"] },
                                { "status", reader["Status"] },
                                { "createdAt", Convert.ToDateTime(reader["CreatedAt"]).ToString("dd/MM/yyyy HH:mm") },
                                { "cancellationReason", cancellationReason },
                                { "cancelledAt", cancelledAt }
                            });
                        }
                    }
                }
                return new Dictionary<string, object> { 
                    { "success", true }, 
                    { "data", orders },
                    { "totalCount", totalCount },
                    { "pageIndex", pageIndex },
                    { "pageSize", pageSize }
                };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        public object GetOrderDetails(int orderId)
        {
            if (Session["AdminLoggedIn"] == null) return new Dictionary<string, object> { { "success", false }, { "message", "Non autorisé" } };

            try
            {
                var details = new Dictionary<string, object>();
                using (var conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    
                    // Let's get the list of columns first to avoid errors
                    var columns = new List<string>();
                    var schemaCmd = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'Orders'", conn);
                    using (var r = schemaCmd.ExecuteReader()) {
                        while (r.Read()) columns.Add(r["COLUMN_NAME"].ToString().ToLower());
                    }
                    
                    details["_debug_columns"] = string.Join(", ", columns);

                    string qColumns = "o.OrderId, o.Status, o.CreatedAt, o.UserId";
                    if (columns.Contains("totalttc")) qColumns += ", o.TotalTTC";
                    else if (columns.Contains("total_ttc")) qColumns += ", o.Total_TTC as TotalTTC";
                    
                    if (columns.Contains("totalht")) qColumns += ", o.TotalHT";
                    else if (columns.Contains("total_ht")) qColumns += ", o.Total_HT as TotalHT";

                    if (columns.Contains("deliveryfee")) qColumns += ", o.DeliveryFee";
                    else if (columns.Contains("delivery_fee")) qColumns += ", o.Delivery_Fee as DeliveryFee";

                    if (columns.Contains("trackingnumber")) qColumns += ", o.TrackingNumber";
                    else if (columns.Contains("tracking_number")) qColumns += ", o.Tracking_Number as TrackingNumber";

                    if (columns.Contains("validatedat")) qColumns += ", o.ValidatedAt";
                    if (columns.Contains("inpreparationat")) qColumns += ", o.InPreparationAt";
                    if (columns.Contains("shippedat")) qColumns += ", o.ShippedAt";
                    if (columns.Contains("deliveredat")) qColumns += ", o.DeliveredAt";
                    
                    if (columns.Contains("cancellationreason")) qColumns += ", o.CancellationReason";
                    if (columns.Contains("cancelledat")) qColumns += ", o.CancelledAt";
                    
                    if (columns.Contains("addressid")) qColumns += ", o.AddressId";
                    if (columns.Contains("shippingid")) qColumns += ", o.ShippingId";
                    if (columns.Contains("paymentmethod")) qColumns += ", o.PaymentMethod";

                    string query = $@"
                        SELECT {qColumns},
                               u.FullName as UserFullName, u.Email, u.Phone as UserPhone,
                               a.FullName as RecipientName, a.AddressLine, a.PostalCode, a.City, a.Phone as RecipientPhone,
                               s.MethodName
                        FROM Orders o
                        LEFT JOIN Users u ON o.UserId = u.UserId
                        LEFT JOIN Addresses a ON o.AddressId = a.AddressId
                        LEFT JOIN ShippingMethods s ON o.ShippingId = s.ShippingId
                        WHERE o.OrderId = @id";
                    
                    var cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@id", orderId);

                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            details["orderId"] = reader["OrderId"];
                            details["status"] = reader["Status"] != DBNull.Value ? reader["Status"].ToString().Trim() : "";
                            details["totalHT"] = columns.Contains("totalht") || columns.Contains("total_ht") ? reader["TotalHT"] : 0;
                            details["totalTTC"] = columns.Contains("totalttc") || columns.Contains("total_ttc") ? reader["TotalTTC"] : 0;
                            details["deliveryFee"] = columns.Contains("deliveryfee") || columns.Contains("delivery_fee") ? reader["DeliveryFee"] : 0;
                            details["trackingNumber"] = columns.Contains("trackingnumber") || columns.Contains("tracking_number") ? reader["TrackingNumber"].ToString() : "";
                            
                            // Cancellation info
                            if (columns.Contains("cancellationreason"))
                                details["cancellationReason"] = reader["CancellationReason"] != DBNull.Value ? reader["CancellationReason"].ToString() : null;
                            if (columns.Contains("cancelledat"))
                                details["cancelledAt"] = reader["CancelledAt"] != DBNull.Value ? Convert.ToDateTime(reader["CancelledAt"]).ToString("dd/MM/yyyy HH:mm") : null;
                            
                            details["customer"] = new Dictionary<string, string> {
                                { "name", reader["UserFullName"] != DBNull.Value ? reader["UserFullName"].ToString() : "Client Inconnu" },
                                { "email", reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "" },
                                { "phone", reader["UserPhone"] != DBNull.Value ? reader["UserPhone"].ToString() : "" }
                            };

                            details["shipping"] = new Dictionary<string, string> {
                                { "recipient", reader["RecipientName"] != DBNull.Value ? reader["RecipientName"].ToString() : "" },
                                { "address", reader["AddressLine"] != DBNull.Value ? reader["AddressLine"].ToString() : "" },
                                { "zip", reader["PostalCode"] != DBNull.Value ? reader["PostalCode"].ToString() : "" },
                                { "city", reader["City"] != DBNull.Value ? reader["City"].ToString() : "" },
                                { "phone", reader["RecipientPhone"] != DBNull.Value ? reader["RecipientPhone"].ToString() : "" },
                                { "method", reader["MethodName"] != DBNull.Value ? reader["MethodName"].ToString() : "" }
                            };
                        }
                        else
                        {
                            return new Dictionary<string, object> { { "success", false }, { "message", "Commande #" + orderId + " introuvable" } };
                        }
                    }

                    // Order Items
                    var items = new List<Dictionary<string, object>>();
                    string itemsQuery = @"
                        SELECT oi.Quantity, oi.UnitPrice, oi.FormatId,
                               p.Name as ProductName, 
                               (SELECT TOP 1 ImageUrl FROM ProductImages pi WHERE pi.ProductId = p.ProductId AND pi.IsMain = 1) as ImageUrl,
                               f.Label as FormatLabel
                        FROM OrderItems oi
                        LEFT JOIN Products p ON oi.ProductId = p.ProductId
                        LEFT JOIN ProductFormats f ON oi.FormatId = f.FormatId
                        WHERE oi.OrderId = @id";
                    
                    cmd = new System.Data.SqlClient.SqlCommand(itemsQuery, conn);
                    cmd.Parameters.AddWithValue("@id", orderId);
                    
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            items.Add(new Dictionary<string, object> {
                                { "productName", reader["ProductName"] != DBNull.Value ? reader["ProductName"] : "Produit Inconnu" },
                                { "imageUrl", reader["ImageUrl"] != DBNull.Value ? reader["ImageUrl"] : "" },
                                { "quantity", reader["Quantity"] != DBNull.Value ? reader["Quantity"] : 0 },
                                { "unitPrice", reader["UnitPrice"] != DBNull.Value ? reader["UnitPrice"] : 0 },
                                { "formatLabel", reader["FormatLabel"] != DBNull.Value ? reader["FormatLabel"] : "" }
                            });
                        }
                    }
                    details["items"] = items;
                }
                return new Dictionary<string, object> { { "success", true }, { "data", details } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", "Erreur serveur: " + ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        public object UpdateOrderStatus(int orderId, string status, string trackingNumber = "")
        {
            if (Session["AdminLoggedIn"] == null) return new Dictionary<string, object> { { "success", false }, { "message", "Non autorisé" } };

            try
            {
                using (var conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    
                    // Récupérer l'ancien statut pour vérifier si on doit restaurer le stock
                    string oldStatus = null;
                    string getStatusQuery = "SELECT Status FROM Orders WHERE OrderId = @id";
                    using (var cmdStatus = new System.Data.SqlClient.SqlCommand(getStatusQuery, conn))
                    {
                        cmdStatus.Parameters.AddWithValue("@id", orderId);
                        var result = cmdStatus.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                            oldStatus = result.ToString();
                    }

                    // Si on annule la commande (changement vers "Annulée"), restaurer le stock
                    if (status == "Annulée" && oldStatus != "Annulée" && oldStatus != "Expédiée" && oldStatus != "Livrée")
                    {
                        string restoreStockQuery = @"
                            UPDATE pf
                            SET pf.Stock = pf.Stock + oi.Quantity
                            FROM ProductFormats pf
                            INNER JOIN OrderItems oi ON pf.FormatId = oi.FormatId
                            WHERE oi.OrderId = @id";

                        using (var cmdStock = new System.Data.SqlClient.SqlCommand(restoreStockQuery, conn))
                        {
                            cmdStock.Parameters.AddWithValue("@id", orderId);
                            cmdStock.ExecuteNonQuery();
                        }
                    }
                    // Note: Le stock est déjà diminué lors de la création de la commande dans Checkout.aspx.cs
                    // car les commandes sont créées avec le statut "Validée"
                    // Donc on ne diminue le stock ici que si on passe d'un statut "Annulée" vers "Validée" (réactivation)
                    if (status == "Validée" && oldStatus == "Annulée")
                    {
                        // Vérifier d'abord que le stock est suffisant
                        string checkStockQuery = @"
                            SELECT oi.FormatId, oi.Quantity, pf.Stock, pf.Label, p.Name as ProductName
                            FROM OrderItems oi
                            INNER JOIN ProductFormats pf ON oi.FormatId = pf.FormatId
                            INNER JOIN Products p ON oi.ProductId = p.ProductId
                            WHERE oi.OrderId = @id";

                        using (var cmdCheck = new System.Data.SqlClient.SqlCommand(checkStockQuery, conn))
                        {
                            cmdCheck.Parameters.AddWithValue("@id", orderId);
                            using (var reader = cmdCheck.ExecuteReader())
                            {
                                while (reader.Read())
                                {
                                    int quantity = (int)reader["Quantity"];
                                    int stock = (int)reader["Stock"];
                                    string productName = reader["ProductName"].ToString();
                                    string formatLabel = reader["Label"].ToString();
                                    
                                    if (stock < quantity)
                                    {
                                        return new Dictionary<string, object> { 
                                            { "success", false }, 
                                            { "message", $"Stock insuffisant pour {productName} ({formatLabel}). Stock disponible: {stock}, Quantité demandée: {quantity}" } 
                                        };
                                    }
                                }
                            }
                        }

                        // Diminuer le stock (réactivation d'une commande annulée)
                        string decreaseStockQuery = @"
                            UPDATE pf
                            SET pf.Stock = pf.Stock - oi.Quantity
                            FROM ProductFormats pf
                            INNER JOIN OrderItems oi ON pf.FormatId = oi.FormatId
                            WHERE oi.OrderId = @id";

                        using (var cmdStock = new System.Data.SqlClient.SqlCommand(decreaseStockQuery, conn))
                        {
                            cmdStock.Parameters.AddWithValue("@id", orderId);
                            cmdStock.ExecuteNonQuery();
                        }
                    }

                    string query = @"
                        UPDATE Orders 
                        SET Status = @status, 
                            TrackingNumber = @tracking";

                    if (status == "Validée") query += ", ValidatedAt = GETDATE()";
                    else if (status == "En préparation") query += ", InPreparationAt = GETDATE()";
                    else if (status == "Expédiée") query += ", ShippedAt = GETDATE()";
                    else if (status == "Livrée") query += ", DeliveredAt = GETDATE()";
                    else if (status == "Annulée") query += ", CancelledAt = GETDATE()";

                    query += " WHERE OrderId = @id";

                    var cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@status", status);
                    cmd.Parameters.AddWithValue("@tracking", trackingNumber);
                    cmd.Parameters.AddWithValue("@id", orderId);
                    
                    cmd.ExecuteNonQuery();
                }
                return new Dictionary<string, object> { { "success", true }, { "message", "Commande mise à jour" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        public object GetCustomers(string searchTerm = "", string statusFilter = "", int pageIndex = 1, int pageSize = 10)
        {
            if (Session["AdminLoggedIn"] == null) return new Dictionary<string, object> { { "success", false }, { "message", "Non autorisé" } };

            try
            {
                var customers = new List<Dictionary<string, object>>();
                int totalCount = 0;

                using (var conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Filters
                    string filterClause = "WHERE Role != 'Admin'";
                    if (!string.IsNullOrEmpty(searchTerm))
                    {
                        filterClause += " AND (FullName LIKE @search OR Email LIKE @search)";
                    }
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        bool isActive = statusFilter == "true";
                        filterClause += " AND IsActive = @isActive";
                    }

                    // Count
                    string countQuery = $"SELECT COUNT(*) FROM Users {filterClause}";
                    using (var countCmd = new System.Data.SqlClient.SqlCommand(countQuery, conn))
                    {
                        if (!string.IsNullOrEmpty(searchTerm)) countCmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                        if (!string.IsNullOrEmpty(statusFilter))
                        {
                            bool isActive = statusFilter == "true";
                            countCmd.Parameters.AddWithValue("@isActive", isActive);
                        }
                        totalCount = (int)countCmd.ExecuteScalar();
                    }

                    // Paged Data
                    string query = $@"
                        SELECT UserId, FullName, Email, Phone, CreatedAt, IsActive,
                        (SELECT COUNT(*) FROM Orders WHERE UserId = u.UserId) as OrderCount,
                        (SELECT ISNULL(SUM(TotalTTC), 0) FROM Orders WHERE UserId = u.UserId) as TotalSpent
                        FROM Users u
                        {filterClause}
                        ORDER BY TotalSpent DESC
                        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";

                    var cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                    if (!string.IsNullOrEmpty(searchTerm)) cmd.Parameters.AddWithValue("@search", "%" + searchTerm + "%");
                    if (!string.IsNullOrEmpty(statusFilter))
                    {
                        bool isActive = statusFilter == "true";
                        cmd.Parameters.AddWithValue("@isActive", isActive);
                    }
                    
                    cmd.Parameters.AddWithValue("@Offset", (pageIndex - 1) * pageSize);
                    cmd.Parameters.AddWithValue("@PageSize", pageSize);

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            customers.Add(new Dictionary<string, object> {
                                { "id", reader["UserId"] },
                                { "fullName", reader["FullName"] },
                                { "email", reader["Email"] },
                                { "phone", reader["Phone"] },
                                { "isActive", reader["IsActive"] != DBNull.Value ? (bool)reader["IsActive"] : true },
                                { "orderCount", reader["OrderCount"] },
                                { "totalSpent", reader["TotalSpent"] },
                                { "createdAt", Convert.ToDateTime(reader["CreatedAt"]).ToString("dd/MM/yyyy") }
                            });
                        }
                    }
                }
                return new Dictionary<string, object> { 
                    { "success", true }, 
                    { "data", customers },
                    { "totalCount", totalCount },
                    { "pageIndex", pageIndex },
                    { "pageSize", pageSize }
                };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        public object ToggleCustomerStatus(int userId, bool isActive)
        {
            if (Session["AdminLoggedIn"] == null) return new Dictionary<string, object> { { "success", false }, { "message", "Non autorisé" } };

            try
            {
                using (var conn = Database.Database.GetConnection())
                {
                    string query = "UPDATE Users SET IsActive = @isActive WHERE UserId = @id";
                    var cmd = new System.Data.SqlClient.SqlCommand(query, conn);
                    cmd.Parameters.AddWithValue("@isActive", isActive);
                    cmd.Parameters.AddWithValue("@id", userId);
                    
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
                return new Dictionary<string, object> { { "success", true }, { "message", "Statut client mis à jour" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }
    }
}

