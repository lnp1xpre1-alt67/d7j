import Foundation
import Combine

public final class DataStore: ObservableObject {
    public static let shared = DataStore()

    // Published properties for reactive UI
    @Published public private(set) var goals: UserGoals?
    @Published public private(set) var foodItems: [FoodItem] = []
    @Published public private(set) var savedFoods: [SavedFood] = []
    @Published public private(set) var workoutSessions: [WorkoutSession] = []
    @Published public private(set) var activeWorkoutDraft: WorkoutSession?

    private let fileManager = FileManager.default
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    // Filenames
    private let goalsFileName = "user_goals.json"
    private let foodsFileName = "food_items.json"
    private let savedFoodsFileName = "saved_foods.json"
    private let workoutsFileName = "workout_sessions.json"
    private let activeDraftFileName = "active_workout_draft.json"

    public init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        self.jsonEncoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = decoder

        loadAllData()
    }

    private var documentsDirectory: URL {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    private func fileURL(for name: String) -> URL {
        return documentsDirectory.appendingPathComponent(name)
    }

    // MARK: - Loading
    public func loadAllData() {
        loadGoals()
        loadFoodItems()
        loadSavedFoods()
        loadWorkoutSessions()
        loadActiveWorkoutDraft()

        // Seed initial saved foods if user has none
        if savedFoods.isEmpty {
            seedInitialSavedFoods()
        }
    }

    // MARK: - Goals
    public var hasCompletedOnboarding: Bool {
        return goals != nil
    }

    public func saveGoals(_ newGoals: UserGoals) {
        self.goals = newGoals
        persist(newGoals, to: goalsFileName)
    }

    public func resetGoals() {
        self.goals = nil
        removeFile(named: goalsFileName)
    }

    private func loadGoals() {
        self.goals = read(from: goalsFileName, as: UserGoals.self)
    }

    // MARK: - Food Items
    public func addFoodItem(_ item: FoodItem) {
        foodItems.insert(item, at: 0)
        persist(foodItems, to: foodsFileName)
    }

    public func updateFoodItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems[index] = item
            persist(foodItems, to: foodsFileName)
        }
    }

    public func deleteFoodItem(withId id: UUID) {
        foodItems.removeAll { $0.id == id }
        persist(foodItems, to: foodsFileName)
    }

    public func foodItems(forDate targetDate: Date) -> [FoodItem] {
        let calendar = Calendar.current
        return foodItems.filter { calendar.isDate($0.date, inSameDayAs: targetDate) }
    }

    public func repeatFoodItem(_ item: FoodItem, toDate: Date) {
        var copy = item
        copy.id = UUID()
        copy.date = toDate
        copy.createdAt = Date()
        addFoodItem(copy)
    }

    public func copyMeal(from mealType: MealType, sourceDate: Date, to destinationDate: Date) {
        let sourceItems = foodItems(forDate: sourceDate).filter { $0.mealType == mealType }
        for item in sourceItems {
            var copy = item
            copy.id = UUID()
            copy.date = destinationDate
            copy.createdAt = Date()
            foodItems.insert(copy, at: 0)
        }
        persist(foodItems, to: foodsFileName)
    }

    private func loadFoodItems() {
        self.foodItems = read(from: foodsFileName, as: [FoodItem].self) ?? []
    }

    // MARK: - Saved Foods
    public func addSavedFood(_ item: SavedFood) {
        savedFoods.append(item)
        persist(savedFoods, to: savedFoodsFileName)
    }

    public func updateSavedFood(_ item: SavedFood) {
        if let index = savedFoods.firstIndex(where: { $0.id == item.id }) {
            savedFoods[index] = item
            persist(savedFoods, to: savedFoodsFileName)
        }
    }

    public func deleteSavedFood(withId id: UUID) {
        savedFoods.removeAll { $0.id == id }
        persist(savedFoods, to: savedFoodsFileName)
    }

    public func toggleFavoriteSavedFood(withId id: UUID) {
        if let index = savedFoods.firstIndex(where: { $0.id == id }) {
            savedFoods[index].isFavorite.toggle()
            persist(savedFoods, to: savedFoodsFileName)
        }
    }

    private func loadSavedFoods() {
        self.savedFoods = read(from: savedFoodsFileName, as: [SavedFood].self) ?? []
    }

    private func seedInitialSavedFoods() {
        let sampleFoods: [SavedFood] = [
            SavedFood(name: "صدور دجاج مشوية", baseAmount: 100, unit: "غرام", caloriesPerBase: 165, proteinPerBase: 31, carbsPerBase: 0, fatPerBase: 3.6, isFavorite: true),
            SavedFood(name: "أرز أبيض مطبوخ", baseAmount: 100, unit: "غرام", caloriesPerBase: 130, proteinPerBase: 2.7, carbsPerBase: 28.2, fatPerBase: 0.3, isFavorite: true),
            SavedFood(name: "خبز توست أسمر", baseAmount: 1, unit: "قطعة", caloriesPerBase: 75, proteinPerBase: 3.5, carbsPerBase: 13, fatPerBase: 1, isFavorite: true),
            SavedFood(name: "زبادي يوناني سادة", baseAmount: 100, unit: "غرام", caloriesPerBase: 59, proteinPerBase: 10, carbsPerBase: 3.6, fatPerBase: 0.4, isFavorite: true),
            SavedFood(name: "مسحوق بروتين (واي)", baseAmount: 30, unit: "غرام", caloriesPerBase: 120, proteinPerBase: 24, carbsPerBase: 2, fatPerBase: 1.5, isFavorite: true),
            SavedFood(name: "بيض مسلوق كامل", baseAmount: 1, unit: "بيضة", caloriesPerBase: 78, proteinPerBase: 6.3, carbsPerBase: 0.6, fatPerBase: 5.3, isFavorite: true),
            SavedFood(name: "زبدة الفول السوداني", baseAmount: 30, unit: "غرام", caloriesPerBase: 188, proteinPerBase: 8, carbsPerBase: 6, fatPerBase: 16, isFavorite: false),
            SavedFood(name: "شوفان جاف", baseAmount: 100, unit: "غرام", caloriesPerBase: 389, proteinPerBase: 16.9, carbsPerBase: 66.3, fatPerBase: 6.9, isFavorite: false)
        ]
        self.savedFoods = sampleFoods
        persist(sampleFoods, to: savedFoodsFileName)
    }

    // MARK: - Workout Sessions
    public func saveWorkoutSession(_ session: WorkoutSession) {
        if let index = workoutSessions.firstIndex(where: { $0.id == session.id }) {
            workoutSessions[index] = session
        } else {
            workoutSessions.insert(session, at: 0)
        }
        clearActiveWorkoutDraft()
        persist(workoutSessions, to: workoutsFileName)
    }

    public func deleteWorkoutSession(withId id: UUID) {
        workoutSessions.removeAll { $0.id == id }
        persist(workoutSessions, to: workoutsFileName)
    }

    public func duplicateWorkoutSession(_ session: WorkoutSession, toDate: Date) {
        var copy = session
        copy.id = UUID()
        copy.date = toDate
        copy.createdAt = Date()
        // Reset set completion status for fresh session
        copy.exercises = session.exercises.map { exercise in
            var exCopy = exercise
            exCopy.id = UUID()
            exCopy.sets = exercise.sets.map { s in
                var setCopy = s
                setCopy.id = UUID()
                setCopy.isCompleted = false
                return setCopy
            }
            return exCopy
        }
        workoutSessions.insert(copy, at: 0)
        persist(workoutSessions, to: workoutsFileName)
    }

    public func workoutSessions(forDate targetDate: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        return workoutSessions.filter { calendar.isDate($0.date, inSameDayAs: targetDate) }
    }

    private func loadWorkoutSessions() {
        self.workoutSessions = read(from: workoutsFileName, as: [WorkoutSession].self) ?? []
    }

    // MARK: - Active Workout Autosave Draft
    public func saveActiveWorkoutDraft(_ draft: WorkoutSession) {
        self.activeWorkoutDraft = draft
        persist(draft, to: activeDraftFileName)
    }

    public func clearActiveWorkoutDraft() {
        self.activeWorkoutDraft = nil
        removeFile(named: activeDraftFileName)
    }

    private func loadActiveWorkoutDraft() {
        self.activeWorkoutDraft = read(from: activeDraftFileName, as: WorkoutSession.self)
    }

    // MARK: - Backup and Reset
    public func exportAllData() -> BackupData {
        return BackupData(
            version: 1,
            exportedAt: Date(),
            goals: self.goals,
            foodItems: self.foodItems,
            savedFoods: self.savedFoods,
            workoutSessions: self.workoutSessions
        )
    }

    public func restoreBackup(_ backup: BackupData) {
        if let g = backup.goals {
            self.goals = g
            persist(g, to: goalsFileName)
        }

        // Merge or replace foods with duplicate prevention by ID
        var currentFoodDict = Dictionary(uniqueKeysWithValues: foodItems.map { ($0.id, $0) })
        for item in backup.foodItems {
            currentFoodDict[item.id] = item
        }
        self.foodItems = Array(currentFoodDict.values).sorted(by: { $0.date > $1.date })
        persist(self.foodItems, to: foodsFileName)

        var currentSavedDict = Dictionary(uniqueKeysWithValues: savedFoods.map { ($0.id, $0) })
        for item in backup.savedFoods {
            currentSavedDict[item.id] = item
        }
        self.savedFoods = Array(currentSavedDict.values).sorted(by: { $0.name < $1.name })
        persist(self.savedFoods, to: savedFoodsFileName)

        var currentWorkoutsDict = Dictionary(uniqueKeysWithValues: workoutSessions.map { ($0.id, $0) })
        for session in backup.workoutSessions {
            currentWorkoutsDict[session.id] = session
        }
        self.workoutSessions = Array(currentWorkoutsDict.values).sorted(by: { $0.date > $1.date })
        persist(self.workoutSessions, to: workoutsFileName)
    }

    public func resetAllData() {
        self.goals = nil
        self.foodItems = []
        self.savedFoods = []
        self.workoutSessions = []
        self.activeWorkoutDraft = nil

        removeFile(named: goalsFileName)
        removeFile(named: foodsFileName)
        removeFile(named: savedFoodsFileName)
        removeFile(named: workoutsFileName)
        removeFile(named: activeDraftFileName)
    }

    // MARK: - File I/O Helpers
    private func persist<T: Encodable>(_ object: T, to fileName: String) {
        do {
            let data = try jsonEncoder.encode(object)
            let url = fileURL(for: fileName)
            try data.write(to: url, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Error persisting \(fileName): \(error.localizedDescription)")
        }
    }

    private func read<T: Decodable>(from fileName: String, as type: T.Type) -> T? {
        let url = fileURL(for: fileName)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try jsonDecoder.decode(type, from: data)
        } catch {
            print("Error reading \(fileName): \(error.localizedDescription)")
            return nil
        }
    }

    private func removeFile(named fileName: String) {
        let url = fileURL(for: fileName)
        if fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
