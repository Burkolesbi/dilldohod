import SwiftUI

enum SkillCategory: String, Codable, CaseIterable, Identifiable {
    case music
    case language
    case art
    case cooking
    case sport
    case technology
    case craft
    case academic

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .music: "Music"
        case .language: "Language"
        case .art: "Art"
        case .cooking: "Cooking"
        case .sport: "Sport"
        case .technology: "Technology"
        case .craft: "Craft"
        case .academic: "Academic"
        }
    }

    var iconName: String {
        switch self {
        case .music: "music.note"
        case .language: "globe"
        case .art: "paintbrush.fill"
        case .cooking: "fork.knife"
        case .sport: "figure.run"
        case .technology: "desktopcomputer"
        case .craft: "scissors"
        case .academic: "book.fill"
        }
    }
}

enum SkillLevel: String, Codable, CaseIterable, Identifiable, Comparable {
    case beginner
    case elementary
    case intermediate
    case advanced
    case expert

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: "Beginner"
        case .elementary: "Elementary"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        case .expert: "Expert"
        }
    }

    var color: Color {
        switch self {
        case .beginner: .blue
        case .elementary: .cyan
        case .intermediate: .green
        case .advanced: .orange
        case .expert: .yellow
        }
    }

    var hourThreshold: Int {
        switch self {
        case .beginner: 0
        case .elementary: 10
        case .intermediate: 50
        case .advanced: 200
        case .expert: 500
        }
    }

    var sortOrder: Int {
        switch self {
        case .beginner: 0
        case .elementary: 1
        case .intermediate: 2
        case .advanced: 3
        case .expert: 4
        }
    }

    static func < (lhs: SkillLevel, rhs: SkillLevel) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }

    var nextLevel: SkillLevel? {
        switch self {
        case .beginner: .elementary
        case .elementary: .intermediate
        case .intermediate: .advanced
        case .advanced: .expert
        case .expert: nil
        }
    }

    static func level(forHours hours: Double) -> SkillLevel {
        if hours >= 500 { return .expert }
        if hours >= 200 { return .advanced }
        if hours >= 50 { return .intermediate }
        if hours >= 10 { return .elementary }
        return .beginner
    }
}
