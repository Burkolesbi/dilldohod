import SwiftUI
import SwiftData

struct MilestonesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Skill> { $0.isActive }, sort: \Skill.name) private var activeSkills: [Skill]

    @State private var selectedSkill: Skill?
    @State private var showingAddMilestone = false
    @State private var newMilestoneTitle = ""

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if activeSkills.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "flag.fill")
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
                                        Text(skill.name)
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(selectedSkill?.id == skill.id ? .white : .gray)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(selectedSkill?.id == skill.id ? neonBlue.opacity(0.3) : cardBg)
                                            )
                                    }
                                }
                            }
                        }

                        if let skill = selectedSkill {
                            let incomplete = skill.milestones.filter { !$0.isCompleted }
                            let completed = skill.milestones.filter { $0.isCompleted }

                            ForEach(incomplete) { milestone in
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
                                .padding(12)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                            ForEach(completed) { milestone in
                                HStack(spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text(milestone.title)
                                        .font(.subheadline)
                                        .foregroundStyle(.gray)
                                        .strikethrough()
                                    Spacer()
                                }
                                .padding(12)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(16)
            }
            .background(darkBg.ignoresSafeArea())
            .navigationTitle("Milestones")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if selectedSkill != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingAddMilestone = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(neonBlue)
                        }
                    }
                }
            }
            .alert("Add Milestone", isPresented: $showingAddMilestone) {
                TextField("Milestone title", text: $newMilestoneTitle)
                Button("Add") {
                    guard let skill = selectedSkill,
                          !newMilestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty else {
                        newMilestoneTitle = ""
                        return
                    }
                    let milestone = Milestone(title: newMilestoneTitle.trimmingCharacters(in: .whitespaces))
                    milestone.skill = skill
                    modelContext.insert(milestone)
                    newMilestoneTitle = ""
                }
                Button("Cancel", role: .cancel) { newMilestoneTitle = "" }
            }
            .onAppear {
                if selectedSkill == nil, let first = activeSkills.first {
                    selectedSkill = first
                }
            }
        }
    }
}

struct MilestoneRow: View {
    let milestone: Milestone
    let isCelebrating: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                Image(systemName: "circle")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
            Text(milestone.title)
                .font(.subheadline)
                .lineLimit(2)
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .scaleEffect(isCelebrating ? 1.05 : 1.0)
    }
}

struct CompletedMilestoneRow: View {
    let milestone: Milestone

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.subheadline)
                    .strikethrough()
                    .foregroundStyle(.secondary)
                if let completed = milestone.dateCompleted {
                    Text(completed, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    MilestonesView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
