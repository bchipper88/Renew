import SwiftUI
import Combine

struct LearningView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = LearningViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    ForEach(viewModel.orderedCategories, id: \.self) { category in
                        let articles = viewModel.articles(for: category)
                        if !articles.isEmpty {
                            LearningCategorySection(
                                category: category,
                                articles: articles,
                                isFavorite: { viewModel.isFavorite($0) },
                                toggleFavorite: { viewModel.toggleFavorite($0) }
                            )
                        }
                    }
                }
                .padding(.vertical, 24)
                .padding(.horizontal, 20)
            }
            .background(GradientBackground())
            .navigationTitle("Learn")
            .navigationDestination(for: LearningArticle.self) { article in
                LearningDetailView(article: article, isFavorite: viewModel.binding(for: article))
            }
        }
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct LearningDetailView: View {
    let article: LearningArticle
    @Binding var isFavorite: Bool
    private let headerHeight: CGFloat = 280

    var body: some View {
        GeometryReader { fullProxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    GeometryReader { proxy in
                        let offset = proxy.frame(in: .named("scroll")).minY
                        let height = offset > 0
                            ? headerHeight + offset
                            : max(headerHeight + offset, 180)
                        let parallaxOffset = offset > 0 ? -offset : offset * 0.35

                        Image(article.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(height: height)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(stops: [
                                        .init(color: .clear, location: 0.35),
                                        .init(color: Color.white.opacity(0.5), location: 0.7),
                                        .init(color: .white, location: 1.0)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .overlay(alignment: .topTrailing) {
                                FavoriteButton(isFavorite: isFavorite) {
                                    isFavorite.toggle()
                                }
                                .padding(.trailing, 20)
                                .padding(.top, 20)
                            }
                            .offset(y: parallaxOffset)
                            .accessibilityHidden(true)
                    }
                    .frame(height: headerHeight)

                    VStack(alignment: .leading, spacing: 24) {
                        LearningDetailHeader(article: article)

                        LearningDetailSection(title: "Summary") {
                            Text(article.summary)
                                .foregroundStyle(.secondary)
                        }

                        LearningDetailSection(title: "Article") {
                            Text(.init(article.articleMarkdown))
                                .foregroundStyle(.primary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        if !article.references.isEmpty {
                            LearningDetailSection(title: "References") {
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(article.references) { reference in
                                        Link(destination: reference.url) {
                                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                                Image(systemName: "link")
                                                    .font(.footnote)
                                                    .foregroundStyle(.tint)
                                                Text(reference.title)
                                                    .foregroundStyle(.tint)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: max(fullProxy.size.height - headerHeight + 40, 0), alignment: .top)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(TopRoundedRectangle(radius: 32))
                    .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 14)
                    .padding(.top, -40)
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .background(
                GradientBackground()
                    .overlay(
                        LinearGradient(colors: [.clear, .white], startPoint: .top, endPoint: .bottom)
                    )
            )
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea(edges: .top)
        }
        .navigationTitle(article.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

@MainActor
final class LearningViewModel: ObservableObject {
    @Published var articles: [LearningArticle] = []
    @Published private(set) var favoriteIDs: Set<LearningArticle.ID> = []
    private var cancellables: Set<AnyCancellable> = []

    var orderedCategories: [LearningCategory] {
        LearningCategory.allCases
    }

    func articles(for category: LearningCategory) -> [LearningArticle] {
        let sortedArticles = articles.sorted { $0.title < $1.title }
        switch category {
        case .favorites:
            return sortedArticles.filter { favoriteIDs.contains($0.id) }
        default:
            return sortedArticles.filter { $0.category == category }
        }
    }

    func isFavorite(_ article: LearningArticle) -> Bool {
        favoriteIDs.contains(article.id)
    }

    func toggleFavorite(_ article: LearningArticle) {
        if favoriteIDs.contains(article.id) {
            favoriteIDs.remove(article.id)
        } else {
            favoriteIDs.insert(article.id)
        }
    }

    func binding(for article: LearningArticle) -> Binding<Bool> {
        Binding(
            get: { [weak self] in
                self?.favoriteIDs.contains(article.id) ?? false
            },
            set: { [weak self] newValue in
                guard let self else { return }
                if newValue {
                    self.favoriteIDs.insert(article.id)
                } else {
                    self.favoriteIDs.remove(article.id)
                }
            }
        )
    }

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
        container.learningService.articlesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] articles in
                guard let self else { return }
                self.articles = articles
                let defaultFavorites = Set(articles.filter { $0.category == .favorites }.map(\.id))
                if self.favoriteIDs.isEmpty {
                    self.favoriteIDs = defaultFavorites
                } else {
                    self.favoriteIDs.formUnion(defaultFavorites)
                }
            }
            .store(in: &cancellables)
    }
}

private struct LearningCategorySection: View {
    let category: LearningCategory
    let articles: [LearningArticle]
    let isFavorite: (LearningArticle) -> Bool
    let toggleFavorite: (LearningArticle) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(category.title)
                .font(.title3.weight(.semibold))

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(articles) { article in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(value: article) {
                                LearningCardView(article: article)
                            }
                            .buttonStyle(.plain)

                            FavoriteButton(isFavorite: isFavorite(article)) {
                                toggleFavorite(article)
                            }
                            .padding(.trailing, 16)
                            .padding(.top, 16)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

private struct LearningCardView: View {
    let article: LearningArticle

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                Image(article.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 170)
                    .frame(maxWidth: .infinity)
                    .clipped()

                LinearGradient(colors: [.clear, Color.black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(article.summary)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(2)
                }
                .padding(16)
            }

            HStack {
                Text(article.category.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(.teal.opacity(0.15), in: Capsule())

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .frame(width: cardWidth)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.18))
        )
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 12)
    }

    private var cardWidth: CGFloat { 260 }
}

private struct LearningDetailHeader: View {
    let article: LearningArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(article.category.title.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(Color.secondary.opacity(0.1), in: Capsule())

            Text(article.title)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
        }
    }
}

private struct LearningDetailSection<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3.weight(.semibold))
                .foregroundStyle(isFavorite ? .red : .white)
                .padding(10)
                .background(.ultraThinMaterial, in: Circle())
        }
        .buttonStyle(.plain)
        .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Save to Favorites")
    }
}

private struct TopRoundedRectangle: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
