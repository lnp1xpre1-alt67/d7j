import SwiftUI

public struct StatisticsView: View {
    @StateObject private var viewModel: StatisticsViewModel

    public init(viewModel: StatisticsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Timeframe Picker
                    Picker("الفترة الزمنية", selection: $viewModel.selectedTimeframe) {
                        ForEach(AnalyticsTimeframe.allCases) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Explanation Notice
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(ArabicTheme.proteinBlue)
                            .font(.caption)
                        Text(viewModel.nutritionAverages.explanation)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(ArabicTheme.cardBackground)
                    .cornerRadius(10)

                    // Nutrition Averages Cards Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        StatCardView(
                            title: "متوسط السعرات",
                            value: "\(String(format: "%.0f", viewModel.nutritionAverages.averageCalories)) kcal",
                            subtitle: "\(viewModel.nutritionAverages.loggedDaysCount) أيام مسجلة",
                            icon: "flame.fill",
                            iconColor: ArabicTheme.primaryOrange
                        )

                        StatCardView(
                            title: "أيام الالتزام بالهدف",
                            value: "\(viewModel.nutritionAverages.adherenceDaysCount) يوم",
                            subtitle: "ضمن هامش ±10%",
                            icon: "checkmark.seal.fill",
                            iconColor: ArabicTheme.primaryGreen
                        )

                        StatCardView(
                            title: "متوسط البروتين",
                            value: "\(String(format: "%.1f", viewModel.nutritionAverages.averageProtein)) g",
                            subtitle: "يومياً",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.proteinBlue
                        )

                        StatCardView(
                            title: "متوسط الكربوهيدرات",
                            value: "\(String(format: "%.1f", viewModel.nutritionAverages.averageCarbs)) g",
                            subtitle: "يومياً",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.carbsYellow
                        )

                        StatCardView(
                            title: "متوسط الدهون",
                            value: "\(String(format: "%.1f", viewModel.nutritionAverages.averageFat)) g",
                            subtitle: "يومياً",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.fatRed
                        )

                        StatCardView(
                            title: "الحصص التدريبية",
                            value: "\(viewModel.filteredWorkoutsCount)",
                            subtitle: "في الفترة المحددة",
                            icon: "dumbbell.fill",
                            iconColor: ArabicTheme.workoutPurple
                        )
                    }

                    // Top Exercises
                    CardContainer {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(ArabicTheme.workoutPurple)
                                Text("التمارين الأكثر تسجيلاً")
                                    .font(.headline)
                            }

                            if viewModel.topExercises.isEmpty {
                                Text("لا توجد تمارين كافية لعرض الترتيب.")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            } else {
                                ForEach(viewModel.topExercises, id: \.name) { item in
                                    HStack {
                                        Text(item.name)
                                            .font(.subheadline)
                                        Spacer()
                                        Text("\(item.count) مرات")
                                            .font(.caption.bold())
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 2)
                                    Divider()
                                }
                            }
                        }
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("الإحصائيات والتقارير")
            .navigationBarTitleDisplayMode(.inline)
        }
        .arabicRTL()
    }
}
