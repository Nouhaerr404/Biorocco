using System;
using System.Web.Services;
using System.Net.Http;
using System.Text;
using Newtonsoft.Json;

namespace Multi_cooperative
{
    /// <summary>
    /// Service Web pour le Chatbot Assistant Virtuel
    /// Connecté à n8n webhook pour les réponses IA
    /// </summary>
    [WebService(Namespace = "http://tempuri.org/")]
    [WebServiceBinding(ConformsTo = WsiProfiles.BasicProfile1_1)]
    [System.ComponentModel.ToolboxItem(false)]
    [System.Web.Script.Services.ScriptService]
    public class ChatbotService : System.Web.Services.WebService
    {
        /// <summary>
        /// Obtient une réponse du chatbot via n8n webhook
        /// </summary>
        /// <param name="message">Message de l'utilisateur</param>
        /// <returns>Réponse du bot</returns>
        [WebMethod]
        [System.Web.Script.Services.ScriptMethod(ResponseFormat = System.Web.Script.Services.ResponseFormat.Json)]
        public string GetBotResponse(string message)
        {
            using (var client = new HttpClient())
            {
                // Crée le corps de la requête
                var body = new
                {
                    message = message
                };

                var content = new StringContent(
                    JsonConvert.SerializeObject(body),
                    Encoding.UTF8,
                    "application/json"
                );

                // ✅ URL Webhook n8n - Mode Production
                var response = client.PostAsync(
                    "https://jihanelhamdaoui.app.n8n.cloud/webhook/chatbot1",
                    content
                ).Result;

                if (!response.IsSuccessStatusCode)
                {
                    // Gestion d'erreur simple
                    return $"Erreur : {response.StatusCode}";
                }

                // Lit le JSON renvoyé par n8n
                var jsonResponse = response.Content.ReadAsStringAsync().Result;
                
                if (string.IsNullOrWhiteSpace(jsonResponse))
                {
                    return "Erreur : La réponse de n8n est vide.";
                }

                // Utilisation de JObject pour éviter les erreurs de binding dynamique sur null
                try 
                {
                    // Tente de parser. Si n8n renvoie juste du texte (pas un JSON), ça ira dans le catch
                    var result = Newtonsoft.Json.Linq.JObject.Parse(jsonResponse);
                    
                    // Vérifie si la propriété 'response' existe
                    if (result["response"] != null)
                    {
                        return result["response"].ToString();
                    }
                    // Parfois n8n renvoie 'output' ou une autre structure
                    else if (result["output"] != null)
                    {
                         return result["output"].ToString();
                    }
                    
                    // Si on ne trouve pas la clé, on renvoie une erreur plus claire avec le contenu brut
                    return "Réponse inattendue de n8n (JSON valide mais pas de clé 'response') : " + jsonResponse;
                }
                catch (Exception ex)
                {
                    // Si ce n'est pas du JSON, on affiche le texte brut reçu
                    return "Erreur lecture JSON (" + ex.Message + "). Contenu reçu : " + jsonResponse;
                }
            }
        }
    }
}
