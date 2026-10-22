import Foundation

public struct SavedFood: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var baseAmount: Double
    public var unit: String
    public var caloriesPerBase: Double
    public var proteinPerBase: Double
    public var carbsPerBase: Double
    public var fatPerBase: Double
    public var isFavorite: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        baseAmount: Double = 100,
        unit: String = "غرام",
        caloriesPerBase: Double,
        proteinPerBase: Double,
        carbsPerBase: Double,
        fatPerBase: Double,
        isFavorite: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.baseAmount = baseAmount > 0 ? baseAmount : 100
        self.unit = unit
        self.caloriesPerBase = caloriesPerBase
        self.proteinPerBase = proteinPerBase
        self.carbsPerBase = carbsPerBase
        self.fatPerBase = fatPerBase
        self.isFavorite = isFavorite
        self.createdAt = createdAt
    }

    public func calculateNutrition(forAmount amount: Double) -> (calories: Double, protein: Double, carbs: Double, fat: Double) {
        guard baseAmount > 0, amount >= 0 else {
            return (0, 0, 0, 0)
        }
        let ratio = amount / baseAmount
        let cals = (caloriesPerBase * ratio * 10).rounded() / 10
        let p = (proteinPerBase * ratio * 10).rounded() / 10
        let c = (carbsPerBase * ratio * 10).rounded() / 10
        let f = (fatPerBase * ratio * 10).rounded() / 10
        return (cals, p, c, f)
    }

    public static func validate(
        name: String,
        baseAmount: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double
    ) -> Result<Void, String> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .failure("اسم الطعام مطلوب")
        }
        if baseAmount <= 0 || baseAmount.isNaN || baseAmount.isInfinite {
            return .failure("يجب أن تكون الكمية الأساسية أكبر من صفر (مثلاً 100)")
        }
        if calories < 0 || calories.isNaN || calories.isInfinite {
            return .failure("لا يمكن أن تكون السعرات سالبة")
        }
        if protein < 0 || protein.isNaN || protein.isInfinite {
            return .failure("لا يمكن أن يكون البروتين سالباً")
        }
        if carbs < 0 || carbs.isNaN || carbs.isInfinite {
            return .failure("لا يمكن أن تكون الكربوهيدرات سالبة")
        }
        if fat < 0 || fat.isNaN || fat.isInfinite {
            return .failure("لا يمكن أن تكون الدهون سالبة")
        }
        return .success(())
    }
}
