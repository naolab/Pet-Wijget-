import SwiftUI

struct PhotoCropperView: View {
    let image: UIImage
    let onComplete: (UIImage) -> Void
    let onCancel: () -> Void

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var rotation: Angle = .zero
    @State private var lastRotation: Angle = .zero

    private let minScale: CGFloat = 1.0
    private let maxScale: CGFloat = 5.0
    private let cropFrameSize: CGFloat = 300

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景は黒で統一
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // ヘッダー
                    HStack {
                        Button(action: {
                            onCancel()
                        }) {
                            Text("キャンセル")
                                .foregroundColor(.white)
                                .padding()
                        }

                        Spacer()

                        Button(action: {
                            cropAndComplete()
                        }) {
                            Text("完了")
                                .foregroundColor(.white)
                                .fontWeight(.semibold)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.black.opacity(0.8))
                    .frame(height: 60)

                    Spacer()

                    // 画像表示エリア
                    ZStack {
                        // 暗く表示する背景用（フレーム外の見え方用）
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .rotationEffect(rotation)
                            .offset(offset)
                            .opacity(0.35)
                            .allowsHitTesting(false)

                        // 画像
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(scale)
                            .rotationEffect(rotation)
                            .offset(offset)
                            .frame(width: cropFrameSize, height: cropFrameSize)
                            .clipped()

                        // クロップフレーム（正方形の枠線）
                        Rectangle()
                            .stroke(Color.white, lineWidth: 2)
                            .frame(width: cropFrameSize, height: cropFrameSize)

                        // 暗い領域（フレーム外）
                        CropOverlay(frameSize: cropFrameSize)
                    }
                    .frame(width: cropFrameSize, height: cropFrameSize)
                    .contentShape(Rectangle())
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                let delta = value / lastScale
                                lastScale = value
                                let newScale = scale * delta
                                let minScale = minimumScale(for: rotation)
                                scale = min(max(newScale, minScale), maxScale)
                                offset = clampedOffset(for: offset, scale: scale, rotation: rotation)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                                lastOffset = offset
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { value in
                                    let proposedOffset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                    offset = clampedOffset(for: proposedOffset, scale: scale, rotation: rotation)
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                            )
                            .simultaneously(with: RotationGesture()
                                .onChanged { value in
                                    rotation = lastRotation + value
                                    let minScale = minimumScale(for: rotation)
                                    if scale < minScale {
                                        scale = minScale
                                    }
                                    offset = clampedOffset(for: offset, scale: scale, rotation: rotation)
                                }
                                .onEnded { _ in
                                    lastRotation = rotation
                                    lastOffset = offset
                                }
                            )
                    )

                    Spacer()

                    // 90度回転ボタン
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            rotation += .degrees(90)
                            lastRotation = rotation
                            let minScale = minimumScale(for: rotation)
                            if scale < minScale {
                                scale = minScale
                            }
                            offset = clampedOffset(for: offset, scale: scale, rotation: rotation)
                            lastOffset = offset
                        }
                    }) {
                        Image(systemName: "rotate.right")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
    }

    private func cropAndComplete() {
        guard let croppedImage = PhotoManager.shared.cropImage(
            image,
            scale: scale,
            offset: offset,
            frameSize: cropFrameSize,
            rotation: CGFloat(rotation.radians)
        ) else {
            return
        }

        onComplete(croppedImage)
    }

    private func minimumScale(for rotation: Angle) -> CGFloat {
        let displaySize = displaySize(for: rotation)
        let widthScale = cropFrameSize / displaySize.width
        let heightScale = cropFrameSize / displaySize.height
        return max(widthScale, heightScale, minScale)
    }

    private func displaySize(for rotation: Angle) -> CGSize {
        let rotatedSize = rotatedImageSize(for: image.size, angle: CGFloat(rotation.radians))
        let aspectRatio = rotatedSize.width / rotatedSize.height

        if aspectRatio > 1 {
            return CGSize(width: cropFrameSize * aspectRatio, height: cropFrameSize)
        } else {
            return CGSize(width: cropFrameSize, height: cropFrameSize / aspectRatio)
        }
    }

    private func rotatedImageSize(for size: CGSize, angle: CGFloat) -> CGSize {
        let normalizedAngle = abs(angle.truncatingRemainder(dividingBy: .pi))
        let cosValue = abs(cos(normalizedAngle))
        let sinValue = abs(sin(normalizedAngle))

        let width = size.width * cosValue + size.height * sinValue
        let height = size.width * sinValue + size.height * cosValue

        return CGSize(width: width, height: height)
    }

    private func clampedOffset(for proposedOffset: CGSize, scale: CGFloat, rotation: Angle) -> CGSize {
        let displaySize = displaySize(for: rotation)
        let scaledWidth = displaySize.width * scale
        let scaledHeight = displaySize.height * scale

        let horizontalLimit = max(0, (scaledWidth - cropFrameSize) / 2)
        let verticalLimit = max(0, (scaledHeight - cropFrameSize) / 2)

        let clampedX = min(max(proposedOffset.width, -horizontalLimit), horizontalLimit)
        let clampedY = min(max(proposedOffset.height, -verticalLimit), verticalLimit)

        return CGSize(width: clampedX, height: clampedY)
    }
}

// クロップフレーム外を暗くするオーバーレイ
struct CropOverlay: View {
    let frameSize: CGFloat

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerX = width / 2
            let centerY = height / 2
            let halfFrame = frameSize / 2

            Path { path in
                // 外側の矩形
                path.addRect(CGRect(origin: .zero, size: geometry.size))

                // 内側のクロップフレーム（くり抜く）
                path.addRect(CGRect(
                    x: centerX - halfFrame,
                    y: centerY - halfFrame,
                    width: frameSize,
                    height: frameSize
                ))
            }
            .fill(Color.black.opacity(0.5), style: FillStyle(eoFill: true))
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    PhotoCropperView(
        image: UIImage(systemName: "photo")!,
        onComplete: { _ in },
        onCancel: {}
    )
}
