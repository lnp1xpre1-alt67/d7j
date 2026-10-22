import Foundation
import Combine

public final class StatisticsViewModel: ObservableObject {
    @Published public var selectedTimeframe: AnalyticsTimeframe = .month

    public let store: DataStore
    private let analytics: AnalyticsService
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared, analytics: AnalyticsService = .shared) {
        self.store = store
        self.analytics = analytics

        store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    public var nutritionAverages: NutritionAverages {
        analytics.calculateNutritionAverages(
            foodItems: store.foodItems,
            goals: store.goals,
            timeframe: selectedTimeframe
        )
    }

    public var filteredWorkoutsCount: Int {
        guard let days = selectedTimeframe.days else {
            return store.workoutSessions.count
        }
        guard let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else {
            return store.workoutSessions.count
        }
        return store.workoutSessions.filter { $0.date >= startDate }.count
    }

    public var topExercises: [(name: String, count: Int)] {
        let filteredSessions: [WorkoutSession]
        if let days = selectedTimeframe.days,
           let startDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) {
            filteredSessions = store.workoutSessions.filter { $0.date >= startDate }
        } else {
            filteredSessions = store.workoutSessions
        }
        return analytics.mostFrequentExercises(from: filteredSessions, limit: 5)
    }
}
