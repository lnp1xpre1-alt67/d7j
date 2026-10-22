import SwiftUI

public struct PrimaryButton: View {
    public let title: String
    public let icon: String?
    public let color: Color
    public let action: () -> Void

    public init(
        title: String,
        icon: String? = nil,
        color: Color = ArabicTheme.primaryGreen,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    public var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(color)
            .cornerRadius(14)
            .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 3)
        }
    }
}
