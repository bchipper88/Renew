import SwiftUI
import Combine

struct JournalView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingComposer = false
    @State private var showingMoodCheckIn = false
    @State private var selectedMood: MoodOption?

    private let quickPrompts = QuickPrompt.samples
    private let moodOptions = MoodOption.all

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    moodCheckInCard
                    quickPromptsSection
                    newEntryButton
                    journalEntriesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 40)
            }
            .background(GradientBackground())
            .navigationTitle("Journal")
        }
        .task {
            await viewModel.connect(container: container)
        }
        .sheet(isPresented: $showingComposer) {
            JournalComposerView { entry in
                await viewModel.add(entry: entry, container: container)
            }
        }
        .sheet(isPresented: $showingMoodCheckIn) {
            MoodCheckInView(options: moodOptions, selectedMood: $selectedMood)
        }
    }

    private var moodCheckInCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How do you feel?")
                .font(.title2.weight(.semibold))

            if let mood = selectedMood {
                HStack(spacing: 16) {
                    Text(mood.emoji)
                        .font(.system(size: 44))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(mood.label)
                            .font(.headline)
                        Text("Thanks for checking in today.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                Text("Take a quick moment to capture how you're feeling.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button {
                showingMoodCheckIn = true
            } label: {
                Text("Check In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color.black.opacity(0.85)))
                    .foregroundStyle(.white)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    private var quickPromptsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quick Prompts")
                    .font(.headline)
                Spacer()
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(quickPrompts) { prompt in
                        QuickPromptCard(prompt: prompt)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }

    private var newEntryButton: some View {
        Button {
            showingComposer = true
        } label: {
            Text("+ New Journal Entry")
                .font(.headline.weight(.semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color.black))
                .foregroundStyle(.white)
                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }

    private var journalEntriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Journal Entries")
                .font(.title2.weight(.semibold))

            if viewModel.entries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nothing logged yet")
                        .font(.headline)
                    Text("Your reflections will appear here once you add a new entry.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                )
            } else {
                VStack(spacing: 18) {
                    ForEach(viewModel.entries) { entry in
                        JournalEntryRow(entry: entry)
                    }
                }
            }
        }
    }
}

struct QuickPromptCard: View {
    let prompt: QuickPrompt

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.title)
                .font(.headline)
            Text(prompt.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 220, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(prompt.tint.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(prompt.tint.opacity(0.3), lineWidth: 1)
        )
    }
}

struct QuickPrompt: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tint: Color

    static let samples: [QuickPrompt] = [
        QuickPrompt(id: "purpose", title: "What gave you purpose today?", subtitle: "Take a minute to celebrate it.", tint: Color(red: 0.98, green: 0.74, blue: 0.70)),
        QuickPrompt(id: "gratitude", title: "List one thing you're grateful for.", subtitle: "Small moments count too.", tint: Color(red: 0.74, green: 0.80, blue: 1.0))
    ]
}

struct MoodOption: Identifiable, Hashable {
    let id: String
    let emoji: String
    let label: String
    let tint: Color

    static let all: [MoodOption] = [
        MoodOption(id: "radiant", emoji: "😄", label: "Radiant", tint: Color(red: 0.99, green: 0.79, blue: 0.36)),
        MoodOption(id: "grateful", emoji: "😊", label: "Grateful", tint: Color(red: 0.98, green: 0.64, blue: 0.68)),
        MoodOption(id: "steady", emoji: "🙂", label: "Steady", tint: Color(red: 0.77, green: 0.86, blue: 0.76)),
        MoodOption(id: "curious", emoji: "🤔", label: "Curious", tint: Color(red: 0.75, green: 0.83, blue: 0.99)),
        MoodOption(id: "stretched", emoji: "😬", label: "Stretched", tint: Color(red: 0.97, green: 0.77, blue: 0.53)),
        MoodOption(id: "tired", emoji: "😴", label: "Tired", tint: Color(red: 0.78, green: 0.73, blue: 0.89)),
        MoodOption(id: "overwhelmed", emoji: "😓", label: "Overwhelmed", tint: Color(red: 0.96, green: 0.74, blue: 0.73)),
        MoodOption(id: "discouraged", emoji: "😔", label: "Discouraged", tint: Color(red: 0.86, green: 0.70, blue: 0.80))
    ]
}

struct MoodCheckInView: View {
    @Environment(\.dismiss) private var dismiss
    let options: [MoodOption]
    @Binding var selectedMood: MoodOption?

    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                Text("Select the mood that fits best right now.")
                    .font(.headline)

                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(options) { option in
                        Button {
                            selectedMood = option
                            dismiss()
                        } label: {
                            VStack(spacing: 12) {
                                Text(option.emoji)
                                    .font(.system(size: 36))
                                Text(option.label)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                            .frame(maxWidth: .infinity, minHeight: 82)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(option.tint.opacity(0.22))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(option.tint.opacity(0.4), lineWidth: selectedMood == option ? 2 : 1)
                            )
                        }
                    }
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Mood Check-In")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Text(entry.date.formatted(date: .long, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                MoodBadge(mood: entry.moodScore, energy: entry.energyScore)
            }

            Text(entry.purposeNote)
                .font(.headline)

            Text(entry.gratitudeNote)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 8)
    }
}

struct JournalComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var purpose = ""
    @State private var gratitude = ""
    @State private var mood = 3
    @State private var energy = 3
    @State private var burnout = 3
    var onSubmit: (JournalEntry) async -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Prompts") {
                    TextField("What gave you purpose today?", text: $purpose, axis: .vertical)
                    TextField("List one thing you're grateful for.", text: $gratitude, axis: .vertical)
                }

                Section("Scores") {
                    Stepper(value: $mood, in: 1...5) {
                        Label("Mood", systemImage: "face.smiling")
                        Spacer()
                        Text("\(mood)")
                    }
                    Stepper(value: $energy, in: 1...5) {
                        Label("Energy", systemImage: "bolt.fill")
                        Spacer()
                        Text("\(energy)")
                    }
                    Stepper(value: $burnout, in: 1...5) {
                        Label("Burnout", systemImage: "flame")
                        Spacer()
                        Text("\(burnout)")
                    }
                }
            }
            .navigationTitle("New Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await submit()
                        }
                    }
                    .disabled(purpose.isEmpty || gratitude.isEmpty)
                }
            }
        }
    }

    private func submit() async {
        let entry = JournalEntry(
            id: UUID(),
            date: Date(),
            purposeNote: purpose,
            gratitudeNote: gratitude,
            moodScore: mood,
            energyScore: energy,
            burnoutScore: burnout
        )
        await onSubmit(entry)
        dismiss()
    }
}

struct MoodBadge: View {
    let mood: Int
    let energy: Int

    var body: some View {
        HStack(spacing: 4) {
            Label("\(mood)", systemImage: "face.smiling")
            Label("\(energy)", systemImage: "bolt.fill")
        }
        .font(.caption)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(Color.teal.opacity(0.16)))
    }
}

@MainActor
final class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    private var cancellables: Set<AnyCancellable> = []

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
        container.journalService.entriesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$entries)
    }

    func add(entry: JournalEntry, container: AppContainer) async {
        do {
            try await container.journalService.addEntry(entry)
        } catch {
            // TODO: handle error states
        }
    }
}
