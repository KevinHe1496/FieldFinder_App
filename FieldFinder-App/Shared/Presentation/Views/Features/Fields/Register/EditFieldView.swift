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
    
    @State private var isSaving = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BrandFormSection(title: "Cancha") {
                    BrandChoiceField(title: "Tipo de césped", options: Field.allCases,
                                     selection: $selectedField) { $0.displayName }
                    BrandChoiceField(title: "Tamaño", options: Capacidad.allCases,
                                     selection: $selectedCapacidad) { $0.displayName }
                    VStack(spacing: 4) {
                        BrandToggleRow(title: "Iluminada", systemImage: "lightbulb.fill", isOn: $iluminada)
                        BrandToggleRow(title: "Cubierta", systemImage: "house.fill", isOn: $cubierta)
                    }
                }

                BrandFormSection(title: "Precio") {
                    BrandPriceField(title: "Precio por hora", text: $precio,
                                    currencySymbol: viewModel.localCurrencySymbol())
                }

                BrandSubmitButton(title: "Guardar cambios", isLoading: isSaving) {
                    isSaving = true
                    Task {
                        let newModel = FieldRequest(
                            tipo: selectedField.rawValue,
                            modalidad: selectedCapacidad.rawValue,
                            precio: Double(precio.replacingOccurrences(of: ",", with: ".")) ?? 0,
                            iluminada: iluminada,
                            cubierta: cubierta,
                            establecimientoID: establecimientoID
                        )

                        try? await viewModel.editCancha(canchaID: canchaID, canchaModel: newModel)
                        isSaving = false
                        showAlert = true
                    }
                }
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBackground)
        .navigationTitle("Editar cancha")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Aviso", isPresented: $showAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(viewModel.alertMessage ?? "")
        }
    }
}

#Preview {
    EditFieldView(selectedField: .cesped, selectedCapacidad: .siete, precio: "12", iluminada: true, cubierta: true, canchaID: "1", establecimientoID: "1")
}
