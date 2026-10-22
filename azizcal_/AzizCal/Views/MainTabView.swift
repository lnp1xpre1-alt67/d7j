import SwiftUI

public struct MainTabView: View {
    @State private var selectedTab: Int = 0

    // ViewModels
    @StateObject private var dashboardVM = DashboardViewModel()
    @StateObject private var nutritionVM = NutritionViewModel()
    @StateObject private var workoutsVM = WorkoutsViewModel()
    @StateObject private var progressVM = ProgressViewModel()
    @StateObject private var statsVM = StatisticsViewModel()
    @StateObject private var settingsVM = SettingsViewModel()

    public init() {}

    public var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Dashboard
            DashboardView(viewModel: dashboardVM, selectedTab: $selectedTab)
                .tabItem {
                    Label("الرئيسية", systemImage: "house.fill")
                }
                .tag(0)

            // Tab 2: Nutrition
            NutritionView(viewModel: nutritionVM)
                .tabItem {
                    Label("التغذية", systemImage: "fork.knife")
                }
                .tag(1)

            // Tab 3: Workouts
            WorkoutsView(viewModel: workoutsVM)
                .tabItem {
                    Label("التمارين", systemImage: "dumbbell.fill")
                }
                .tag(2)

            // Tab 4: Progress & Analytics
            ProgressTabContainer(progressVM: progressVM, statsVM: statsVM)
                .tabItem {
                    Label("التقدم", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            // Tab 5: Settings
            SettingsView(viewModel: settingsVM)
                .tabItem {
                    Label("الإعدادات", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(ArabicTheme.primaryGreen)
        .arabicRTL()
    }
}

// Container for Progress and Statistics with a top segment
struct ProgressTabContainer: View {
    @ObservedObject var progressVM: ProgressViewModel
    @ObservedObject var statsVM: StatisticsViewModel
    @State private var selectedSegment: Int = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("", selection: $selectedSegment) {
                    Text("سجل التمارين والأوزان").tag(0)
                    Text("التقارير والإحصائيات").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(ArabicTheme.pageBackground)

                if selectedSegment == 0 {
                    ProgressView(viewModel: progressVM)
                } else {
                    StatisticsView(viewModel: statsVM)
                }
            }
            .navigationBarHidden(true)
        }
        .arabicRTL()
    }
}
