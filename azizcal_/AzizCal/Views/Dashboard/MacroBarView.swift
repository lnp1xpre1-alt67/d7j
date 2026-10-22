import SwiftUI

public struct MacroBarView: View {
    public let title: String
    public let summary: MacroSummary
    public let color: Color
    public let icon: String

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }

                Spacer()

                if summary.isExceeded {
                    Text("+\(String(format: "%.0f", summary.surplus))g فائض")
                        .font(.caption.bold())
                        .foregroundColor(ArabicTheme.fatRed)
                } else {
                    Text("باقي \(String(format: "%.0f", summary.remaining))g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Linear Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.secondary.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(summary.isExceeded ? ArabicTheme.fatRed : color)
                        .frame(
                            width: min(geo.size.width, geo.size.width * CGFloat(min(1.0, summary.consumed / max(1.0, summary.target)))),
                            height: 8
                        )
                        .animation(.easeInOut, value: summary.consumed)
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(String(format: "%.0f", summary.consumed)) / \(String(format: "%.0f", summary.target))g")
                    .font(.caption2)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(String(format: "%.0f", summary.percentage))%")
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(ArabicTheme.cardBackground)
        .cornerRadius(12)
    }
}
