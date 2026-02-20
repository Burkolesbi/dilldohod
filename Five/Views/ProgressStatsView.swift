import SwiftUI
import SwiftData

struct ProgressStatsView: View {
    @Query private var allSkills: [Skill]
    @Query(sort: \PracticeSession.date, order: .reverse) private var allSessions: [PracticeSession]
    @Query private var allMilestones: [Milestone]

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    let activeSkills = allSkills.filter { $0.isActive }
                    let totalXP = allSkills.reduce(0) { $0 + $1.totalPracticeMinutes }

                    HStack(spacing: 12) {
                        statCard(title: "Total XP", value: "\(totalXP)", icon: "bolt.fill", color: .yellow)
                        statCard(title: "Skills", value: "\(activeSkills.count)", icon: "star.fill", color: neonBlue)
                    }
                    HStack(spacing: 12) {
                        statCard(title: "Sessions", value: "\(allSessions.count)", icon: "timer", color: .orange)
                        statCard(title: "Hours", value: String(format: "%.1f", activeSkills.reduce(0.0) { $0 + $1.totalHours }), icon: "clock.fill", color: .cyan)
                    }
                }
                .padding(16)
            }
            .background(darkBg.ignoresSafeArea())
            .navigationTitle("Progress")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.4), radius: 4)
            Text(value)
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
        )
    }
}

struct StatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let appeared: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text("\(value)")
                .font(.title2.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct HighlightCard: View {
    let title: String
    let skillName: String
    let icon: String
    let detail: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                Text(skillName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
            }
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ProgressStatsView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
