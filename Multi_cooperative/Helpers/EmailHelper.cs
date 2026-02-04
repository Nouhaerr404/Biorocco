using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Text;
using Multi_cooperative.Database;

namespace Multi_cooperative.Helpers
{
    public class EmailHelper
    {
        private static string SmtpHost => ConfigurationManager.AppSettings["SmtpHost"];
        private static int SmtpPort => int.Parse(ConfigurationManager.AppSettings["SmtpPort"]);
        private static string SenderEmail => ConfigurationManager.AppSettings["SmtpEmail"];
        private static string SenderPassword => ConfigurationManager.AppSettings["SmtpPassword"];

        public static void SendOrderConfirmation(string clientEmail, string clientName, int orderId, decimal totalAmount)
        {
            try
            {
                string itemsHtml = GetOrderItemsHtml(orderId);

                using (SmtpClient client = new SmtpClient(SmtpHost, SmtpPort))
                {
                    client.EnableSsl = true;
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(SenderEmail, SenderPassword);
                    client.Timeout = 10000; // 10 secondes pour la connexion SMTP

                    using (MailMessage mail = new MailMessage())
                    {
                        mail.From = new MailAddress(SenderEmail, "Biorocco Commandes");
                        mail.To.Add(clientEmail);
                        mail.Subject = $"Confirmation de votre commande #{orderId}";
                        mail.IsBodyHtml = true;

                        // --- CONSTRUCTION DU DESIGN DE L'EMAIL ---
                        StringBuilder body = new StringBuilder();

                        // Conteneur principal
                        body.Append("<div style='font-family: Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;'>");

                        // En-tête Vert Biorocco
                        body.Append("<div style='background-color: #2D5F3F; padding: 20px; text-align: center;'>");
                        body.Append("<h1 style='color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px;'>BIOROCCO</h1>");
                        body.Append("</div>");

                        // Message de bienvenue
                        body.Append("<div style='padding: 20px; border: 1px solid #eee; border-top: none;'>");
                        body.Append($"<p style='font-size: 16px;'>Bonjour <strong>{clientName}</strong>,</p>");
                        body.Append("<p>Nous avons bien reçu votre commande ! Elle est maintenant en cours de préparation.</p>");

                        // Bloc Numéro de commande
                        body.Append("<div style='background-color: #F9F7F2; border-left: 4px solid #E8967D; padding: 15px; margin: 20px 0;'>");
                        body.Append("<p style='margin: 0; font-size: 12px; color: #888; text-transform: uppercase;'>Numéro de commande</p>");
                        body.Append($"<p style='margin: 5px 0 0 0; font-size: 20px; font-weight: bold; color: #2D5F3F;'>#{orderId}</p>");
                        body.Append("</div>");

                        // --- TABLEAU DES PRODUITS (Généré dynamiquement) ---
                        body.Append("<h3 style='border-bottom: 1px solid #ddd; padding-bottom: 10px; margin-top: 30px; color: #2D5F3F;'>Détails de la commande</h3>");
                        body.Append("<table width='100%' cellpadding='10' cellspacing='0' style='border-collapse: collapse; margin-bottom: 20px;'>");

                        // En-têtes du tableau
                        body.Append("<tr style='background-color: #f8f8f8; text-align: left;'>");
                        body.Append("<th style='border-bottom: 1px solid #ddd; font-size: 12px; color: #666;'>PRODUIT</th>");
                        body.Append("<th style='border-bottom: 1px solid #ddd; font-size: 12px; color: #666;'>QTÉ</th>");
                        body.Append("<th style='border-bottom: 1px solid #ddd; font-size: 12px; color: #666; text-align: right;'>PRIX</th>");
                        body.Append("</tr>");

                        // Insertion des lignes produits
                        body.Append(itemsHtml);

                        // Total
                        body.Append("<tr>");
                        body.Append("<td colspan='2' style='text-align: right; padding-top: 20px; font-weight: bold;'>TOTAL TTC</td>");
                        body.Append($"<td style='text-align: right; padding-top: 20px; font-weight: bold; font-size: 18px; color: #2D5F3F;'>{totalAmount:N2} DH</td>");
                        body.Append("</tr>");

                        body.Append("</table>");

                        // Bouton d'action
                        body.Append("<div style='text-align: center; margin-top: 40px; margin-bottom: 20px;'>");
                        body.Append("<a href='http://localhost:44361/ClientProfile.aspx' style='background-color: #E8967D; color: white; padding: 12px 25px; text-decoration: none; border-radius: 4px; font-weight: bold;'>Suivre ma commande</a>");
                        body.Append("</div>");

                        // Footer
                        body.Append("<p style='font-size: 12px; color: #999; text-align: center; margin-top: 30px;'>Merci de votre confiance. L'équipe Biorocco.</p>");

                        body.Append("</div>"); // Fin du padding
                        body.Append("</div>"); // Fin du conteneur

                        mail.Body = body.ToString();
                        
                        System.Diagnostics.Debug.WriteLine($"[EMAIL] Envoi vers: {clientEmail}");
                        System.Diagnostics.Debug.WriteLine($"[EMAIL] De: {SenderEmail}");
                        client.Send(mail);
                        System.Diagnostics.Debug.WriteLine($"[EMAIL] ✓ Email envoyé avec succès à {clientEmail}");
                    }
                }
            }
            catch (SmtpException smtpEx)
            {
                System.Diagnostics.Debug.WriteLine("[EMAIL] ❌ Erreur SMTP: " + smtpEx.Message);
                System.Diagnostics.Debug.WriteLine("[EMAIL] StatusCode: " + smtpEx.StatusCode);
                System.Diagnostics.Debug.WriteLine("[EMAIL] InnerException: " + smtpEx.InnerException?.Message);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[EMAIL] ❌ Erreur générale: " + ex.Message);
                System.Diagnostics.Debug.WriteLine("[EMAIL] Stack: " + ex.StackTrace);
            }
        }

