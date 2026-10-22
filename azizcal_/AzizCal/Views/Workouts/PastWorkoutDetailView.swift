import SwiftUI

public struct PastWorkoutDetailView: View {
    public let session: WorkoutSession
    @ObservedObject var viewModel: WorkoutsViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingRepeatAlert = false
    @State private var showingDeleteAlert = false

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "EEEE، d MMMM yyyy - HH:mm"
        return formatter.string(from: session.date)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Info
                CardContainer {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(session.title)
                            .font(.title2.bold())
                        Text(formattedDate)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 16) {
                            Text("\(session.exercises.count) تمارين")
                                .font(.caption.bold())
                                .foregroundColor(ArabicTheme.workoutPurple)
                            Text("\(session.totalSetsCount) مجموعات")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            Text("إجمالي الحجم: \(String(format: "%.0f", session.totalVolume)) كجم")
                                .font(.caption.bold())
                                .foregroundColor(ArabicTheme.primaryGreen)
                        }
                        .padding(.top, 4)
                    }
                }

                // Exercises & Sets
                ForEach(session.exercises) { exercise in
                    CardContainer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(exercise.name)
                                .font(.headline)

                            ForEach(exercise.sets) { set in
                                HStack {
                                    Text("المجموعة \(set.setNumber)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text(set.displaySummary)
                                        .font(.subheadline.bold())
                                }
                                .padding(.vertical, 2)
                                Divider()
                            }
                        }
                    }
                }

                // Repeat Workout Button
                PrimaryButton(
                    title: "تكرار هذه الحصة لليوم",
                    icon: "plus.square.on.square",
                    color: ArabicTheme.workoutPurple
                ) {
                    viewModel.duplicateWorkout(session, toDate: Date())
                    showingRepeatAlert = true
                }
                .padding(.top, 8)

                // Delete Button
                Button(action: { showingDeleteAlert = true }) {
                    Text("حذف هذه الحصة من السجل")
                        .font(.footnote)
                        .foregroundColor(.red)
                }
                .padding(.top, 4)

                Spacer(minLength: 40)
            }
            .padding()
        }
        .background(ArabicTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("تفاصيل الحصة")
        .navigationBarTitleDisplayMode(.inline)
        .alert(isPresented: $showingRepeatAlert) {
            Alert(
                title: Text("تم التكرار"),
                message: Text("تم نسخ الحصة بنجاح إلى سجل اليوم لتسهيل بدء التدريب بنفس التمارين."),
                dismissButton: .default(Text("حسناً")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("حذف الحصة"),
                message: Text("هل أنت متأكد من حذف هذه الحصة نهائياً؟"),
                primaryButton: .destructive(Text("حذف")) {
                    viewModel.deleteWorkout(session)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel(Text("إلغاء"))
            )
        }
        .arabicRTL()
    }
}
