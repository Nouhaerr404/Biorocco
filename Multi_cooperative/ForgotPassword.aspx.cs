using System;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using Multi_cooperative.Database;
using Multi_cooperative.Helpers;

namespace Multi_cooperative
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void btnSendResetLink_Click(object sender, EventArgs e)
        {
            try
            {
                string email = txtEmail.Text.Trim();

                if (string.IsNullOrEmpty(email))
                {
                    lblError.Text = "Veuillez entrer votre adresse email.";
                    lblError.Visible = true;
                    lblSuccess.Visible = false;
                    return;
                }

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Vérifier si l'email existe
                    string checkQuery = "SELECT UserId, FullName FROM Users WHERE Email = @Email AND IsActive = 1";
                    int userId = 0;
                    string userName = "";

                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        using (SqlDataReader reader = checkCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                userId = (int)reader["UserId"];
                                userName = reader["FullName"].ToString();
                            }
                        }
                    }

                    if (userId == 0)
                    {
                        // Pour des raisons de sécurité, on ne révèle pas si l'email existe ou non
                        lblSuccess.Text = "Si cette adresse email existe dans notre système, un lien de réinitialisation a été envoyé.";
                        lblSuccess.Visible = true;
                        lblError.Visible = false;
                        return;
                    }

                    // Générer un token unique
                    string token = GenerateResetToken();
                    DateTime expiresAt = DateTime.Now.AddHours(24); // Token valide pendant 24h

                    // Supprimer les anciens tokens pour cet utilisateur
                    string deleteOldTokensQuery = "DELETE FROM PasswordResetTokens WHERE UserId = @UserId";
                    using (SqlCommand deleteCmd = new SqlCommand(deleteOldTokensQuery, conn))
                    {
                        deleteCmd.Parameters.AddWithValue("@UserId", userId);
                        deleteCmd.ExecuteNonQuery();
                    }

                    // Insérer le nouveau token
                    string insertTokenQuery = @"INSERT INTO PasswordResetTokens (UserId, Token, ExpiresAt) 
                                                VALUES (@UserId, @Token, @ExpiresAt)";
                    using (SqlCommand insertCmd = new SqlCommand(insertTokenQuery, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@UserId", userId);
                        insertCmd.Parameters.AddWithValue("@Token", token);
                        insertCmd.Parameters.AddWithValue("@ExpiresAt", expiresAt);
                        insertCmd.ExecuteNonQuery();
                    }

                    // Envoyer l'email avec le lien de réinitialisation
                    string resetUrl = Request.Url.GetLeftPart(UriPartial.Authority) + 
                                     "/ResetPassword.aspx?token=" + Server.UrlEncode(token);

                    try
                    {
                        EmailHelper.SendPasswordResetEmail(email, userName, resetUrl);
                        // Message de succès
                        lblSuccess.Text = "Un lien de réinitialisation a été envoyé à votre adresse email. Veuillez vérifier votre boîte de réception.";
                        lblSuccess.Visible = true;
                        lblError.Visible = false;
                    }
                    catch (Exception emailEx)
                    {
                        // Si l'email ne peut pas être envoyé, on affiche quand même un message mais avec le lien direct
                        System.Diagnostics.Debug.WriteLine("Erreur envoi email: " + emailEx.Message);
                        lblSuccess.Text = $"Un lien de réinitialisation a été généré. Si vous ne recevez pas l'email, utilisez ce lien : <br/><a href='{resetUrl}' style='color: #E8967D; word-break: break-all;'>{resetUrl}</a>";
                        lblSuccess.Visible = true;
                        lblError.Visible = false;
                    }
                }
            }
            catch (Exception ex)
            {
                lblError.Text = "Une erreur est survenue. Veuillez réessayer plus tard.";
                lblError.Visible = true;
                lblSuccess.Visible = false;
                System.Diagnostics.Debug.WriteLine("Erreur réinitialisation mot de passe: " + ex.Message);
            }
        }

        private string GenerateResetToken()
        {
            using (System.Security.Cryptography.RandomNumberGenerator rng = System.Security.Cryptography.RandomNumberGenerator.Create())
            {
                byte[] tokenData = new byte[32];
                rng.GetBytes(tokenData);
                return Convert.ToBase64String(tokenData).Replace("+", "-").Replace("/", "_").Replace("=", "");
            }
        }
    }
}

