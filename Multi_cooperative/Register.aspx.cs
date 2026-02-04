using System;
using System.Data.SqlClient;
using Multi_cooperative.Helpers;
using Multi_cooperative.Database; // Ajoute ça pour voir la classe Database

namespace Multi_cooperative
{
    public partial class Register : System.Web.UI.Page
    {
        protected void btnRegister_Click(object sender, EventArgs e)
        {
            if (txtPassword.Text != txtConfirmPass.Text)
            {
                lblError.Text = "Les mots de passe ne correspondent pas.";
                lblError.Visible = true;
                return;
            }

            try
            {
                // ON UTILISE LA CLASSE EXISTANTE ICI
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // 1. Vérifier si l'email existe déjà
                    string checkQuery = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        if ((int)checkCmd.ExecuteScalar() > 0)
                        {
                            lblError.Text = "Cet email est déjà utilisé.";
                            lblError.Visible = true;
                            return;
                        }
                    }

                    // 2. Insérer le nouveau client
                    string insertQuery = @"INSERT INTO Users (FullName, Email, Phone, PasswordHash, Role, IsActive) 
                                           VALUES (@FullName, @Email, @Phone, @PasswordHash, 'Client', 1)";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@FullName", txtFullName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@Phone", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@PasswordHash", SecurityHelper.HashPassword(txtPassword.Text));

                        cmd.ExecuteNonQuery();
                    }
                }

                // Redirection vers la page de connexion
                Response.Redirect("Login.aspx");
            }
            catch (Exception ex)
            {
                lblError.Text = "Erreur : " + ex.Message;
                lblError.Visible = true;
            }
        }
    }
}