        // --- NOUVELLE FONCTION : Récupère les articles depuis la BD pour l'email ---
        private static string GetOrderItemsHtml(int orderId)
        {
            StringBuilder rows = new StringBuilder();

            using (SqlConnection conn = Database.Database.GetConnection())
            {
                conn.Open();
                string sql = @"
                    SELECT p.Name, f.Label, oi.Quantity, (oi.Quantity * oi.UnitPrice) as TotalRow
                    FROM OrderItems oi
                    JOIN Products p ON oi.ProductId = p.ProductId
                    JOIN ProductFormats f ON oi.FormatId = f.FormatId
                    WHERE oi.OrderId = @OrderId";

                using (SqlCommand cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@OrderId", orderId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            string productName = rdr["Name"].ToString();
                            string format = rdr["Label"].ToString();
                            int qty = Convert.ToInt32(rdr["Quantity"]);
                            decimal price = Convert.ToDecimal(rdr["TotalRow"]);

                            rows.Append("<tr>");

                            // Colonne Produit
                            rows.Append($"<td style='border-bottom: 1px solid #eee; color: #333;'>");
                            rows.Append($"<strong>{productName}</strong><br/>");
                            rows.Append($"<span style='font-size: 12px; color: #888;'>Format : {format}</span>");
                            rows.Append("</td>");

                            // Colonne Quantité
                            rows.Append($"<td style='border-bottom: 1px solid #eee; color: #333;'>x {qty}</td>");

                            // Colonne Prix
                            rows.Append($"<td style='border-bottom: 1px solid #eee; text-align: right; color: #333;'>{price:N2} DH</td>");

                            rows.Append("</tr>");
                        }
                    }
                }
            }
            return rows.ToString();
        }

        public static void SendPasswordResetEmail(string email, string userName, string resetUrl)
        {
            try
            {
                using (SmtpClient client = new SmtpClient(SmtpHost, SmtpPort))
                {
                    client.EnableSsl = true;
                    client.DeliveryMethod = SmtpDeliveryMethod.Network;
                    client.UseDefaultCredentials = false;
                    client.Credentials = new NetworkCredential(SenderEmail, SenderPassword);
                    client.Timeout = 10000;

                    using (MailMessage mail = new MailMessage())
                    {
                        mail.From = new MailAddress(SenderEmail, "Biorocco");
                        mail.To.Add(email);
                        mail.Subject = "Réinitialisation de votre mot de passe";
                        mail.IsBodyHtml = true;

                        StringBuilder body = new StringBuilder();

                        // Conteneur principal
                        body.Append("<div style='font-family: Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;'>");

                        // En-tête
                        body.Append("<div style='background-color: #2D5F3F; padding: 20px; text-align: center;'>");
                        body.Append("<h1 style='color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px;'>BIOROCCO</h1>");
                        body.Append("</div>");

                        // Contenu
                        body.Append("<div style='padding: 30px; border: 1px solid #eee; border-top: none;'>");
                        body.Append($"<p style='font-size: 16px;'>Bonjour <strong>{userName}</strong>,</p>");
                        body.Append("<p>Vous avez demandé la réinitialisation de votre mot de passe.</p>");
                        body.Append("<p>Cliquez sur le bouton ci-dessous pour créer un nouveau mot de passe :</p>");

                        // Bouton de réinitialisation
                        body.Append("<div style='text-align: center; margin: 30px 0;'>");
                        body.Append($"<a href='{resetUrl}' style='background-color: #E8967D; color: white; padding: 14px 30px; text-decoration: none; border-radius: 25px; font-weight: bold; display: inline-block;'>Réinitialiser mon mot de passe</a>");
                        body.Append("</div>");

                        body.Append("<p style='font-size: 14px; color: #666;'>Ou copiez et collez ce lien dans votre navigateur :</p>");
                        body.Append($"<p style='font-size: 12px; color: #999; word-break: break-all;'>{resetUrl}</p>");

                        body.Append("<p style='font-size: 14px; color: #666; margin-top: 30px;'>Ce lien est valide pendant 24 heures.</p>");
                        body.Append("<p style='font-size: 14px; color: #666;'>Si vous n'avez pas demandé cette réinitialisation, ignorez cet email.</p>");

                        body.Append("</div>");

                        // Footer
                        body.Append("<div style='background-color: #f9f9f9; padding: 20px; text-align: center; border-top: 1px solid #eee;'>");
                        body.Append("<p style='font-size: 12px; color: #999; margin: 0;'>Merci de votre confiance. L'équipe Biorocco.</p>");
                        body.Append("</div>");

                        body.Append("</div>");

                        mail.Body = body.ToString();

                        System.Diagnostics.Debug.WriteLine($"[EMAIL] Envoi réinitialisation mot de passe vers: {email}");
                        client.Send(mail);
                        System.Diagnostics.Debug.WriteLine($"[EMAIL] ✓ Email de réinitialisation envoyé avec succès à {email}");
                    }
                }
            }
            catch (SmtpException smtpEx)
            {
                System.Diagnostics.Debug.WriteLine("[EMAIL] ❌ Erreur SMTP: " + smtpEx.Message);
                throw;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("[EMAIL] ❌ Erreur générale: " + ex.Message);
                throw;
            }
        }
    }
}