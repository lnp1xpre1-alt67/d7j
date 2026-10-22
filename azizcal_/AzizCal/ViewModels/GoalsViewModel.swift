import Foundation
import Combine

public final class GoalsViewModel: ObservableObject {
    @Published public var caloriesText: String = ""
    @Published public var proteinText: String = ""
    @Published public var carbsText: String = ""
    @Published public var fatText: String = ""
    @Published public var errorMessage: String?
    @Published public var isSavedSuccessfully: Bool = false

    private let store: DataStore

    public init(store: DataStore = .shared) {
        self.store = store
        loadExistingGoals()
    }

    public func loadExistingGoals() {
        if let current = store.goals {
            self.caloriesText = String(format: "%.0f", current.calories)
            self.proteinText = String(format: "%.0f", current.protein)
            self.carbsText = String(format: "%.0f", current.carbs)
            self.fatText = String(format: "%.0f", current.fat)
        }
    }

    public func saveGoals() -> Bool {
        errorMessage = nil

        let cal = Double(caloriesText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let p = Double(proteinText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let c = Double(carbsText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let f = Double(fatText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1

        let validation = UserGoals.validate(calories: cal, protein: p, carbs: c, fat: f)
        switch validation {
        case .success:
            let newGoals = UserGoals(calories: cal, protein: p, carbs: c, fat: f)
            store.saveGoals(newGoals)
            isSavedSuccessfully = true
            return true
        case .failure(let error):
            errorMessage = error
            return false
        }
    }
}
