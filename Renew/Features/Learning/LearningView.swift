import SwiftUI
import Combine

struct LearningView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = LearningViewModel()

    var body: some View {
        NavigationStack {
            List(viewModel.articles) { article in
                NavigationLink(value: article) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(article.title)
                            .font(.headline)
                        Text(article.isPremium ? "Premium" : "Included")
                            .font(.caption)
                            .foregroundStyle(article.isPremium ? .orange : .teal)
                    }
                }
            }
            .background(GradientBackground())
            .scrollContentBackground(.hidden)
            .navigationTitle("Learning")
            .navigationDestination(for: LearningArticle.self) { article in
                LearningDetailView(article: article)
            }
        }
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct LearningDetailView: View {
    let article: LearningArticle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .font(.title2.weight(.semibold))
                Text(article.bodyMarkdown)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .navigationTitle(article.title)
    }
}

@MainActor
final class LearningViewModel: ObservableObject {
    @Published var articles: [LearningArticle] = []
    private var cancellables: Set<AnyCancellable> = []

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
        container.learningService.articlesPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$articles)
    }
}
