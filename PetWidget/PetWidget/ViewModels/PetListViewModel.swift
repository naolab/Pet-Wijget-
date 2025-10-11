import Foundation
import SwiftUI
import WidgetKit
import Combine

@MainActor
class PetListViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false

    private let dataManager: PetDataManagerProtocol

    init(dataManager: PetDataManagerProtocol = PetDataManager.shared) {
        self.dataManager = dataManager
    }

    func loadPets() {
        isLoading = true
        errorMessage = nil

        do {
            pets = try dataManager.fetchAll()
        } catch {
            errorMessage = "ペット情報の読み込みに失敗しました: \(error.localizedDescription)"
            pets = []
        }

        isLoading = false
    }

    func addPet(_ pet: Pet) {
        do {
            try dataManager.create(pet)
            loadPets()
            reloadWidgets()
        } catch {
            errorMessage = "ペットの追加に失敗しました: \(error.localizedDescription)"
        }
    }

    func updatePet(_ pet: Pet) {
        do {
            try dataManager.update(pet)
            loadPets()
            reloadWidgets()
        } catch {
            errorMessage = "ペット情報の更新に失敗しました: \(error.localizedDescription)"
        }
    }

    func deletePet(_ pet: Pet) {
        do {
            try dataManager.delete(pet)
            loadPets()
            reloadWidgets()
        } catch {
            errorMessage = "ペットの削除に失敗しました: \(error.localizedDescription)"
        }
    }

    func deletePets(at offsets: IndexSet) {
        for index in offsets {
            let pet = pets[index]
            deletePet(pet)
        }
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
