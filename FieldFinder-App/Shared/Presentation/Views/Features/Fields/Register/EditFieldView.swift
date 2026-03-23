//
//  EditFieldView.swift
//  FieldFinder-App
//
//  Created by Andy Heredia on 16/5/25.
//

import SwiftUI

struct EditFieldView: View {
    
    // Properties to Edit
    @State var selectedField: Field
    @State var selectedCapacidad: Capacidad
    @State var precio: String
    @State var iluminada: Bool
    @State var cubierta: Bool
    @State var canchaID: String
    @State var establecimientoID: String
    // ViewModel and dissmis
    @State var viewModel = RegisterFieldViewModel()
    @Environment(\.dismiss) var dismiss
    
    // Alert and message
    @State private var showAlert: Bool = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("Cancha")
                    Spacer()
                    Picker("Selecciona la cancha", selection: $selectedField) {
                        ForEach(Field.allCases) { cancha in
                            Text(cancha.displayName)
                                .tag(cancha)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Divider()
                HStack {
                    Text("Capacidad")
                    Spacer()
                    Picker("Selecciona modalidad", selection: $selectedCapacidad) {
                        ForEach(Capacidad.allCases) { capacidad in
                            Text(capacidad.rawValue)
                                .tag(capacidad)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Divider()
                Toggle("Iluminada", isOn: $iluminada)
                
                Divider()
                Toggle("Cubierta", isOn: $cubierta)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            //MARK: PRECIO
            HStack {
                Text("Precio por hora")
                Spacer()
                HStack {
                    Text(viewModel.localCurrencySymbol())
                        .foregroundStyle(.secondary)
                    TextField("0.00", text: $precio)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            
            CustomButtonView(title: "Guardar", color: .primaryColorGreen, textColor: .thirdColorWhite) {
                Task {
                    
                    let newModel = FieldRequest(
                        tipo: selectedField.rawValue,
                        modalidad: selectedCapacidad.rawValue,
                        precio: Double(precio) ?? 0,
                        iluminada: iluminada,
                        cubierta: cubierta,
                        establecimientoID: establecimientoID
                    )
                    
                    try await viewModel.editCancha(canchaID: canchaID, canchaModel: newModel)
                    showAlert = true
                }
                
            }
            .navigationTitle("Editar Cancha")
            .padding()
            .alert("Mensaje", isPresented: $showAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            Spacer()
            
        }
    }
}

#Preview {
    EditFieldView(selectedField: .cesped, selectedCapacidad: .siete, precio: "12", iluminada: true, cubierta: true, canchaID: "1", establecimientoID: "1")
}
