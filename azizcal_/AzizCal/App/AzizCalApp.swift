import SwiftUI

@main
struct AzizCalApp: App {
    @StateObject private var appState = AppState.shared
    @StateObject private var dataStore = DataStore.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    MainTabView()
                } else {
                    OnboardingGoalsView {
                        withAnimation {
                            appState.completeOnboarding()
                        }
                    }
                }
            }
            .environmentObject(dataStore)
            .environmentObject(appState)
        }
    }
}
