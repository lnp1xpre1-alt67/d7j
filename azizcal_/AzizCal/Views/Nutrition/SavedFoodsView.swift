import SwiftUI

public struct SavedFoodsView: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var showingAddSheet = false
    @State private var searchQuery = ""

    public init(viewModel: NutritionViewModel) {
        self.viewModel = viewModel
    }

    private var displayFoods: [SavedFood] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if trimmed.isEmpty {
            return viewModel.store.savedFoods.sorted { ($0.isFavorite ? 0 : 1) < ($1.isFavorite ? 0 : 1) }
        }
        return viewModel.store.savedFoods.filter { $0.name.lowercased().contains(trimmed) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("ابحث في قائمتك الشخصية...", text: $searchQuery)
            }
            .padding(10)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            .padding()

            if displayFoods.isEmpty {
                EmptyStateView(
                    icon: "basket.fill",
                    title: "لا توجد أطعمة محفوظة",
                    subtitle: "أضف أطعمتك ووجباتك المتكررة لحساب السعرات والماكروز تلقائياً بضغطة واحدة.",
                    actionTitle: "إضافة طعام جديد"
                ) {
                    showingAddSheet = true
                }
                Spacer()
            } else {
                List {
                    ForEach(displayFoods) { food in
                        HStack(spacing: 12) {
                            Button(action: {
                                viewModel.store.toggleFavoriteSavedFood(withId: food.id)
                            }) {
                                Image(systemName: food.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(food.isFavorite ? .yellow : .secondary)
                                    .font(.title3)
                            }
                            .buttonStyle(BorderlessButtonStyle())

                            VStack(alignment: .leading, spacing: 4) {
                                Text(food.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Text("\(String(format: "%.0f", food.caloriesPerBase)) kcal لكل \(String(format: "%.0f", food.baseAmount)) \(food.unit)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 8) {
                                    Text("بروتين: \(String(format: "%.1f", food.proteinPerBase))g")
                                        .font(.caption2)
                                        .foregroundColor(ArabicTheme.proteinBlue)
                                    Text("كارب: \(String(format: "%.1f", food.carbsPerBase))g")
                                        .font(.caption2)
                                        .foregroundColor(ArabicTheme.carbsYellow)
                                    Text("دهون: \(String(format: "%.1f", food.fatPerBase))g")
                                        .font(.caption2)
                                        .foregroundColor(ArabicTheme.fatRed)
                                }
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let food = displayFoods[index]
                            viewModel.store.deleteSavedFood(withId: food.id)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("أطعمتي المحفوظة")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddSheet = true }) {
                    Image(systemName: "plus")
                        .font(.headline)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddSavedFoodSheet(viewModel: viewModel)
        }
        .arabicRTL()
    }
}

public struct AddSavedFoodSheet: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var name: String = ""
    @State private var baseAmount: String = "100"
    @State private var unit: String = "غرام"
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var isFavorite: Bool = false
    @State private var errorMessage: String?

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("معلومات الطعام")) {
                    TextField("اسم الطعام (مثال: صدور دجاج)", text: $name)

                    HStack {
                        Text("الكمية المرجعية:")
                        TextField("100", text: $baseAmount)
                            .keyboardType(.decimalPad)

                        Picker("الوحدة", selection: $unit) {
                            Text("غرام").tag("غرام")
                            Text("مل").tag("مل")
                            Text("حصة/قطعة").tag("حصة")
                        }
                        .pickerStyle(.menu)
                    }

                    Toggle("إضافة إلى المفضلة", isOn: $isFavorite)
                }

                Section(header: Text("القيم الغذائية لكل \(baseAmount) \(unit)")) {
                    HStack {
                        Image(systemName: "flame.fill").foregroundColor(ArabicTheme.primaryOrange)
                        Text("السعرات (kcal):")
                        TextField("0", text: $calories)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.proteinBlue).frame(width: 8, height: 8)
                        Text("البروتين (g):")
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.carbsYellow).frame(width: 8, height: 8)
                        Text("الكربوهيدرات (g):")
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }

                    HStack {
                        Circle().fill(ArabicTheme.fatRed).frame(width: 8, height: 8)
                        Text("الدهون (g):")
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }

                if let err = errorMessage {
                    Section {
                        Text(err).foregroundColor(.red).font(.footnote)
                    }
                }
            }
            .navigationTitle("حفظ طعام جديد")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("حفظ") {
                        saveFood()
                    }
                    .font(.headline)
                    .foregroundColor(ArabicTheme.primaryGreen)
                }
            }
        }
        .arabicRTL()
    }

    private func saveFood() {
        errorMessage = nil
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = Double(baseAmount.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 100
        let cal = Double(calories.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? -1
        let p = Double(protein.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0
        let c = Double(carbs.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0
        let f = Double(fat.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)) ?? 0

        let val = SavedFood.validate(name: trimmed, baseAmount: base, calories: cal, protein: p, carbs: c, fat: f)
        switch val {
        case .failure(let err):
            errorMessage = err
        case .success:
            let newSaved = SavedFood(
                name: trimmed,
                baseAmount: base,
                unit: unit,
                caloriesPerBase: cal,
                proteinPerBase: p,
                carbsPerBase: c,
                fatPerBase: f,
                isFavorite: isFavorite
            )
            viewModel.store.addSavedFood(newSaved)
            presentationMode.wrappedValue.dismiss()
        }
    }
}
