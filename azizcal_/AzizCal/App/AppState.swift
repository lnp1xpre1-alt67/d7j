import Foundation
import Combine
import SwiftUI

public final class AppState: ObservableObject {
    public static let shared = AppState()

    @Published public var hasCompletedOnboarding: Bool = false
    private let store: DataStore
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared) {
        self.store = store
        self.hasCompletedOnboarding = store.hasCompletedOnboarding

        store.objectWillChange.sink { [weak self] _ in
            guard let self = self else { return }
            self.hasCompletedOnboarding = self.store.hasCompletedOnboarding
        }.store(in: &cancellables)
    }

    public func completeOnboarding() {
        self.hasCompletedOnboarding = true
    }
}
