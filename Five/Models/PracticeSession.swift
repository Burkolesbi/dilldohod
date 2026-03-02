import Foundation
import SwiftData

@Model
final class PracticeSession {
    var id: UUID
    var date: Date
    var durationMinutes: Int
    var focusArea: String
    var difficultyRating: Int
    var satisfaction: Int
    var notes: String
    var skill: Skill?

    init(
        date: Date = Date(),
        durationMinutes: Int,
        focusArea: String = "",
        difficultyRating: Int = 3,
        satisfaction: Int = 3,
        notes: String = ""
    ) {
        self.id = UUID()
        self.date = date
        self.durationMinutes = durationMinutes
        self.focusArea = focusArea
        self.difficultyRating = min(max(difficultyRating, 1), 5)
        self.satisfaction = min(max(satisfaction, 1), 5)
        self.notes = notes
    }
}
