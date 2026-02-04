using System;

namespace Multi_cooperative
{
    public partial class OrderSuccess : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string id = Request.QueryString["orderId"];
                if (!string.IsNullOrEmpty(id))
                {
                    lblOrderNumber.Text = id;
                }
                else
                {
                    Response.Redirect("Default.aspx");
                }
            }
        }
    }
}