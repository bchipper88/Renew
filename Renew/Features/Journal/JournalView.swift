import SwiftUI
import Combine

struct JournalView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingComposer = false
    @State private var showingMoodCheckIn = false
    @State private var selectedMood: MoodOption?
    @State private var energyLevel: Int = 5
    @State private var burnoutLevel: Int = 5
    @State private var activeQuickPrompt: QuickPrompt?

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
            MoodCheckInView(
                options: moodOptions,
                selectedMood: $selectedMood,
                energyLevel: $energyLevel,
                burnoutLevel: $burnoutLevel
            )
        }
        .sheet(item: $activeQuickPrompt) { prompt in
            QuickPromptResponseView(prompt: prompt) { response in
                await submitQuickPromptResponse(response, for: prompt)
                await MainActor.run {
                    activeQuickPrompt = nil
                }
            }
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
                        HStack(spacing: 12) {
                            Label("\(energyLevel)/10", systemImage: "bolt.fill")
                            Label("\(burnoutLevel)/10", systemImage: "flame")
                        }
                        .font(.caption.weight(.semibold))
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
                        QuickPromptCard(prompt: prompt) { selectedPrompt in
                            activeQuickPrompt = selectedPrompt
                        }
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

    private func submitQuickPromptResponse(_ response: String, for prompt: QuickPrompt) async {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let entry = JournalEntry(
            id: UUID(),
            date: Date(),
            purposeNote: prompt.title,
            gratitudeNote: trimmed,
            moodScore: 0,
            energyScore: 0,
            burnoutScore: nil
        )

        await viewModel.add(entry: entry, container: container)
    }
}

struct QuickPromptCard: View {
    let prompt: QuickPrompt
    var onRespond: (QuickPrompt) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(prompt.title)
                .font(.headline)
            Text(prompt.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(20)
        .frame(width: 220, height: 160, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(prompt.tint.opacity(0.18))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(prompt.tint.opacity(0.3), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onRespond(prompt)
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                onRespond(prompt)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(prompt.tint)
            }
            .buttonStyle(.plain)
            .padding(12)
        }
    }
}

struct QuickPrompt: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let tint: Color
    let kind: Kind

    enum Kind {
        case purpose
        case gratitude
    }

    static let samples: [QuickPrompt] = [
        QuickPrompt(
            id: "purpose",
            title: "Purpose",
            subtitle: "What gave you purpose today?",
            tint: Color(red: 0.98, green: 0.74, blue: 0.70),
            kind: .purpose
        ),
        QuickPrompt(
            id: "gratitude",
            title: "Gratitude",
            subtitle: "List one thing you're grateful for.",
            tint: Color(red: 0.74, green: 0.80, blue: 1.0),
            kind: .gratitude
        )
    ]
}

struct QuickPromptResponseView: View {
    @Environment(\.dismiss) private var dismiss
    let prompt: QuickPrompt
    var onSubmit: (String) async -> Void

    @State private var response: String = ""
    @FocusState private var isTextFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(prompt.title)
                        .font(.title3.weight(.semibold))
                    Text(prompt.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(prompt.tint.opacity(0.1))
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(prompt.tint.opacity(0.3), lineWidth: 1)

                    TextEditor(text: $response)
                        .focused($isTextFocused)
                        .background(Color.clear)
                        .padding(12)
                }
                .frame(minHeight: 180)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Quick Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { await submit() }
                    }
                    .disabled(response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task {
                isTextFocused = true
            }
        }
    }

    private func submit() async {
        let trimmed = response.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        await onSubmit(trimmed)
        dismiss()
    }
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
    @Binding var energyLevel: Int
    @Binding var burnoutLevel: Int

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

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Energy", systemImage: "bolt.fill")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(energyLevel)/10")
                                .font(.headline)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(energyLevel) },
                                set: { energyLevel = Int($0) }
                            ),
                            in: 0...10,
                            step: 1
                        )
                        Text("10 means you're feeling fully charged.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Burnout", systemImage: "flame")
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text("\(burnoutLevel)/10")
                                .font(.headline)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(burnoutLevel) },
                                set: { burnoutLevel = Int($0) }
                            ),
                            in: 0...10,
                            step: 1
                        )
                        Text("10 means burnout feels very high right now.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
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
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .disabled(selectedMood == nil)
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
                if entry.moodScore > 0 || entry.energyScore > 0 || entry.burnoutScore != nil {
                    MoodBadge(mood: entry.moodScore, energy: entry.energyScore, burnout: entry.burnoutScore)
                }
            }

            if !entry.purposeNote.isEmpty {
                Text(entry.purposeNote)
                    .font(.headline)
            }

            if !entry.gratitudeNote.isEmpty {
                Text(entry.gratitudeNote)
                    .font(entry.purposeNote.isEmpty ? .headline : .subheadline)
                    .foregroundStyle(entry.purposeNote.isEmpty ? .primary : .secondary)
            }
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
    @State private var energy = 5
    @State private var burnout = 5
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
                    Stepper(value: $energy, in: 0...10) {
                        Label("Energy", systemImage: "bolt.fill")
                        Spacer()
                        Text("\(energy)/10")
                    }
                    Stepper(value: $burnout, in: 0...10) {
                        Label("Burnout", systemImage: "flame")
                        Spacer()
                        Text("\(burnout)/10")
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
    let burnout: Int?

    var body: some View {
        HStack(spacing: 4) {
            Label("\(mood)", systemImage: "face.smiling")
            Label("\(energy)/10", systemImage: "bolt.fill")
            if let burnout {
                Label("\(burnout)/10", systemImage: "flame")
            }
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
