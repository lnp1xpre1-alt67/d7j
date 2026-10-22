import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showingResetGoalsConfirmation = false
    @State private var showingResetAllConfirmation = false

    public init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        NavigationView {
            Form {
                // Section 1: Goals and Targets
                Section(header: Text("الأهداف والتغذية")) {
                    NavigationLink(destination: EditGoalsView()) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(ArabicTheme.primaryOrange)
                            Text("تعديل الأهداف اليومية (سعرات وماكروز)")
                        }
                    }

                    if let current = viewModel.store.goals {
                        HStack {
                            Text("الهدف الحالي:")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(String(format: "%.0f", current.calories)) kcal")
                                .font(.footnote.bold())
                                .foregroundColor(ArabicTheme.primaryOrange)
                        }
                    }
                }

                // Section 2: Backup and Data
                Section(header: Text("البيانات والنسخ الاحتياطي")) {
                    NavigationLink(destination: BackupRestoreView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "externaldrive.fill")
                                .foregroundColor(ArabicTheme.proteinBlue)
                            Text("تصدير واستيراد البيانات (JSON / CSV)")
                        }
                    }
                }

                // Section 3: Privacy & Security
                Section(header: Text("الخصوصية والأمان")) {
                    HStack {
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(ArabicTheme.primaryGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("تطبيق محلي 100% (Offline)")
                                .font(.subheadline.bold())
                            Text("لا نجمع أي بيانات، ولا توجد حسابات أو إعلانات أو خوادم خارجية.")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }

                // Section 4: Danger Zone
                Section(header: Text("المنطقة الحساسة")) {
                    Button(action: { showingResetGoalsConfirmation = true }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.orange)
                            Text("إعادة تعيين الأهداف فقط")
                                .foregroundColor(.orange)
                        }
                    }

                    Button(action: { showingResetAllConfirmation = true }) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(.red)
                            Text("مسح كافة البيانات وإعادة ضبط المصنع")
                                .foregroundColor(.red)
                        }
                    }
                }

                // Section 5: About App
                Section(header: Text("حول التطبيق")) {
                    HStack {
                        Text("اسم التطبيق")
                        Spacer()
                        Text("عزيز كال (AzizCal)")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("الإصدار")
                        Spacer()
                        Text("1.0.0 (Native iOS)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("الإعدادات")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showingResetGoalsConfirmation) {
                Alert(
                    title: Text("إعادة تعيين الأهداف"),
                    message: Text("سيتم مسح الأهداف الحالية ومطالبتك بتحديد أهداف جديدة، مع الحفاظ الكامل على جميع وجباتك وتمارينك السابقة. هل ترغب بالاستمرار؟"),
                    primaryButton: .destructive(Text("إعادة التعيين")) {
                        viewModel.resetGoalsOnly()
                    },
                    secondaryButton: .cancel(Text("إلغاء"))
                )
            }
            .alert(isPresented: $showingResetAllConfirmation) {
                Alert(
                    title: Text("تحذير: مسح كافة البيانات نهائياً"),
                    message: Text("هل أنت متأكد تماماً؟ سيتم مسح كافة الأهداف وسجلات الطعام والأطعمة المحفوظة وسجل التمارين بالكامل ولن تتمكن من استعادتها إلا إذا كان لديك ملف نسخة احتياطية."),
                    primaryButton: .destructive(Text("مسح كل شيء")) {
                        viewModel.resetEverything()
                    },
                    secondaryButton: .cancel(Text("إلغاء"))
                )
            }
        }
        .arabicRTL()
    }
}
