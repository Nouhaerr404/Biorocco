<%@ Page Title="Connexion" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="Login.aspx.cs"
    Inherits="Multi_cooperative.Login" %>
<%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- HEADER -->
    <uc:Header ID="Header1" runat="server" />

    <!-- Background -->
    <div class="relative min-h-screen flex items-center justify-center bg-cover bg-center"
         style="background-image: url('Images/bg_auth.jpg'); padding-top: 120px; padding-bottom: 80px;">

       <!-- Overlay -->
       <div class="absolute inset-0 bg-black/50"></div>

       <!-- Card -->
       <div class="relative max-w-xl mx-auto bg-white rounded-3xl shadow-2xl p-8" style="z-index: 10;">

            <!-- Title -->
            <div class="text-center mb-8">
                <h2 class="text-3xl font-serif text-[#2D5F3F]">
                    Connexion
                </h2>
                <div class="mt-2 h-1 w-14 bg-[#E8967D] mx-auto rounded"></div>
            </div>

            <!-- Error -->
            <asp:Label ID="lblError" runat="server"
                CssClass="block text-center text-sm text-red-600 bg-red-100 py-2 rounded mb-6"
                Visible="false" />

            <!-- Form -->
            <div class="space-y-4">

                <!-- Email -->
                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Email
                    </label>
                    <asp:TextBox ID="txtEmail" runat="server"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <!-- Password -->
                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Mot de passe
                    </label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <!-- Button -->
                <asp:Button ID="btnLogin" runat="server"
                    Text="Se connecter"
                    OnClick="btnLogin_Click"
                    CssClass="w-full h-12 mt-4 bg-[#2D5F3F] hover:bg-[#1e422b] text-white text-base font-semibold rounded-3xl transition" />

                <!-- Links -->
                <div class="text-center space-y-3 pt-4">
                    <a href="Register.aspx"
                       class="block text-sm text-[#E8967D] hover:underline font-medium">
                        Créer un compte
                    </a>
                    <a href="ForgotPassword.aspx"
                       class="block text-sm text-[#E8967D] hover:underline font-medium">
                        Mot de passe oublié ?
                    </a>
                </div>

            </div>
        </div>
    </div>

   

</asp:Content>