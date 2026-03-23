import SwiftUI

struct FullscreenImageView: View {
    let photoURLs: [URL]
    @State private var selectedIndex: Int

    @Environment(\.dismiss) private var dismiss
    
    init(photoURLs: [URL], selectedIndex: Int) {
        self.photoURLs = photoURLs
        self._selectedIndex = State(initialValue: selectedIndex)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            TabView(selection: $selectedIndex) {
                ForEach(Array(photoURLs.enumerated()), id: \.1) { index, url in
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color.black)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .foregroundStyle(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(index) // 👈🏻 Esto es clave para que TabView sepa qué índice está activo
                }
            }
            .tabViewStyle(.page)
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .padding()
            }
        }
    }
}
