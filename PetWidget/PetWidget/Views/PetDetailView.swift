import SwiftUI
import PhotosUI

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

    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var isLoadingPhoto = false

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
                        if isLoadingPhoto {
                            ProgressView()
                                .frame(width: 150, height: 150)
                        } else {
                            PetPhotoView(
                                photoData: photoData,
                                size: 150,
                                shape: .roundedRectangle(cornerRadius: 16)
                            )
                        }

                        PhotosPicker(
                            selection: $selectedPhotoItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Label("写真を選択", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(10)
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
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    await loadPhoto(from: newItem)
                }
            }
            .onAppear {
                if let pet = pet {
                    name = pet.name
                    birthDate = pet.birthDate
                    selectedSpecies = pet.species
                    photoData = pet.photoData

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
                displayOrder: existingPet.displayOrder,
                breed: breedString
            )
        } else {
            newPet = Pet(
                name: name,
                birthDate: birthDate,
                species: selectedSpecies,
                photoData: photoData,
                breed: breedString
            )
        }

        onSave(newPet)
        dismiss()
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item = item else { return }

        isLoadingPhoto = true
        defer { isLoadingPhoto = false }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                // PhotoManagerを使って画像をリサイズ
                photoData = PhotoManager.shared.processImage(image, maxSize: AppConfig.maxImageSize)
            }
        } catch {
            print("写真の読み込みに失敗: \(error)")
        }
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
