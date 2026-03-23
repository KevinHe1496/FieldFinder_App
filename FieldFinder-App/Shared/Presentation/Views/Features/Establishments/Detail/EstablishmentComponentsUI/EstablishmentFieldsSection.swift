import SwiftUI

struct EstablishmentFieldsSection: View {
    let canchas: [FieldResponse]
    @State private var shownItems: Set<String> = []
    let rows = GridItem(.flexible(minimum: 80))
    let establecimientoID: String
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Altura adaptativa mínima
    private var adaptiveMinHeight: CGFloat {
        horizontalSizeClass == .regular ? 500 : 300
    }
    
    // Ancho adaptativo
    private var adaptiveWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return horizontalSizeClass == .regular ? screenWidth * 0.6 : screenWidth * 0.9
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Canchas")
                    .font(.headline)
                    .padding(.horizontal, 20)
                    .foregroundStyle(.primaryColorGreen)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHGrid(rows: [rows]) {
                        ForEach(canchas) { cancha in
                            NavigationLink {
                                FieldDetailView(fieldId: cancha.id,
                                                establecimientoID: establecimientoID)
                            } label: {
                                FieldGridItemView(field: cancha)
                                    .frame(width: adaptiveWidth)
                                    .frame(minHeight: adaptiveMinHeight)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(.thirdColorWhite)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    EstablishmentFieldsSection(canchas: [.sample], establecimientoID: "")
}
