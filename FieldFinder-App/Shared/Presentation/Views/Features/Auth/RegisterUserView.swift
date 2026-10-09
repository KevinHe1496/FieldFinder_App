//
//  RegisterUserView.swift
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
    
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?

    private enum Field { case name, email, password }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Encabezado
                    VStack(alignment: .leading, spacing: 14) {
                        Image(.splashLogo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 72, height: 72)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .accessibilityHidden(true)

                        Text("Crea tu cuenta")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)
                    }

                    // MARK: - Formulario
                    VStack(spacing: 14) {
                        CustomTextFieldLogin(
                            titleKey: "Nombre",
                            textField: $name,
                            keyboardType: .default,
                            prompt: Text("Nombre"),
                            colorBackground: .thirdColorWhite
                        )
                        .textContentType(.name)
                        .autocorrectionDisabled(true)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .name)
                        .onSubmit { focusedField = .email }

                        CustomTextFieldLogin(
                            titleKey: "Email",
                            textField: $email,
                            keyboardType: .emailAddress,
                            prompt: Text("Email"),
                            colorBackground: .thirdColorWhite
                        )
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = .password }

                        VStack(alignment: .leading, spacing: 6) {
                            CustomSecureFieldView(titleKey: "Contraseña", textField: $password, keyboardType: .default, prompt: Text("Contraseña"))
                                .textContentType(.newPassword)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .submitLabel(.done)
                                .focused($focusedField, equals: .password)

                            Label("Mínimo 6 caracteres", systemImage: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                .font(.footnote)
                                .foregroundStyle(password.count >= 6 ? Color.primaryColorGreen : Color.white.opacity(0.6))
                        }

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

                        Button(action: submit) {
                            if isLoading {
                                ProgressView()
                                    .tint(Color.secondaryColorBlack)
                            } else {
                                Text("Crear cuenta")
                            }
                        }
                        .buttonStyle(BrandPrimaryButtonStyle())
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondaryColorBlack)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel(Text("Cerrar"))
                }
            }
            .toolbarBackground(Color.secondaryColorBlack, for: .navigationBar)
            .alert("Revisa tus datos", isPresented: $viewModel.showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.message ?? "")
            }
        }
    }

    private func submit() {
        guard !isLoading else { return }
        focusedField = nil
        isLoading = true
        Task {
            // Si falla, el view model muestra la alerta con el motivo.
            _ = await viewModel.registerUser(
                name: name.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                password: password,
                rol: selectedRole.rawValue.lowercased()
            )
            isLoading = false
        }
    }
}

#Preview {
    RegisterUserView(appState: AppState())
        .environment(AppState())
}
