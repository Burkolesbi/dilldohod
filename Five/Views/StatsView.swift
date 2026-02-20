import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \Skill.name) private var allSkills: [Skill]
    @Query(sort: \PracticeSession.date, order: .reverse) private var allSessions: [PracticeSession]

    @State private var selectedSkillIndex: Int = 0
    @State private var appeared = false

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    private var activeSkills: [Skill] {
        allSkills.filter { $0.isActive }
    }

    private var selectedSkill: Skill? {
        guard !activeSkills.isEmpty, selectedSkillIndex < activeSkills.count else { return nil }
        return activeSkills[selectedSkillIndex]
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack {
                    Text("Statistics")
                        .font(.title.bold())
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if !activeSkills.isEmpty {
                    skillPicker
                        .padding(.horizontal, 20)
                }

                weeklyBarChart
                    .padding(.horizontal, 20)

                if selectedSkill != nil {
                    skillProgressChart
                        .padding(.horizontal, 20)
                }

                summaryRow
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(darkBg)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
    }

    private var skillPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(activeSkills.enumerated()), id: \.element.id) { index, skill in
                    Button {
                        withAnimation(.snappy) {
                            selectedSkillIndex = index
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: skill.category.iconName)
                                .font(.caption)
                            Text(skill.name)
                                .font(.caption.weight(.medium))
                        }
                        .foregroundStyle(selectedSkillIndex == index ? .white : .gray)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedSkillIndex == index ? neonBlue.opacity(0.3) : cardBg)
                                .overlay(
                                    Capsule()
                                        .stroke(
                                            selectedSkillIndex == index ? neonBlue.opacity(0.6) : Color.clear,
                                            lineWidth: 1
                                        )
                                )
                        )
                    }
                }
            }
        }
    }

    private var weeklyBarChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hours by Day")
                .font(.headline)
                .foregroundStyle(.white)

            let dailyData = last7DaysData()

            Chart(dailyData, id: \.label) { entry in
                BarMark(
                    x: .value("Day", entry.label),
                    y: .value("Hours", appeared ? entry.hours : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [neonBlue, neonPurple],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(4)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.08))
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.gray)
                }
            }
            .frame(height: 180)
            .animation(.easeOut(duration: 0.8), value: appeared)
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

    private var skillProgressChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cumulative Progress")
                .font(.headline)
                .foregroundStyle(.white)

            if let skill = selectedSkill {
                let progressData = cumulativeProgress(for: skill)

                if progressData.isEmpty {
                    Text("No sessions yet for this skill")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    Chart(progressData, id: \.date) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Hours", entry.hours)
                        )
                        .foregroundStyle(neonPurple)
                        .lineStyle(StrokeStyle(lineWidth: 2))

                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Hours", entry.hours)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [neonPurple.opacity(0.3), neonPurple.opacity(0.0)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine()
                                .foregroundStyle(Color.white.opacity(0.08))
                            AxisValueLabel()
                                .foregroundStyle(.gray)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in
                            AxisValueLabel()
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(height: 180)
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

    private var summaryRow: some View {
        let totalHours = activeSkills.reduce(0.0) { $0 + $1.totalHours }
        let totalSessions = allSessions.count
        let streak = calculateStreak()

        return HStack(spacing: 12) {
            miniStatCard(icon: "clock.fill", value: String(format: "%.1f", totalHours), label: "Hours", color: neonBlue)
            miniStatCard(icon: "list.bullet", value: "\(totalSessions)", label: "Sessions", color: neonPurple)
            miniStatCard(icon: "flame.fill", value: "\(streak)", label: "Streak", color: .orange)
        }
    }

    private func miniStatCard(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.4), radius: 4)

            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text(label)
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func last7DaysData() -> [(label: String, hours: Double)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

        return (0..<7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today)!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: day)!

            let dayMinutes = allSessions.filter { session in
                session.date >= day && session.date < nextDay
            }.reduce(0) { $0 + $1.durationMinutes }

            return (label: dayFormatter.string(from: day), hours: Double(dayMinutes) / 60.0)
        }
    }

    private func cumulativeProgress(for skill: Skill) -> [(date: Date, hours: Double)] {
        let sorted = skill.sessions.sorted { $0.date < $1.date }
        guard !sorted.isEmpty else { return [] }

        var cumulative: Double = 0
        return sorted.map { session in
            cumulative += Double(session.durationMinutes) / 60.0
            return (date: session.date, hours: cumulative)
        }
    }

    private func calculateStreak() -> Int {
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
}

#Preview {
    StatsView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
