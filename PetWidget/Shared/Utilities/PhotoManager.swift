import UIKit
import Photos

final class PhotoManager {
    static let shared = PhotoManager()

    private init() {}

    // UIImageをリサイズしてData化
    func processImage(_ image: UIImage, maxSize: CGFloat = 800, compressionQuality: CGFloat = 0.8) -> Data? {
        let resizedImage = resizeImage(image, maxSize: maxSize)
        return resizedImage.jpegData(compressionQuality: compressionQuality)
    }

    // ウィジェット用にさらに小さくリサイズ
    func processImageForWidget(_ image: UIImage) -> Data? {
        return processImage(image, maxSize: 300, compressionQuality: 0.7)
    }

    // DataからUIImageに変換
    func loadImage(from data: Data) -> UIImage? {
        return UIImage(data: data)
    }

    // 画像リサイズ
    private func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let ratio = size.width / size.height

        var newSize: CGSize
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / ratio)
        } else {
            newSize = CGSize(width: maxSize * ratio, height: maxSize)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
