import Foundation
import Combine

public final class WorkoutsViewModel: ObservableObject {
    @Published public var activeSession: WorkoutSession?
    @Published public var isWorkoutActive: Bool = false
    @Published public var showingNewWorkoutPrompt: Bool = false
    @Published public var newWorkoutTitle: String = ""
    @Published public var selectedDate: Date = Date()
    @Published public var selectedPastSession: WorkoutSession?
    @Published public var newExerciseName: String = ""
    @Published public var showingAddExerciseModal: Bool = false
    @Published public var errorMessage: String?

    public let store: DataStore
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared) {
        self.store = store

        store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)

        // Check for recovered draft from previous unclosed workout
        if let draft = store.activeWorkoutDraft {
            self.activeSession = draft
            self.isWorkoutActive = true
        }
    }

    public var pastSessions: [WorkoutSession] {
        store.workoutSessions.sorted { $0.date > $1.date }
    }

    public func startNewWorkout(title: String, date: Date = Date()) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalTitle = trimmed.isEmpty ? "حصة تدريبية" : trimmed

        let newSession = WorkoutSession(
            title: finalTitle,
            date: date,
            exercises: [],
            notes: nil,
            createdAt: Date()
        )
        self.activeSession = newSession
        self.isWorkoutActive = true
        store.saveActiveWorkoutDraft(newSession)
    }

    public func addExercise(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, var session = activeSession else { return }

        // Start with 1 default set
        let initialSet = WorkoutSet(setNumber: 1, weightKg: 20, reps: 10, isBodyweight: false)
        let newExercise = WorkoutExercise(name: trimmed, sets: [initialSet])
        session.exercises.append(newExercise)

        self.activeSession = session
        store.saveActiveWorkoutDraft(session)
        newExerciseName = ""
        showingAddExerciseModal = false
    }

    public func addSet(toExerciseId exerciseId: UUID) {
        guard var session = activeSession,
              let exIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }) else { return }

        let currentSets = session.exercises[exIndex].sets
        let nextNumber = currentSets.count + 1
        let lastSet = currentSets.last

        let newSet = WorkoutSet(
            setNumber: nextNumber,
            weightKg: lastSet?.weightKg ?? 20,
            reps: lastSet?.reps ?? 10,
            isBodyweight: lastSet?.isBodyweight ?? false
        )
        session.exercises[exIndex].sets.append(newSet)

        self.activeSession = session
        store.saveActiveWorkoutDraft(session)
    }

    public func removeSet(fromExerciseId exerciseId: UUID, setId: UUID) {
        guard var session = activeSession,
              let exIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }) else { return }

        session.exercises[exIndex].sets.removeAll { $0.id == setId }
        // Re-number remaining sets
        for i in 0..<session.exercises[exIndex].sets.count {
            session.exercises[exIndex].sets[i].setNumber = i + 1
        }

        self.activeSession = session
        store.saveActiveWorkoutDraft(session)
    }

    public func updateSet(exerciseId: UUID, set: WorkoutSet) {
        guard var session = activeSession,
              let exIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = session.exercises[exIndex].sets.firstIndex(where: { $0.id == set.id }) else { return }

        session.exercises[exIndex].sets[setIndex] = set
        self.activeSession = session
        // Auto-save draft on every change
        store.saveActiveWorkoutDraft(session)
    }

    public func toggleSetCompletion(exerciseId: UUID, setId: UUID) {
        guard var session = activeSession,
              let exIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = session.exercises[exIndex].sets.firstIndex(where: { $0.id == setId }) else { return }

        session.exercises[exIndex].sets[setIndex].isCompleted.toggle()
        self.activeSession = session
        store.saveActiveWorkoutDraft(session)
    }

    public func removeExercise(exerciseId: UUID) {
        guard var session = activeSession else { return }
        session.exercises.removeAll { $0.id == exerciseId }
        self.activeSession = session
        store.saveActiveWorkoutDraft(session)
    }

    public func finishAndSaveWorkout() {
        guard let session = activeSession else { return }
        store.saveWorkoutSession(session)
        self.activeSession = nil
        self.isWorkoutActive = false
        store.clearActiveWorkoutDraft()
    }

    public func discardActiveWorkout() {
        self.activeSession = nil
        self.isWorkoutActive = false
        store.clearActiveWorkoutDraft()
    }

    public func duplicateWorkout(_ session: WorkoutSession, toDate: Date = Date()) {
        store.duplicateWorkoutSession(session, toDate: toDate)
    }

    public func deleteWorkout(_ session: WorkoutSession) {
        store.deleteWorkoutSession(withId: session.id)
    }
}
