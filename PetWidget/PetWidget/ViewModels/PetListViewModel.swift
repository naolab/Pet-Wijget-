import Foundation
import SwiftUI
import WidgetKit
import Combine

@MainActor
class PetListViewModel: ObservableObject {
    @Published var pets: [Pet] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var currentSortOption: PetSortOption = .displayOrder

    private let dataManager: PetDataManagerProtocol

    init(dataManager: PetDataManagerProtocol = PetDataManager.shared) {
        self.dataManager = dataManager
        loadSortOption()
    }

    func loadPets() {
        isLoading = true
        errorMessage = nil

        do {
            pets = try dataManager.fetchAll(sortBy: currentSortOption)
        } catch {
            errorMessage = "ペット情報の読み込みに失敗しました: \(error.localizedDescription)"
            pets = []
        }

        isLoading = false
    }

    func changeSortOption(_ option: PetSortOption) {
        currentSortOption = option
        saveSortOption()
        loadPets()
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

    func movePets(from source: IndexSet, to destination: Int) {
        // 配列内で並び替え
        pets.move(fromOffsets: source, toOffset: destination)

        // displayOrderを更新
        for (index, pet) in pets.enumerated() {
            var updatedPet = pet
            updatedPet.displayOrder = index
            pets[index] = updatedPet
        }

        // データベースに反映
        do {
            try dataManager.updateDisplayOrders(pets)
            reloadWidgets()
        } catch {
            errorMessage = "並び順の保存に失敗しました: \(error.localizedDescription)"
            loadPets() // エラー時は元に戻す
        }
    }

    private func loadSortOption() {
        if let savedOption = UserDefaults.standard.string(forKey: "PetSortOption") {
            switch savedOption {
            case "displayOrder":
                currentSortOption = .displayOrder
            case "name":
                currentSortOption = .name
            case "birthDate":
                currentSortOption = .birthDate
            case "species":
                currentSortOption = .species
            default:
                currentSortOption = .displayOrder
            }
        }
    }

    private func saveSortOption() {
        let optionString: String
        switch currentSortOption {
        case .displayOrder:
            optionString = "displayOrder"
        case .name:
            optionString = "name"
        case .birthDate:
            optionString = "birthDate"
        case .species:
            optionString = "species"
        }
        UserDefaults.standard.set(optionString, forKey: "PetSortOption")
    }

    private func reloadWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
