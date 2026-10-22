import Foundation

public struct BackupData: Codable {
    public var version: Int
    public var exportedAt: Date
    public var goals: UserGoals?
    public var foodItems: [FoodItem]
    public var savedFoods: [SavedFood]
    public var workoutSessions: [WorkoutSession]

    public init(
        version: Int = 1,
        exportedAt: Date = Date(),
        goals: UserGoals? = nil,
        foodItems: [FoodItem] = [],
        savedFoods: [SavedFood] = [],
        workoutSessions: [WorkoutSession] = []
    ) {
        self.version = version
        self.exportedAt = exportedAt
        self.goals = goals
        self.foodItems = foodItems
        self.savedFoods = savedFoods
        self.workoutSessions = workoutSessions
    }
}
