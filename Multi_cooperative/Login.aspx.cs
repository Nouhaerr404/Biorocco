using System;
using System.Data.SqlClient;
using Multi_cooperative.Helpers;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    public partial class Login : System.Web.UI.Page
    {
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            try
            {
                // ON UTILISE LA CLASSE EXISTANTE ICI
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = "SELECT UserId, FullName, PasswordHash, Role FROM Users WHERE Email = @Email AND IsActive = 1";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedHash = reader["PasswordHash"].ToString();
                                string inputHash = SecurityHelper.HashPassword(txtPassword.Text);

                                if (storedHash == inputHash)
                                {
                                    // Succès
                                    Session["UserId"] = reader["UserId"];
                                    Session["UserEmail"] = txtEmail.Text.Trim();
                                    Session["UserName"] = reader["FullName"].ToString();
                                    string userRole = reader["Role"].ToString().ToLower();
                                    Session["UserRole"] = userRole;

                                    // Support for legacy admin session variable
                                    if (userRole == "admin")
                                    {
                                        Session["AdminLoggedIn"] = true;
                                    }

                                    string returnUrl = Request.QueryString["ReturnUrl"];
                                    if (!string.IsNullOrEmpty(returnUrl))
                                        Response.Redirect(returnUrl);
                                    else
                                    {
                                        // Redirection basée sur le rôle
                                        if (userRole == "admin")
                                            Response.Redirect("AdminDashboard.aspx");
                                        else
                                            Response.Redirect("Default.aspx");
                                    }
                                }
                                else
                                {
                                    lblError.Text = "Mot de passe incorrect.";
                                    lblError.Visible = true;
                                }
                            }
                            else
                            {
                                lblError.Text = "Aucun compte trouvé avec cet email.";
                                lblError.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Erreur de connexion : " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}