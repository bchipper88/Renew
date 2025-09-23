import Combine
import Foundation

final class LearningService {
    private let articlesSubject: CurrentValueSubject<[LearningArticle], Never>

    init() {
        let topics: [LearningArticle] = [
            LearningArticle(
                id: UUID(),
                title: "Daily Light Ritual",
                summary: "Anchor your circadian rhythm with 10 minutes of early light.",
                articleMarkdown: """
                Opening your blinds within 30 minutes of waking signals to your suprachiasmatic nucleus that it's time to be alert. Pair the habit with your morning beverage so it becomes automatic. On overcast days, extend exposure to 20 minutes to achieve a similar lux dose.
                """,
                category: .favorites,
                imageName: "energizedBot",
                references: [
                    LearningReference(
                        title: "Light exposure and circadian entrainment",
                        url: URL(string: "https://pubmed.ncbi.nlm.nih.gov/30731285/")!
                    )
                ]
            ),
            LearningArticle(
                id: UUID(),
                title: "Magnesium Glycinate",
                summary: "A gentle mineral for muscle relaxation and restorative sleep.",
                articleMarkdown: """
                Magnesium glycinate combines elemental magnesium with the amino acid glycine. The pairing supports GABA activity, encouraging relaxation without digestive side effects common with other forms. Start with 200 mg in the evening alongside a small snack to improve absorption.
                """,
                category: .supplements,
                imageName: "sleepyBot",
                references: [
                    LearningReference(
                        title: "Magnesium supplementation and sleep quality",
                        url: URL(string: "https://pubmed.ncbi.nlm.nih.gov/23853635/")!
                    ),
                    LearningReference(
                        title: "Role of glycine in sleep",
                        url: URL(string: "https://pubmed.ncbi.nlm.nih.gov/22017936/")!
                    )
                ]
            ),
            LearningArticle(
                id: UUID(),
                title: "Identity-Based Habits",
                summary: "Design routines that reinforce who you want to become.",
                articleMarkdown: """
                A habit sticks when it confirms an identity you value. Instead of saying you want to meditate, reframe it as "I am the type of person who protects a calm mind." Attach the identity to an existing ritual and set up a quick win so the feedback loop starts immediately.
                """,
                category: .concepts,
                imageName: "steadyBot",
                references: [
                    LearningReference(
                        title: "Identity and habit formation",
                        url: URL(string: "https://www.frontiersin.org/articles/10.3389/fpsyg.2020.00556/full")!
                    )
                ]
            ),
            LearningArticle.sample
        ]
        self.articlesSubject = CurrentValueSubject(topics)
    }

    var articlesPublisher: AnyPublisher<[LearningArticle], Never> {
        articlesSubject.eraseToAnyPublisher()
    }
}
