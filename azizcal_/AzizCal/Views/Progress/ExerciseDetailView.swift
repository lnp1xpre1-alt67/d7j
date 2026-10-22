import SwiftUI

public struct ExerciseDetailView: View {
    public let exerciseName: String
    @ObservedObject var viewModel: ProgressViewModel

    private var history: [ExerciseProgressPoint] {
        viewModel.history(for: exerciseName)
    }

    private var pr: ExercisePersonalRecord {
        viewModel.personalRecord(for: exerciseName)
    }

    private var lastPerformance: ExerciseProgressPoint? {
        viewModel.lastPerformance(for: exerciseName)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Personal Record Card
                CardContainer {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                                .font(.title2)
                            Text("أفضل أداء مسجل (PR)")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "%.1f كجم", pr.maxWeight))
                                .font(.title3.bold())
                                .foregroundColor(ArabicTheme.workoutPurple)
                        }

                        Text("المعيار: \(pr.definition)")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        if let date = pr.achievedDate {
                            Text("تاريخ الإنجاز: \(formatDate(date))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Last Logged Card
                if let last = lastPerformance {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                    .foregroundColor(ArabicTheme.primaryGreen)
                                Text("آخر أداء تم تسجيله")
                                    .font(.headline)
                                Spacer()
                                Text(last.bestSetSummary)
                                    .font(.subheadline.bold())
                            }

                            Text("التاريخ: \(formatDate(last.date))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Progression Chart
                CardContainer {
                    if viewModel.canShowChart(for: exerciseName) {
                        ExerciseChartView(points: history)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 32))
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            Text("البيانات غير كافية لرسم المخطط")
                                .font(.subheadline.bold())
                            Text("يتطلب رسم منحنى التقدم جلستين تدريبيتين على الأقل لنفس التمرين لتفادي عرض بيانات غير دقيقة.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                }

                // Full History Log
                VStack(alignment: .leading, spacing: 8) {
                    Text("سجل الجلسات السابقة لهذا التمرين")
                        .font(.headline)
                        .padding(.horizontal, 4)

                    ForEach(history.reversed()) { point in
                        CardContainer {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(formatDate(point.date))
                                        .font(.subheadline.bold())
                                    Text("أفضل مجموعة: \(point.bestSetSummary)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("\(String(format: "%.1f", point.maxWeight)) كجم")
                                        .font(.headline)
                                        .foregroundColor(ArabicTheme.workoutPurple)
                                    Text("إجمالي: \(point.totalReps) تكرار")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
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
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
        .arabicRTL()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}
