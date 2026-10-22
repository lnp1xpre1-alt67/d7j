import SwiftUI
import UniformTypeIdentifiers

public struct BackupRestoreView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var showingDocumentPicker = false
    @State private var showingShareSheet = false
    @State private var shareURL: URL?

    public var body: some View {
        Form {
            Section(header: Text("تصدير نسخة احتياطية"), footer: Text("يقوم بتصدير ملف JSON يحتوي على كامل أهدافك وسجلاتك الغذائية وقائمتك المحفوظة وحصص التمارين.")) {
                Button(action: {
                    if let url = viewModel.exportJSON() {
                        self.shareURL = url
                        self.showingShareSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(ArabicTheme.primaryGreen)
                        Text("تصدير كافة البيانات (JSON)")
                            .foregroundColor(.primary)
                    }
                }

                Button(action: {
                    let csv = BackupService.shared.exportFoodItemsCSV(store: viewModel.store)
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Nutrition_Records.csv")
                    try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
                    self.shareURL = tempURL
                    self.showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "tablecells")
                            .foregroundColor(ArabicTheme.primaryOrange)
                        Text("تصدير سجل التغذية (CSV)")
                            .foregroundColor(.primary)
                    }
                }

                Button(action: {
                    let csv = BackupService.shared.exportWorkoutsCSV(store: viewModel.store)
                    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("Workouts_Records.csv")
                    try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
                    self.shareURL = tempURL
                    self.showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "dumbbell")
                            .foregroundColor(ArabicTheme.workoutPurple)
                        Text("تصدير سجل التمارين (CSV)")
                            .foregroundColor(.primary)
                    }
                }
            }

            Section(header: Text("استيراد نسخة احتياطية"), footer: Text("يتم فحص سلامة الملف ومطابقته لمنع أي تكرار غير مقصود للبيانات.")) {
                Button(action: { showingDocumentPicker = true }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundColor(ArabicTheme.proteinBlue)
                        Text("اختيار ملف نسخة احتياطية (JSON)")
                            .foregroundColor(.primary)
                    }
                }
            }

            Section(header: Text("تنبيه هام حول الخصوصية والتخزين المحلي")) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("جميع بياناتك مخزنة محلياً بنسبة 100% على جهاز الآيفون الخاص بك ولا يتم إرسالها إلى أي خادم خارجي.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    Text("في حال قمت بحذف التطبيق من الآيفون، قد يقوم نظام iOS بمسح البيانات المحلية، لذا ننصح بأخذ نسخة احتياطية وتصديرها دورياً لحفظها في ملفاتك أو iCloud Drive.")
                        .font(.footnote)
                        .foregroundColor(ArabicTheme.fatRed)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("النسخ الاحتياطي والبيانات")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            if let url = shareURL {
                ShareActivityView(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(allowedContentTypes: [.json]) { selectedURL in
                viewModel.importJSON(from: selectedURL)
            }
        }
        .alert(isPresented: $viewModel.showingImportSuccess) {
            Alert(
                title: Text("إشعار"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("حسناً"))
            )
        }
        .arabicRTL()
    }
}

// UIKit wrapper for sharing files
struct ShareActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// UIKit wrapper for document picker
struct DocumentPicker: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let first = urls.first {
                onPick(first)
            }
        }
    }
}
