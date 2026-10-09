import SwiftUI
import PhotosUI
import TipKit

struct RegisterEstablishmentView: View {
    
    @Environment(AppState.self) var appState
    @State private var viewModel: RegisterEstablismentViewModel
    
    let coverTip = CoverImageTip()
    
    
    init(appState: AppState) {
        _viewModel = State(initialValue: RegisterEstablismentViewModel(appState: appState))
    }
    
    @State private var name = ""
    @State private var info = ""
    @State private var address2: String = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var parqueadero = false
    @State private var vestidores = false
    
    
    @State private var bar = false
    @State private var banos = false
    @State private var duchas = false
    @State private var userCoordinates = CLLocationCoordinate2D()
    
    @State private var selectedImages: [Data] = []
    @State var showAlert: Bool = false
    @State var showingStore = false
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TipView(coverTip, arrowEdge: .bottom)

                    BrandFormSection(title: "Fotos", footer: "La primera foto será la portada. Hasta 12.") {
                        CustomUIImage(selectedImagesData: $selectedImages)
                    }

                    BrandFormSection(title: "Datos de la cancha") {
                        BrandTextField(title: "Nombre", text: $name, placeholder: "Ej.: Cancha Sintética La Vicentina")
                            .autocorrectionDisabled(true)
                        BrandTextField(title: "Descripción", text: $info,
                                       placeholder: "Horarios, tipo de canchas, cómo reservar…",
                                       axis: .vertical)
                        BrandTextField(title: "Teléfono o WhatsApp", text: $phone,
                                       placeholder: "099 123 4567", keyboard: .phonePad,
                                       hint: "Si es celular, los jugadores te escribirán por WhatsApp.")
                            .textContentType(.telephoneNumber)
                    }

                    BrandFormSection(title: "Ubicación", footer: "Mueve el mapa hasta que el pin quede sobre tu cancha.") {
                        BrandTextField(title: "Calle principal", text: $address, placeholder: "Av. 6 de Diciembre")
                            .autocorrectionDisabled(true)
                        BrandTextField(title: "Intersección o referencia", text: $address2, placeholder: "y Av. Colón, junto al parque")
                        LocationPickerView(coordinates: $userCoordinates)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.brandBorder, lineWidth: 1))
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

                    BrandSubmitButton(title: "Continuar", isLoading: viewModel.isLoading) {
                        Task {
                            try await viewModel.registerEstablishment(
                                name: name,
                                info: info,
                                address: address,
                                address2: address2,
                                parqueadero: parqueadero,
                                vestidores: vestidores,
                                bar: bar,
                                banos: banos,
                                duchas: duchas,
                                phone: phone,
                                images: selectedImages,
                                userCoordinates: userCoordinates
                            )
                            showAlert = true
                        }
                    }
                    .sheet(isPresented: $showingStore) {
                        StoreView()
                            .environment(appState)
                    }
                }
                .padding(16)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.brandBackground)
            .task {
                do {
                    try Tips.configure()
                } catch {
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
            .navigationTitle("Registrar mi cancha")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Aviso", isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
}

#Preview {
    
    RegisterEstablishmentView(appState: AppState())
        .environment(AppState())
        .environment(\.locale, .init(identifier: "en"))
    
}
