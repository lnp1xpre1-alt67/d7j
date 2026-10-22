import SwiftUI
import Charts

public struct ExerciseChartView: View {
    public let points: [ExerciseProgressPoint]

    public init(points: [ExerciseProgressPoint]) {
        self.points = points
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("مخطط تطور أقصى وزن (كجم)")
                .font(.caption.bold())
                .foregroundColor(.secondary)

            Chart {
                ForEach(points) { point in
                    LineMark(
                        x: .value("التاريخ", point.date),
                        y: .value("أقصى وزن (كجم)", point.maxWeight)
                    )
                    .foregroundStyle(ArabicTheme.workoutPurple)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("التاريخ", point.date),
                        y: .value("أقصى وزن (كجم)", point.maxWeight)
                    )
                    .foregroundStyle(ArabicTheme.workoutPurple)
                    .symbolSize(36)
                }
            }
            .frame(height: 180)
            .padding(.vertical, 8)
        }
    }
}
