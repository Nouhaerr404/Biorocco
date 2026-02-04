using System;
using System.Web;
using System.Web.UI;

namespace Multi_cooperative
{
    public partial class AdminLogin : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Redirection vers le formulaire de connexion unifié
            Response.Redirect("Login.aspx");
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // Cette méthode n'est plus utilisée
            // La redirection vers Login.aspx se fait dans Page_Load
        }
    }
}

