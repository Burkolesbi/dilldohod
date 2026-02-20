import Foundation
import SwiftData

@Model
final class Milestone {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var dateCompleted: Date?
    var dateCreated: Date
    var skill: Skill?

    init(
        title: String
    ) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.dateCompleted = nil
        self.dateCreated = Date()
    }
}
