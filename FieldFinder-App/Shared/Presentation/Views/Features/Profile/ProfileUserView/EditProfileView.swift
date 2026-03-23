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
    
    var body: some View {
        Form {
            Section(header: Text("Nombre")) {
                TextField("Tu nombre", text: $name)
            }
            
            Section {
                Button("Guardar cambios") {
                    Task {
                        do {
                            try await viewModel.updateUser(name: name)
                            showAlertSucess = true
                        } catch {
                            errorMessage = "Algo salió mal. Intenta más tarde."
                            print("Error real:", error.localizedDescription)
                            showAlertError = true
                        }
                    }
                }
                .disabled(name.isEmpty)
            }
        }
        .navigationTitle("Editar perfil")
        .alert("Editar mi perfil", isPresented: $showAlertSucess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Nombre de usuario cambiado exitosamente.")
        }
        
        .alert("Error Editar mi perfil", isPresented: $showAlertError) {
            Button("OK") {
                
            }
        } message: {
            Text(errorMessage ?? "No se pudo actualizar tu nombre de usuario.")
        }
    }
}

#Preview {
    EditProfileView(currentName: "Olga")
}
