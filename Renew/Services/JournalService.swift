import Combine
import Foundation

final class JournalService {
    private let entriesSubject: CurrentValueSubject<[JournalEntry], Never>

    init() {
        let today = Date()
        let entries = (0..<7).map { offset -> JournalEntry in
            let date = Calendar.current.date(byAdding: .day, value: -offset, to: today) ?? today
            return JournalEntry.placeholder(date: date)
        }
        self.entriesSubject = CurrentValueSubject(entries)
    }

    var entriesPublisher: AnyPublisher<[JournalEntry], Never> {
        entriesSubject.eraseToAnyPublisher()
    }

    @MainActor
    func addEntry(_ entry: JournalEntry) async throws {
        var entries = entriesSubject.value
        entries.insert(entry, at: 0)
        entriesSubject.send(entries)
    }
}
