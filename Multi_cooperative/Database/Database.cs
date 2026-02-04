using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Multi_cooperative.Database
{
    public class Database
    {
        private static readonly string connectionString = "Data Source=localhost\\SQLEXPRESS;Initial Catalog=AppEcommerce;Integrated Security=SSPI;TrustServerCertificate=True;";
        public static SqlConnection GetConnection()
        {
            return new SqlConnection(connectionString);
        }

        public static string GetConnectionString()
        {
            return connectionString;
        }
    }
}