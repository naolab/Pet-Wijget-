import SwiftUI

struct PetDetailView: View {
    let pet: Pet?
    let onSave: (Pet) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var selectedSpecies: PetType = .dog
    @State private var selectedDogBreed: DogBreed?
    @State private var selectedCatBreed: CatBreed?
    @State private var photoData: Data?
    @State private var originalPhotoData: Data?

    @State private var showingImagePicker = false
    @State private var showingPhotoCropper = false
    @State private var selectedImage: UIImage?

    // フルスクリーン表示の状態管理用
    enum FullScreenState: Identifiable {
        case imagePicker
        case photoCropper(UIImage)

        var id: String {
            switch self {
            case .imagePicker: return "imagePicker"
            case .photoCropper: return "photoCropper"
            }
        }
    }
    @State private var fullScreenState: FullScreenState?

    var isEditing: Bool {
        pet != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section("基本情報") {
                    TextField("名前", text: $name)

                    DatePicker(
                        "誕生日",
                        selection: $birthDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .environment(\.locale, Locale(identifier: "ja_JP"))

                    Picker("種別", selection: $selectedSpecies) {
                        ForEach(PetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: iconForSpecies(type))
                                Text(displayNameForSpecies(type))
                            }
                            .tag(type)
                        }
                    }
                    .onChange(of: selectedSpecies) { _, newValue in
                        // 種別が変更されたら品種をクリア
                        if newValue != .dog {
                            selectedDogBreed = nil
                        }
                        if newValue != .cat {
                            selectedCatBreed = nil
                        }
                    }

                    // 犬の場合のみ犬種選択を表示
                    if selectedSpecies == .dog {
                        Picker("犬種", selection: $selectedDogBreed) {
                            Text("選択してください").tag(nil as DogBreed?)

                            Section(header: Text("小型犬")) {
                                ForEach(DogBreed.smallBreeds, id: \.self) { breed in
                                    Text(breed.displayName).tag(breed as DogBreed?)
                                }
                            }

                            Section(header: Text("中型犬")) {
                                ForEach(DogBreed.mediumBreeds, id: \.self) { breed in
                                    Text(breed.displayName).tag(breed as DogBreed?)
                                }
                            }

                            Section(header: Text("大型犬")) {
                                ForEach(DogBreed.largeBreeds, id: \.self) { breed in
                                    Text(breed.displayName).tag(breed as DogBreed?)
                                }
                            }

                            Section(header: Text("その他")) {
                                ForEach(DogBreed.otherBreeds, id: \.self) { breed in
                                    Text(breed.displayName).tag(breed as DogBreed?)
                                }
                            }
                        }
                    }

                    // 猫の場合のみ猫種選択を表示
                    if selectedSpecies == .cat {
                        Picker("猫種", selection: $selectedCatBreed) {
                            Text("選択してください").tag(nil as CatBreed?)

                            ForEach(CatBreed.allCases, id: \.self) { breed in
                                Text(breed.displayName).tag(breed as CatBreed?)
                            }
                        }
                    }
                }

