//
//  LoginView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

struct LoginView: View {

    #if DEBUG
    @State private var email = "kevin@example.com"
    @State private var password = "123456"
    #else
    // MARK: - State Properties
    @State private var email = ""
    @State private var password = ""
    #endif
    
    @Environment(AppState.self) var appState
    
    var body: some View {
        NavigationStack {
            
            VStack {
                VStack {
                    // MARK: - Logo Image
                    Image(.splashLogo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                    
               
                    // MARK: - Login Form Section
                    Section {
                        VStack(spacing: 15) {
                            // Email input field
                            CustomTextFieldLogin(
                                titleKey: "Email",
                                textField: $email,
                                keyboardType: .emailAddress,
                                prompt: Text("Email"),
                                colorBackground: .thirdColorWhite
                            )
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            
                            // Password input field
                            CustomSecureFieldView(titleKey: "Contraseña", textField: $password, keyboardType: .default, prompt: Text("Contraseña"))
                                
                            
                           //  Sign in button
                            
                            if appState.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.thirdColorWhite)
                                    .foregroundStyle(.secondaryColorBlack)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                CustomButtonView(title: "Iniciar Sesión", color: .primaryColorGreen, textColor: .white) {
                                    Task {
                                        try await appState.login(email:email, password: password)
                                    }
                                   
                                }
                            }
                            
                        }
                        
                    } header: {
                        HStack {
                            Text("INICIA SESIÓN")
                                .font(.appTitle)
                                .foregroundStyle(.primaryColorGreen)
                            Spacer()
                        }
                        
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondaryColorBlack)
            .alert("Mensaje", isPresented: Binding(
                get: { appState.showAlert },
                set: { appState.showAlert = $0 }
            )) {
                Button("OK") {}
            } message: {
                Text(appState.messageAlert)
            }
            
            
        }
        
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
