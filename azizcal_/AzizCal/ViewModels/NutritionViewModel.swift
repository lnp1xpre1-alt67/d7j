import Foundation
import Combine

public final class NutritionViewModel: ObservableObject {
    @Published public var selectedDate: Date = Date()
    @Published public var showingAddSheet: Bool = false
    @Published public var showingSavedFoodsSheet: Bool = false
    @Published public var showingCopyMealSheet: Bool = false
    @Published public var selectedMealForAdd: MealType = .breakfast
    @Published public var editingFoodItem: FoodItem?

    // Add / Edit Form State
    @Published public var formName: String = ""
    @Published public var formAmount: String = "100"
    @Published public var formUnit: String = "غرام"
    @Published public var formCalories: String = ""
    @Published public var formProtein: String = ""
    @Published public var formCarbs: String = ""
    @Published public var formFat: String = ""
    @Published public var formMealType: MealType = .breakfast
    @Published public var formErrorMessage: String?

    // Saved Food Search
    @Published public var savedFoodSearchQuery: String = ""

    public let store: DataStore
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared) {
        self.store = store
        store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    public var dailyFoodItems: [FoodItem] {
        store.foodItems(forDate: selectedDate)
    }

    public func items(for meal: MealType) -> [FoodItem] {
        dailyFoodItems.filter { $0.mealType == meal }
    }

    public func totalCalories(for meal: MealType) -> Double {
        items(for: meal).reduce(0.0) { $0 + $1.calories }
    }

    public func totalProtein(for meal: MealType) -> Double {
        items(for: meal).reduce(0.0) { $0 + $1.protein }
    }

    public func totalCarbs(for meal: MealType) -> Double {
        items(for: meal).reduce(0.0) { $0 + $1.carbs }
    }

    public func totalFat(for meal: MealType) -> Double {
        items(for: meal).reduce(0.0) { $0 + $1.fat }
    }

    public var filteredSavedFoods: [SavedFood] {
        let trimmed = savedFoodSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return store.savedFoods.sorted { ($0.isFavorite ? 0 : 1) < ($1.isFavorite ? 0 : 1) }
        }
        return store.savedFoods.filter { $0.name.lowercased().contains(trimmed) }
    }

    // Prepare Form for New Item
    public func prepareForNewItem(mealType: MealType? = nil) {
        editingFoodItem = nil
        formName = ""
        formAmount = "100"
        formUnit = "غرام"
        formCalories = ""
        formProtein = ""
        formCarbs = ""
        formFat = ""
        formMealType = mealType ?? selectedMealForAdd
        formErrorMessage = nil
        showingAddSheet = true
    }

    // Prepare Form for Editing Existing Item
    public func prepareForEdit(_ item: FoodItem) {
        editingFoodItem = item
        formName = item.name
        formAmount = String(format: "%.1f", item.amount).replacingOccurrences(of: ".0", with: "")
        formUnit = item.unit
        formCalories = String(format: "%.1f", item.calories).replacingOccurrences(of: ".0", with: "")
        formProtein = String(format: "%.1f", item.protein).replacingOccurrences(of: ".0", with: "")
        formCarbs = String(format: "%.1f", item.carbs).replacingOccurrences(of: ".0", with: "")
        formFat = String(format: "%.1f", item.fat).replacingOccurrences(of: ".0", with: "")
        formMealType = item.mealType
        formErrorMessage = nil
        showingAddSheet = true
    }

    // Apply Saved Food template
    public func applySavedFood(_ saved: SavedFood, customAmount: Double? = nil) {
        formName = saved.name
        formUnit = saved.unit
        let amount = customAmount ?? saved.baseAmount
        formAmount = String(format: "%.1f", amount).replacingOccurrences(of: ".0", with: "")

        let calculated = saved.calculateNutrition(forAmount: amount)
        formCalories = String(format: "%.1f", calculated.calories).replacingOccurrences(of: ".0", with: "")
        formProtein = String(format: "%.1f", calculated.protein).replacingOccurrences(of: ".0", with: "")
        formCarbs = String(format: "%.1f", calculated.carbs).replacingOccurrences(of: ".0", with: "")
        formFat = String(format: "%.1f", calculated.fat).replacingOccurrences(of: ".0", with: "")
    }

    public func onAmountChangedInForm(savedFood: SavedFood?) {
        guard let saved = savedFood else { return }
        if let amount = Double(formAmount.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) {
            let calc = saved.calculateNutrition(forAmount: amount)
            formCalories = String(format: "%.1f", calc.calories).replacingOccurrences(of: ".0", with: "")
            formProtein = String(format: "%.1f", calc.protein).replacingOccurrences(of: ".0", with: "")
            formCarbs = String(format: "%.1f", calc.carbs).replacingOccurrences(of: ".0", with: "")
            formFat = String(format: "%.1f", calc.fat).replacingOccurrences(of: ".0", with: "")
        }
    }

    public func saveCurrentForm() -> Bool {
        formErrorMessage = nil

        let name = formName.trimmingCharacters(in: .whitespacesAndNewlines)
        let amount = Double(formAmount.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let cal = Double(formCalories.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let p = Double(formProtein.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0.0
        let c = Double(formCarbs.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0.0
        let f = Double(formFat.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0.0

        let val = FoodItem.validate(name: name, amount: amount, calories: cal, protein: p, carbs: c, fat: f)
        switch val {
        case .failure(let err):
            formErrorMessage = err
            return false
        case .success:
            if let existing = editingFoodItem {
                var updated = existing
                updated.name = name
                updated.amount = amount
                updated.unit = formUnit
                updated.calories = cal
                updated.protein = p
                updated.carbs = c
                updated.fat = f
                updated.mealType = formMealType
                store.updateFoodItem(updated)
            } else {
                let newItem = FoodItem(
                    name: name,
                    amount: amount,
                    unit: formUnit,
                    calories: cal,
                    protein: p,
                    carbs: c,
                    fat: f,
                    mealType: formMealType,
                    date: selectedDate
                )
                store.addFoodItem(newItem)
            }
            showingAddSheet = false
            return true
        }
    }

    public func deleteFoodItem(_ item: FoodItem) {
        store.deleteFoodItem(withId: item.id)
    }

    public func repeatFoodItemInCurrentDate(_ item: FoodItem) {
        store.repeatFoodItem(item, toDate: selectedDate)
    }

    public func copyMealToDate(meal: MealType, toDate: Date) {
        store.copyMeal(from: meal, sourceDate: selectedDate, to: toDate)
    }
}
