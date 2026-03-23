import SwiftUI

struct RemoteImageCardView: View {
    let url: URL?
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var adaptiveHeight: CGFloat {
        horizontalSizeClass == .regular ? 400 : 240
    }
    
    var adaptiveWidth: CGFloat? {
        if horizontalSizeClass == .regular {
            return nil
        } else {
            return UIScreen.main.bounds.width * 0.8
        }
    }
    
    var body: some View {
        Group {
            if let imageURL = url {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .modifier(PlaceholderStyle(width: adaptiveWidth, height: adaptiveHeight, isRegular: horizontalSizeClass == .regular))
                        
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: adaptiveWidth, height: adaptiveHeight)
                            .frame(maxWidth: horizontalSizeClass == .regular ? .infinity : nil)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                    case .failure:
                        // Icono cuando falla la carga
                        PlaceholderView(systemName: "sportscourt", label: "No se pudo cargar la imagen")
                            .modifier(PlaceholderStyle(width: adaptiveWidth, height: adaptiveHeight, isRegular: horizontalSizeClass == .regular))
                        
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Icono cuando ni siquiera hay URL
                PlaceholderView(systemName: "photo.badge.plus", label: "Sin fotos disponibles")
                    .modifier(PlaceholderStyle(width: adaptiveWidth, height: adaptiveHeight, isRegular: horizontalSizeClass == .regular))
            }
        }
    }
    
    // Vista interna para el estado vacío/error
    @ViewBuilder
    private func PlaceholderView(systemName: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: systemName)
                .font(.system(size: 40))
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundStyle(.gray)
    }
}

// Modificador para reutilizar el estilo del contenedor
struct PlaceholderStyle: ViewModifier {
    let width: CGFloat?
    let height: CGFloat
    let isRegular: Bool
    
    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .frame(maxWidth: isRegular ? .infinity : nil)
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {

    RemoteImageCardView(url: URL(string: "https://fieldfinder-uploads.s3.us-east-2.amazonaws.com/cancha/6E1285EF-35F3-4A85-BC8B-689C1E001404-image0.jpg"))

}
