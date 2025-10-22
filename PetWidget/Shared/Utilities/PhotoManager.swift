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

    // 画像を切り抜き（正方形）
    // - Parameters:
    //   - image: 元画像
    //   - scale: 拡大率（1.0 = 原寸、2.0 = 2倍拡大）
    //   - offset: オフセット（UIのドラッグ量）
    //   - frameSize: クロップフレームのサイズ
    // - Returns: 切り抜かれた正方形の画像
    func cropImage(_ image: UIImage, scale: CGFloat, offset: CGSize, frameSize: CGFloat) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }

        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)

        // UI上の表示サイズを計算
        let aspectRatio = imageSize.width / imageSize.height
        var displaySize: CGSize
        if aspectRatio > 1 {
            // 横長画像
            displaySize = CGSize(width: frameSize * aspectRatio, height: frameSize)
        } else {
            // 縦長画像
            displaySize = CGSize(width: frameSize, height: frameSize / aspectRatio)
        }

        // スケール適用後の表示サイズ
        let scaledDisplaySize = CGSize(
            width: displaySize.width * scale,
            height: displaySize.height * scale
        )

        // UI座標からピクセル座標への変換比率
        let pixelRatio = imageSize.width / scaledDisplaySize.width

        // クロップ領域の中心点（UI座標）
        let centerX = (scaledDisplaySize.width - frameSize) / 2 - offset.width
        let centerY = (scaledDisplaySize.height - frameSize) / 2 - offset.height

        // クロップ領域の左上座標（ピクセル座標）
        let cropX = centerX * pixelRatio
        let cropY = centerY * pixelRatio
        let cropSize = frameSize * pixelRatio

        // クロップ領域を画像内に収める
        let clampedX = max(0, min(cropX, imageSize.width - cropSize))
        let clampedY = max(0, min(cropY, imageSize.height - cropSize))
        let clampedSize = min(cropSize, imageSize.width - clampedX, imageSize.height - clampedY)

        let cropRect = CGRect(
            x: clampedX,
            y: clampedY,
            width: clampedSize,
            height: clampedSize
        )

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { return nil }

        return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
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
