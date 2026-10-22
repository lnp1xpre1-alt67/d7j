import Foundation

public struct WorkoutSession: Codable, Identifiable, Equatable {
    public var id: UUID
    public var title: String
    public var date: Date
    public var exercises: [WorkoutExercise]
    public var notes: String?
    public var durationMinutes: Int?
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        date: Date = Date(),
        exercises: [WorkoutExercise] = [],
        notes: String? = nil,
        durationMinutes: Int? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.exercises = exercises
        self.notes = notes
        self.durationMinutes = durationMinutes
        self.createdAt = createdAt
    }

    public var totalSetsCount: Int {
        return exercises.reduce(0) { $0 + $1.sets.count }
    }

    public var totalVolume: Double {
        return exercises.reduce(0.0) { $0 + $1.totalVolume }
    }

    public static func validate(title: String) -> Result<Void, String> {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .failure("يجب كتابة اسم الحصة التدريبية (مثال: Push أو أرجل)")
        }
        return .success(())
    }
}
