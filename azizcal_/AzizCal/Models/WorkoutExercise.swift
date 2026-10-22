import Foundation

public struct WorkoutExercise: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var sets: [WorkoutSet]
    public var notes: String?

    public init(
        id: UUID = UUID(),
        name: String,
        sets: [WorkoutSet] = [],
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.notes = notes
    }

    public var maxWeight: Double {
        return sets.compactMap { $0.weightKg }.max() ?? 0.0
    }

    public var totalReps: Int {
        return sets.reduce(0) { $0 + $1.reps }
    }

    public var totalVolume: Double {
        return sets.reduce(0.0) { $0 + $1.volume }
    }

    public var bestSetSummary: String {
        guard !sets.isEmpty else { return "لا توجد مجموعات" }
        if let maxSet = sets.filter({ !$0.isBodyweight }).max(by: { ($0.weightKg ?? 0) < ($1.weightKg ?? 0) }) {
            return maxSet.displaySummary
        } else if let first = sets.first {
            return first.displaySummary
        }
        return "-"
    }
}
