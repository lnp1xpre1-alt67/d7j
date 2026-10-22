import Foundation

public enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast = "فطور"
    case lunch = "غداء"
    case dinner = "عشاء"
    case snack = "سناك"

    public var id: String { rawValue }

    public var title: String {
        return rawValue
    }

    public var icon: String {
        switch self {
        case .breakfast:
            return "sun.horizon.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.stars.fill"
        case .snack:
            return "leaf.fill"
        }
    }

    public var sortOrder: Int {
        switch self {
        case .breakfast: return 0
        case .lunch: return 1
        case .dinner: return 2
        case .snack: return 3
        }
    }
}
