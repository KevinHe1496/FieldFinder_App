import SwiftUI

struct FieldGridItemView: View {
    let field: FieldResponse
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Altura adaptativa para la imagen
    private var adaptiveHeight: CGFloat {
        horizontalSizeClass == .regular ? 400 : 210
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RemoteImageCardView(url: field.photoCanchas.first)
                    .frame(height: adaptiveHeight)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                // Etiqueta en la esquina
                Text(LocalizedStringKey(field.tipo.capitalized))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.primaryColorGreen.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(field.modalidad)
                    .font(.headline)
                    .foregroundStyle(.primaryColorGreen)
                
                HStack(spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .foregroundColor(.primaryColorGreen)
                    Text("Precio: \(field.precio, format: .currency(code: "USD")) por hora")
                        .font(.subheadline)
                        .foregroundStyle(.colorBlack)
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

#Preview {
    FieldGridItemView(field: .sample)
}
