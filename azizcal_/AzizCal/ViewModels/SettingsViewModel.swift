import Foundation
import Combine
import SwiftUI

public final class SettingsViewModel: ObservableObject {
    @Published public var showingResetGoalsAlert: Bool = false
    @Published public var showingResetAllAlert: Bool = false
    @Published public var showingImportSuccess: Bool = false
    @Published public var alertMessage: String = ""
    @Published public var isExporting: Bool = false
    @Published public var exportedFileURL: URL?

    public let store: DataStore
    private let backupService: BackupService
    private var cancellables = Set<AnyCancellable>()

    public init(store: DataStore = .shared, backupService: BackupService = .shared) {
        self.store = store
        self.backupService = backupService

        store.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }

    public func exportJSON() -> URL? {
        do {
            let url = try backupService.exportToJSONFile(store: store)
            self.exportedFileURL = url
            return url
        } catch {
            self.alertMessage = "فشل تصدير البيانات: \(error.localizedDescription)"
            return nil
        }
    }

    public func importJSON(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let result = backupService.importFromJSONData(data, into: store)
            switch result {
            case .success(let count):
                self.alertMessage = "تم استيراد \(count) سجلاً بنجاح دون أي تكرار غير مقصود."
                self.showingImportSuccess = true
            case .failure(let err):
                self.alertMessage = err
                self.showingImportSuccess = true
            }
        } catch {
            self.alertMessage = "تعذر قراءة ملف النسخة الاحتياطية: \(error.localizedDescription)"
            self.showingImportSuccess = true
        }
    }

    public func resetGoalsOnly() {
        store.resetGoals()
        self.alertMessage = "تمت إعادة تعيين الأهداف بنجاح مع الاحتفاظ بكافة سجلات الأيام السابقة."
        self.showingImportSuccess = true
    }

    public func resetEverything() {
        store.resetAllData()
        self.alertMessage = "تم مسح كافة البيانات والعودة للوضع المبدئي."
        self.showingImportSuccess = true
    }
}
