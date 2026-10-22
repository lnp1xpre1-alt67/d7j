import Foundation
import Combine

public final class ProgressViewModel: ObservableObject {
    @Published public var searchQuery: String = ""
    @Published public var selectedExerciseName: String?

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

    public var allExerciseNames: [String] {
        analytics.allUniqueExerciseNames(from: store.workoutSessions)
    }

    public var filteredExerciseNames: [String] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return allExerciseNames
        }
        return allExerciseNames.filter { $0.lowercased().contains(trimmed) }
    }

    public func history(for exerciseName: String) -> [ExerciseProgressPoint] {
        analytics.progressHistory(for: exerciseName, in: store.workoutSessions)
    }

    public func personalRecord(for exerciseName: String) -> ExercisePersonalRecord {
        analytics.personalRecord(for: exerciseName, in: store.workoutSessions)
    }

    public func lastPerformance(for exerciseName: String) -> ExerciseProgressPoint? {
        history(for: exerciseName).last
    }

    public func canShowChart(for exerciseName: String) -> Bool {
        return history(for: exerciseName).count >= 2
    }
}
