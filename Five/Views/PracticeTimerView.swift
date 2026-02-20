import SwiftUI
import SwiftData

struct PracticeTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(filter: #Predicate<Skill> { $0.isActive }, sort: \Skill.name) private var activeSkills: [Skill]

    @State private var selectedSkill: Skill?
    @State private var selectedMinutes: Int = 30
    @State private var phase: PracticePhase = .selectSkill
    @State private var timeRemaining: Int = 0
    @State private var timer: Timer?
    @State private var isPaused = false
    @State private var earnedXP: Int = 0
    @State private var showXPBurst = false
    @State private var burstParticles: [BurstParticle] = []

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    private let durations = [15, 30, 45, 60]

    enum PracticePhase {
        case selectSkill
        case selectTime
        case practicing
        case finished
    }

    var body: some View {
        ZStack {
            darkBg.ignoresSafeArea()

            switch phase {
            case .selectSkill:
                skillSelectionView
            case .selectTime:
                timeSelectionView
            case .practicing:
                timerView
            case .finished:
                finishedView
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        stopTimer()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                    }
                    .padding(20)
                }
                Spacer()
            }
        }
    }

    private var skillSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("Choose Your Skill")
                .font(.title.bold())
                .foregroundStyle(.white)

            Text("What do you want to practice?")
                .font(.subheadline)
                .foregroundStyle(.gray)

            if activeSkills.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundStyle(.gray)
                    Text("No active skills yet")
                        .foregroundStyle(.gray)
                    Text("Add skills from the home screen first")
                        .font(.caption)
                        .foregroundStyle(.gray.opacity(0.7))
                }
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 16)], spacing: 16) {
                    ForEach(activeSkills) { skill in
                        Button {
                            withAnimation(.snappy) {
                                selectedSkill = skill
                                phase = .selectTime
                            }
                        } label: {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(cardBg)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Circle()
                                                .stroke(skill.currentLevel.color.opacity(0.6), lineWidth: 2)
                                        )
                                        .shadow(color: skill.currentLevel.color.opacity(0.3), radius: 6)

                                    Image(systemName: skill.category.iconName)
                                        .font(.title3)
                                        .foregroundStyle(skill.currentLevel.color)
                                }

                                Text(skill.name)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
    }

    private var timeSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()

            if let skill = selectedSkill {
                VStack(spacing: 8) {
                    Image(systemName: skill.category.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(skill.currentLevel.color)
                        .shadow(color: skill.currentLevel.color.opacity(0.5), radius: 10)

                    Text(skill.name)
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                }
            }

            Text("Set Duration")
                .font(.headline)
                .foregroundStyle(.gray)

            HStack(spacing: 16) {
                ForEach(durations, id: \.self) { mins in
                    Button {
                        withAnimation(.snappy) {
                            selectedMinutes = mins
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text("\(mins)")
                                .font(.title2.bold())
                            Text("min")
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedMinutes == mins ? .white : .gray)
                        .frame(width: 68, height: 68)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(selectedMinutes == mins ? neonBlue.opacity(0.3) : cardBg)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            selectedMinutes == mins ? neonBlue : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                        )
                        .shadow(color: selectedMinutes == mins ? neonBlue.opacity(0.3) : .clear, radius: 6)
                    }
                }
            }

            Button {
                startPractice()
            } label: {
                HStack {
                    Image(systemName: "play.fill")
                    Text("Begin Practice")
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
            .padding(.horizontal, 40)

            Button {
                withAnimation(.snappy) {
                    phase = .selectSkill
                }
            } label: {
                Text("Back")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }

            Spacer()
            Spacer()
        }
    }

    private var timerView: some View {
        VStack(spacing: 40) {
            Spacer()

            if let skill = selectedSkill {
                Text(skill.name)
                    .font(.headline)
                    .foregroundStyle(.gray)
            }

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: 240, height: 240)

                Circle()
                    .trim(from: 0, to: timerProgress)
                    .stroke(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 240, height: 240)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: neonBlue.opacity(0.4), radius: 10)
                    .animation(.linear(duration: 1), value: timeRemaining)

                VStack(spacing: 8) {
                    Text(timeString)
                        .font(.system(size: 56, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)

                    Text(isPaused ? "PAUSED" : "FOCUS")
                        .font(.caption.bold())
                        .foregroundStyle(isPaused ? .yellow : neonBlue)
                        .tracking(4)
                }
            }

            HStack(spacing: 32) {
                Button {
                    togglePause()
                } label: {
                    ZStack {
                        Circle()
                            .fill(cardBg)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(neonBlue.opacity(0.3), lineWidth: 1)
                            )

                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.title3)
                            .foregroundStyle(neonBlue)
                    }
                }

                Button {
                    finishPractice()
                } label: {
                    ZStack {
                        Circle()
                            .fill(cardBg)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
                            )

                        Image(systemName: "stop.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                }
            }

            Spacer()
            Spacer()
        }
    }

    private var finishedView: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()

                Text("+\(earnedXP) XP")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [neonBlue, neonPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: neonBlue.opacity(0.6), radius: 12)
                    .scaleEffect(showXPBurst ? 1.0 : 0.3)
                    .opacity(showXPBurst ? 1.0 : 0.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showXPBurst)

                Text("Great Practice!")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .opacity(showXPBurst ? 1.0 : 0.0)
                    .animation(.easeIn(duration: 0.4).delay(0.3), value: showXPBurst)

                if let skill = selectedSkill {
                    Text(skill.name)
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .opacity(showXPBurst ? 1.0 : 0.0)
                        .animation(.easeIn(duration: 0.4).delay(0.4), value: showXPBurst)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
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
                .padding(.horizontal, 40)
                .opacity(showXPBurst ? 1.0 : 0.0)
                .animation(.easeIn(duration: 0.4).delay(0.6), value: showXPBurst)

                Spacer()
                Spacer()
            }

            ForEach(burstParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .offset(x: showXPBurst ? particle.endX : 0, y: showXPBurst ? particle.endY : 0)
                    .opacity(showXPBurst ? 0 : 1)
                    .animation(
                        .easeOut(duration: particle.duration).delay(particle.delay),
                        value: showXPBurst
                    )
            }
        }
        .onAppear {
            generateBurstParticles()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showXPBurst = true
            }
        }
    }

    private var timerProgress: CGFloat {
        let total = Double(selectedMinutes * 60)
        guard total > 0 else { return 0 }
        return CGFloat(1.0 - Double(timeRemaining) / total)
    }

    private var timeString: String {
        let mins = timeRemaining / 60
        let secs = timeRemaining % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func startPractice() {
        timeRemaining = selectedMinutes * 60
        isPaused = false
        phase = .practicing
        startTimerTick()
    }

    private func startTimerTick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                finishPractice()
            }
        }
    }

    private func togglePause() {
        isPaused.toggle()
        if isPaused {
            timer?.invalidate()
        } else {
            startTimerTick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func finishPractice() {
        stopTimer()

        guard let skill = selectedSkill else {
            dismiss()
            return
        }

        let totalSeconds = selectedMinutes * 60
        let practicedSeconds = totalSeconds - timeRemaining
        let practicedMinutes = max(practicedSeconds / 60, 1)

        earnedXP = practicedMinutes

        let session = PracticeSession(
            durationMinutes: practicedMinutes
        )
        session.skill = skill
        modelContext.insert(session)

        skill.totalPracticeMinutes += practicedMinutes
        skill.recalculateLevel()

        withAnimation {
            phase = .finished
        }
    }

    private func generateBurstParticles() {
        burstParticles = (0..<20).map { _ in
            BurstParticle(
                color: [neonBlue, neonPurple, .yellow, .cyan].randomElement()!,
                size: CGFloat.random(in: 6...14),
                endX: CGFloat.random(in: -150...150),
                endY: CGFloat.random(in: -200...100),
                duration: Double.random(in: 0.6...1.2),
                delay: Double.random(in: 0...0.3)
            )
        }
    }
}

struct BurstParticle: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let endX: CGFloat
    let endY: CGFloat
    let duration: Double
    let delay: Double
}

#Preview {
    PracticeTimerView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
