import Foundation

public enum AnalyticsTimeframe: String, CaseIterable, Identifiable {
    case week = "أسبوع"
    case month = "30 يوم"
    case threeMonths = "90 يوم"
    case all = "الكل"

    public var id: String { rawValue }

    public var days: Int? {
        switch self {
        case .week: return 7
        case .month: return 30
        case .threeMonths: return 90
        case .all: return nil
        }
    }
}

public struct ExerciseProgressPoint: Identifiable, Equatable {
    public var id: UUID
    public var date: Date
    public var maxWeight: Double
    public var totalReps: Int
    public var totalVolume: Double
    public var bestSetSummary: String

    public init(id: UUID = UUID(), date: Date, maxWeight: Double, totalReps: Int, totalVolume: Double, bestSetSummary: String) {
        self.id = id
        self.date = date
        self.maxWeight = maxWeight
        self.totalReps = totalReps
        self.totalVolume = totalVolume
        self.bestSetSummary = bestSetSummary
    }
}

public struct ExercisePersonalRecord {
    public var maxWeight: Double
    public var achievedDate: Date?
    public var bestSetSummary: String
    public var definition: String = "أعلى وزن تم رفعه في مجموعة واحدة"
}

public struct NutritionAverages {
    public var averageCalories: Double
    public var averageProtein: Double
    public var averageCarbs: Double
    public var averageFat: Double
    public var loggedDaysCount: Int
    public var totalDaysInPeriod: Int
    public var adherenceDaysCount: Int
    public var explanation: String
}

public final class AnalyticsService {
    public static let shared = AnalyticsService()

    private init() {}

    // MARK: - Nutrition Analytics
    public func calculateNutritionAverages(
        foodItems: [FoodItem],
        goals: UserGoals?,
        timeframe: AnalyticsTimeframe
    ) -> NutritionAverages {
        let calendar = Calendar.current
        let now = Date()

        let filteredItems: [FoodItem]
        let totalPeriodDays: Int

        if let days = timeframe.days {
            guard let startDate = calendar.date(byAdding: .day, value: -days, to: now) else {
                return emptyAverages()
            }
            filteredItems = foodItems.filter { $0.date >= startDate }
            totalPeriodDays = days
        } else {
            filteredItems = foodItems
            if let firstDate = foodItems.map({ $0.date }).min() {
                let diff = calendar.dateComponents([.day], from: firstDate, to: now).day ?? 1
                totalPeriodDays = max(1, diff + 1)
            } else {
                totalPeriodDays = 0
            }
        }

        // Group by day string "yyyy-MM-dd"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let groupedByDay = Dictionary(grouping: filteredItems) { item in
            formatter.string(from: item.date)
        }

        let loggedDaysCount = groupedByDay.keys.count

        guard loggedDaysCount > 0 else {
            return NutritionAverages(
                averageCalories: 0,
                averageProtein: 0,
                averageCarbs: 0,
                averageFat: 0,
                loggedDaysCount: 0,
                totalDaysInPeriod: totalPeriodDays,
                adherenceDaysCount: 0,
                explanation: "لا توجد سجلات غذائية مسجلة في هذه الفترة."
            )
        }

        var totalCals: Double = 0
        var totalP: Double = 0
        var totalC: Double = 0
        var totalF: Double = 0
        var adherenceDays = 0

        for (_, items) in groupedByDay {
            let dayCals = items.reduce(0.0) { $0 + $1.calories }
            let dayP = items.reduce(0.0) { $0 + $1.protein }
            let dayC = items.reduce(0.0) { $0 + $1.carbs }
            let dayF = items.reduce(0.0) { $0 + $1.fat }

            totalCals += dayCals
            totalP += dayP
            totalC += dayC
            totalF += dayF

            if let targetCals = goals?.calories, targetCals > 0 {
                // Within 10% of target is considered adhering
                let diff = abs(dayCals - targetCals)
                if diff <= (targetCals * 0.10) {
                    adherenceDays += 1
                }
            }
        }

        let count = Double(loggedDaysCount)
        let explanation = "تم احتساب المتوسط بناءً على الأيام الفعلية التي قمت بتسجيل وجبات فيها (\(loggedDaysCount) يوم) فقط، دون احتساب الأيام الفارغة كصفر لتجنب تشويه المعدل الحقيقي."

        return NutritionAverages(
            averageCalories: (totalCals / count).rounded(),
            averageProtein: ((totalP / count) * 10).rounded() / 10,
            averageCarbs: ((totalC / count) * 10).rounded() / 10,
            averageFat: ((totalF / count) * 10).rounded() / 10,
            loggedDaysCount: loggedDaysCount,
            totalDaysInPeriod: totalPeriodDays,
            adherenceDaysCount: adherenceDays,
            explanation: explanation
        )
    }

    private func emptyAverages() -> NutritionAverages {
        return NutritionAverages(
            averageCalories: 0,
            averageProtein: 0,
            averageCarbs: 0,
            averageFat: 0,
            loggedDaysCount: 0,
            totalDaysInPeriod: 0,
            adherenceDaysCount: 0,
            explanation: "لا توجد بيانات متاحة."
        )
    }

    // MARK: - Exercise Progress
    public func allUniqueExerciseNames(from sessions: [WorkoutSession]) -> [String] {
        var names = Set<String>()
        for session in sessions {
            for exercise in session.exercises {
                let trimmed = exercise.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    names.insert(trimmed)
                }
            }
        }
        return Array(names).sorted()
    }

    public func progressHistory(for exerciseName: String, in sessions: [WorkoutSession]) -> [ExerciseProgressPoint] {
        let cleanName = exerciseName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var points: [ExerciseProgressPoint] = []

        let sortedSessions = sessions.sorted(by: { $0.date < $1.date })

        for session in sortedSessions {
            for exercise in session.exercises {
                if exercise.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == cleanName {
                    let point = ExerciseProgressPoint(
                        date: session.date,
                        maxWeight: exercise.maxWeight,
                        totalReps: exercise.totalReps,
                        totalVolume: exercise.totalVolume,
                        bestSetSummary: exercise.bestSetSummary
                    )
                    points.append(point)
                }
            }
        }

        return points
    }

    public func personalRecord(for exerciseName: String, in sessions: [WorkoutSession]) -> ExercisePersonalRecord {
        let points = progressHistory(for: exerciseName, in: sessions)
        guard let maxPoint = points.max(by: { $0.maxWeight < $1.maxWeight }), maxPoint.maxWeight > 0 else {
            return ExercisePersonalRecord(
                maxWeight: 0,
                achievedDate: nil,
                bestSetSummary: "لا يوجد رقم مسجل بعد",
                definition: "أعلى وزن تم تسجيله في أي تكرار أو مجموعة"
            )
        }

        return ExercisePersonalRecord(
            maxWeight: maxPoint.maxWeight,
            achievedDate: maxPoint.date,
            bestSetSummary: maxPoint.bestSetSummary,
            definition: "أعلى وزن تم تسجيله في أي تكرار أو مجموعة"
        )
    }

    public func mostFrequentExercises(from sessions: [WorkoutSession], limit: Int = 5) -> [(name: String, count: Int)] {
        var counts: [String: Int] = [:]
        for session in sessions {
            for exercise in session.exercises {
                let name = exercise.name.trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty {
                    counts[name, default: 0] += 1
                }
            }
        }
        let sorted = counts.sorted(by: { $0.value > $1.value })
        return Array(sorted.prefix(limit)).map { ($0.key, $0.value) }
    }
}
