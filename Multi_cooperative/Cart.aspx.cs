using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    public partial class Cart : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Vérifier connexion
                if (Session["UserId"] == null)
                {
                    Response.Redirect("Login.aspx?ReturnUrl=Cart.aspx");
                    return;
                }
                LoadCart();
            }
        }

        private void LoadCart()
        {
            int userId = (int)Session["UserId"];
            decimal subTotal = 0;

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT ci.CartItemId, ci.Quantity, ci.UnitPrice, (ci.Quantity * ci.UnitPrice) as TotalPrice,
                           p.ProductId, p.Name, f.Label, img.ImageUrl
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

                    if (dt.Rows.Count > 0)
                    {
                        rptCart.DataSource = dt;
                        rptCart.DataBind();

                        // Calcul du total
                        foreach (DataRow row in dt.Rows)
                        {
                            subTotal += Convert.ToDecimal(row["TotalPrice"]);
                        }
                        litSubTotal.Text = subTotal.ToString("N2");

                        pnlCartContent.Visible = true;
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        pnlCartContent.Visible = false;
                        pnlEmpty.Visible = true;
                    }
                }
            }
        }

        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
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
                    // Vérifier si quantité > 1
                    string checkSql = "SELECT Quantity FROM CartItems WHERE CartItemId = @Id";
                    int qty = 0;
                    using (SqlCommand cmdCheck = new SqlCommand(checkSql, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Id", cartItemId);
                        object res = cmdCheck.ExecuteScalar();
                        if (res != null) qty = (int)res;
                    }

                    if (qty > 1)
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
            // Recharger le panier pour voir les changements
            LoadCart();
        }

        protected void btnCheckout_Click(object sender, EventArgs e)
        {
            Response.Redirect("Checkout.aspx");
        }
    }
}