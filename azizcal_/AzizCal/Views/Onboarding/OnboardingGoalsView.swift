import SwiftUI

public struct OnboardingGoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    public var onFinished: () -> Void

    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "flame.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(ArabicTheme.primaryOrange)
                            .padding(.top, 20)

                        Text("مرحباً بك في عزيز كال")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)

                        Text("حدد أهدافك اليومية بدقة للبدء في تتبع التغذية والتمارين. يمكنك تعديلها في أي وقت من الإعدادات.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // Input Form
                    VStack(spacing: 16) {
                        GoalInputField(
                            title: "السعرات الحرارية اليومية المستهدفة",
                            unit: "kcal",
                            icon: "flame.fill",
                            iconColor: ArabicTheme.primaryOrange,
                            placeholder: "مثال: 2200",
                            text: $viewModel.caloriesText
                        )

                        GoalInputField(
                            title: "البروتين المستهدف يومياً",
                            unit: "g",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.proteinBlue,
                            placeholder: "مثال: 150",
                            text: $viewModel.proteinText
                        )

                        GoalInputField(
                            title: "الكربوهيدرات المستهدفة يومياً",
                            unit: "g",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.carbsYellow,
                            placeholder: "مثال: 250",
                            text: $viewModel.carbsText
                        )

                        GoalInputField(
                            title: "الدهون المستهدفة يومياً",
                            unit: "g",
                            icon: "circle.fill",
                            iconColor: ArabicTheme.fatRed,
                            placeholder: "مثال: 65",
                            text: $viewModel.fatText
                        )
                    }
                    .padding(.horizontal)

                    // Error Message if any
                    if let err = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(err)
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                    }

                    // Save Button
                    PrimaryButton(
                        title: "حفظ الأهداف والبدء",
                        icon: "arrow.left.circle.fill",
                        color: ArabicTheme.primaryGreen
                    ) {
                        if viewModel.saveGoals() {
                            onFinished()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer(minLength: 40)
                }
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .arabicRTL()
    }
}

struct GoalInputField: View {
    let title: String
    let unit: String
    let icon: String
    let iconColor: Color
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.subheadline)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundColor(.primary)
            }

            HStack {
                TextField(placeholder, text: $text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.leading)

                Text(unit)
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
            }
            .padding(14)
            .background(ArabicTheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
            )
        }
    }
}
