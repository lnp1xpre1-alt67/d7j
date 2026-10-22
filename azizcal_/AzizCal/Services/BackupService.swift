import Foundation

public final class BackupService {
    public static let shared = BackupService()

    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    private init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.jsonEncoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = decoder
    }

    public func exportToJSONData(store: DataStore) throws -> Data {
        let backup = store.exportAllData()
        return try jsonEncoder.encode(backup)
    }

    public func exportToJSONFile(store: DataStore) throws -> URL {
        let data = try exportToJSONData(store: store)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmm"
        let dateStr = formatter.string(from: Date())
        let fileName = "AzizCal_Backup_\(dateStr).json"

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try data.write(to: tempURL, options: .atomic)
        return tempURL
    }

    public func importFromJSONData(_ data: Data, into store: DataStore) -> Result<Int, String> {
        do {
            let backup = try jsonDecoder.decode(BackupData.self, from: data)
            guard backup.version >= 1 else {
                return .failure("إصدار ملف النسخة الاحتياطية غير مدعوم")
            }
            let totalItems = backup.foodItems.count + backup.workoutSessions.count + backup.savedFoods.count
            store.restoreBackup(backup)
            return .success(totalItems)
        } catch {
            return .failure("الملف غير صالح أو تالف: \(error.localizedDescription)")
        }
    }

    public func exportFoodItemsCSV(store: DataStore) -> String {
        var csv = "ID,التاريخ,الوجبة,اسم الطعام,الكمية,الوحدة,السعرات,البروتين,الكربوهيدرات,الدهون\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        for item in store.foodItems {
            let line = [
                item.id.uuidString,
                formatter.string(from: item.date),
                item.mealType.rawValue,
                "\"\(item.name.replacingOccurrences(of: "\"", with: "\"\""))\"",
                String(format: "%.1f", item.amount),
                item.unit,
                String(format: "%.1f", item.calories),
                String(format: "%.1f", item.protein),
                String(format: "%.1f", item.carbs),
                String(format: "%.1f", item.fat)
            ].joined(separator: ",")
            csv.append(line + "\n")
        }
        return csv
    }

    public func exportWorkoutsCSV(store: DataStore) -> String {
        var csv = "معرف الحصة,التاريخ,عنوان الحصة,اسم التمرين,رقم المجموعة,الوزن_كجم,التكرارات,وزن_الجسم,ملاحظات\n"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        for session in store.workoutSessions {
            for exercise in session.exercises {
                for set in exercise.sets {
                    let weightStr = set.isBodyweight ? "0" : String(format: "%.1f", set.weightKg ?? 0)
                    let line = [
                        session.id.uuidString,
                        formatter.string(from: session.date),
                        "\"\(session.title.replacingOccurrences(of: "\"", with: "\"\""))\"",
                        "\"\(exercise.name.replacingOccurrences(of: "\"", with: "\"\""))\"",
                        "\(set.setNumber)",
                        weightStr,
                        "\(set.reps)",
                        set.isBodyweight ? "نعم" : "لا",
                        "\"\(set.notes ?? "")\""
                    ].joined(separator: ",")
                    csv.append(line + "\n")
                }
            }
        }
        return csv
    }
}
