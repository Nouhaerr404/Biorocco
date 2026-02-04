using System;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;

namespace Multi_cooperative
{
    public partial class Header : System.Web.UI.UserControl
    {
        // Propriété publique pour le nombre d'items dans le panier
        public int CartItemCount { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Charger le nombre d'items du panier à chaque chargement
            LoadCartItemCount();
        }

        /// <summary>
        /// Récupère le nombre total d'items dans le panier de l'utilisateur connecté
        /// </summary>
        private void LoadCartItemCount()
        {
            // Par défaut, 0 items
            CartItemCount = 0;

            // Vérifier si l'utilisateur est connecté
            if (Session["UserId"] == null)
            {
                return; // Pas connecté = panier vide
            }

            try
            {
                int userId = Convert.ToInt32(Session["UserId"]);

                using (SqlConnection conn = Database.Database.GetConnection())
                {
                    conn.Open();

                    // Requête pour compter le NOMBRE TOTAL d'items (somme des quantités)
                    string query = @"
                        SELECT ISNULL(SUM(ci.Quantity), 0) AS TotalItems
                        FROM CartItems ci
                        INNER JOIN Cart c ON ci.CartId = c.CartId
                        WHERE c.UserId = @UserId
                        AND c.CartId NOT IN (
                            SELECT ISNULL(CartId, 0) 
                            FROM Orders 
                            WHERE CartId IS NOT NULL
                        )";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        object result = cmd.ExecuteScalar();

                        if (result != null && result != DBNull.Value)
                        {
                            CartItemCount = Convert.ToInt32(result);
                        }
                    }
                }

                System.Diagnostics.Debug.WriteLine($"[Header] Panier chargé - UserId: {userId}, Items: {CartItemCount}");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[Header] Erreur LoadCartItemCount: {ex.Message}");
                CartItemCount = 0; // En cas d'erreur, afficher 0
            }
        }

        /// <summary>
        /// Gère la déconnexion de l'utilisateur
        /// </summary>
        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            // 1. Vider la session
            Session.Clear();
            Session.Abandon();

            // 2. Supprimer le cookie de session
            if (Request.Cookies["ASP.NET_SessionId"] != null)
            {
                Response.Cookies["ASP.NET_SessionId"].Value = string.Empty;
                Response.Cookies["ASP.NET_SessionId"].Expires = DateTime.Now.AddMonths(-20);
            }

            // 3. Redirection vers la page d'accueil
            Response.Redirect("~/Default.aspx");
        }
    }
}