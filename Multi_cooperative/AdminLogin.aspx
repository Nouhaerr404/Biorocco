<%@ Page Title="Connexion Admin - BIOROCCO" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminLogin.aspx.cs" Inherits="Multi_cooperative.AdminLogin" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="min-h-screen bg-[#F5F1E8] flex items-center justify-center px-4">
        <div class="max-w-md w-full">
            <div class="text-center mb-8">
                <h1 class="text-4xl text-[#2D5F3F] mb-2">BIOROCCO</h1>
                <p class="text-gray-600">Administration</p>
            </div>

            <div class="bg-white rounded-lg shadow-lg p-8">
                <h2 class="text-2xl text-[#2D5F3F] mb-6 text-center">Connexion</h2>
                
                <form id="loginForm" >
                    <div class="space-y-6">
                        <div>
                            <label class="block text-gray-700 mb-2">Email</label>
                            <div class="relative">
                                <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
                                </svg>
                                <asp:TextBox ID="txtEmail" runat="server" 
                                    CssClass="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D] focus:border-transparent" 
                                    placeholder="admin@biorocco.com" 
                                    TextMode="Email" />
                            </div>
                        </div>

                        <div>
                            <label class="block text-gray-700 mb-2">Mot de passe</label>
                            <div class="relative">
                                <svg class="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                                </svg>
                                <asp:TextBox ID="txtPassword" runat="server" 
                                    CssClass="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-[#E8967D] focus:border-transparent" 
                                    placeholder="••••••••" 
                                    TextMode="Password" />
                            </div>
                        </div>

                        <asp:Button ID="btnLogin" runat="server" 
                            Text="Se connecter" 
                            CssClass="w-full py-3 bg-[#E8967D] text-white rounded-lg hover:bg-[#d67e6a] transition-colors" 
                            OnClick="btnLogin_Click" />
                    </div>
                </form>

                <div class="mt-6 text-center">
                    <p class="text-sm text-gray-500">
                        Démo: utilisez n'importe quel email et mot de passe
                    </p>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

