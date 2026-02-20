import SwiftUI
import SwiftData

struct ProfileView: View {
    @Query private var allSkills: [Skill]
    @Query(sort: \PracticeSession.date, order: .reverse) private var allSessions: [PracticeSession]
    @Query private var allMilestones: [Milestone]

    @AppStorage("playerName") private var playerName = "Player"
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    private var totalXP: Int {
        allSkills.reduce(0) { $0 + $1.totalPracticeMinutes }
    }

    private var currentLevel: Int {
        xpLevel(for: totalXP)
    }

    private var streakDays: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var streak = 0
        var checkDate = today
        let sessionDates = Set(allSessions.map { calendar.startOfDay(for: $0.date) })
        while sessionDates.contains(checkDate) {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }
        return streak
    }

    private var initials: String {
        let parts = playerName.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(playerName.prefix(2)).uppercased()
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                HStack {
                    Text("Profile")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        hasCompletedOnboarding = false
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundStyle(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                avatarSection
                    .padding(.horizontal, 20)

                statsRow
                    .padding(.horizontal, 20)

                achievementsGrid
                    .padding(.horizontal, 20)

                milestonesBadges
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(darkBg)
    }

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 90, height: 90)
                    .shadow(color: neonBlue.opacity(0.4), radius: 12)

                Circle()
                    .fill(cardBg)
                    .frame(width: 82, height: 82)

                Text(initials)
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }

            Text(playerName)
                .font(.title2.bold())
                .foregroundStyle(.white)

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text("Level \(currentLevel)")
                        .font(.subheadline.bold())
                        .foregroundStyle(neonBlue)
                }

                Text("|")
                    .foregroundStyle(.gray.opacity(0.3))

                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text("\(totalXP) XP")
                        .font(.subheadline.bold())
                        .foregroundStyle(neonPurple)
                }
            }
        }
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            profileStat(
                icon: "flame.fill",
                value: "\(streakDays)",
                label: "Streak",
                color: .orange
            )

            profileStat(
                icon: "clock.fill",
                value: String(format: "%.0f", allSkills.reduce(0.0) { $0 + $1.totalHours }),
                label: "Hours",
                color: neonBlue
            )

            profileStat(
                icon: "star.fill",
                value: "\(allSkills.filter { $0.isActive }.count)",
                label: "Skills",
                color: .yellow
            )

            profileStat(
                icon: "list.bullet",
                value: "\(allSessions.count)",
                label: "Sessions",
                color: neonPurple
            )
        }
    }

    private func profileStat(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.4), radius: 4)

            Text(value)
                .font(.headline)
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var achievementsGrid: some View {
        let completedMilestones = allMilestones.filter { $0.isCompleted }
        let achievements: [(icon: String, title: String, unlocked: Bool)] = [
            ("flame.fill", "First Flame", allSessions.count >= 1),
            ("star.fill", "Rising Star", allSessions.count >= 5),
            ("bolt.fill", "Power Up", currentLevel >= 3),
            ("trophy.fill", "Century", totalXP >= 100),
            ("crown.fill", "Elite", totalXP >= 500),
            ("medal.fill", "Goal Setter", completedMilestones.count >= 1),
            ("sparkles", "Dedicated", streakDays >= 7),
            ("shield.fill", "Veteran", allSessions.count >= 50),
            ("laurel.leading", "Master", currentLevel >= 5)
        ]

        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(achievements.filter(\.unlocked).count)/\(achievements.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(achievements.indices, id: \.self) { i in
                    let a = achievements[i]
                    VStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(a.unlocked ? cardBg : Color.white.opacity(0.03))
                                .frame(height: 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            a.unlocked ? neonBlue.opacity(0.4) : Color.gray.opacity(0.1),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: a.unlocked ? neonBlue.opacity(0.2) : .clear, radius: 6)

                            Image(systemName: a.icon)
                                .font(.title2)
                                .foregroundStyle(a.unlocked ? .yellow : .gray.opacity(0.2))
                        }

                        Text(a.title)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(a.unlocked ? .white : .gray.opacity(0.4))
                            .lineLimit(1)
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
                        .stroke(neonPurple.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private var milestonesBadges: some View {
        let completed = allMilestones.filter { $0.isCompleted }
            .sorted { ($0.dateCompleted ?? .distantPast) > ($1.dateCompleted ?? .distantPast) }
        let pending = allMilestones.filter { !$0.isCompleted }

        return VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.headline)
                .foregroundStyle(.white)

            if allMilestones.isEmpty {
                Text("No milestones set yet. Add them from skill details.")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                if !completed.isEmpty {
                    ForEach(completed.prefix(5)) { milestone in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                                .shadow(color: .green.opacity(0.4), radius: 4)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(milestone.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                if let date = milestone.dateCompleted {
                                    Text(date, style: .date)
                                        .font(.caption2)
                                        .foregroundStyle(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.04))
                        )
                    }
                }

                if !pending.isEmpty {
                    ForEach(pending.prefix(3)) { milestone in
                        HStack(spacing: 10) {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.gray.opacity(0.3))

                            Text(milestone.title)
                                .font(.subheadline)
                                .foregroundStyle(.gray.opacity(0.5))

                            Spacer()
                        }
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.02))
                        )
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
                        .stroke(Color.green.opacity(0.15), lineWidth: 1)
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
}

#Preview {
    ProfileView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
