import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Skill.dateStarted, order: .reverse) private var allSkills: [Skill]
    @Query(sort: \PracticeSession.date, order: .reverse) private var allSessions: [PracticeSession]
    @Query private var allMilestones: [Milestone]
    @Binding var showPractice: Bool
    @State private var showAddSkill = false

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    private var activeSkills: [Skill] {
        allSkills.filter { $0.isActive }
    }

    private var totalXP: Int {
        allSkills.reduce(0) { $0 + $1.totalPracticeMinutes }
    }

    private var currentLevel: Int {
        xpLevel(for: totalXP)
    }

    private var xpForCurrentLevel: Int {
        xpThreshold(for: currentLevel)
    }

    private var xpForNextLevel: Int {
        xpThreshold(for: currentLevel + 1)
    }

    private var xpProgressInLevel: Double {
        let range = xpForNextLevel - xpForCurrentLevel
        guard range > 0 else { return 1.0 }
        return Double(totalXP - xpForCurrentLevel) / Double(range)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Skill Quest")
                            .font(.title.bold())
                            .foregroundStyle(.white)
                        Text("Keep grinding!")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                    Button {
                        showAddSkill = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(neonBlue)
                            .shadow(color: neonBlue.opacity(0.5), radius: 6)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                xpBarSection
                    .padding(.horizontal, 20)

                if !activeSkills.isEmpty {
                    skillsScrollSection
                }

                todayPracticeCard
                    .padding(.horizontal, 20)

                achievementsSection
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(darkBg)
        .sheet(isPresented: $showAddSkill) {
            AddSkillView()
        }
    }

    private var xpBarSection: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text("Level \(currentLevel)")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                }

                Spacer()

                Text("\(totalXP)/\(xpForNextLevel) XP")
                    .font(.caption.bold())
                    .foregroundStyle(neonBlue)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [neonBlue, neonPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * max(xpProgressInLevel, 0.02), height: 12)
                        .shadow(color: neonBlue.opacity(0.6), radius: 6)
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [neonBlue.opacity(0.3), neonPurple.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var skillsScrollSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your Skills")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(activeSkills) { skill in
                        SkillBadgeView(skill: skill, neonBlue: neonBlue, neonPurple: neonPurple, cardBg: cardBg)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var todayPracticeCard: some View {
        let calendar = Calendar.current
        let todaySessions = allSessions.filter { calendar.isDateInToday($0.date) }
        let todayMinutes = todaySessions.reduce(0) { $0 + $1.durationMinutes }

        return VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Practice")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("\(todaySessions.count) session\(todaySessions.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(todayMinutes)")
                        .font(.title.bold())
                        .foregroundStyle(neonBlue)
                    Text("minutes")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }

            Button {
                showPractice = true
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Start Practice")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [neonBlue, neonPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: neonBlue.opacity(0.4), radius: 8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(neonBlue.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var achievementsSection: some View {
        let completedMilestones = allMilestones.filter { $0.isCompleted }
        let pendingMilestones = allMilestones.filter { !$0.isCompleted }

        let achievementIcons: [(String, String, Bool)] = [
            ("flame.fill", "First Session", allSessions.count >= 1),
            ("star.fill", "5 Sessions", allSessions.count >= 5),
            ("bolt.fill", "Level 3", currentLevel >= 3),
            ("trophy.fill", "100 XP", totalXP >= 100),
            ("crown.fill", "500 XP", totalXP >= 500),
            ("medal.fill", "Milestone Done", completedMilestones.count >= 1)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(achievementIcons.filter(\.2).count)/\(achievementIcons.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(achievementIcons.indices, id: \.self) { i in
                        let achievement = achievementIcons[i]
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(achievement.2 ? cardBg : Color.white.opacity(0.05))
                                    .frame(width: 52, height: 52)
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                achievement.2 ? neonBlue.opacity(0.6) : Color.gray.opacity(0.2),
                                                lineWidth: 1.5
                                            )
                                    )
                                    .shadow(color: achievement.2 ? neonBlue.opacity(0.3) : .clear, radius: 6)

                                Image(systemName: achievement.0)
                                    .font(.title3)
                                    .foregroundStyle(achievement.2 ? .yellow : .gray.opacity(0.3))
                            }

                            Text(achievement.1)
                                .font(.caption2)
                                .foregroundStyle(achievement.2 ? .white : .gray.opacity(0.5))
                                .lineLimit(1)
                        }
                        .frame(width: 68)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(neonPurple.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func xpLevel(for xp: Int) -> Int {
        if xp >= 2000 { return 7 }
        if xp >= 1500 { return 6 }
        if xp >= 1000 { return 5 }
        if xp >= 600 { return 4 }
        if xp >= 300 { return 3 }
        if xp >= 100 { return 2 }
        return 1
    }

    private func xpThreshold(for level: Int) -> Int {
        switch level {
        case 1: return 0
        case 2: return 100
        case 3: return 300
        case 4: return 600
        case 5: return 1000
        case 6: return 1500
        case 7: return 2000
        default: return 3000
        }
    }
}

struct SkillBadgeView: View {
    let skill: Skill
    let neonBlue: Color
    let neonPurple: Color
    let cardBg: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [skill.currentLevel.color, skill.currentLevel.color.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 58, height: 58)
                    .shadow(color: skill.currentLevel.color.opacity(0.4), radius: 6)

                Circle()
                    .fill(cardBg)
                    .frame(width: 50, height: 50)

                Image(systemName: skill.category.iconName)
                    .font(.title3)
                    .foregroundStyle(skill.currentLevel.color)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("L\(skill.currentLevel.sortOrder + 1)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(skill.currentLevel.color)
                    .clipShape(Capsule())
                    .offset(x: 4, y: 4)
            }

            Text(skill.name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
        .frame(width: 72)
    }
}

#Preview {
    HomeView(showPractice: .constant(false))
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
