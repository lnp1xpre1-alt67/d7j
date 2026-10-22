import SwiftUI

public struct ExerciseSetRowView: View {
    public let exerciseId: UUID
    public let setItem: WorkoutSet
    public let onUpdate: (WorkoutSet) -> Void
    public let onDelete: () -> Void

    @State private var weightText: String = ""
    @State private var repsText: String = ""
    @State private var isBodyweight: Bool = false

    public init(
        exerciseId: UUID,
        setItem: WorkoutSet,
        onUpdate: @escaping (WorkoutSet) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.exerciseId = exerciseId
        self.setItem = setItem
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        _weightText = State(initialValue: setItem.weightKg != nil ? String(format: "%.1f", setItem.weightKg!).replacingOccurrences(of: ".0", with: "") : "")
        _repsText = State(initialValue: "\(setItem.reps)")
        _isBodyweight = State(initialValue: setItem.isBodyweight)
    }

    public var body: some View {
        HStack(spacing: 8) {
            // Set Number Badge
            Text("\(setItem.setNumber)")
                .font(.caption.bold())
                .frame(width: 26, height: 26)
                .background(setItem.isCompleted ? ArabicTheme.primaryGreen : Color.secondary.opacity(0.15))
                .foregroundColor(setItem.isCompleted ? .white : .primary)
                .clipShape(Circle())

            if isBodyweight {
                Text("وزن الجسم")
                    .font(.caption.bold())
                    .foregroundColor(ArabicTheme.workoutPurple)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 4) {
                    TextField("0", text: $weightText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .frame(width: 55, height: 32)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                        .onChange(of: weightText) { _ in notifyChange() }
                    Text("كجم")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }

            // Reps Input
            HStack(spacing: 4) {
                TextField("0", text: $repsText)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 32)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(6)
                    .onChange(of: repsText) { _ in notifyChange() }
                Text("تكرار")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Bodyweight toggle button
            Button(action: {
                isBodyweight.toggle()
                notifyChange()
            }) {
                Image(systemName: isBodyweight ? "figure.walk.circle.fill" : "figure.walk.circle")
                    .foregroundColor(isBodyweight ? ArabicTheme.workoutPurple : .secondary)
                    .font(.title3)
            }

            // Completion Checkmark Button
            Button(action: {
                var updated = setItem
                updated.isCompleted.toggle()
                onUpdate(updated)
            }) {
                Image(systemName: setItem.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(setItem.isCompleted ? ArabicTheme.primaryGreen : .secondary)
                    .font(.title3)
            }

            // Delete set
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(4)
            }
        }
        .padding(.vertical, 4)
    }

    private func notifyChange() {
        let w = Double(weightText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces))
        let r = Int(repsText.trimmingCharacters(in: .whitespaces)) ?? setItem.reps
        var updated = setItem
        updated.isBodyweight = isBodyweight
        updated.weightKg = isBodyweight ? nil : (w ?? setItem.weightKg)
        updated.reps = max(0, r)
        onUpdate(updated)
    }
}
