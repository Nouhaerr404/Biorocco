<%@ Page Title="Inscription"
    Language="C#"
    MasterPageFile="~/Site.Master"
    AutoEventWireup="true"
    CodeBehind="Register.aspx.cs"
    Inherits="Multi_cooperative.Register" %>
<%@ Register Src="~/Header.ascx" TagPrefix="uc" TagName="Header" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- HEADER -->
    <uc:Header ID="Header1" runat="server" />

    <!-- Full screen background -->
    <div class="min-h-screen flex items-center justify-center bg-cover bg-center"
         style="background-image: url('Images/bg_auth.jpg'); padding-top: 120px; padding-bottom: 80px;">

        <!-- Overlay -->
        <div class="absolute inset-0 bg-black/50"></div>

        <!-- Card -->
        <div class="relative max-w-xl mx-auto bg-white rounded-3xl shadow-2xl p-8" style="z-index: 10;">

            <!-- Title -->
            <div class="text-center mb-6">
                <h2 class="text-2xl font-semibold text-[#2D5F3F]">
                    Inscription Client
                </h2>
                <div class="mt-2 h-1 w-14 bg-[#E8967D] mx-auto rounded"></div>
            </div>

            <!-- Error message -->
            <asp:Label ID="lblError" runat="server"
                CssClass="block text-center text-sm text-red-600 bg-red-100 py-2 rounded mb-4"
                Visible="false" />

            <!-- Form -->
            <div class="space-y-4">

                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Nom complet
                    </label>
                    <asp:TextBox ID="txtFullName" runat="server"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Email
                    </label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Téléphone
                    </label>
                    <asp:TextBox ID="txtPhone" runat="server"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Mot de passe
                    </label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <div class="flex flex-col">
                    <label class="text-sm font-medium text-gray-700 mb-2">
                        Confirmer le mot de passe
                    </label>
                    <asp:TextBox ID="txtConfirmPass" runat="server" TextMode="Password"
                        CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                </div>

                <asp:Button ID="btnRegister" runat="server"
                    Text="Créer un compte"
                    OnClick="btnRegister_Click"
                    CssClass="w-full h-12 mt-4 bg-[#2D5F3F] hover:bg-[#1e422b] text-white text-base font-semibold rounded-3xl transition" />

                <!-- Lien vers connexion -->
                <div class="text-center pt-4">
                    <a href="Login.aspx"
                       class="block text-sm text-[#E8967D] hover:underline font-medium">
                        Déjà inscrit ? Se connecter
                    </a>
                </div>

            </div>
        </div>
    </div>

    <!-- FOOTER -->
    

</asp:Content>