import Foundation

public struct FoodItem: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String
    public var amount: Double
    public var unit: String
    public var calories: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var mealType: MealType
    public var date: Date
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        name: String,
        amount: Double,
        unit: String = "غرام",
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        mealType: MealType,
        date: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.mealType = mealType
        self.date = date
        self.createdAt = createdAt
    }

    public static func validate(
        name: String,
        amount: Double,
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double
    ) -> Result<Void, String> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .failure("اسم الطعام مطلوب")
        }
        if amount <= 0 || amount.isNaN || amount.isInfinite {
            return .failure("يجب أن تكون الكمية أكبر من صفر")
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
