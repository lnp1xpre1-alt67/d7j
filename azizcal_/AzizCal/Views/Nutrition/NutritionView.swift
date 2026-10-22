import SwiftUI

public struct NutritionView: View {
    @StateObject private var viewModel: NutritionViewModel
    @State private var showingDatePicker = false
    @State private var mealToCopy: MealType?
    @State private var foodToDelete: FoodItem?
    @State private var showingDeleteAlert = false

    public init(viewModel: NutritionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar")
        if Calendar.current.isDateInToday(viewModel.selectedDate) {
            return "اليوم، " + formatter.string(from: viewModel.selectedDate)
        }
        formatter.dateFormat = "EEEE، d MMMM"
        return formatter.string(from: viewModel.selectedDate)
    }

    private var dailyTotalCalories: Double {
        viewModel.dailyFoodItems.reduce(0.0) { $0 + $1.calories }
    }
    private var dailyTotalProtein: Double {
        viewModel.dailyFoodItems.reduce(0.0) { $0 + $1.protein }
    }
    private var dailyTotalCarbs: Double {
        viewModel.dailyFoodItems.reduce(0.0) { $0 + $1.carbs }
    }
    private var dailyTotalFat: Double {
        viewModel.dailyFoodItems.reduce(0.0) { $0 + $1.fat }
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    // Date Navigation
                    dateHeader

                    // Daily Nutrition Summary Bar
                    dailySummaryCard

                    // Top Action: Saved Foods & Add Food
                    HStack(spacing: 12) {
                        NavigationLink(destination: SavedFoodsView(viewModel: viewModel)) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                Text("أطعمتي المحفوظة")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(ArabicTheme.primaryGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(ArabicTheme.primaryGreen.opacity(0.12))
                            .cornerRadius(12)
                        }

                        Button(action: { viewModel.prepareForNewItem() }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("إضافة طعام")
                                    .font(.subheadline.bold())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(ArabicTheme.primaryGreen)
                            .cornerRadius(12)
                        }
                    }

                    // Meals Sections
                    ForEach(MealType.allCases) { meal in
                        mealSection(meal: meal)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("التغذية")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $viewModel.showingAddSheet) {
                AddFoodSheet(viewModel: viewModel)
            }
            .sheet(item: $mealToCopy) { meal in
                CopyMealSheet(viewModel: viewModel, mealType: meal)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("حذف السجل"),
                    message: Text("هل أنت متأكد من رغبتك في حذف هذا الطعام؟"),
                    primaryButton: .destructive(Text("حذف")) {
                        if let food = foodToDelete {
                            viewModel.deleteFoodItem(food)
                        }
                    },
                    secondaryButton: .cancel(Text("إلغاء"))
                )
            }
        }
        .arabicRTL()
    }

    // MARK: - Subviews
    private var dateHeader: some View {
        HStack {
            Button(action: {
                if let next = Calendar.current.date(byAdding: .day, value: 1, to: viewModel.selectedDate) {
                    viewModel.selectedDate = next
                }
            }) {
                Image(systemName: "chevron.right")
                    .padding(8)
                    .background(ArabicTheme.cardBackground)
                    .clipShape(Circle())
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .foregroundColor(ArabicTheme.primaryGreen)
                Text(formattedDateString)
                    .font(.headline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(ArabicTheme.cardBackground)
            .cornerRadius(20)

            Spacer()

            Button(action: {
                if let prev = Calendar.current.date(byAdding: .day, value: -1, to: viewModel.selectedDate) {
                    viewModel.selectedDate = prev
                }
            }) {
                Image(systemName: "chevron.left")
                    .padding(8)
                    .background(ArabicTheme.cardBackground)
                    .clipShape(Circle())
            }
        }
    }

    private var dailySummaryCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("إجمالي استهلاك اليوم")
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.0f", dailyTotalCalories)) kcal")
                        .font(.headline.bold())
                        .foregroundColor(ArabicTheme.primaryOrange)
                }

                HStack(spacing: 16) {
                    macroItem(title: "البروتين", value: dailyTotalProtein, color: ArabicTheme.proteinBlue)
                    macroItem(title: "الكارب", value: dailyTotalCarbs, color: ArabicTheme.carbsYellow)
                    macroItem(title: "الدهون", value: dailyTotalFat, color: ArabicTheme.fatRed)
                }
                .padding(.top, 4)
            }
        }
    }

    private func macroItem(title: String, value: Double, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text("\(title): \(String(format: "%.0f", value))g")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }

    private func mealSection(meal: MealType) -> some View {
        let items = viewModel.items(for: meal)
        let mealCals = viewModel.totalCalories(for: meal)
        let mealP = viewModel.totalProtein(for: meal)
        let mealC = viewModel.totalCarbs(for: meal)
        let mealF = viewModel.totalFat(for: meal)

        return CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: meal.icon)
                        .foregroundColor(ArabicTheme.primaryOrange)
                    Text(meal.title)
                        .font(.headline)
                    Spacer()
                    Text("\(String(format: "%.0f", mealCals)) سعرة")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }

                if !items.isEmpty {
                    HStack(spacing: 12) {
                        Text("P: \(String(format: "%.0f", mealP))g").font(.caption2).foregroundColor(ArabicTheme.proteinBlue)
                        Text("C: \(String(format: "%.0f", mealC))g").font(.caption2).foregroundColor(ArabicTheme.carbsYellow)
                        Text("F: \(String(format: "%.0f", mealF))g").font(.caption2).foregroundColor(ArabicTheme.fatRed)
                        Spacer()

                        // Copy entire meal button
                        Button(action: { mealToCopy = meal }) {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                Text("نسخ الوجبة")
                            }
                            .font(.caption2.bold())
                            .foregroundColor(ArabicTheme.primaryGreen)
                        }
                    }
                    Divider()
                }

                if items.isEmpty {
                    Text("لم تسجل أي صنف في هذه الوجبة.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                } else {
                    VStack(spacing: 8) {
                        ForEach(items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline.bold())
                                    Text("\(String(format: "%.0f", item.amount)) \(item.unit) • \(String(format: "%.0f", item.calories)) kcal")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()

                                // Action Menu for Edit/Delete/Repeat
                                Menu {
                                    Button(action: { viewModel.prepareForEdit(item) }) {
                                        Label("تعديل", systemImage: "pencil")
                                    }
                                    Button(action: { viewModel.repeatFoodItemInCurrentDate(item) }) {
                                        Label("تكرار في اليوم الحالي", systemImage: "plus.square.on.square")
                                    }
                                    Button(role: .destructive, action: {
                                        foodToDelete = item
                                        showingDeleteAlert = true
                                    }) {
                                        Label("حذف", systemImage: "trash")
                                    }
                                } label: {
                                    Image(systemName: "ellipsis.circle")
                                        .font(.title3)
                                        .foregroundColor(.secondary)
                                        .padding(4)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // Add button for this specific meal
                Button(action: {
                    viewModel.prepareForNewItem(mealType: meal)
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("إضافة إلى \(meal.title)")
                    }
                    .font(.footnote.bold())
                    .foregroundColor(ArabicTheme.primaryGreen)
                    .padding(.top, 4)
                }
            }
        }
    }
}
