import SwiftUI

public struct ArabicRTLModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .environment(\.layoutDirection, .rightToLeft)
            .environment(\.locale, Locale(identifier: "ar"))
    }
}

public extension View {
    func arabicRTL() -> some View {
        self.modifier(ArabicRTLModifier())
    }
}

public struct ArabicTheme {
    public static let primaryGreen = Color(red: 0.13, green: 0.69, blue: 0.45) // Health green
    public static let primaryOrange = Color(red: 1.0, green: 0.58, blue: 0.0) // Calorie orange
    public static let proteinBlue = Color(red: 0.0, green: 0.48, blue: 1.0) // Protein blue
    public static let carbsYellow = Color(red: 0.95, green: 0.77, blue: 0.06) // Carbs yellow
    public static let fatRed = Color(red: 0.93, green: 0.27, blue: 0.35) // Fat red
    public static let workoutPurple = Color(red: 0.58, green: 0.24, blue: 0.89) // Workout purple

    public static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    public static let pageBackground = Color(UIColor.systemGroupedBackground)
}
