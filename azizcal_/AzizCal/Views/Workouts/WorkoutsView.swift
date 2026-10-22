import SwiftUI

public struct WorkoutsView: View {
    @StateObject private var viewModel: WorkoutsViewModel
    @State private var showingStartModal = false
    @State private var workoutTitleInput: String = "Push"
    @State private var showingActiveSheet = false

    public init(viewModel: WorkoutsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Active Workout in progress banner (if any)
                    if viewModel.isWorkoutActive {
                        CardContainer {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Circle()
                                        .fill(ArabicTheme.primaryGreen)
                                        .frame(width: 10, height: 10)
                                    Text("حصة تدريبية جارية حالياً")
                                        .font(.subheadline.bold())
                                        .foregroundColor(ArabicTheme.primaryGreen)
                                    Spacer()
                                    Text(viewModel.activeSession?.title ?? "")
                                        .font(.headline)
                                }

                                Text("لديك حصة محفوظة قيد العمل، يمكنك المتابعة من حيث توقفت.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Button(action: { showingActiveSheet = true }) {
                                    Text("متابعة الحصة الآن")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .background(ArabicTheme.workoutPurple)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 4)
                            }
                        }
                    }

                    // Start New Workout Button
                    PrimaryButton(
                        title: "بدء حصة تدريبية جديدة",
                        icon: "play.circle.fill",
                        color: ArabicTheme.workoutPurple
                    ) {
                        showingStartModal = true
                    }

                    // Past Sessions Header
                    HStack {
                        Text("سجل الحصص التدريبية")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Text("(\(viewModel.pastSessions.count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 8)

                    // Past Sessions List
                    if viewModel.pastSessions.isEmpty {
                        EmptyStateView(
                            icon: "dumbbell",
                            title: "لا توجد حصص تدريبية سابقة",
                            subtitle: "ابدأ بتسجيل أول حصة تدريبية في النادي لتتبع أوزانك وتكراراتك وتطورك الرياضي.",
                            actionTitle: "بدء أول حصة"
                        ) {
                            showingStartModal = true
                        }
                    } else {
                        VStack(spacing: 12) {
                            ForEach(viewModel.pastSessions) { session in
                                NavigationLink(destination: PastWorkoutDetailView(session: session, viewModel: viewModel)) {
                                    CardContainer {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(session.title)
                                                    .font(.headline)
                                                    .foregroundColor(.primary)

                                                Text(formatDate(session.date))
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)

                                                Text("\(session.exercises.count) تمارين • \(session.totalSetsCount) مجموعة")
                                                    .font(.caption2.bold())
                                                    .foregroundColor(ArabicTheme.workoutPurple)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.left")
                                                .font(.caption.bold())
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("التمارين")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingStartModal) {
                startWorkoutModal
            }
            .sheet(isPresented: $showingActiveSheet) {
                ActiveWorkoutView(viewModel: viewModel)
            }
        }
        .arabicRTL()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "EEEE، d MMMM yyyy"
        return formatter.string(from: date)
    }

    private var startWorkoutModal: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("اسم الحصة التدريبية:")
                        .font(.subheadline.bold())
                    TextField("مثال: Push أو أرجل أو صدر وتراي", text: $workoutTitleInput)
                        .padding(12)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()

                // Preset Titles
                VStack(alignment: .leading, spacing: 8) {
                    Text("تسميات شائعة:")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    HStack(spacing: 8) {
                        ForEach(["Push", "Pull", "Legs", "صدر وباي", "ظهر وتراي", "أكتاف وبطن"], id: \.self) { preset in
                            Button(action: { workoutTitleInput = preset }) {
                                Text(preset)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.secondary.opacity(0.12))
                                    .cornerRadius(8)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                PrimaryButton(
                    title: "بدء التمرين الآن",
                    icon: "play.fill",
                    color: ArabicTheme.workoutPurple
                ) {
                    viewModel.startNewWorkout(title: workoutTitleInput)
                    showingStartModal = false
                    showingActiveSheet = true
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("حصة تدريبية جديدة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { showingStartModal = false }
                }
            }
        }
        .arabicRTL()
    }
}
