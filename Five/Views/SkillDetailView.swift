import SwiftUI
import SwiftData

struct SkillDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var skill: Skill
    @State private var appeared = false
    @State private var showingAddMilestone = false
    @State private var newMilestoneTitle = ""

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                headerSection
                xpRingSection
                infoGrid
                milestonesSection
                recentSessionsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .background(darkBg.ignoresSafeArea())
        .navigationTitle(skill.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
        .alert("Add Milestone", isPresented: $showingAddMilestone) {
            TextField("Milestone title", text: $newMilestoneTitle)
            Button("Add") {
                guard !newMilestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
                    newMilestoneTitle = ""
                    return
                }
                let m = Milestone(title: newMilestoneTitle.trimmingCharacters(in: .whitespaces))
                m.skill = skill
                modelContext.insert(m)
                newMilestoneTitle = ""
            }
            Button("Cancel", role: .cancel) { newMilestoneTitle = "" }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [skill.currentLevel.color, skill.currentLevel.color.opacity(0.3)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: skill.currentLevel.color.opacity(0.4), radius: 10)

                Circle()
                    .fill(cardBg)
                    .frame(width: 72, height: 72)

                if let imageData = skill.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(Circle())
                } else {
                    Image(systemName: skill.category.iconName)
                        .font(.title)
                        .foregroundStyle(skill.currentLevel.color)
                }
            }
            .scaleEffect(appeared ? 1 : 0.5)
            .opacity(appeared ? 1 : 0)

            HStack(spacing: 8) {
                Text(skill.category.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(neonBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(neonBlue.opacity(0.15))
                    .clipShape(Capsule())

                Text(skill.currentLevel.displayName)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(skill.currentLevel.color.opacity(0.8))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private var xpRingSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 10)
                    .frame(width: 160, height: 160)

                Circle()
                    .trim(from: 0, to: appeared ? skill.progressToNextLevel : 0)
                    .stroke(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: neonBlue.opacity(0.4), radius: 8)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)

                VStack(spacing: 4) {
                    Text(String(format: "%.1f", skill.totalHours))
                        .font(.title.bold())
                        .foregroundStyle(.white)

                    if let next = skill.currentLevel.nextLevel {
                        Text("of \(next.hourThreshold) hrs")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        Text("hours total")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }

            if let next = skill.currentLevel.nextLevel {
                Text("\(String(format: "%.1f", skill.hoursToNextLevel)) hours to \(next.displayName)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            } else {
                Text("Maximum level reached!")
                    .font(.caption)
                    .foregroundStyle(neonBlue)
                    .shadow(color: neonBlue.opacity(0.4), radius: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(neonBlue.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private var infoGrid: some View {
        HStack(spacing: 12) {
            detailStat(label: "Target", value: "\(skill.targetHours)h", icon: "target", color: neonBlue)
            detailStat(label: "Sessions", value: "\(skill.sessions.count)", icon: "list.bullet", color: neonPurple)
            detailStat(label: "Avg", value: "\(Int(skill.averageSessionMinutes))m", icon: "timer", color: .orange)
        }
    }

    private func detailStat(label: String, value: String, icon: String, color: Color) -> some View {
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

    private var milestonesSection: some View {
        let incomplete = skill.milestones.filter { !$0.isCompleted }.sorted { $0.dateCreated < $1.dateCreated }
        let completed = skill.milestones.filter { $0.isCompleted }

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Milestones")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text("\(completed.count)/\(skill.milestones.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Button {
                    showingAddMilestone = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(neonBlue)
                }
            }

            if skill.milestones.isEmpty {
                Text("No milestones yet")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(incomplete.prefix(5)) { milestone in
                    HStack(spacing: 10) {
                        Button {
                            withAnimation(.snappy) {
                                milestone.isCompleted = true
                                milestone.dateCompleted = Date()
                            }
                        } label: {
                            Image(systemName: "circle")
                                .foregroundStyle(neonBlue)
                        }
                        Text(milestone.title)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                ForEach(completed.prefix(3)) { milestone in
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(milestone.title)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .strikethrough()
                        Spacer()
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.02))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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

    private var recentSessionsSection: some View {
        let sessions = skill.sessions.sorted { $0.date > $1.date }.prefix(5)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Recent Sessions")
                .font(.headline)
                .foregroundStyle(.white)

            if sessions.isEmpty {
                Text("No practice sessions yet")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                ForEach(Array(sessions), id: \.id) { session in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.date, style: .date)
                                .font(.caption.bold())
                                .foregroundStyle(.white)
                            if !session.focusArea.isEmpty {
                                Text(session.focusArea)
                                    .font(.caption2)
                                    .foregroundStyle(.gray)
                                    .lineLimit(1)
                            }
                        }
                        Spacer()
                        Text("+\(session.durationMinutes) XP")
                            .font(.caption.bold())
                            .foregroundStyle(neonBlue)
                            .shadow(color: neonBlue.opacity(0.3), radius: 4)
                    }
                    .padding(10)
                    .background(Color.white.opacity(0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
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
}

struct InfoItem: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)
            Text(value)
                .font(.subheadline.bold())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        SkillDetailView(skill: {
            let skill = Skill(name: "Guitar", category: .music, targetHours: 100)
            skill.totalPracticeMinutes = 1500
            skill.recalculateLevel()
            return skill
        }())
    }
    .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
