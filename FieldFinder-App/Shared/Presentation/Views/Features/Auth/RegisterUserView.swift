//
//  LoginView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

struct RegisterUserView: View {
    
    // MARK: - State Properties
    
    @Environment(AppState.self) var appState
    @State private var viewModel: UserAuthViewModel
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole: UserRole = .jugador
    @State private var isLoading = false

    
    init(appState: AppState) {
        _viewModel = State(initialValue: UserAuthViewModel(appState: appState))
    }
    
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
                            
                            // Name input field
                            
                            CustomTextFieldLogin(
                                titleKey: "Nombre",
                                textField: $name,
                                keyboardType: .default,
                                prompt: Text("Nombre"),
                                colorBackground: .thirdColorWhite
                            )
                            .autocorrectionDisabled(true)
                            
                            // Email input field
                            CustomTextFieldLogin(
                                titleKey: "Email",
                                textField: $email,
                                keyboardType: .emailAddress,
                                prompt: Text("Email"),
                                colorBackground: .thirdColorWhite
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            
                            // Password input field
                            CustomSecureFieldView(titleKey: "Contraseña", textField: $password, keyboardType: .default, prompt: Text("Contraseña"))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                            
                            // Rol
                            HStack {
                                Text("Selecciona tu rol:")
                                    .font(.appDescription)
                                Spacer()
                                Picker("Selecciona tu rol", selection: $selectedRole) {
                                    ForEach(UserRole.allCases) { role in
                                        Text(role.displayName)
                                            .tag(role)
                                    }
                                    
                                }
                                .pickerStyle(.menu)
                                .frame(width: 130)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: 55)
                            .background(.thirdColorWhite)
                            .clipShape(.buttonBorder)
                            
                            // Sign in button
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.thirdColorWhite)
                                    .foregroundStyle(.secondaryColorBlack)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                CustomButtonView(title: "Registrar", color: .primaryColorGreen, textColor: .white) {
                                    isLoading = true
                                    Task {
                                        let error = await viewModel.registerUser(
                                            name: name,
                                            email: email,
                                            password: password,
                                            rol: selectedRole.rawValue.lowercased()
                                        )
                                        
                                        isLoading = false

                                        if let error = error {
                                            print("Error al registrar: \(error)")
                                        } else {
                                            print("Registro exitoso")
                                        }
                                    }
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text("CREA TU CUENTA")
                                .font(.appTitle)
                                .foregroundStyle(.primaryColorGreen)
                            Spacer()
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .alert("Mensaje", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.message ?? "")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondaryColorBlack)
        }
    }
}

#Preview {
    RegisterUserView(appState: AppState())
        .environment(AppState())
}
