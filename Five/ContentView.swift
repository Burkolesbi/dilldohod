import SwiftUI
import SwiftData

enum AppTab: Int, CaseIterable {
    case home = 0
    case stats = 1
    case profile = 2
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .home
    @State private var showPractice = false

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)

    var body: some View {
        ZStack(alignment: .bottom) {
            darkBg.ignoresSafeArea()

            Group {
                switch selectedTab {
                case .home:
                    HomeView(showPractice: $showPractice)
                case .stats:
                    StatsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)

            CustomTabBar(selectedTab: $selectedTab, showPractice: $showPractice)
        }
        .fullScreenCover(isPresented: $showPractice) {
            PracticeTimerView()
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @Binding var showPractice: Bool

    private let darkBg = Color(red: 0.06, green: 0.07, blue: 0.18)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)
    private let neonPurple = Color(red: 0.6, green: 0.3, blue: 1.0)

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(darkBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [neonBlue.opacity(0.3), neonPurple.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
                .frame(height: 64)
                .shadow(color: neonBlue.opacity(0.15), radius: 20, y: -5)

            HStack {
                tabButton(tab: .home, icon: "house.fill", label: "Home")

                Spacer()

                Color.clear.frame(width: 70)

                Spacer()

                tabButton(tab: .stats, icon: "chart.bar.fill", label: "Stats")

                Spacer()

                tabButton(tab: .profile, icon: "person.fill", label: "Profile")
            }
            .padding(.horizontal, 24)
            .frame(height: 64)

            Button {
                showPractice = true
            } label: {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [neonBlue, neonPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 62, height: 62)
                        .shadow(color: neonBlue.opacity(0.5), radius: 12)
                        .shadow(color: neonPurple.opacity(0.3), radius: 8)

                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -24)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 2)
    }

    private func tabButton(tab: AppTab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.caption2.weight(.medium))
            }
            .foregroundStyle(selectedTab == tab ? neonBlue : .gray.opacity(0.5))
            .shadow(color: selectedTab == tab ? neonBlue.opacity(0.4) : .clear, radius: 6)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
