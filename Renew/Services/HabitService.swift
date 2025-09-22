import Combine
import Foundation

final class HabitService {
    private let dailyLogSubject: CurrentValueSubject<HabitLog, Never>

    init() {
        let today = HabitLog.placeholder(date: Date())
        self.dailyLogSubject = CurrentValueSubject(today)
    }

    var dailyLogPublisher: AnyPublisher<HabitLog, Never> {
        dailyLogSubject.eraseToAnyPublisher()
    }

    func defaultGoals() -> [CoreHabitType] {
        CoreHabitType.allCases
    }

    @MainActor
    func saveGoals(_ goals: [CoreHabitType]) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        // TODO: Persist to Supabase `user_profile`
    }

    @MainActor
    func requestHealthPermissions() async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        // TODO: Request HealthKit permissions
    }

    @MainActor
    func update(metric: CoreHabitType, progress: Double) {
        var log = dailyLogSubject.value
        if var metricValue = log.metrics[metric] {
            metricValue.progress = progress
            log.metrics[metric] = metricValue
        }
        dailyLogSubject.send(log)
    }

    @MainActor
    func toggleShutdownDone() {
        var log = dailyLogSubject.value
        log.shutdownDone.toggle()
        dailyLogSubject.send(log)
    }
}
