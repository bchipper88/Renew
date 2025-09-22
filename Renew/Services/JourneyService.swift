import Combine
import Foundation

final class JourneyService {
    private let snapshotsSubject: CurrentValueSubject<[JourneySnapshot], Never>
    private let dailyScoresSubject: CurrentValueSubject<[DailyJourneyScore], Never>

    init() {
        self.snapshotsSubject = CurrentValueSubject([.weekly])

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let range = -59...0
        let scores = range.compactMap { offset -> DailyJourneyScore? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            // Generate a smooth, deterministic curve between 30 and 95.
            let normalized = (sin(Double(offset) / 6.0) + 1) / 2 // 0...1
            let score = 40 + normalized * 55
            return DailyJourneyScore(date: date, score: score)
        }
        self.dailyScoresSubject = CurrentValueSubject(scores)
    }

    var snapshotsPublisher: AnyPublisher<[JourneySnapshot], Never> {
        snapshotsSubject.eraseToAnyPublisher()
    }

    var dailyScoresPublisher: AnyPublisher<[DailyJourneyScore], Never> {
        dailyScoresSubject.eraseToAnyPublisher()
    }
}
