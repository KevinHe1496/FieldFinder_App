//
//  LoginView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 8/5/25.
//


import SwiftUI

/// Se presenta como hoja (sheet) desde Perfil o desde el detalle de una cancha.
/// Al iniciar sesión, RootView cambia de estado y la hoja se cierra sola.
struct LoginView: View {

    #if DEBUG
    @State private var email = "kevin@example.com"
    @State private var password = "123456"
    #else
    // MARK: - State Properties
    @State private var email = ""
    @State private var password = ""
    #endif

    @State private var showRegisterSheet = false
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool

    @Environment(AppState.self) var appState
    @Environment(\.dismiss) private var dismiss

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

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

                        Text("Inicia sesión")
                            .font(.largeTitle.bold())
                            .foregroundStyle(.white)

                        Text("Guarda tus canchas favoritas y administra la tuya si eres dueño.")
                            .font(.callout)
                            .foregroundStyle(Color.white.opacity(0.72))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // MARK: - Formulario
                    VStack(spacing: 14) {
                        BrandTextField(
                            title: "Correo",
                            text: $email,
                            placeholder: "tu@correo.com",
                            keyboard: .emailAddress,
                            onDark: true,
                            focus: $emailFocused
                        )
                        .textContentType(.username)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.next)
                        .onSubmit { passwordFocused = true }

                        BrandSecureField(
                            title: "Contraseña",
                            text: $password,
                            onDark: true,
                            focus: $passwordFocused
                        )
                        .textContentType(.password)
                        .submitLabel(.go)
                        .onSubmit(submit)

                        BrandSubmitButton(
                            title: "Iniciar sesión",
                            isLoading: appState.isLoading,
                            isEnabled: canSubmit,
                            action: submit
                        )
                        .padding(.top, 4)
                    }

                    // MARK: - Crear cuenta
                    HStack(spacing: 4) {
                        Text("¿No tienes cuenta?")
                            .foregroundStyle(Color.white.opacity(0.72))
                        Button("Crear cuenta") { showRegisterSheet = true }
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.primaryColorGreen)
                    }
                    .font(.callout)
                    .frame(maxWidth: .infinity)
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
            .alert("No pudimos iniciar sesión", isPresented: Binding(
                get: { appState.showAlert },
                set: { appState.showAlert = $0 }
            )) {
                Button("OK") {}
            } message: {
                Text(appState.messageAlert)
            }
            .sheet(isPresented: $showRegisterSheet) {
                RegisterUserView(appState: appState)
            }
        }
    }

    private func submit() {
        guard canSubmit, !appState.isLoading else { return }
        emailFocused = false
        passwordFocused = false
        Task {
            try? await appState.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
        }
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
