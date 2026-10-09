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
    @FocusState private var nameFocused: Bool
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

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
                        BrandTextField(
                            title: "Nombre",
                            text: $name,
                            placeholder: "Cómo te llamas",
                            onDark: true,
                            focus: $nameFocused
                        )
                        .textContentType(.name)
                        .autocorrectionDisabled(true)
                        .submitLabel(.next)
                        .onSubmit { emailFocused = true }

                        BrandTextField(
                            title: "Correo",
                            text: $email,
                            placeholder: "tu@correo.com",
                            keyboard: .emailAddress,
                            onDark: true,
                            focus: $emailFocused
                        )
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .submitLabel(.next)
                        .onSubmit { passwordFocused = true }

                        VStack(alignment: .leading, spacing: 6) {
                            BrandSecureField(
                                title: "Contraseña",
                                text: $password,
                                onDark: true,
                                focus: $passwordFocused
                            )
                            .textContentType(.newPassword)
                            .submitLabel(.done)

                            Label("Mínimo 6 caracteres", systemImage: password.count >= 6 ? "checkmark.circle.fill" : "circle")
                                .font(.footnote)
                                .foregroundStyle(password.count >= 6 ? Color.primaryColorGreen : Color.white.opacity(0.6))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            BrandFieldLabel(title: "¿Cómo usarás la app?", onDark: true)
                            HStack(spacing: 8) {
                                ForEach(UserRole.allCases) { role in
                                    BrandFilterChip(title: role == .jugador ? String(localized: "Quiero jugar") : String(localized: "Tengo una cancha"),
                                                    isSelected: selectedRole == role) {
                                        selectedRole = role
                                    }
                                }
                            }
                        }

                        BrandSubmitButton(title: "Crear cuenta", isLoading: isLoading, action: submit)
                            .padding(.top, 4)
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
        nameFocused = false
        emailFocused = false
        passwordFocused = false
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
