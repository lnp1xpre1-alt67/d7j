import SwiftUI

public struct StatCardView: View {
    public let title: String
    public let value: String
    public let subtitle: String?
    public let icon: String
    public let iconColor: Color

    public init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
    }

    public var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.subheadline)
                    Text(title)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                if let sub = subtitle {
                    Text(sub)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}
