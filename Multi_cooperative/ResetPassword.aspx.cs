using System;
using System.Data.SqlClient;
using Multi_cooperative.Database;
using Multi_cooperative.Helpers;

namespace Multi_cooperative
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string token = Request.QueryString["token"];

                if (string.IsNullOrEmpty(token))
                {
                    lblError.Text = "Token de réinitialisation invalide ou manquant.";
                    lblError.Visible = true;
                    pnlResetForm.Visible = false;
                    pnlSuccess.Visible = false;
                    return;
                }

                // Décoder le token (au cas où il serait encodé)
                token = Server.UrlDecode(token);

                // Vérifier la validité du token
                if (!IsTokenValid(token))
                {
                    lblError.Text = "Ce lien de réinitialisation est invalide ou a expiré. Veuillez demander un nouveau lien.";
                    lblError.Visible = true;
                    pnlResetForm.Visible = false;
                    pnlSuccess.Visible = false;
                    return;
                }
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            try
            {
                string token = Request.QueryString["token"];

                if (string.IsNullOrEmpty(token))
                {
                    lblError.Text = "Token de réinitialisation manquant.";
                    lblError.Visible = true;
                    return;
                }

                // Décoder le token
                token = Server.UrlDecode(token);

                if (!IsTokenValid(token))
                {
                    lblError.Text = "Token de réinitialisation invalide ou expiré.";
                    lblError.Visible = true;
                    return;
                }

                string newPassword = txtNewPassword.Text.Trim();
                string confirmPassword = txtConfirmPassword.Text.Trim();

                if (string.IsNullOrEmpty(newPassword) || newPassword != confirmPassword)
                {
                    lblError.Text = "Les mots de passe ne correspondent pas.";
                    lblError.Visible = true;
                    return;
                }

                if (newPassword.Length < 6)
                {
                    lblError.Text = "Le mot de passe doit contenir au moins 6 caractères.";
                    lblError.Visible = true;
                    return;
                }

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Récupérer l'UserId depuis le token
                    int userId = 0;
                    string getUserIdQuery = @"SELECT UserId FROM PasswordResetTokens 
                                             WHERE Token = @Token AND ExpiresAt > GETDATE()";
                    
                    using (SqlCommand getUserIdCmd = new SqlCommand(getUserIdQuery, conn))
                    {
                        getUserIdCmd.Parameters.AddWithValue("@Token", token);
                        object result = getUserIdCmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            userId = (int)result;
                        }
                    }

                    if (userId == 0)
                    {
                        lblError.Text = "Token de réinitialisation invalide ou expiré.";
                        lblError.Visible = true;
                        return;
                    }

                    // Mettre à jour le mot de passe
                    string hashedPassword = SecurityHelper.HashPassword(newPassword);
                    string updatePasswordQuery = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserId = @UserId";

                    using (SqlCommand updateCmd = new SqlCommand(updatePasswordQuery, conn))
                    {
                        updateCmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                        updateCmd.Parameters.AddWithValue("@UserId", userId);
                        updateCmd.ExecuteNonQuery();
                    }

                    // Supprimer le token utilisé
                    string deleteTokenQuery = "DELETE FROM PasswordResetTokens WHERE Token = @Token";
                    using (SqlCommand deleteCmd = new SqlCommand(deleteTokenQuery, conn))
                    {
                        deleteCmd.Parameters.AddWithValue("@Token", token);
                        deleteCmd.ExecuteNonQuery();
                    }

                    // Afficher le message de succès
                    pnlResetForm.Visible = false;
                    pnlSuccess.Visible = true;
                    lblError.Visible = false;
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Une erreur est survenue. Veuillez réessayer plus tard.";
                lblError.Visible = true;
                System.Diagnostics.Debug.WriteLine("Erreur réinitialisation mot de passe: " + ex.Message);
            }
        }

        private bool IsTokenValid(string token)
        {
            try
            {
                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();
                    string query = @"SELECT COUNT(*) FROM PasswordResetTokens 
                                    WHERE Token = @Token AND ExpiresAt > GETDATE()";
                    
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Token", token);
                        int count = (int)cmd.ExecuteScalar();
                        return count > 0;
                    }
                }
            }
            catch
            {
                return false;
            }
        }
    }
}

