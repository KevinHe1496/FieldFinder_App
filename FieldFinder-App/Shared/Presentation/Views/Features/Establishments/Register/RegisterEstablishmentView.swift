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
                    CustomUIImage(selectedImagesData: $selectedImages)
                        .padding(.bottom,8)
                    
                    //MARK: - Register Form
                    
                    CustomTextFieldLogin(titleKey: "Nombre", textField: $name, keyboardType: .default, prompt: Text("Nombre"), colorBackground: Color(.secondarySystemBackground))
                        .autocorrectionDisabled(true)
                    
                    CustomTextFieldLogin(titleKey: "Información", textField: $info, keyboardType: .default, prompt: Text("Información"), colorBackground: Color(.secondarySystemBackground))
                        
                    
                    CustomTextFieldLogin(titleKey: "Calle", textField: $address, keyboardType: .default, prompt: Text("Calle"), colorBackground: Color(.secondarySystemBackground))
                        .autocorrectionDisabled(true)
                    
                    CustomTextFieldLogin(titleKey: "Calle 2", textField: $address2, keyboardType: .default, prompt: Text("Calle 2"), colorBackground: Color(.secondarySystemBackground))
                    
                    CustomTextFieldLogin(titleKey: "Teléfono", textField: $phone, keyboardType: .phonePad, prompt: Text("Teléfono"), colorBackground: Color(.secondarySystemBackground))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Pon la ubicación del establecimiento")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        
                        LocationPickerView(coordinates: $userCoordinates)
                            .frame(height: 400)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    
                    VStack {
                        
                        Toggle("Parqueadero", isOn: $parqueadero)
                        Divider()
                        Toggle("Vestidores", isOn: $vestidores)
                        
                        Divider()
                        Toggle("Bar", isOn: $bar)
                        
                        Divider()
                        Toggle("Baños", isOn: $banos)
                        
                        Divider()
                        Toggle("Duchas", isOn: $duchas)
                        
                        
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
                        CustomButtonView(title: "Continuar", color: .primaryColorGreen, textColor: .white) {
                            
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
                    
                }
                .padding()
                
            }
            .task {
                // Configure and load your tips at app launch.
                do {
                    try Tips.configure()
                }
                catch {
                    // Handle TipKit errors
                    print("Error initializing TipKit \(error.localizedDescription)")
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("REGISTRAR PROPIEDAD")
                        .font(.appTitle)
                        .foregroundStyle(.primaryColorGreen)
                }
            }
            .alert("Mensaje", isPresented: $showAlert) {
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
