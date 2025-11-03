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
                // 背景（暗い）
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
                                scale = min(max(newScale, minScale), maxScale)
                            }
                            .onEnded { _ in
                                lastScale = 1.0
                            }
                            .simultaneously(with: DragGesture()
                                .onChanged { value in
                                    offset = CGSize(
                                        width: lastOffset.width + value.translation.width,
                                        height: lastOffset.height + value.translation.height
                                    )
                                }
                                .onEnded { _ in
                                    lastOffset = offset
                                }
                            )
                            .simultaneously(with: RotationGesture()
                                .onChanged { value in
                                    rotation = lastRotation + value
                                }
                                .onEnded { _ in
                                    lastRotation = rotation
                                }
                            )
                    )

                    Spacer()

                    // 90度回転ボタン
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            rotation += .degrees(90)
                            lastRotation = rotation
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "rotate.right")
                                .font(.system(size: 20))
                            Text("90°回転")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
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
