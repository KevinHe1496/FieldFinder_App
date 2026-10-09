//
//  ClaimEstablishmentView.swift
//  FieldFinder-App
//
//  Formulario para que el dueño reclame un establecimiento importado (sin dueño).
//  La solicitud la revisa un administrador antes de asignarle el establecimiento.
//

import SwiftUI

struct ClaimEstablishmentView: View {
    let establishmentID: String
    let establishmentName: String

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = ClaimEstablishmentViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.didSubmit {
                    successView
                } else {
                    form
                }
            }
            .navigationTitle("Reclamar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.didSubmit {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { dismiss() }
                    }
                }
            }
        }
    }

    private var form: some View {
        @Bindable var bindable = viewModel

        return ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(establishmentName)
                        .font(.system(size: 22, weight: .heavy))
                        .foregroundStyle(Color.brandInk)
                    Text("Revisaremos tu solicitud y te daremos acceso para agregar fotos, canchas, precios y teléfono.")
                        .font(.system(size: 15))
                        .foregroundStyle(Color.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                BrandFormSection(title: "¿Cuál es tu relación con el lugar?") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(ClaimRelationship.allCases) { relationship in
                            BrandFilterChip(title: relationship.displayName,
                                            isSelected: viewModel.relationship == relationship) {
                                viewModel.relationship = relationship
                            }
                        }
                    }
                }

                BrandFormSection(title: "Datos de contacto",
                                 footer: "Solo los usamos para verificar que eres el dueño. No se muestran en la app.") {
                    BrandTextField(title: "Teléfono de contacto", text: $bindable.phone,
                                   placeholder: "099 123 4567", keyboard: .phonePad)
                        .textContentType(.telephoneNumber)
                    BrandTextField(title: "Cédula o RUC", text: $bindable.documentID,
                                   placeholder: "1712345678", keyboard: .numberPad)
                    BrandTextField(title: "Redes sociales o web (opcional)", text: $bindable.socialMedia,
                                   placeholder: "instagram.com/tucancha")
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                BrandFormSection(title: "¿Cómo podemos verificarlo?") {
                    BrandTextField(title: "Mensaje", text: $bindable.message,
                                   placeholder: "Ej.: Soy el dueño desde 2019, el local está a nombre de mi empresa…",
                                   axis: .vertical)
                }

                if let error = viewModel.errorMessage {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }

                BrandSubmitButton(title: "Enviar solicitud", isLoading: viewModel.isSubmitting) {
                    Task { await viewModel.submit(establishmentID: establishmentID) }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBackground)
    }

    private var successView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.primaryColorGreen)

            Text("¡Solicitud enviada!")
                .font(.title2.bold())

            Text("Vamos a revisar tus datos. Puedes ver el estado en Perfil > Mis solicitudes.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Spacer()

            Button("Listo") { dismiss() }
                .buttonStyle(BrandPrimaryButtonStyle())
                .padding(.horizontal)
        }
        .padding()
        .task {
            // Momento con contexto para pedir notificaciones (antes se pedía al abrir la app).
            try? await Task.sleep(for: .seconds(1))
            await PushPermission.requestIfNeeded()
        }
    }
}

#Preview {
    ClaimEstablishmentView(establishmentID: "123", establishmentName: "Cancha Sintética La Vicentina")
}
