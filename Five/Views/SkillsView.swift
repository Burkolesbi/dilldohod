import SwiftUI
import SwiftData

struct SkillsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Skill.dateStarted, order: .reverse) private var allSkills: [Skill]

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    private var activeSkills: [Skill] {
        allSkills.filter { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(activeSkills) { skill in
                        NavigationLink(destination: SkillDetailView(skill: skill)) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(cardBg)
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            Circle()
                                                .stroke(skill.currentLevel.color.opacity(0.5), lineWidth: 2)
                                        )
                                    Image(systemName: skill.category.iconName)
                                        .foregroundStyle(skill.currentLevel.color)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(skill.name)
                                        .font(.subheadline.bold())
                                        .foregroundStyle(.white)
                                    Text("\(String(format: "%.1f", skill.totalHours)) hrs - \(skill.currentLevel.displayName)")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.gray.opacity(0.5))
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(cardBg)
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(darkBg)
            .navigationTitle("Skills")
        }
    }
}

#Preview {
    SkillsView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
