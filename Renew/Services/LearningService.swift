import Combine
import Foundation

final class LearningService {
    private let articlesSubject: CurrentValueSubject<[LearningArticle], Never>

    init() {
        let topics = [
            LearningArticle(
                id: UUID(),
                title: "Self-Labeling and Identity",
                bodyMarkdown: """
                Reclaim your identity by naming helpful labels and releasing harmful ones.
                """,
                isPremium: false
            ),
            LearningArticle.sample,
            LearningArticle(
                id: UUID(),
                title: "Screen Time Effects",
                bodyMarkdown: """
                Reducing screen time lowers stress and improves sleep. Renew shows your daily totals to keep you accountable.
                """,
                isPremium: true
            )
        ]
        self.articlesSubject = CurrentValueSubject(topics)
    }

    var articlesPublisher: AnyPublisher<[LearningArticle], Never> {
        articlesSubject.eraseToAnyPublisher()
    }
}
