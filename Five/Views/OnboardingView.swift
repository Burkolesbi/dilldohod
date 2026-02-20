import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("playerName") private var playerName = ""

    @State private var step: OnboardingStep = .welcome
    @State private var nameInput = ""
    @State private var selectedSkills: Set<SkillTemplate> = []
    @State private var appeared = false

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    enum OnboardingStep {
        case welcome
        case nameEntry
        case skillPick
    }

    struct SkillTemplate: Hashable {
        let name: String
        let emoji: String
        let category: SkillCategory
    }

    private let skillTemplates: [SkillTemplate] = [
        SkillTemplate(name: "Guitar", emoji: "🎸", category: .music),
        SkillTemplate(name: "Piano", emoji: "🎹", category: .music),
        SkillTemplate(name: "Singing", emoji: "🎤", category: .music),
        SkillTemplate(name: "Drawing", emoji: "🎨", category: .art),
        SkillTemplate(name: "Photography", emoji: "📷", category: .art),
        SkillTemplate(name: "Cooking", emoji: "🍳", category: .cooking),
        SkillTemplate(name: "Baking", emoji: "🧁", category: .cooking),
        SkillTemplate(name: "Spanish", emoji: "🇪🇸", category: .language),
        SkillTemplate(name: "Japanese", emoji: "🇯🇵", category: .language),
        SkillTemplate(name: "French", emoji: "🇫🇷", category: .language),
        SkillTemplate(name: "Running", emoji: "🏃", category: .sport),
        SkillTemplate(name: "Yoga", emoji: "🧘", category: .sport),
        SkillTemplate(name: "Swimming", emoji: "🏊", category: .sport),
        SkillTemplate(name: "Coding", emoji: "💻", category: .technology),
        SkillTemplate(name: "Design", emoji: "🖌️", category: .technology),
        SkillTemplate(name: "Knitting", emoji: "🧶", category: .craft),
        SkillTemplate(name: "Writing", emoji: "✍️", category: .academic),
        SkillTemplate(name: "Chess", emoji: "♟️", category: .academic),
    ]

    var body: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            switch step {
            case .welcome:
                welcomeView
            case .nameEntry:
                nameEntryView
            case .skillPick:
                skillPickView
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 0.6)) {
                    appeared = true
                }
            }
        }
    }

    private var welcomeView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(neonBlue)
                .shadow(color: neonBlue.opacity(0.6), radius: 16)
                .scaleEffect(appeared ? 1.0 : 0.5)
                .opacity(appeared ? 1 : 0)

            VStack(spacing: 12) {
                Text("Skill Quest")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)
                    .opacity(appeared ? 1 : 0)

                Text("Level up your real-world skills")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
                    .opacity(appeared ? 1 : 0)
            }

            VStack(spacing: 8) {
                featureRow(icon: "bolt.fill", text: "Earn XP for every minute of practice", color: .yellow)
                featureRow(icon: "chart.bar.fill", text: "Track your progress with detailed stats", color: neonBlue)
                featureRow(icon: "trophy.fill", text: "Unlock achievements as you grow", color: neonPurple)
            }
            .padding(.horizontal, 32)
            .opacity(appeared ? 1 : 0)

            Spacer()

            Button {
                withAnimation(.snappy) { step = .nameEntry }
            } label: {
                Text("Begin Your Quest")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: neonBlue.opacity(0.4), radius: 10)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 50)
        }
    }

    private func featureRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.4), radius: 4)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var nameEntryView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 56))
                .foregroundStyle(neonPurple)
                .shadow(color: neonPurple.opacity(0.5), radius: 12)

            VStack(spacing: 8) {
                Text("Create Your Profile")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text("What should we call you?")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            TextField("Enter your name", text: $nameInput)
                .font(.title3)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(cardBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(neonBlue.opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 40)

            Spacer()

            Button {
                withAnimation(.snappy) { step = .skillPick }
            } label: {
                Text("Next")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: neonBlue.opacity(0.4), radius: 10)
            }
            .padding(.horizontal, 32)
            .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1.0)

            Button {
                withAnimation(.snappy) { step = .welcome }
            } label: {
                Text("Back")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 50)
        }
    }

    private var skillPickView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("Choose Your Skills")
                    .font(.title.bold())
                    .foregroundStyle(.white)

                Text("Pick at least 1 skill to begin (\(selectedSkills.count) selected)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.top, 40)

            ScrollView(showsIndicators: false) {
                let columns = [
                    GridItem(.adaptive(minimum: 90), spacing: 12)
                ]

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(skillTemplates, id: \.name) { template in
                        let isSelected = selectedSkills.contains(template)
                        Button {
                            withAnimation(.snappy) {
                                if isSelected {
                                    selectedSkills.remove(template)
                                } else {
                                    selectedSkills.insert(template)
                                }
                            }
                        } label: {
                            VStack(spacing: 6) {
                                Text(template.emoji)
                                    .font(.title)
                                Text(template.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(isSelected ? .white : .gray)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(isSelected ? neonBlue.opacity(0.25) : cardBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(
                                                isSelected ? neonBlue : Color.clear,
                                                lineWidth: 1.5
                                            )
                                    )
                            )
                            .shadow(color: isSelected ? neonBlue.opacity(0.3) : .clear, radius: 6)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }

            Button {
                finishOnboarding()
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("Start Your Journey")
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [neonBlue, neonPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: neonBlue.opacity(0.4), radius: 10)
            }
            .padding(.horizontal, 32)
            .disabled(selectedSkills.isEmpty)
            .opacity(selectedSkills.isEmpty ? 0.5 : 1.0)

            Button {
                withAnimation(.snappy) { step = .nameEntry }
            } label: {
                Text("Back")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
            .padding(.bottom, 30)
        }
    }

    private func finishOnboarding() {
        playerName = nameInput.trimmingCharacters(in: .whitespaces)

        for template in selectedSkills {
            let skill = Skill(name: template.name, category: template.category)
            modelContext.insert(skill)
        }

        withAnimation(.snappy) {
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
