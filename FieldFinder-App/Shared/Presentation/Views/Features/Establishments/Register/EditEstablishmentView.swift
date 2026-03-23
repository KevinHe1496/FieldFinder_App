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
  
    
    var body: some View {
        Form {
            Section {
                TextField("Nombre", text: $name)
                TextField("información", text: $info)
                
                TextField("Calle", text: $address)
                TextField("Calle 2", text: $address2)
                TextField("Teléfono", text: $phone)
        
                Toggle("Parqueadero", isOn: $parqueadero)
                Toggle("Vestidores", isOn: $vestidores)
                Toggle("Bar", isOn: $bar)
                Toggle("Baños", isOn: $banos)
                Toggle("Duchas", isOn: $duchas)
            } header: {
                Text("Información")
            }

            
            Section {
                Button("Guardar cambios") {
                    
                    Task {
                        try await viewModel.editEstablishment(
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
                        showAlert = true
                    }
                    
                  
                }
               
            }
        }
        .alert("Mensaje", isPresented: $showAlert) {
           
            
            Button("OK") {
               
                dismiss()
            }
        } message: {
            Text("Se ha editado exitosamente")
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
