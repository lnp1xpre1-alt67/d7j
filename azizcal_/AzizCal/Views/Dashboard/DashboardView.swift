import SwiftUI

public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @Binding var selectedTab: Int
    @State private var showingDatePicker = false

    public init(viewModel: DashboardViewModel, selectedTab: Binding<Int>) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _selectedTab = selectedTab
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Date Navigation Bar
                    dateNavigationBar

                    // Calories Ring Card
                    CardContainer {
                        VStack(spacing: 8) {
                            Text("ملخص السعرات الحرارية")
                                .font(.headline)
                                .foregroundColor(.primary)

                            CalorieRingView(summary: viewModel.calorieSummary)
                        }
                    }

                    // Macronutrients Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("الماكروز اليومية")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 4)

                        MacroBarView(
                            title: "البروتين",
                            summary: viewModel.proteinSummary,
                            color: ArabicTheme.proteinBlue,
                            icon: "circle.fill"
                        )

                        MacroBarView(
                            title: "الكربوهيدرات",
                            summary: viewModel.carbsSummary,
                            color: ArabicTheme.carbsYellow,
                            icon: "circle.fill"
                        )

                        MacroBarView(
                            title: "الدهون",
                            summary: viewModel.fatSummary,
                            color: ArabicTheme.fatRed,
                            icon: "circle.fill"
                        )
                    }

                    // Quick Action Buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            selectedTab = 1 // Switch to Nutrition
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.headline)
                                Text("إضافة طعام")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ArabicTheme.primaryGreen)
                            .cornerRadius(12)
                        }

                        Button(action: {
                            selectedTab = 2 // Switch to Workouts
                        }) {
                            HStack {
                                Image(systemName: "dumbbell.fill")
                                    .font(.headline)
                                Text("تسجيل تمرين")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(ArabicTheme.workoutPurple)
                            .cornerRadius(12)
                        }
                    }

                    // Today's Meals Summary
                    todayMealsSection

                    // Today's Workouts Summary
                    todayWorkoutsSection

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("الرئيسية")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDatePicker) {
                NavigationView {
                    VStack {
                        DatePicker(
                            "اختر التاريخ",
                            selection: $viewModel.selectedDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()

                        Spacer()
                    }
                    .navigationTitle("تحديد التاريخ")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("تم") { showingDatePicker = false }
                        }
                    }
                }
                .arabicRTL()
            }
        }
        .arabicRTL()
    }

    // MARK: - Subviews
    private var dateNavigationBar: some View {
        HStack {
            Button(action: { viewModel.goToNextDay() }) {
                Image(systemName: "chevron.right")
                    .font(.body.bold())
                    .padding(8)
                    .background(ArabicTheme.cardBackground)
                    .clipShape(Circle())
            }

            Spacer()

            Button(action: { showingDatePicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(ArabicTheme.primaryGreen)
                    Text(viewModel.formattedDateString)
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(ArabicTheme.cardBackground)
                .cornerRadius(20)
            }

            Spacer()

            Button(action: { viewModel.goToPreviousDay() }) {
                Image(systemName: "chevron.left")
                    .font(.body.bold())
                    .padding(8)
                    .background(ArabicTheme.cardBackground)
                    .clipShape(Circle())
            }
        }
    }

    private var todayMealsSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(ArabicTheme.primaryOrange)
                    Text("وجبات اليوم (\(viewModel.todayFoodItems.count))")
                        .font(.headline)
                    Spacer()
                    Button("عرض التفاصيل") {
                        selectedTab = 1
                    }
                    .font(.footnote.bold())
                    .foregroundColor(ArabicTheme.primaryGreen)
                }

                if viewModel.todayFoodItems.isEmpty {
                    Text("لم تقم بتسجيل أي طعام لهذا اليوم بعد.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    VStack(spacing: 8) {
                        ForEach(MealType.allCases) { meal in
                            let mealItems = viewModel.todayFoodItems.filter { $0.mealType == meal }
                            if !mealItems.isEmpty {
                                let cals = mealItems.reduce(0.0) { $0 + $1.calories }
                                HStack {
                                    Image(systemName: meal.icon)
                                        .foregroundColor(.secondary)
                                        .frame(width: 20)
                                    Text(meal.title)
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(String(format: "%.0f", cals)) سعرة")
                                        .font(.subheadline.bold())
                                        .foregroundColor(.primary)
                                }
                                .padding(.vertical, 4)
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }

    private var todayWorkoutsSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .foregroundColor(ArabicTheme.workoutPurple)
                    Text("تمارين اليوم (\(viewModel.todayWorkouts.count))")
                        .font(.headline)
                    Spacer()
                    Button("سجل التمارين") {
                        selectedTab = 2
                    }
                    .font(.footnote.bold())
                    .foregroundColor(ArabicTheme.workoutPurple)
                }

                if viewModel.todayWorkouts.isEmpty {
                    Text("لم تسجل أي حصة تدريبية في هذا التاريخ.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.todayWorkouts) { session in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(session.title)
                                        .font(.subheadline.bold())
                                    Text("\(session.exercises.count) تمارين • \(session.totalSetsCount) مجموعة")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ArabicTheme.primaryGreen)
                            }
                            .padding(.vertical, 4)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}
