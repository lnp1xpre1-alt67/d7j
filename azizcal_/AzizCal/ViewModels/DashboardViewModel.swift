import Foundation
import Combine

public struct MacroSummary {
    public var consumed: Double
    public var target: Double
    public var remaining: Double
    public var surplus: Double
    public var percentage: Double
    public var isExceeded: Bool

    public init(consumed: Double, target: Double) {
        self.consumed = consumed
        self.target = target
        let diff = target - consumed
        if diff >= 0 {
            self.remaining = diff
            self.surplus = 0
            self.isExceeded = false
        } else {
            self.remaining = 0
            self.surplus = abs(diff)
            self.isExceeded = true
        }
        if target > 0 {
            self.percentage = min(999.0, (consumed / target) * 100)
        } else {
            self.percentage = 0
        }
    }
}

public final class DashboardViewModel: ObservableObject {
    @Published public var selectedDate: Date = Date()
    @Published public var showingAddFoodSheet: Bool = false
    @Published public var showingNewWorkoutSheet: Bool = false

    public let store: DataStore
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared) {
        self.store = store
        // Observe store changes
        store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    public var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    public var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        if Calendar.current.isDateInToday(selectedDate) {
            formatter.dateFormat = "اليوم، d MMMM"
        } else if Calendar.current.isDateInYesterday(selectedDate) {
            formatter.dateFormat = "أمس، d MMMM"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            formatter.dateFormat = "غداً، d MMMM"
        } else {
            formatter.dateFormat = "EEEE، d MMMM yyyy"
        }
        return formatter.string(from: selectedDate)
    }

    public func goToPreviousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    public func goToNextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    public func goToToday() {
        selectedDate = Date()
    }

    // MARK: - Nutrition Calculations
    public var todayFoodItems: [FoodItem] {
        store.foodItems(forDate: selectedDate)
    }

    public var todayCaloriesConsumed: Double {
        todayFoodItems.reduce(0.0) { $0 + $1.calories }
    }

    public var todayProteinConsumed: Double {
        todayFoodItems.reduce(0.0) { $0 + $1.protein }
    }

    public var todayCarbsConsumed: Double {
        todayFoodItems.reduce(0.0) { $0 + $1.carbs }
    }

    public var todayFatConsumed: Double {
        todayFoodItems.reduce(0.0) { $0 + $1.fat }
    }

    public var calorieSummary: MacroSummary {
        let target = store.goals?.calories ?? 0.0
        return MacroSummary(consumed: todayCaloriesConsumed, target: target)
    }

    public var proteinSummary: MacroSummary {
        let target = store.goals?.protein ?? 0.0
        return MacroSummary(consumed: todayProteinConsumed, target: target)
    }

    public var carbsSummary: MacroSummary {
        let target = store.goals?.carbs ?? 0.0
        return MacroSummary(consumed: todayCarbsConsumed, target: target)
    }

    public var fatSummary: MacroSummary {
        let target = store.goals?.fat ?? 0.0
        return MacroSummary(consumed: todayFatConsumed, target: target)
    }

    public var todayWorkouts: [WorkoutSession] {
        store.workoutSessions(forDate: selectedDate)
    }
}
