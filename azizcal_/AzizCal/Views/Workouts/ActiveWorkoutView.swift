import SwiftUI

public struct ActiveWorkoutView: View {
    @ObservedObject var viewModel: WorkoutsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var exerciseNameInput: String = ""
    @State private var showingAddExerciseDialog = false
    @State private var showingDiscardAlert = false

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Autosave Banner
                    HStack {
                        Image(systemName: "checkmark.icloud.fill")
                            .foregroundColor(ArabicTheme.primaryGreen)
                        Text("يتم حفظ التعديلات تلقائياً لمنع فقدان البيانات")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)

                    // Session Title and Summary Card
                    if let session = viewModel.activeSession {
                        CardContainer {
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(session.title)
                                        .font(.title3.bold())
                                    Spacer()
                                    Text("\(session.exercises.count) تمارين")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        // Exercises List
                        if session.exercises.isEmpty {
                            EmptyStateView(
                                icon: "dumbbell",
                                title: "لا توجد تمارين مضافة بعد",
                                subtitle: "أضف تمريناً مخصصاً مثل Bench Press أو Squat للبدء بتسجيل المجموعات والأوزان.",
                                actionTitle: "إضافة تمرين"
                            ) {
                                showingAddExerciseDialog = true
                            }
                        } else {
                            VStack(spacing: 16) {
                                ForEach(session.exercises) { exercise in
                                    exerciseCard(exercise: exercise)
                                }
                            }
                        }
                    }

                    // Add Exercise Button
                    Button(action: { showingAddExerciseDialog = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("إضافة تمرين جديد")
                                .font(.subheadline.bold())
                        }
                        .foregroundColor(ArabicTheme.workoutPurple)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(ArabicTheme.workoutPurple.opacity(0.12))
                        .cornerRadius(12)
                    }

                    // Finish Workout Button
                    PrimaryButton(
                        title: "إنهاء الحصة وحفظها",
                        icon: "checkmark.circle.fill",
                        color: ArabicTheme.primaryGreen
                    ) {
                        viewModel.finishAndSaveWorkout()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .padding(.top, 8)

                    // Discard Button
                    Button(action: { showingDiscardAlert = true }) {
                        Text("إلغاء الحصة الحالية")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 4)

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle(viewModel.activeSession?.title ?? "حصة تدريبية")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") {
                        // Dismissing doesn't delete, because draft is autosaved!
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddExerciseDialog) {
                addExerciseModal
            }
            .alert(isPresented: $showingDiscardAlert) {
                Alert(
                    title: Text("إلغاء الحصة"),
                    message: Text("هل أنت متأكد من رغبتك في إلغاء هذه الحصة ومسح مسودتها؟"),
                    primaryButton: .destructive(Text("إلغاء ومسح")) {
                        viewModel.discardActiveWorkout()
                        presentationMode.wrappedValue.dismiss()
                    },
                    secondaryButton: .cancel(Text("متابعة التمرين"))
                )
            }
        }
        .arabicRTL()
    }

    // MARK: - Exercise Card
    private func exerciseCard(exercise: WorkoutExercise) -> some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(exercise.name)
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        viewModel.removeExercise(exerciseId: exercise.id)
                    }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.red.opacity(0.8))
                    }
                }

                // Table Header
                HStack(spacing: 8) {
                    Text("المجموعة").font(.caption2.bold()).foregroundColor(.secondary).frame(width: 32)
                    Text("الوزن").font(.caption2.bold()).foregroundColor(.secondary).frame(width: 70)
                    Text("التكرار").font(.caption2.bold()).foregroundColor(.secondary).frame(width: 70)
                    Spacer()
                    Text("إنجاز").font(.caption2.bold()).foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)

                Divider()

                // Sets Rows
                VStack(spacing: 6) {
                    ForEach(exercise.sets) { setItem in
                        ExerciseSetRowView(
                            exerciseId: exercise.id,
                            setItem: setItem,
                            onUpdate: { updated in
                                viewModel.updateSet(exerciseId: exercise.id, set: updated)
                            },
                            onDelete: {
                                viewModel.removeSet(fromExerciseId: exercise.id, setId: setItem.id)
                            }
                        )
                    }
                }

                // Add Set Button
                Button(action: {
                    viewModel.addSet(toExerciseId: exercise.id)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                        Text("إضافة مجموعة")
                    }
                    .font(.caption.bold())
                    .foregroundColor(ArabicTheme.workoutPurple)
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Add Exercise Modal
    private var addExerciseModal: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("اسم التمرين:")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    TextField("مثال: Bench Press أو سحب ظهر", text: $exerciseNameInput)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()

                // Quick suggestions
                VStack(alignment: .leading, spacing: 10) {
                    Text("مقترحات سريعة:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(["Bench Press", "Squat", "Deadlift", "Overhead Press", "Lat Pulldown", "Biceps Curl", "Leg Extension", "عقلة (Pull-up)", "تمرين ضغط (Push-up)"], id: \.self) { suggestion in
                                Button(action: {
                                    exerciseNameInput = suggestion
                                }) {
                                    Text(suggestion)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.secondary.opacity(0.12))
                                        .cornerRadius(8)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                PrimaryButton(
                    title: "إضافة التمرين للحصة",
                    icon: "plus.circle.fill",
                    color: ArabicTheme.workoutPurple
                ) {
                    if !exerciseNameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                        viewModel.addExercise(name: exerciseNameInput)
                        exerciseNameInput = ""
                        showingAddExerciseDialog = false
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("تمرين جديد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { showingAddExerciseDialog = false }
                }
            }
        }
        .arabicRTL()
    }
}
