import SwiftUI
import SwiftData
import PhotosUI

struct AddSkillView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category: SkillCategory = .technology
    @State private var targetHours = 100
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?

    private let darkBg = Color(red: 0.04, green: 0.05, blue: 0.15)
    private let cardBg = Color(red: 0.08, green: 0.09, blue: 0.22)
    private let neonBlue = Color(red: 0.3, green: 0.5, blue: 1.0)

    var body: some View {
        NavigationStack {
            ZStack {
                darkBg.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Skill Name")
                                .font(.headline)
                                .foregroundStyle(.white)
                            TextField("e.g., Guitar, Swimming", text: $name)
                                .padding(14)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(neonBlue.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundStyle(.white)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(.headline)
                                .foregroundStyle(.white)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 10)], spacing: 10) {
                                ForEach(SkillCategory.allCases) { cat in
                                    Button {
                                        withAnimation(.snappy) { category = cat }
                                    } label: {
                                        VStack(spacing: 4) {
                                            Image(systemName: cat.iconName)
                                                .font(.title3)
                                            Text(cat.displayName)
                                                .font(.caption2)
                                        }
                                        .foregroundStyle(category == cat ? .white : .gray)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(category == cat ? neonBlue.opacity(0.3) : cardBg)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke(category == cat ? neonBlue : Color.clear, lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Target: \(targetHours) hours")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Stepper("Target: \(targetHours) hours", value: $targetHours, in: 10...10000, step: 10)
                                .foregroundStyle(.white)
                                .padding(14)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photo")
                                .font(.headline)
                                .foregroundStyle(.white)

                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                HStack {
                                    if let imageData, let uiImage = UIImage(data: imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 50, height: 50)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } else {
                                        Image(systemName: "photo.badge.plus")
                                            .font(.title3)
                                            .foregroundStyle(neonBlue)
                                            .frame(width: 50, height: 50)
                                            .background(cardBg)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                    Text(imageData == nil ? "Add Photo" : "Change Photo")
                                        .foregroundStyle(neonBlue)
                                }
                            }
                            .onChange(of: selectedPhoto) { _, newValue in
                                Task {
                                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                        imageData = data
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                                .foregroundStyle(.white)

                            TextField("Optional notes", text: $notes, axis: .vertical)
                                .lineLimit(3...6)
                                .padding(14)
                                .background(cardBg)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(neonBlue.opacity(0.2), lineWidth: 1)
                                )
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Skill")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.gray)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveSkill()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(neonBlue)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func saveSkill() {
        let skill = Skill(
            name: name.trimmingCharacters(in: .whitespaces),
            category: category,
            targetHours: targetHours,
            imageData: imageData,
            notes: notes
        )
        modelContext.insert(skill)
        dismiss()
    }
}

#Preview {
    AddSkillView()
        .modelContainer(for: [Skill.self, PracticeSession.self, Milestone.self], inMemory: true)
}
