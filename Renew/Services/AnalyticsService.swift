import Combine
import Foundation

final class AnalyticsService {
    private let snapshotsSubject: CurrentValueSubject<[AnalyticsSnapshot], Never>

    init() {
        self.snapshotsSubject = CurrentValueSubject([.weekly])
    }

    var snapshotsPublisher: AnyPublisher<[AnalyticsSnapshot], Never> {
        snapshotsSubject.eraseToAnyPublisher()
    }
}
