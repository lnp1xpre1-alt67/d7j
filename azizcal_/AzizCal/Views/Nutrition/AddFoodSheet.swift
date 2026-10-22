import SwiftUI

public struct AddFoodSheet: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingSavedPicker = false
    @State private var selectedSavedFood: SavedFood?

    public init(viewModel: NutritionViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("نوع الوجبة")) {
                    Picker("الوجبة", selection: $viewModel.formMealType) {
                        ForEach(MealType.allCases) { meal in
                            HStack {
                                Image(systemName: meal.icon)
                                Text(meal.title)
                            }.tag(meal)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("اختيار سريع من الأطعمة المحفوظة")) {
                    Button(action: { showingSavedPicker = true }) {
                        HStack {
                            Image(systemName: "bookmark.fill")
                                .foregroundColor(ArabicTheme.primaryGreen)
                            Text(selectedSavedFood?.name ?? "اختر من أطعمتي المحفوظة")
                                .foregroundColor(selectedSavedFood == nil ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.left")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section(header: Text("بيانات الطعام")) {
                    HStack {
                        Text("اسم الطعام:")
                            .foregroundColor(.secondary)
                        TextField("مثال: صدور دجاج مشوية", text: $viewModel.formName)
                    }

                    HStack {
                        Text("الكمية:")
                            .foregroundColor(.secondary)
                        TextField("100", text: $viewModel.formAmount)
                            .keyboardType(.decimalPad)
                            .onChange(of: viewModel.formAmount) { _ in
                                viewModel.onAmountChangedInForm(savedFood: selectedSavedFood)
                            }

                        Picker("الوحدة", selection: $viewModel.formUnit) {
                            Text("غرام").tag("غرام")
                            Text("مل").tag("مل")
                            Text("حصة/قطعة").tag("حصة")
                            Text("بيضة").tag("بيضة")
                            Text("ملعقة").tag("ملعقة")
                            Text("كوب").tag("كوب")
                        }
                        .pickerStyle(.menu)
                    }
                }

                Section(header: Text("القيم الغذائية للكمية المدخلة")) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundColor(ArabicTheme.primaryOrange)
                        Text("السعرات (kcal):")
                        Spacer()
                        TextField("0", text: $viewModel.formCalories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.proteinBlue).frame(width: 8, height: 8)
                        Text("البروتين (g):")
                        Spacer()
                        TextField("0", text: $viewModel.formProtein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.carbsYellow).frame(width: 8, height: 8)
                        Text("الكربوهيدرات (g):")
                        Spacer()
                        TextField("0", text: $viewModel.formCarbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.fatRed).frame(width: 8, height: 8)
                        Text("الدهون (g):")
                        Spacer()
                        TextField("0", text: $viewModel.formFat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                if let err = viewModel.formErrorMessage {
                    Section {
                        Text(err)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.editingFoodItem == nil ? "إضافة طعام" : "تعديل طعام")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
                        viewModel.showingAddSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ الطعام") {
                        _ = viewModel.saveCurrentForm()
                    }
                    .font(.headline)
                    .foregroundColor(ArabicTheme.primaryGreen)
                }
            }
            .sheet(isPresented: $showingSavedPicker) {
                SavedFoodPickerSheet(viewModel: viewModel) { chosen in
                    self.selectedSavedFood = chosen
                    viewModel.applySavedFood(chosen)
                    showingSavedPicker = false
                }
            }
        }
        .arabicRTL()
    }
}

struct SavedFoodPickerSheet: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.presentationMode) var presentationMode
    var onSelect: (SavedFood) -> Void

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("ابحث في أطعمتك المحفوظة...", text: $viewModel.savedFoodSearchQuery)
                }
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                List(viewModel.filteredSavedFoods) { food in
                    Button(action: { onSelect(food) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(food.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    if food.isFavorite {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                    }
                                }
                                Text("\(String(format: "%.0f", food.caloriesPerBase)) سعرة لكل \(String(format: "%.0f", food.baseAmount)) \(food.unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text("P: \(String(format: "%.0f", food.proteinPerBase))g")
                                .font(.caption2.bold())
                                .foregroundColor(ArabicTheme.proteinBlue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("اختر طعاماً محفوظاً")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إغلاق") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .arabicRTL()
    }
}
