import SwiftUI

public struct CalorieRingView: View {
    public let summary: MacroSummary

    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Background track
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 16)
                    .frame(width: 170, height: 170)

                // Progress stroke
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(1.0, summary.consumed / max(1.0, summary.target))))
                    .stroke(
                        summary.isExceeded ? ArabicTheme.fatRed : ArabicTheme.primaryOrange,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 170, height: 170)
                    .animation(.easeInOut(duration: 0.5), value: summary.consumed)

                // Inside text
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(summary.isExceeded ? ArabicTheme.fatRed : ArabicTheme.primaryOrange)
                        .font(.title3)

                    Text(String(format: "%.0f", summary.consumed))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("من \(String(format: "%.0f", summary.target)) سعرة")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(String(format: "%.1f", summary.percentage))%")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 4)

            // Status message
            if summary.isExceeded {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(ArabicTheme.fatRed)
                    Text("تجاوزت الهدف بمقدار \(String(format: "%.0f", summary.surplus)) سعرة")
                        .font(.subheadline.bold())
                        .foregroundColor(ArabicTheme.fatRed)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ArabicTheme.fatRed.opacity(0.1))
                .cornerRadius(8)
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ArabicTheme.primaryGreen)
                    Text("المتبقي: \(String(format: "%.0f", summary.remaining)) سعرة")
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ArabicTheme.primaryGreen.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
