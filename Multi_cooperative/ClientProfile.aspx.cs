using System;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using Multi_cooperative.Database;

namespace Multi_cooperative
{
    public partial class ClientProfile : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("Login.aspx?ReturnUrl=" + HttpUtility.UrlEncode(Request.RawUrl));
                return;
            }

            if (!IsPostBack)
            {
                // La page se charge, le JavaScript gérera les appels AJAX
            }
        }
    }
}