                Section("写真") {
                    VStack(spacing: 16) {
                        PetPhotoView(
                            photoData: photoData,
                            size: 150,
                            shape: .roundedRectangle(cornerRadius: 16)
                        )

                        Button {
                            print("DEBUG: 写真を選択ボタンが押されました")
                            guard fullScreenState == nil else {
                                print("DEBUG: 既に状態が設定されているため無視")
                                return
                            }
                            fullScreenState = .imagePicker
                        } label: {
                            Label("写真を選択", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)

                        // 既存の写真がある場合は再編集ボタンを表示
                        if let originalData = originalPhotoData,
                           let originalImage = UIImage(data: originalData) {
                            Button {
                                print("DEBUG: 写真を編集ボタンが押されました")
                                print("DEBUG: originalImage exists: \(originalImage)")
                                guard fullScreenState == nil else {
                                    print("DEBUG: 既に状態が設定されているため無視")
                                    return
                                }
                                fullScreenState = .photoCropper(originalImage)
                            } label: {
                                Label("写真を編集", systemImage: "crop.rotate")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green.opacity(0.1))
                                    .foregroundColor(.green)
                                    .cornerRadius(10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                if pet != nil {
                    Section("年齢情報") {
                        AgeDisplayView(pet: createPreviewPet(), showHumanAge: true)
                    }
                }
            }
            .navigationTitle(isEditing ? "ペット編集" : "ペット登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        savePet()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .fullScreenCover(item: $fullScreenState) { state in
                switch state {
                case .imagePicker:
                    ImagePicker { image in
                        print("DEBUG: ImagePicker - 画像が選択されました")
                        // 元画像を保存
                        originalPhotoData = PhotoManager.shared.processImage(
                            image,
                            maxSize: 2000,
                            compressionQuality: 0.9
                        )
                        // 編集画面を表示（少し遅延させてfullScreenCoverの完全な閉じを待つ）
                        print("DEBUG: ImagePicker - 0.3秒後にPhotoCropperを開きます")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            print("DEBUG: ImagePicker - fullScreenState = .photoCropper を設定")
                            fullScreenState = .photoCropper(image)
                        }
                    }
                    .onAppear {
                        print("DEBUG: ImagePicker が表示されました")
                    }

                case .photoCropper(let image):
                    PhotoCropperView(
                        image: image,
                        onComplete: { croppedImage in
                            print("DEBUG: PhotoCropperView - 完了ボタンが押されました")
                            // 切り抜いた画像を保存
                            photoData = PhotoManager.shared.processImage(
                                croppedImage,
                                maxSize: AppConfig.maxImageSize
                            )
                            fullScreenState = nil
                        },
                        onCancel: {
                            print("DEBUG: PhotoCropperView - キャンセルボタンが押されました")
                            fullScreenState = nil
                        }
                    )
                    .onAppear {
                        print("DEBUG: PhotoCropperView が表示されました (image: \(image.size))")
                    }
                }
            }
            .onAppear {
                if let pet = pet {
                    name = pet.name
                    birthDate = pet.birthDate
                    selectedSpecies = pet.species
                    photoData = pet.photoData
                    originalPhotoData = pet.originalPhotoData

                    // 品種の読み込み
                    if let breedString = pet.breed {
                        switch pet.species {
                        case .dog:
                            if let breed = DogBreed(rawValue: breedString) {
                                selectedDogBreed = breed
                            }
                        case .cat:
                            if let breed = CatBreed(rawValue: breedString) {
                                selectedCatBreed = breed
                            }
                        default:
                            break
                        }
                    }
                }
            }
        }
    }

    private func savePet() {
        // 選択された品種の取得
        let breedString: String?
        switch selectedSpecies {
        case .dog:
            breedString = selectedDogBreed?.rawValue
        case .cat:
            breedString = selectedCatBreed?.rawValue
        default:
            breedString = nil
        }

        let newPet: Pet
        if let existingPet = pet {
            newPet = Pet(
                id: existingPet.id,
                name: name,
                birthDate: birthDate,
                species: selectedSpecies,
                photoData: photoData,
                originalPhotoData: originalPhotoData,
                displayOrder: existingPet.displayOrder,
                breed: breedString
            )
        } else {
            newPet = Pet(
                name: name,
                birthDate: birthDate,
                species: selectedSpecies,
                photoData: photoData,
                originalPhotoData: originalPhotoData,
                breed: breedString
            )
        }

        onSave(newPet)
        dismiss()
    }

    private func createPreviewPet() -> Pet {
        // 選択された品種の取得
        let breedString: String?
        switch selectedSpecies {
        case .dog:
            breedString = selectedDogBreed?.rawValue
        case .cat:
            breedString = selectedCatBreed?.rawValue
        default:
            breedString = nil
        }

        return Pet(
            id: pet?.id ?? UUID(),
            name: name.isEmpty ? "名前未設定" : name,
            birthDate: birthDate,
            species: selectedSpecies,
            photoData: photoData,
            breed: breedString
        )
    }

    private func iconForSpecies(_ species: PetType) -> String {
        switch species {
        case .dog: return "pawprint.fill"
        case .cat: return "cat.fill"
        case .fish: return "fish.fill"
        case .smallAnimal: return "hare.fill"
        case .turtle: return "tortoise.fill"
        case .bird: return "bird.fill"
        case .insect: return "ladybug.fill"
        case .other: return "questionmark.circle.fill"
        }
    }

    private func displayNameForSpecies(_ species: PetType) -> String {
        switch species {
        case .dog: return "犬"
        case .cat: return "猫"
        case .fish: return "魚"
        case .smallAnimal: return "小動物"
        case .turtle: return "カメ"
        case .bird: return "鳥"
        case .insect: return "虫"
        case .other: return "その他"
        }
    }
}

#Preview {
    PetDetailView(pet: nil) { _ in }
}
