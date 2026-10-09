//
//  EditProfileEstablishmentView.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 16/5/25.
//

import SwiftUI

struct EditEstablishmentView: View {
    
    @State var name: String
    @State var info: String
    @State var address2: String
    @State var address: String
    @State var phone: String
    @State var establishmentID: String
    
    @State var parqueadero: Bool
    @State var vestidores: Bool
    @State var bar: Bool
    @State var banos: Bool
    @State var duchas: Bool
    
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: RegisterEstablismentViewModel
     
    init(
        name: String,
        info: String,
        address2: String?,
        address: String,
        phone: String,
        establishmentID: String,
        parqueadero: Bool,
        vestidores: Bool,
        bar: Bool,
        banos: Bool,
        duchas: Bool,
        appState: AppState
    ) {
        
        _viewModel = State(initialValue: RegisterEstablismentViewModel(appState: appState))
        
        self.name = name
        self.info = info
        self.address2 = address2 ?? ""
        self.address = address
        self.phone = phone
        self.establishmentID = establishmentID
        self.parqueadero = parqueadero
        self.vestidores = vestidores
        self.bar = bar
        self.banos = banos
        self.duchas = duchas
    }
    
    @State private var showAlert = false
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandFormSection(title: "Datos de la cancha") {
                    BrandTextField(title: "Nombre", text: $name)
                        .autocorrectionDisabled(true)
                    BrandTextField(title: "Descripción", text: $info,
                                   placeholder: "Horarios, tipo de canchas, cómo reservar…",
                                   axis: .vertical)
                    BrandTextField(title: "Teléfono o WhatsApp", text: $phone,
                                   placeholder: "099 123 4567", keyboard: .phonePad,
                                   hint: "Si es celular, los jugadores te escribirán por WhatsApp.")
                        .textContentType(.telephoneNumber)
                }

                BrandFormSection(title: "Ubicación") {
                    BrandTextField(title: "Calle principal", text: $address)
                        .autocorrectionDisabled(true)
                    BrandTextField(title: "Intersección o referencia", text: $address2)
                }

                BrandFormSection(title: "Servicios") {
                    VStack(spacing: 4) {
                        BrandToggleRow(title: "Parqueadero", systemImage: "car.fill", isOn: $parqueadero)
                        BrandToggleRow(title: "Vestidores", systemImage: "tshirt.fill", isOn: $vestidores)
                        BrandToggleRow(title: "Baños", systemImage: "toilet.fill", isOn: $banos)
                        BrandToggleRow(title: "Duchas", systemImage: "shower.fill", isOn: $duchas)
                        BrandToggleRow(title: "Bar", systemImage: "cup.and.saucer.fill", isOn: $bar)
                    }
                }

                BrandSubmitButton(title: "Guardar cambios", isLoading: isSaving,
                                  isEnabled: !name.trimmingCharacters(in: .whitespaces).isEmpty) {
                    isSaving = true
                    Task {
                        try? await viewModel.editEstablishment(
                            establishmentID: establishmentID,
                            name: name,
                            info: info,
                            address: address,
                            address2: address2,
                            parqueadero: parqueadero,
                            vestidores: vestidores,
                            bar: bar,
                            banos: banos,
                            duchas: duchas,
                            phone: phone
                        )
                        isSaving = false
                        showAlert = true
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBackground)
        .navigationTitle("Editar mi cancha")
        .navigationBarTitleDisplayMode(.inline)
        .alert(viewModel.didSaveEdit ? Text("Cambios guardados") : Text("No se guardaron los cambios"), isPresented: $showAlert) {
            Button("OK") {
                if viewModel.didSaveEdit { dismiss() }
            }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }
}

#Preview {
    EditEstablishmentView(
        name: "",
        info: "",
        address2: "",
        address: "",
        phone: "",
        establishmentID: "",
        parqueadero: false,
        vestidores: false,
        bar: false,
        banos: false,
        duchas: false,
        appState: AppState()
    )
        .environment(AppState())
        .environment(\.locale, .init(identifier: "en"))
}
