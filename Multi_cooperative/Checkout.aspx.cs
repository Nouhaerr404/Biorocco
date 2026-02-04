using System;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Multi_cooperative.Database;
using Multi_cooperative.Helpers;

namespace Multi_cooperative
{
    public partial class Checkout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx?ReturnUrl=Checkout.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAddresses();
                LoadShippingMethods();
                UpdateTotals();
            }
        }

        private void LoadAddresses()
        {
            int userId = (int)Session["UserId"];
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = "SELECT AddressId, AddressLine + ' - ' + City as FullAddr FROM Addresses WHERE UserId = @UserId";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    ddlAddresses.DataSource = cmd.ExecuteReader();
                    ddlAddresses.DataTextField = "FullAddr";
                    ddlAddresses.DataValueField = "AddressId";
                    ddlAddresses.DataBind();
                }
            }

            if (ddlAddresses.Items.Count == 0)
            {
                ddlAddresses.Items.Add(new ListItem("Aucune adresse trouvée (Ajoutez-en une dans Profil)", "0"));
                btnPay.Enabled = false;
            }
        }

        private void LoadShippingMethods()
        {
            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = "SELECT ShippingId, MethodName + ' (' + CAST(Price as varchar) + ' MAD)' as Label, Price FROM ShippingMethods";
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    ddlShipping.DataSource = cmd.ExecuteReader();
                    ddlShipping.DataTextField = "Label";
                    ddlShipping.DataValueField = "ShippingId";
                    ddlShipping.DataBind();
                }
            }
        }

        protected void ddlShipping_SelectedIndexChanged(object sender, EventArgs e)
        {
            UpdateTotals();
        }

        private void UpdateTotals()
        {
            int userId = (int)Session["UserId"];
            decimal cartTotal = 0;
            decimal shippingPrice = 0;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                string sqlCart = @"SELECT SUM(Quantity * UnitPrice) 
                                   FROM CartItems 
                                   WHERE CartId = (SELECT TOP 1 CartId FROM Cart WHERE UserId = @Uid)";
                using (SqlCommand cmd = new SqlCommand(sqlCart, conn))
                {
                    cmd.Parameters.AddWithValue("@Uid", userId);
                    object result = cmd.ExecuteScalar();
                    if (result != DBNull.Value && result != null)
                        cartTotal = Convert.ToDecimal(result);
                }

                if (!string.IsNullOrEmpty(ddlShipping.SelectedValue))
                {
                    string sqlShip = "SELECT Price FROM ShippingMethods WHERE ShippingId = @Sid";
                    using (SqlCommand cmd = new SqlCommand(sqlShip, conn))
                    {
                        cmd.Parameters.AddWithValue("@Sid", ddlShipping.SelectedValue);
                        object res = cmd.ExecuteScalar();
                        if (res != null && res != DBNull.Value)
                            shippingPrice = Convert.ToDecimal(res);
                    }
                }
            }

            lblSubTotal.Text = cartTotal.ToString("N2");
            lblShippingFee.Text = shippingPrice.ToString("N2");
            lblTotalTTC.Text = (cartTotal + shippingPrice).ToString("N2");
        }

        protected void btnPay_Click(object sender, EventArgs e)
        {
            if (ddlAddresses.SelectedValue == "0") return;

            int userId = (int)Session["UserId"];
            int addressId = int.Parse(ddlAddresses.SelectedValue);
            int shippingId = int.Parse(ddlShipping.SelectedValue);
            decimal totalAmount = decimal.Parse(lblTotalTTC.Text);

            int newOrderId = 0;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();

                
                string sqlOrder = @"
                    INSERT INTO Orders (UserId, AddressId, ShippingId, Status, TotalTTC, PaymentMethod, CreatedAt) 
                    OUTPUT INSERTED.OrderId 
                    VALUES (@UserId, @AddressId, @ShippingId, 'Validée', @Total, @PaymentMethod, GETDATE())";

                using (SqlCommand cmd = new SqlCommand(sqlOrder, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.Parameters.AddWithValue("@AddressId", addressId);
                    cmd.Parameters.AddWithValue("@ShippingId", shippingId);
                    cmd.Parameters.AddWithValue("@Total", totalAmount);

                    // Récupérer le mode de paiement depuis la DropDownList
                    string paymentMethod = ddlPaymentMethod.SelectedValue == "CarteBancaire" ? "Carte Bancaire" : "Paiement à la livraison";
                    cmd.Parameters.AddWithValue("@PaymentMethod", paymentMethod);

                    newOrderId = (int)cmd.ExecuteScalar();
                }

                // Vérifier le stock avant de créer la commande
                string checkStockQuery = @"
                    SELECT ci.FormatId, ci.Quantity, pf.Stock, pf.Label, p.Name as ProductName
                    FROM CartItems ci
                    INNER JOIN ProductFormats pf ON ci.FormatId = pf.FormatId
                    INNER JOIN Products p ON ci.ProductId = p.ProductId
                    WHERE ci.CartId = (SELECT TOP 1 CartId FROM Cart WHERE UserId = @UserId)";
                
                using (SqlCommand cmd = new SqlCommand(checkStockQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int formatId = (int)reader["FormatId"];
                            int quantity = (int)reader["Quantity"];
                            int stock = (int)reader["Stock"];
                            string productName = reader["ProductName"].ToString();
                            string formatLabel = reader["Label"].ToString();
                            
                            if (stock < quantity)
                            {
                                throw new Exception($"Stock insuffisant pour {productName} ({formatLabel}). Stock disponible: {stock}, Quantité demandée: {quantity}");
                            }
                        }
                    }
                }

                // Copier les items du panier vers OrderItems
                string sqlItems = @"
                    INSERT INTO OrderItems (OrderId, ProductId, FormatId, Quantity, UnitPrice)
                    SELECT @OrderId, ProductId, FormatId, Quantity, UnitPrice
                    FROM CartItems 
                    WHERE CartId = (SELECT TOP 1 CartId FROM Cart WHERE UserId = @UserId)";

                using (SqlCommand cmd = new SqlCommand(sqlItems, conn))
                {
                    cmd.Parameters.AddWithValue("@OrderId", newOrderId);
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }

                // Diminuer le stock pour chaque format commandé
                string updateStockQuery = @"
                    UPDATE pf
                    SET pf.Stock = pf.Stock - ci.Quantity
                    FROM ProductFormats pf
                    INNER JOIN CartItems ci ON pf.FormatId = ci.FormatId
                    WHERE ci.CartId = (SELECT TOP 1 CartId FROM Cart WHERE UserId = @UserId)";

                using (SqlCommand cmd = new SqlCommand(updateStockQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }

                // Vider le panier après la commande
                string sqlClean = "DELETE FROM CartItems WHERE CartId = (SELECT TOP 1 CartId FROM Cart WHERE UserId = @UserId)";
                using (SqlCommand cmd = new SqlCommand(sqlClean, conn))
                {
                    cmd.Parameters.AddWithValue("@UserId", userId);
                    cmd.ExecuteNonQuery();
                }
            }

            // Envoi d'email de confirmation (optionnel)
            try
            {
                if (Session["UserEmail"] != null && Session["UserName"] != null)
                {
                    string clientEmail = Session["UserEmail"].ToString();
                    string clientName = Session["UserName"].ToString();
                    EmailHelper.SendOrderConfirmation(clientEmail, clientName, newOrderId, totalAmount);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Erreur Email: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
            }

            Response.Redirect("OrderSuccess.aspx?orderId=" + newOrderId);
        }
    }
}