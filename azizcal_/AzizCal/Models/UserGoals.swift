import Foundation

public struct UserGoals: Codable, Equatable {
    public var id: UUID
    public var calories: Double
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        calories: Double,
        protein: Double,
        carbs: Double,
        fat: Double,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.updatedAt = updatedAt
    }

    public static func validate(calories: Double, protein: Double, carbs: Double, fat: Double) -> Result<Void, String> {
        if calories <= 0 || calories.isNaN || calories.isInfinite {
            return .failure("يجب إدخال سعرات حرارية مستهدفة أكبر من صفر")
        }
        if calories > 15000 {
            return .failure("قيمة السعرات المستهدفة مرتفعة جداً وغير منطقية")
        }
        if protein < 0 || protein.isNaN || protein.isInfinite {
            return .failure("لا يمكن أن يكون البروتين قيمة سالبة")
        }
        if carbs < 0 || carbs.isNaN || carbs.isInfinite {
            return .failure("لا يمكن أن تكون الكربوهيدرات قيمة سالبة")
        }
        if fat < 0 || fat.isNaN || fat.isInfinite {
            return .failure("لا يمكن أن تكون الدهون قيمة سالبة")
        }
        if protein == 0 && carbs == 0 && fat == 0 {
            return .failure("يجب إدخال قيمة واحدة على الأقل للماكروز (بروتين، كربوهيدرات، أو دهون)")
        }
        return .success(())
    }
}
