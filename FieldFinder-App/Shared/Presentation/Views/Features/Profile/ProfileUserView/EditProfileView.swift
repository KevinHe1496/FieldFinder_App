//
//  EditProfileView.swift
//  FieldFinder-App
//
//  Created by Kevin Heredia on 14/5/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var viewModel = ProfileUserViewModel()
    @State private var showAlertSucess = false
    @State private var showAlertError = false
    @State private var errorMessage: String?
    
    init(currentName: String) {
        _name = State(initialValue: currentName)
    }
    
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandFormSection(title: "Tu perfil") {
                    BrandTextField(title: "Nombre", text: $name, placeholder: "Cómo te llamas")
                        .textContentType(.name)
                }

                BrandSubmitButton(title: "Guardar cambios", isLoading: isSaving,
                                  isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    isSaving = true
                    Task {
                        do {
                            try await viewModel.updateUser(name: name.trimmingCharacters(in: .whitespaces))
                            showAlertSucess = true
                        } catch {
                            errorMessage = String(localized: "Algo salió mal. Intenta más tarde.")
                            print("Error real:", error.localizedDescription)
                            showAlertError = true
                        }
                        isSaving = false
                    }
                }
            }
            .padding(16)
        }
        .background(Color.brandBackground)
        .navigationTitle("Editar perfil")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Cambios guardados", isPresented: $showAlertSucess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Tu nombre se actualizó.")
        }
        .alert("No se guardaron los cambios", isPresented: $showAlertError) {
            Button("OK") { }
        } message: {
            Text(errorMessage ?? String(localized: "No se pudo actualizar tu nombre."))
        }
    }
}

#Preview {
    EditProfileView(currentName: "Olga")
}
