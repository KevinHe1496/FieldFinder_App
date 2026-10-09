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

        return Form {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(establishmentName)
                        .font(.headline)
                        .foregroundStyle(.primaryColorGreen)
                    Text("Revisaremos tu solicitud y te daremos acceso para agregar fotos, canchas, precios y teléfono.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("¿Cuál es tu relación con el lugar?") {
                Picker("Relación", selection: $bindable.relationship) {
                    ForEach(ClaimRelationship.allCases) { relationship in
                        Text(relationship.displayName).tag(relationship)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            }

            Section {
                TextField("Teléfono de contacto", text: $bindable.phone)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                TextField("Cédula o RUC", text: $bindable.documentID)
                    .keyboardType(.numberPad)
                TextField("Instagram, Facebook o web (opcional)", text: $bindable.socialMedia)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                Text("Datos de contacto")
            } footer: {
                Text("Solo los usamos para verificar que eres el dueño. No se muestran en la app.")
            }

            Section {
                TextField("Ej.: Soy el dueño desde 2019, el local está a nombre de mi empresa…",
                          text: $bindable.message,
                          axis: .vertical)
                    .lineLimit(3...6)
            } header: {
                Text("¿Cómo podemos verificarlo?")
            }

            if let error = viewModel.errorMessage {
                Section {
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.subheadline)
                }
            }

            Section {
                Button {
                    Task { await viewModel.submit(establishmentID: establishmentID) }
                } label: {
                    HStack {
                        Spacer()
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Enviar solicitud")
                                .bold()
                        }
                        Spacer()
                    }
                }
                .disabled(viewModel.isSubmitting)
            }
        }
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

            CustomButtonView(title: "Listo", color: .primaryColorGreen, textColor: .white) {
                dismiss()
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ClaimEstablishmentView(establishmentID: "123", establishmentName: "Cancha Sintética La Vicentina")
}
