<%@ Page Title="Réinitialiser le mot de passe" Language="C#" MasterPageFile="~/Site.Master"
    AutoEventWireup="true" CodeBehind="ResetPassword.aspx.cs"
    Inherits="Multi_cooperative.ResetPassword" %>
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
                    Réinitialiser le mot de passe
                </h2>
                <div class="mt-2 h-1 w-14 bg-[#E8967D] mx-auto rounded"></div>
            </div>

            <!-- Error -->
            <asp:Label ID="lblError" runat="server"
                CssClass="block text-center text-sm text-red-600 bg-red-100 py-2 px-4 rounded-lg mb-6"
                Visible="false" />

            <!-- Form -->
            <asp:Panel ID="pnlResetForm" runat="server" Visible="true">
                <div class="space-y-4">
                    <!-- New Password -->
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-2">
                            Nouveau mot de passe
                        </label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                            CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                        <asp:RequiredFieldValidator ID="rfvNewPassword" runat="server"
                            ControlToValidate="txtNewPassword"
                            ErrorMessage="Le mot de passe est requis."
                            CssClass="text-red-600 text-sm mt-1"
                            Display="Dynamic" />
                    </div>

                    <!-- Confirm Password -->
                    <div class="flex flex-col">
                        <label class="text-sm font-medium text-gray-700 mb-2">
                            Confirmer le mot de passe
                        </label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                            CssClass="w-full h-11 px-4 text-base border border-gray-300 rounded-3xl focus:ring-2 focus:ring-[#2D5F3F] focus:outline-none" />
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ErrorMessage="La confirmation du mot de passe est requise."
                            CssClass="text-red-600 text-sm mt-1"
                            Display="Dynamic" />
                        <asp:CompareValidator ID="cvPasswords" runat="server"
                            ControlToValidate="txtConfirmPassword"
                            ControlToCompare="txtNewPassword"
                            Operator="Equal"
                            ErrorMessage="Les mots de passe ne correspondent pas."
                            CssClass="text-red-600 text-sm mt-1"
                            Display="Dynamic" />
                    </div>

                    <!-- Button -->
                    <asp:Button ID="btnResetPassword" runat="server"
                        Text="Réinitialiser le mot de passe"
                        OnClick="btnResetPassword_Click"
                        CssClass="w-full h-12 mt-4 bg-[#2D5F3F] hover:bg-[#1e422b] text-white text-base font-semibold rounded-3xl transition" />

                    <!-- Links -->
                    <div class="text-center space-y-3 pt-4">
                        <a href="Login.aspx"
                           class="block text-sm text-[#E8967D] hover:underline font-medium">
                            ← Retour à la connexion
                        </a>
                    </div>
                </div>
            </asp:Panel>

            <!-- Success Message -->
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" class="text-center">
                <div class="mb-6">
                    <div class="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#10b981" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="20 6 9 17 4 12"></polyline>
                        </svg>
                    </div>
                    <h3 class="text-xl font-semibold text-gray-800 mb-2">Mot de passe réinitialisé avec succès !</h3>
                    <p class="text-gray-600 mb-6">Vous pouvez maintenant vous connecter avec votre nouveau mot de passe.</p>
                    <a href="Login.aspx" 
                       class="inline-block bg-[#2D5F3F] hover:bg-[#1e422b] text-white font-semibold px-6 py-3 rounded-3xl transition">
                        Se connecter
                    </a>
                </div>
            </asp:Panel>

        </div>
    </div>

</asp:Content>

