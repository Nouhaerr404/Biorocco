using System;
using System.Web;
using System.Web.UI;

namespace Multi_cooperative
{
    public partial class AdminDashboard : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in and has Admin role
            if (Session["UserId"] == null || Session["UserRole"] == null || Session["UserRole"].ToString().ToLower() != "admin")
            {
                Response.Redirect("Login.aspx?ReturnUrl=" + HttpUtility.UrlEncode(Request.RawUrl));
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session["UserId"] = null;
            Session["UserEmail"] = null;
            Session["UserName"] = null;
            Session["UserRole"] = null;
            Session["AdminLoggedIn"] = null;
            Session.Abandon();
            Response.Redirect("Default.aspx");
        }
    }
}

