import SwiftUI

public struct EditGoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        Form {
            Section(header: Text("الأهداف اليومية المستهدفة")) {
                HStack {
                    Image(systemName: "flame.fill").foregroundColor(ArabicTheme.primaryOrange)
                    Text("السعرات (kcal):")
                    Spacer()
                    TextField("2000", text: $viewModel.caloriesText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Circle().fill(ArabicTheme.proteinBlue).frame(width: 8, height: 8)
                    Text("البروتين (g):")
                    Spacer()
                    TextField("150", text: $viewModel.proteinText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Circle().fill(ArabicTheme.carbsYellow).frame(width: 8, height: 8)
                    Text("الكربوهيدرات (g):")
                    Spacer()
                    TextField("200", text: $viewModel.carbsText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Circle().fill(ArabicTheme.fatRed).frame(width: 8, height: 8)
                    Text("الدهون (g):")
                    Spacer()
                    TextField("60", text: $viewModel.fatText)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            if let err = viewModel.errorMessage {
                Section {
                    Text(err).foregroundColor(.red).font(.footnote)
                }
            }
        }
        .navigationTitle("تعديل الأهداف اليومية")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("حفظ") {
                    if viewModel.saveGoals() {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .font(.headline)
                .foregroundColor(ArabicTheme.primaryGreen)
            }
        }
        .arabicRTL()
    }
}
