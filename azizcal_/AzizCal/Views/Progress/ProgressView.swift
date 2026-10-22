import SwiftUI

public struct ProgressView: View {
    @StateObject private var viewModel: ProgressViewModel

    public init(viewModel: ProgressViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("ابحث عن تمرين لمتابعة أوزانك...", text: $viewModel.searchQuery)
                }
                .padding(10)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(10)
                .padding()

                if viewModel.allExerciseNames.isEmpty {
                    EmptyStateView(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "لا توجد تمارين مسجلة بعد",
                        subtitle: "سجل تمارينك وأوزانك في قسم التمارين، وسيتم إنشاء إحصائيات التطور ورسم المخططات البيانية تلقائياً هنا."
                    )
                    Spacer()
                } else if viewModel.filteredExerciseNames.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "لا توجد نتائج بحث",
                        subtitle: "لم يتم العثور على تمرين يطابق البحث المدخل."
                    )
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredExerciseNames, id: \.self) { name in
                            NavigationLink(destination: ExerciseDetailView(exerciseName: name, viewModel: viewModel)) {
                                let pr = viewModel.personalRecord(for: name)
                                let last = viewModel.lastPerformance(for: name)

                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(name)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        if let last = last {
                                            Text("آخر أداء: \(last.bestSetSummary)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("أفضل وزن")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Text(String(format: "%.1f كجم", pr.maxWeight))
                                            .font(.subheadline.bold())
                                            .foregroundColor(ArabicTheme.workoutPurple)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(ArabicTheme.pageBackground.ignoresSafeArea())
            .navigationTitle("التقدم والبيانات")
            .navigationBarTitleDisplayMode(.inline)
        }
        .arabicRTL()
    }
}
