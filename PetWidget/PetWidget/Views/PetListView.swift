import SwiftUI

struct PetListView: View {
    @StateObject private var viewModel = PetListViewModel()
    @State private var showingAddPet = false
    @State private var selectedPet: Pet?

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPet = true }) {
                        Image(systemName: "plus")
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

    private var petListContent: some View {
        List {
            ForEach(viewModel.pets) { pet in
                PetRowView(pet: pet)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedPet = pet
                    }
            }
            .onDelete(perform: viewModel.deletePets)
        }
    }
}

struct PetRowView: View {
    let pet: Pet

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
