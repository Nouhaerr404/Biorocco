using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Services;
using System.Web.Script.Services;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [ScriptService]
    public class ClientProfileService : WebService
    {
        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json, UseHttpGet = false)]
        public object GetDemandes(string search = "", string status = "", string type = "")
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];
                var demandes = new List<object>();

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = @"SELECT DemandeId, ReferenceNumber, Type, Content, Status, AdminResponse, 
                                    CreatedAt, UpdatedAt 
                                    FROM Demandes 
                                    WHERE UserId = @UserId";

                    if (!string.IsNullOrEmpty(search))
                        query += " AND (ReferenceNumber LIKE @Search OR Content LIKE @Search)";
                    if (!string.IsNullOrEmpty(status))
                        query += " AND Status = @Status";
                    if (!string.IsNullOrEmpty(type))
                        query += " AND Type = @Type";

                    query += " ORDER BY CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        if (!string.IsNullOrEmpty(search))
                            cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
                        if (!string.IsNullOrEmpty(status))
                            cmd.Parameters.AddWithValue("@Status", status);
                        if (!string.IsNullOrEmpty(type))
                            cmd.Parameters.AddWithValue("@Type", type);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                demandes.Add(new Dictionary<string, object>
                                {
                                    { "demandeId", reader["DemandeId"] },
                                    { "referenceNumber", reader["ReferenceNumber"].ToString() },
                                    { "type", reader["Type"].ToString() },
                                    { "content", reader["Content"].ToString() },
                                    { "status", reader["Status"].ToString() },
                                    { "adminResponse", reader["AdminResponse"] == DBNull.Value ? null : reader["AdminResponse"].ToString() },
                                    { "createdAt", ((DateTime)reader["CreatedAt"]).ToString("dd/MM/yyyy HH:mm") },
                                    { "updatedAt", reader["UpdatedAt"] == DBNull.Value ? null : ((DateTime)reader["UpdatedAt"]).ToString("dd/MM/yyyy HH:mm") }
                                });
                            }
                        }
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "data", demandes } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object CreateDemande(string type, string content)
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];
                string referenceNumber = "DEM-" + DateTime.Now.ToString("yyyyMMddHHmmss") + "-" + userId;

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = @"INSERT INTO Demandes (UserId, ReferenceNumber, Type, Content, Status, CreatedAt)
                                    VALUES (@UserId, @ReferenceNumber, @Type, @Content, 'En attente', GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@ReferenceNumber", referenceNumber);
                        cmd.Parameters.AddWithValue("@Type", type);
                        cmd.Parameters.AddWithValue("@Content", content);
                        cmd.ExecuteNonQuery();
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "message", "Demande créée avec succès" }, { "referenceNumber", referenceNumber } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetAddresses()
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];
                var addresses = new List<object>();

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = @"SELECT AddressId, FullName, Phone, City, AddressLine, PostalCode, IsDefault
                                    FROM Addresses 
                                    WHERE UserId = @UserId
                                    ORDER BY IsDefault DESC, AddressId DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                addresses.Add(new Dictionary<string, object>
                                {
                                    { "addressId", reader["AddressId"] },
                                    { "fullName", reader["FullName"].ToString() },
                                    { "phone", reader["Phone"].ToString() },
                                    { "city", reader["City"].ToString() },
                                    { "addressLine", reader["AddressLine"].ToString() },
                                    { "postalCode", reader["PostalCode"].ToString() },
                                    { "isDefault", (bool)reader["IsDefault"] }
                                });
                            }
                        }
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "data", addresses } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object SaveAddress(int? addressId, string fullName, string phone, string city, string addressLine, string postalCode, bool isDefault)
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Si c'est l'adresse par défaut, désactiver les autres
                    if (isDefault)
                    {
                        string updateQuery = "UPDATE Addresses SET IsDefault = 0 WHERE UserId = @UserId";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    if (addressId.HasValue && addressId.Value > 0)
                    {
                        // Mise à jour
                        string query = @"UPDATE Addresses 
                                        SET FullName = @FullName, Phone = @Phone, City = @City, 
                                            AddressLine = @AddressLine, PostalCode = @PostalCode, IsDefault = @IsDefault
                                        WHERE AddressId = @AddressId AND UserId = @UserId";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@AddressId", addressId.Value);
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@FullName", fullName);
                            cmd.Parameters.AddWithValue("@Phone", phone);
                            cmd.Parameters.AddWithValue("@City", city);
                            cmd.Parameters.AddWithValue("@AddressLine", addressLine);
                            cmd.Parameters.AddWithValue("@PostalCode", postalCode);
                            cmd.Parameters.AddWithValue("@IsDefault", isDefault);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // Vérifier le nombre d'adresses (max 5)
                        string countQuery = "SELECT COUNT(*) FROM Addresses WHERE UserId = @UserId";
                        int count = 0;
                        using (SqlCommand cmd = new SqlCommand(countQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            count = (int)cmd.ExecuteScalar();
                        }

                        if (count >= 5)
                            return new Dictionary<string, object> { { "success", false }, { "message", "Vous ne pouvez pas avoir plus de 5 adresses" } };

                        // Insertion
                        string query = @"INSERT INTO Addresses (UserId, FullName, Phone, City, AddressLine, PostalCode, IsDefault)
                                        VALUES (@UserId, @FullName, @Phone, @City, @AddressLine, @PostalCode, @IsDefault)";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            cmd.Parameters.AddWithValue("@FullName", fullName);
                            cmd.Parameters.AddWithValue("@Phone", phone);
                            cmd.Parameters.AddWithValue("@City", city);
                            cmd.Parameters.AddWithValue("@AddressLine", addressLine);
                            cmd.Parameters.AddWithValue("@PostalCode", postalCode);
                            cmd.Parameters.AddWithValue("@IsDefault", isDefault);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "message", "Adresse enregistrée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object DeleteAddress(int addressId)
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = "DELETE FROM Addresses WHERE AddressId = @AddressId AND UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@AddressId", addressId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.ExecuteNonQuery();
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "message", "Adresse supprimée avec succès" } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        private bool ReaderHasColumn(SqlDataReader reader, string columnName)
        {
            for (int i = 0; i < reader.FieldCount; i++)
            {
                if (string.Equals(reader.GetName(i), columnName, StringComparison.OrdinalIgnoreCase))
                    return true;
            }
            return false;
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object GetOrders()
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];
                var orders = new List<object>();

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = @"SELECT o.OrderId, o.Status, o.TotalTTC, o.PaymentMethod, o.CreatedAt,
                                    o.ValidatedAt, o.InPreparationAt, o.ShippedAt, o.DeliveredAt,
                                    o.CancellationReason, o.CancelledAt,
                                    a.FullName, a.City, a.AddressLine, a.PostalCode,
                                    s.MethodName, s.EstimatedDays
                                    FROM Orders o
                                    INNER JOIN Addresses a ON o.AddressId = a.AddressId
                                    INNER JOIN ShippingMethods s ON o.ShippingId = s.ShippingId
                                    WHERE o.UserId = @UserId
                                    ORDER BY o.CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                var orderId = (int)reader["OrderId"];
                                var status = reader["Status"].ToString().Trim();
                                var canCancel = status != "Expédiée" && status != "Livrée" && status != "Annulée";

                                // Récupérer les items de la commande
                                var items = new List<object>();
                                using (SqlConnection conn2 = Database.Database.GetConnection())
                                {
                                    conn2.Open();
                                    string itemsQuery = @"SELECT oi.Quantity, oi.UnitPrice, p.Name, pf.Label
                                                        FROM OrderItems oi
                                                        INNER JOIN Products p ON oi.ProductId = p.ProductId
                                                        INNER JOIN ProductFormats pf ON oi.FormatId = pf.FormatId
                                                        WHERE oi.OrderId = @OrderId";
                                    using (SqlCommand itemsCmd = new SqlCommand(itemsQuery, conn2))
                                    {
                                        itemsCmd.Parameters.AddWithValue("@OrderId", orderId);
                                        using (SqlDataReader itemsReader = itemsCmd.ExecuteReader())
                                        {
                                            while (itemsReader.Read())
                                            {
                                                items.Add(new Dictionary<string, object>
                                                {
                                                    { "productName", itemsReader["Name"].ToString() },
                                                    { "format", itemsReader["Label"].ToString() },
                                                    { "quantity", (int)itemsReader["Quantity"] },
                                                    { "unitPrice", (decimal)itemsReader["UnitPrice"] }
                                                });
                                            }
                                        }
                                    }
                                }

                                // Colonnes optionnelles : lire uniquement si présentes
                                string tracking = null;
                                string cancellationReason = null;
                                string cancelledAt = null;

                                if (ReaderHasColumn(reader, "TrackingNumber") && reader["TrackingNumber"] != DBNull.Value)
                                    tracking = reader["TrackingNumber"].ToString();

                                if (ReaderHasColumn(reader, "CancellationReason") && reader["CancellationReason"] != DBNull.Value)
                                    cancellationReason = reader["CancellationReason"].ToString();

                                if (ReaderHasColumn(reader, "CancelledAt") && reader["CancelledAt"] != DBNull.Value)
                                    cancelledAt = ((DateTime)reader["CancelledAt"]).ToString("dd/MM/yyyy HH:mm");

                                orders.Add(new Dictionary<string, object>
                                {
                                    { "orderId", orderId },
                                    { "status", status },
                                    { "totalTTC", (decimal)reader["TotalTTC"] },
                                    { "paymentMethod", reader["PaymentMethod"].ToString() },
                                    { "createdAt", ((DateTime)reader["CreatedAt"]).ToString("dd/MM/yyyy HH:mm") },
                                    { "trackingNumber", tracking },
                                    { "cancellationReason", cancellationReason },
                                    { "cancelledAt", cancelledAt },
                                    { "validatedAt", ReaderHasColumn(reader, "ValidatedAt") && reader["ValidatedAt"] != DBNull.Value ? ((DateTime)reader["ValidatedAt"]).ToString("dd/MM/yyyy HH:mm") : null },
                                    { "inPreparationAt", ReaderHasColumn(reader, "InPreparationAt") && reader["InPreparationAt"] != DBNull.Value ? ((DateTime)reader["InPreparationAt"]).ToString("dd/MM/yyyy HH:mm") : null },
                                    { "shippedAt", ReaderHasColumn(reader, "ShippedAt") && reader["ShippedAt"] != DBNull.Value ? ((DateTime)reader["ShippedAt"]).ToString("dd/MM/yyyy HH:mm") : null },
                                    { "deliveredAt", ReaderHasColumn(reader, "DeliveredAt") && reader["DeliveredAt"] != DBNull.Value ? ((DateTime)reader["DeliveredAt"]).ToString("dd/MM/yyyy HH:mm") : null },
                                    { "address", new Dictionary<string, object>
                                        {
                                            { "fullName", reader["FullName"].ToString() },
                                            { "city", reader["City"].ToString() },
                                            { "addressLine", reader["AddressLine"].ToString() },
                                            { "postalCode", reader["PostalCode"].ToString() }
                                        }
                                    },
                                    { "shipping", new Dictionary<string, object>
                                        {
                                            { "methodName", reader["MethodName"].ToString() },
                                            { "estimatedDays", (int)reader["EstimatedDays"] }
                                        }
                                    },
                                    { "items", items },
                                    { "canCancel", canCancel }
                                });
                            }
                        }
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "data", orders } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }

        [WebMethod(EnableSession = true)]
        [ScriptMethod(ResponseFormat = ResponseFormat.Json)]
        public object CancelOrder(int orderId, string reason)
        {
            try
            {
                if (Session["UserId"] == null)
                    return new Dictionary<string, object> { { "success", false }, { "message", "Non authentifié" } };

                int userId = (int)Session["UserId"];

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Vérifier que la commande appartient à l'utilisateur et peut être annulée
                    string checkQuery = "SELECT Status FROM Orders WHERE OrderId = @OrderId AND UserId = @UserId";
                    string status = null;
                    using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        var result = cmd.ExecuteScalar();
                        if (result == null)
                            return new Dictionary<string, object> { { "success", false }, { "message", "Commande introuvable" } };
                        status = result.ToString();
                    }

                    if (status == "Expédiée" || status == "Livrée" || status == "Annulée")
                        return new Dictionary<string, object> { { "success", false }, { "message", "Cette commande ne peut pas être annulée" } };

                    // Restaurer le stock avant d'annuler la commande
                    string restoreStockQuery = @"
                        UPDATE pf
                        SET pf.Stock = pf.Stock + oi.Quantity
                        FROM ProductFormats pf
                        INNER JOIN OrderItems oi ON pf.FormatId = oi.FormatId
                        WHERE oi.OrderId = @OrderId";

                    using (SqlCommand cmd = new SqlCommand(restoreStockQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        cmd.ExecuteNonQuery();
                    }

                    // Annuler la commande
                    string updateQuery = @"UPDATE Orders 
                                          SET Status = 'Annulée', CancellationReason = @Reason, CancelledAt = GETDATE()
                                          WHERE OrderId = @OrderId AND UserId = @UserId";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@OrderId", orderId);
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        cmd.Parameters.AddWithValue("@Reason", reason);
                        cmd.ExecuteNonQuery();
                    }
                }

                return new Dictionary<string, object> { { "success", true }, { "message", "Commande annulée avec succès. Le remboursement sera effectué selon votre mode de paiement." } };
            }
            catch (Exception ex)
            {
                return new Dictionary<string, object> { { "success", false }, { "message", ex.Message } };
            }
        }
    }
}
