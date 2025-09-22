import SwiftUI
import Combine
import OSLog

struct TodayView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = TodayViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Core 4")
                        .font(.title2.weight(.semibold))
                    Text("Complete all four habits to keep your streak alive.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.habitCards) { card in
                        TodayHabitCard(card: card) {
                            viewModel.toggleCompletion(for: card.type)
                        }
                    }
                }

                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Shutdown Ritual")
                                .font(.headline)
                            Text("Wind down with gratitude and reflection.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { viewModel.shutdownDone },
                            set: { _ in viewModel.toggleShutdown() }
                        ))
                        .labelsHidden()
                    }
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    TodayStreakView(streakCount: viewModel.streakCount, completedAll: viewModel.allComplete)
                }
            }
            .padding()
        }
        .background(GradientBackground())
        .navigationTitle("Today")
        .onAppear {
            AppLogger.today.debug("TodayView appeared")
        }
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct TodayHabitCard: View {
    let card: TodayHabitCardViewModel
    let onToggle: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(card.title)
                    .font(.headline)
                Spacer()
                Image(systemName: card.iconName)
                    .font(.title3)
                    .foregroundStyle(card.tint)
            }
            ProgressView(value: card.progressRatio)
                .tint(card.tint)
            HStack {
                Text(card.progressText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onToggle) {
                    Text(card.actionTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(card.tint.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct TodayStreakView: View {
    let streakCount: Int
    let completedAll: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Streak")
                        .font(.headline)
                    Text("Complete all four habits daily to grow your streak.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(streakCount) 🔥")
                    .font(.title.weight(.bold))
            }
            if completedAll {
                Text("Amazing! You're on track today.")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.teal)
            } else {
                Text("Complete the remaining habits to keep the momentum.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var habitCards: [TodayHabitCardViewModel] = []
    @Published private(set) var shutdownDone = false
    @Published private(set) var streakCount = 0

    private var cancellables: Set<AnyCancellable> = []
    private weak var container: AppContainer?

    var allComplete: Bool {
        habitCards.allSatisfy { $0.isComplete } && shutdownDone
    }

    func connect(container: AppContainer) async {
        guard self.container == nil else { return }
        self.container = container
        AppLogger.today.debug("Connecting TodayViewModel to habit service")

        container.habitService.dailyLogPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] log in
                AppLogger.today.debug("Received habit log update for date: \(log.date)")
                self?.habitCards = log.metrics.map { key, metric in
                    TodayHabitCardViewModel(
                        type: key,
                        metric: metric,
                        iconName: Self.icon(for: key)
                    )
                }
                .sorted(by: { $0.type.rawValue < $1.type.rawValue })
                self?.shutdownDone = log.shutdownDone
                self?.streakCount = 5 // TODO: derive from analytics store
            }
            .store(in: &cancellables)
    }

    func toggleCompletion(for type: CoreHabitType) {
        guard let container else { return }
        // TODO: integrate with live data sources; placeholder toggles
        Task {
            AppLogger.today.debug("Toggling metric update for type: \(type.rawValue)")
            await container.habitService.update(metric: type, progress: randomProgress(for: type))
        }
    }

    func toggleShutdown() {
        guard let container else { return }
        AppLogger.today.debug("Toggling shutdown ritual")
        container.habitService.toggleShutdownDone()
    }

    private func randomProgress(for type: CoreHabitType) -> Double {
        switch type {
        case .screenTime: return Double(Int.random(in: 40...130))
        case .sunlight: return Double(Int.random(in: 5...30))
        case .steps: return Double(Int.random(in: 2_000...10_500))
        case .sleep: return Double(Int.random(in: 5 * 60...8 * 60))
        }
    }

    private static func icon(for type: CoreHabitType) -> String {
        switch type {
        case .screenTime: return "iphone"
        case .sunlight: return "sun.max.fill"
        case .steps: return "figure.walk"
        case .sleep: return "moon.zzz"
        }
    }
}

struct TodayHabitCardViewModel: Identifiable {
    let id = UUID()
    let type: CoreHabitType
    let metric: HabitMetric
    let iconName: String

    var progressRatio: Double { metric.completionRatio }
    var isComplete: Bool { metric.isComplete }
    var title: String { type.title }
    var tint: Color {
        isComplete ? .green : .teal
    }

    var progressText: String {
        switch type {
        case .steps:
            return "\(Int(metric.progress))/\(Int(metric.target)) steps"
        case .sleep:
            let targetHours = metric.target / 60
            let progressHours = metric.progress / 60
            return String(format: "%.1f/%.1f hrs", progressHours, targetHours)
        default:
            return "\(Int(metric.progress))/\(Int(metric.target)) min"
        }
    }

    var actionTitle: String {
        isComplete ? "Great job" : "Log"
    }
}
