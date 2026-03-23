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
            Text("REGISTRAR CANCHA")
                .font(.appTitle)
                .foregroundStyle(.primaryColorGreen)
            
            VStack(alignment: .leading, spacing: 16) {
                
                TipView(coverTip, arrowEdge: .bottom)
                CustomUIImage(selectedImagesData: $selectedImages)
                
                VStack {
                    HStack {
                        Text("Cancha")
                        Spacer()
                        Picker("Selecciona la cancha", selection: $selectedField) {
                            ForEach(Field.allCases) { cancha in
                                Text(cancha.displayName).tag(cancha)
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
                                Text(capacidad.rawValue).tag(capacidad)
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
                
                // MARK: PRECIO
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryColorGreen)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    CustomButtonView(title: "Registrar", color: .primaryColorGreen, textColor: .white) {
                        Task {
                            let newModel = FieldRequest(
                                tipo: selectedField.rawValue,
                                modalidad: selectedCapacidad.rawValue,
                                precio: Double(precio) ?? 0,
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
            }
            .task {
                do {
                    try Tips.configure()
                } catch {
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
            .padding()
            .alert("Mensaje", isPresented: $showAlert) {
                if viewModel.shouldDismissAfterAlert {
                    Button("OK") { dismiss() }
                }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
}

#Preview {
    RegisterFieldView(establecimientoID: "", viewModel: RegisterFieldViewModel())
        .environment(AppState())
}
