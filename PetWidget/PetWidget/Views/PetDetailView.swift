import SwiftUI
import PhotosUI

struct PetDetailView: View {
    let pet: Pet?
    let onSave: (Pet) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var birthDate: Date = Date()
    @State private var selectedSpecies: PetType = .dog
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

                    Picker("種別", selection: $selectedSpecies) {
                        ForEach(PetType.allCases, id: \.self) { type in
                            HStack {
                                Image(systemName: iconForSpecies(type))
                                Text(displayNameForSpecies(type))
                            }
                            .tag(type)
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
                }
            }
        }
    }

    private func savePet() {
        let newPet: Pet
        if let existingPet = pet {
            newPet = Pet(
                id: existingPet.id,
                name: name,
                birthDate: birthDate,
                species: selectedSpecies,
                photoData: photoData
            )
        } else {
            newPet = Pet(
                name: name,
                birthDate: birthDate,
                species: selectedSpecies,
                photoData: photoData
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
        Pet(
            id: pet?.id ?? UUID(),
            name: name.isEmpty ? "名前未設定" : name,
            birthDate: birthDate,
            species: selectedSpecies,
            photoData: photoData
        )
    }

    private func iconForSpecies(_ species: PetType) -> String {
        switch species {
        case .dog: return "pawprint.fill"
        case .cat: return "cat.fill"
        case .other: return "hare.fill"
        }
    }

    private func displayNameForSpecies(_ species: PetType) -> String {
        switch species {
        case .dog: return "犬"
        case .cat: return "猫"
        case .other: return "その他"
        }
    }
}

#Preview {
    PetDetailView(pet: nil) { _ in }
}
