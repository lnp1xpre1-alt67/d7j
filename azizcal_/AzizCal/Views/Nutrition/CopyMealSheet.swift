import SwiftUI

public struct CopyMealSheet: View {
    @ObservedObject var viewModel: NutritionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var targetDate: Date = Date()
    public let mealType: MealType

    public init(viewModel: NutritionViewModel, mealType: MealType) {
        self.viewModel = viewModel
        self.mealType = mealType
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("اختر اليوم الذي تريد نسخ وجبة (\(mealType.title)) إليه:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)

                DatePicker("تاريخ الهدف", selection: $targetDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()

                PrimaryButton(
                    title: "تأكيد نسخ الوجبة",
                    icon: "doc.on.doc.fill",
                    color: ArabicTheme.primaryGreen
                ) {
                    viewModel.copyMealToDate(meal: mealType, toDate: targetDate)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("نسخ وجبة \(mealType.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
        .arabicRTL()
    }
}
