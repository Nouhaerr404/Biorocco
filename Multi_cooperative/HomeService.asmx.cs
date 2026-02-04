using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Web.Services;
using System.Web.Script.Services;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [ScriptService]
    public class HomeService : WebService
    {
        [WebMethod]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetProductsByType(string tabType = "new")
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
                                'Tendances' as Badge
                            FROM Products p
                            INNER JOIN Categories c ON p.CategoryId = c.CategoryId
                            WHERE p.IsActive = 1
                            ORDER BY 
                                (SELECT COUNT(*) FROM CartItems ci 
                                 INNER JOIN Cart c ON ci.CartId = c.CartId 
                                 WHERE ci.ProductId = p.ProductId) DESC, 
                                p.CreatedAt DESC";
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

                var products = new List<Dictionary<string, object>>();

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    SqlCommand cmd = new SqlCommand(query, conn);
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        products.Add(new Dictionary<string, object>
                        {
                            { "productId", reader["ProductId"] },
                            { "name", reader["Name"].ToString() },
                            { "description", reader["Description"] == DBNull.Value ? "" : reader["Description"].ToString() },
                            { "isOrganic", reader["IsOrganic"] == DBNull.Value ? false : (bool)reader["IsOrganic"] },
                            { "categoryName", reader["CategoryName"] == DBNull.Value ? "" : reader["CategoryName"].ToString() },
                            { "imageUrl", reader["ImageUrl"].ToString() },
                            { "price", reader["Price"] },
                            { "avgRating", reader["AvgRating"] },
                            { "badge", reader["Badge"].ToString() }
                        });
                    }
                }

                return new Dictionary<string, object>
                {
                    { "success", true },
                    { "data", products }
                };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object>
                {
                    { "success", false },
                    { "message", ex.Message }
                };
            }
        }
    }
}

