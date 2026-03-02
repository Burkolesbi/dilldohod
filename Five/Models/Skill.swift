import Foundation
import SwiftData

@Model
final class Skill {
    var id: UUID
    var name: String
    var category: SkillCategory
    var currentLevel: SkillLevel
    var totalPracticeMinutes: Int
    var targetHours: Int
    var dateStarted: Date
    var imageData: Data?
    var notes: String
    var isActive: Bool

    @Relationship(deleteRule: .cascade, inverse: \PracticeSession.skill)
    var sessions: [PracticeSession]

    @Relationship(deleteRule: .cascade, inverse: \Milestone.skill)
    var milestones: [Milestone]

    init(
        name: String,
        category: SkillCategory,
        targetHours: Int = 100,
        imageData: Data? = nil,
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.category = category
        self.currentLevel = .beginner
        self.totalPracticeMinutes = 0
        self.targetHours = targetHours
        self.dateStarted = Date()
        self.imageData = imageData
        self.notes = notes
        self.isActive = true
        self.sessions = []
        self.milestones = []
    }

    var totalHours: Double {
        Double(totalPracticeMinutes) / 60.0
    }

    var progressToTarget: Double {
        guard targetHours > 0 else { return 0 }
        return min(totalHours / Double(targetHours), 1.0)
    }

    var hoursToNextLevel: Double {
        guard let next = currentLevel.nextLevel else { return 0 }
        return max(Double(next.hourThreshold) - totalHours, 0)
    }

    var progressToNextLevel: Double {
        guard let next = currentLevel.nextLevel else { return 1.0 }
        let currentThreshold = Double(currentLevel.hourThreshold)
        let nextThreshold = Double(next.hourThreshold)
        let range = nextThreshold - currentThreshold
        guard range > 0 else { return 0 }
        return min((totalHours - currentThreshold) / range, 1.0)
    }

    var completedMilestones: Int {
        milestones.filter { $0.isCompleted }.count
    }

    var averageSessionMinutes: Double {
        guard !sessions.isEmpty else { return 0 }
        return Double(totalPracticeMinutes) / Double(sessions.count)
    }

    func recalculateLevel() {
        currentLevel = SkillLevel.level(forHours: totalHours)
    }
}
