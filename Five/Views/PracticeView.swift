import SwiftUI
import SwiftData

struct PracticeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Skill> { $0.isActive }, sort: \Skill.name) private var activeSkills: [Skill]

    @State private var selectedSkill: Skill?
    @State private var durationMinutes = 30
    @State private var focusArea = ""
    @State private var showingSavedAlert = false

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if activeSkills.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "star.slash")
                                .font(.system(size: 48))
                                .foregroundStyle(.gray)
                            Text("No active skills")
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(activeSkills) { skill in
                                    Button {
                                        selectedSkill = skill
                                    } label: {
                                        VStack(spacing: 6) {
                                            ZStack {
                                                Circle()
                                                    .fill(selectedSkill?.id == skill.id ? neonBlue.opacity(0.3) : cardBg)
                                                    .frame(width: 50, height: 50)
                                                Image(systemName: skill.category.iconName)
                                                    .foregroundStyle(selectedSkill?.id == skill.id ? .white : .gray)
                                            }
                                            Text(skill.name)
                                                .font(.caption2)
                                                .foregroundStyle(.white)
                                                .lineLimit(1)
                                        }
                                        .frame(width: 68)
                                    }
                                }
                            }
                        }

                        if selectedSkill != nil {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Duration: \(durationMinutes) min")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Slider(value: Binding(
                                    get: { Double(durationMinutes) },
                                    set: { durationMinutes = Int($0) }
                                ), in: 5...120, step: 5)
                                .tint(neonBlue)
                            }
                            .padding(16)
                            .background(cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 16))

                            TextField("Focus area (optional)", text: $focusArea)
                                .foregroundStyle(.white)
                                .padding(14)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                            Button {
                                logPractice()
                            } label: {
                                Text("Log Practice (+\(durationMinutes) XP)")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        LinearGradient(
                                            colors: [neonBlue, Color(red: 0.6, green: 0.3, blue: 1.0)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(darkBg.ignoresSafeArea())
            .navigationTitle("Quick Log")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear {
                if selectedSkill == nil, let first = activeSkills.first {
                    selectedSkill = first
                }
            }
            .alert("Session Logged", isPresented: $showingSavedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Great practice! XP earned.")
            }
        }
    }

    private func logPractice() {
        guard let skill = selectedSkill else { return }
        let session = PracticeSession(
            durationMinutes: durationMinutes,
            focusArea: focusArea
        )
        session.skill = skill
        modelContext.insert(session)
        skill.totalPracticeMinutes += durationMinutes
        skill.recalculateLevel()
        focusArea = ""
        showingSavedAlert = true
    }
}

struct SkillSelectorCard: View {
    let skill: Skill
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray5))
                        .frame(width: 56, height: 56)
                    Image(systemName: skill.category.iconName)
                        .font(.title3)
                        .foregroundStyle(isSelected ? .white : .blue)
                }
                Text(skill.name)
                    .font(.caption2)
                    .lineLimit(1)
                    .foregroundStyle(isSelected ? .blue : .primary)
            }
            .frame(width: 72)
        }
    }
}

struct StarRating: View {
    @Binding var rating: Int
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(star <= rating ? .yellow : .secondary)
                    .onTapGesture { rating = star }
            }
        }
    }
}

struct SessionRowView: View {
    let session: PracticeSession

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(session.date, style: .date)
                    .font(.caption.bold())
                Spacer()
                Text("\(session.durationMinutes) min")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }
            if !session.focusArea.isEmpty {
                Text(session.focusArea)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    PracticeView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
