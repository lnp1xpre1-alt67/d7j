import Foundation

public struct WorkoutSet: Codable, Identifiable, Equatable {
    public var id: UUID
    public var setNumber: Int
    public var weightKg: Double?
    public var reps: Int
    public var isBodyweight: Bool
    public var notes: String?
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        setNumber: Int,
        weightKg: Double? = nil,
        reps: Int = 10,
        isBodyweight: Bool = false,
        notes: String? = nil,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weightKg = isBodyweight ? nil : weightKg
        self.reps = max(0, reps)
        self.isBodyweight = isBodyweight
        self.notes = notes
        self.isCompleted = isCompleted
    }

    public var effectiveWeight: Double {
        return isBodyweight ? 0.0 : (weightKg ?? 0.0)
    }

    public var volume: Double {
        return effectiveWeight * Double(reps)
    }

    public var displaySummary: String {
        if isBodyweight {
            return "\(reps) تكرار (وزن الجسم)"
        } else {
            let weightStr = String(format: "%.1f", weightKg ?? 0).replacingOccurrences(of: ".0", with: "")
            return "\(weightStr) كجم × \(reps)"
        }
    }
}
