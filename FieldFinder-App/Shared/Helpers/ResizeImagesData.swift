import Foundation
import UIKit

struct ResizeImagesData {
    
    static func resizeImageData(from data: Data, maxDimension: CGFloat = 800, compressionQuality: CGFloat = 0.5) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

        // 1. Calcular nuevo tamaño proporcional
        let size = image.size
        let ratio = min(maxDimension / size.width, maxDimension / size.height)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

        // 2. Redibujar imagen
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        // 3. Comprimir como JPEG
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }
    
}
