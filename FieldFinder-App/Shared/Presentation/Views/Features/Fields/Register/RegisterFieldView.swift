//
//  RegisterFieldView.swift
//  FieldFinder-App
//

import SwiftUI
import PhotosUI
import TipKit
import StoreKit

struct RegisterFieldView: View {
    @Environment(AppState.self) var appState

    @State private var selectedField: Field = .cesped
    @State private var selectedCapacidad: Capacidad = .cinco
    @State private var precio = ""
    @State private var iluminada = false
    @State private var cubierta = false
    @State private var selectedImages: [Data] = []
    let coverTip = CoverImageTip()
    let establecimientoID: String

    @State private var shouldDismissAfterAlert = false
    let localCurrency = Locale.current.currency?.identifier ?? "USD"
    
    @Environment(\.dismiss) var dismiss
    @State var viewModel = RegisterFieldViewModel()
    @State var showAlert: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Agregar cancha")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(Color.brandInk)

                TipView(coverTip, arrowEdge: .bottom)

                BrandFormSection(title: "Fotos", footer: "Sube al menos una foto de esta cancha.") {
                    CustomUIImage(selectedImagesData: $selectedImages)
                }

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

                BrandSubmitButton(title: "Guardar cancha", isLoading: viewModel.isLoading) {
                    Task {
                        let newModel = FieldRequest(
                            tipo: selectedField.rawValue,
                            modalidad: selectedCapacidad.rawValue,
                            precio: Double(precio.replacingOccurrences(of: ",", with: ".")) ?? 0,
                            iluminada: iluminada,
                            cubierta: cubierta,
                            establecimientoID: establecimientoID
                        )

                        await viewModel.registerCancha(
                            newModel,
                            images: selectedImages,
                            establishmentID: establecimientoID
                        )

                        showAlert = true
                    }
                }
            }
            .padding(16)
            .task {
                do {
                    try Tips.configure()
                } catch {
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
            .alert("Aviso", isPresented: $showAlert) {
                if viewModel.shouldDismissAfterAlert {
                    Button("OK") { dismiss() }
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.brandBackground)
    }
}

#Preview {
    RegisterFieldView(establecimientoID: "", viewModel: RegisterFieldViewModel())
        .environment(AppState())
}
