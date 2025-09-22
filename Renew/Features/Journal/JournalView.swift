import SwiftUI
import Combine

struct JournalView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingComposer = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.entries) { entry in
                    JournalEntryRow(entry: entry)
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingComposer = true }) {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("New Entry")
                }
            }
            .sheet(isPresented: $showingComposer) {
                JournalComposerView { entry in
                    await viewModel.add(entry: entry, container: container)
                }
            }
        }
        .background(GradientBackground())
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
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
        .padding(.vertical, 8)
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
        .padding(6)
        .background(Capsule().fill(Color.teal.opacity(0.12)))
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
