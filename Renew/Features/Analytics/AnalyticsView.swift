import SwiftUI
import Combine

struct AnalyticsView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.snapshots) { snapshot in
                Section(snapshot.dateRangeDescription) {
                    AnalyticsRow(title: "Core 4 Completion", value: snapshot.core4CompletionRate.asPercent)
                    AnalyticsRow(title: "Mood Average", value: snapshot.averageMood.formatted(.number.precision(.fractionLength(1))))
                    AnalyticsRow(title: "Energy Average", value: snapshot.averageEnergy.formatted(.number.precision(.fractionLength(1))))
                    AnalyticsRow(title: "Longest Streak", value: "\(snapshot.longestStreak) days")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Analytics")
        }
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct AnalyticsRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

@MainActor
final class AnalyticsViewModel: ObservableObject {
    @Published var snapshots: [AnalyticsSnapshot] = []
    private var cancellables: Set<AnyCancellable> = []

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
        container.analyticsService.snapshotsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$snapshots)
    }
}

private extension Double {
    var asPercent: String {
        (self * 100).formatted(.number.precision(.fractionLength(0...1))) + "%"
    }
}
