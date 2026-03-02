import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    var body: some View {
        NavigationStack {
            ZStack {
                darkBg.ignoresSafeArea()

                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        HStack {
                            Label("Version", systemImage: "info.circle")
                                .foregroundStyle(.white)
                            Spacer()
                            Text("2.0.0")
                                .foregroundStyle(.gray)
                        }
                        .padding(14)
                        .background(cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            Label("Built with", systemImage: "swift")
                                .foregroundStyle(.white)
                            Spacer()
                            Text("SwiftUI + SwiftData")
                                .foregroundStyle(.gray)
                        }
                        .padding(14)
                        .background(cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        Button {
                            hasCompletedOnboarding = false
                        } label: {
                            HStack {
                                Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                                Spacer()
                            }
                            .foregroundStyle(.red)
                            .padding(14)
                            .background(cardBg)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(16)

                    Spacer()
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(neonBlue)
                }
            }
        }
    }
}

struct CategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
    }
}

#Preview {
    SettingsView()
}
