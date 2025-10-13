import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel = PetListViewModel()
    @State private var showingAddPet = false
    @State private var selectedPet: Pet?
    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("読み込み中...")
                } else if viewModel.pets.isEmpty {
                    emptyStateView
                } else {
                    petListContent
                }
            }
            .navigationTitle("ペット一覧")
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        // ソートメニュー
                        Menu {
                            Picker("並び順", selection: $viewModel.currentSortOption) {
                                Label("カスタム", systemImage: "hand.draw").tag(PetSortOption.displayOrder)
                                Label("名前順", systemImage: "textformat").tag(PetSortOption.name)
                                Label("誕生日順", systemImage: "calendar").tag(PetSortOption.birthDate)
                                Label("種別順", systemImage: "pawprint").tag(PetSortOption.species)
                            }
                            .onChange(of: viewModel.currentSortOption) { _, newValue in
                                viewModel.changeSortOption(newValue)
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }

                        // 編集ボタン（カスタム順の時のみ表示）
                        if viewModel.currentSortOption == .displayOrder {
                            Button(action: {
                                withAnimation {
                                    if editMode == .active {
                                        editMode = .inactive
                                    } else {
                                        editMode = .active
                                    }
                                }
                            }) {
                                Text(editMode == .active ? "完了" : "編集")
                            }
                        }

                        // 追加ボタン
                        Button(action: { showingAddPet = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                PetDetailView(pet: nil, onSave: { newPet in
                    viewModel.addPet(newPet)
                    showingAddPet = false
                })
            }
            .sheet(item: $selectedPet) { pet in
                PetDetailView(pet: pet, onSave: { updatedPet in
                    viewModel.updatePet(updatedPet)
                    selectedPet = nil
                })
            }
            .alert("エラー", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onAppear {
                viewModel.loadPets()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("ペットが登録されていません")
                .font(.headline)
                .foregroundColor(.secondary)

            Button(action: { showingAddPet = true }) {
                Label("ペットを追加", systemImage: "plus.circle.fill")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }

    @ViewBuilder
    private var petListContent: some View {
        if viewModel.currentSortOption == .displayOrder {
            List {
                ForEach(viewModel.pets) { pet in
                    petRow(for: pet)
                }
                .onDelete(perform: viewModel.deletePets)
                .onMove(perform: viewModel.movePets)
            }
        } else {
            List {
                ForEach(viewModel.pets) { pet in
                    petRow(for: pet)
                }
                .onDelete(perform: viewModel.deletePets)
            }
        }
    }

    private func petRow(for pet: Pet) -> some View {
        PetRowView(pet: pet, isEditing: editMode == .active)
            .contentShape(Rectangle())
            .onTapGesture {
                if editMode == .inactive {
                    selectedPet = pet
                }
            }
            .contextMenu {
                Button(action: { selectedPet = pet }) {
                    Label("編集", systemImage: "pencil")
                }
                Button(role: .destructive, action: { viewModel.deletePet(pet) }) {
                    Label("削除", systemImage: "trash")
                }
            }
    }
}

struct PetRowView: View {
    let pet: Pet
    var isEditing: Bool = false

    var body: some View {
        HStack(spacing: 16) {
            PetPhotoView(
                photoData: pet.photoData,
                size: 60,
                shape: .circle
            )

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(pet.name)
                        .font(.headline)

                    Image(systemName: speciesIcon)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }

                AgeDisplayView(pet: pet, showHumanAge: true)
            }

            Spacer()

            // 編集モードでない時は編集アイコンを表示
            if !isEditing {
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
    }

    private var speciesIcon: String {
        switch pet.species {
        case .dog:
            return "pawprint.fill"
        case .cat:
            return "cat.fill"
        case .other:
            return "hare.fill"
        }
    }
}

#Preview {
    PetListView()
}
