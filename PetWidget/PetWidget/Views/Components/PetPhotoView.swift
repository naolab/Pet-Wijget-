import SwiftUI

// Shape wrapper for dynamic shapes
struct AnyShape: Shape {
    let shape: PetPhotoView.PhotoShape

    func path(in rect: CGRect) -> Path {
        switch shape {
        case .circle:
            return Circle().path(in: rect)
        case .roundedRectangle(let cornerRadius):
            return RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
        }
    }
}

struct PetPhotoView: View {
    let photoData: Data?
    let size: CGFloat
    let shape: PhotoShape

    enum PhotoShape {
        case circle
        case roundedRectangle(cornerRadius: CGFloat)
    }

    init(photoData: Data?, size: CGFloat = 100, shape: PhotoShape = .circle) {
        self.photoData = photoData
        self.size = size
        self.shape = shape
    }

    var body: some View {
        Group {
            if let photoData = photoData,
               let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // デフォルトプレースホルダー
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .font(.system(size: size * 0.4))
                        .foregroundColor(.gray)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(AnyShape(shape: shape))
    }

    @ViewBuilder
    private var clippedShape: some View {
        switch shape {
        case .circle:
            Circle()
        case .roundedRectangle(let cornerRadius):
            RoundedRectangle(cornerRadius: cornerRadius)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PetPhotoView(photoData: nil, size: 100, shape: .circle)
        PetPhotoView(photoData: nil, size: 100, shape: .roundedRectangle(cornerRadius: 16))
    }
    .padding()
}
