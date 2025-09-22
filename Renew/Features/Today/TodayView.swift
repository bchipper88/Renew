import SwiftUI
import Combine
import OSLog
import UIKit

struct TodayView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = TodayViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TodayDateHeader()
                TodayProgressHeader(overallCompletion: viewModel.dailyCompletion)

                VStack(spacing: 16) {
                    ForEach(viewModel.habitCards) { card in
                        TodayHabitRow(card: card) {
                            viewModel.toggleCompletion(for: card.type)
                        }
                    }
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

private struct TodayDateHeader: View {
    private let date: Date

    init(date: Date = Date()) {
        self.date = date
    }

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    private static let monthDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()

    private var weekdayString: String {
        Self.weekdayFormatter.string(from: date)
    }

    private var monthDayString: String {
        Self.monthDayFormatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Text(weekdayString)
                .font(.title.weight(.black))
                .foregroundStyle(.primary)
            Text(monthDayString)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

struct TodayHabitRow: View {
    let card: TodayHabitCardViewModel
    let onToggle: () -> Void

    private var buttonGradientColors: [Color] {
        let base = card.tint
        return [base.opacity(0.95), base.opacity(0.7)]
    }

    private var progressGradientStops: [Gradient.Stop] {
        let ratio = max(0, min(card.progressRatio, 1))

        let softRed = Color(red: 0.98, green: 0.56, blue: 0.60)
        let softYellow = Color(red: 0.99, green: 0.88, blue: 0.64)
        let softGreen = Color(red: 0.64, green: 0.88, blue: 0.72)
        let funStart = Color(red: 0.54, green: 0.82, blue: 0.99)
        let funEnd = Color(red: 0.58, green: 0.66, blue: 1.0)

        func solid(_ color: Color) -> [Gradient.Stop] {
            [
                Gradient.Stop(color: color, location: 0),
                Gradient.Stop(color: color, location: 1)
            ]
        }

        if ratio >= 0.999 {
            return [
                Gradient.Stop(color: funStart, location: 0),
                Gradient.Stop(color: funEnd, location: 1)
            ]
        }

        let firstThreshold: Double = 0.33
        let secondThreshold: Double = 0.75

        let colors: (Color, Color, Color)
        if card.type == .screenTime {
            colors = (softGreen, softYellow, softRed)
        } else {
            colors = (softRed, softYellow, softGreen)
        }

        let selectedColor: Color
        if ratio < firstThreshold {
            selectedColor = colors.0
        } else if ratio < secondThreshold {
            selectedColor = colors.1
        } else {
            selectedColor = colors.2
        }

        return solid(selectedColor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: card.iconName)
                    .font(.title3)
                    .foregroundStyle(card.tint)
                Text(card.title)
                    .font(.headline)
                Spacer()
            }
            GradientProgressBar(
                value: card.progressRatio,
                gradientStops: progressGradientStops,
                height: 14,
                backgroundOpacity: 0.2
            )
            Text(card.progressText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Button(action: onToggle) {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: buttonGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .buttonStyle(.plain)
            .padding(12)
        }
    }
}

struct TodayProgressHeader: View {
    let overallCompletion: Double

    private var clampedCompletion: Double {
        min(max(overallCompletion, 0), 1)
    }

    private var headerGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.blue.opacity(0.9),
                Color.teal.opacity(0.85)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Daily Progress")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))

                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(clampedCompletion * 100))%")
                        .font(.system(size: 58, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                    if clampedCompletion >= 1 {
                        Text("Complete")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            Text(
                clampedCompletion >= 1
                    ? "You're done! Celebrate the win and rest easy."
                    : "Finish your remaining habits to close out the day."
            )
            .font(.footnote.weight(.semibold))
            .foregroundStyle(.white.opacity(0.85))
        }
        .padding(24)
        .padding(.trailing, 148)
        .background(headerGradient, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            CharacterIllustration(completion: clampedCompletion)
                .padding(20)
        }
    }
}

private struct CharacterIllustration: View {
    let completion: Double

    private let sleepyImageName = "sleepyBot"
    private let steadyImageName = "steadyBot"
    private let happyImageName = "happyBot"
    private let energizedImageName = "energizedBot"

    private var selectedImage: UIImage? {
        switch completion {
        case ..<0.26:
            return UIImage(named: sleepyImageName)
        case 0.26..<0.75:
            return UIImage(named: steadyImageName)
        case 0.75..<0.9:
            return UIImage(named: happyImageName)
        case 0.9...:
            return UIImage(named: energizedImageName)
        default:
            return nil
        }
    }

    var body: some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        } else {
            CharacterPlaceholder()
        }
    }
}

private struct CharacterPlaceholder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color.white.opacity(0.18))
            .frame(width: 120, height: 140)
            .overlay(
                Text("Character\nImage")
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.82))
            )
    }
}

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var habitCards: [TodayHabitCardViewModel] = []
    @Published private(set) var dailyCompletion: Double = 0

    private var cancellables: Set<AnyCancellable> = []
    private weak var container: AppContainer?

    func connect(container: AppContainer) async {
        guard self.container == nil else { return }
        self.container = container
        AppLogger.today.debug("Connecting TodayViewModel to habit service")

        container.habitService.dailyLogPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] log in
                AppLogger.today.debug("Received habit log update for date: \(log.date)")
                let cards = CoreHabitType.allCases.compactMap { type -> TodayHabitCardViewModel? in
                    guard let metric = log.metrics[type] else { return nil }
                    return TodayHabitCardViewModel(
                        type: type,
                        metric: metric,
                        iconName: Self.icon(for: type)
                    )
                }
                self?.habitCards = cards
                self?.dailyCompletion = TodayProgressCalculator.overallCompletion(from: log)
            }
            .store(in: &cancellables)
    }

    func toggleCompletion(for type: CoreHabitType) {
        guard let container else { return }
        // TODO: integrate with live data sources; placeholder toggles
        AppLogger.today.debug("Toggling metric update for type: \(type.rawValue)")
        container.habitService.update(metric: type, progress: randomProgress(for: type))
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

    var progressRatio: Double { TodayProgressCalculator.displayRatio(for: type, metric: metric) }
    var isComplete: Bool {
        switch type {
        case .screenTime:
            return metric.progress <= metric.target
        default:
            return metric.progress >= metric.target
        }
    }
    var title: String { type.title }
    var tint: Color {
        if type == .screenTime && metric.progress > metric.target {
            return .orange
        }
        return isComplete ? .green : .teal
    }

    var progressText: String {
        switch type {
        case .steps:
            return "\(Int(metric.progress))/\(Int(metric.target)) steps"
        case .sleep:
            let targetHours = metric.target / 60
            let progressHours = metric.progress / 60
            return String(format: "%.1f/%.1f hrs", progressHours, targetHours)
        case .screenTime:
            let progress = Int(metric.progress)
            let target = Int(metric.target)
            if progress <= target {
                return "\(progress)/\(target) min"
            }
            return "\(progress) min (\(progress - target) over)"
        default:
            return "\(Int(metric.progress))/\(Int(metric.target)) min"
        }
    }
}

struct GradientProgressBar: View {
    var value: Double
    var gradientStops: [Gradient.Stop] = []
    var height: CGFloat = 14
    var backgroundOpacity: Double = 0.2

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }

    private var progressGradient: LinearGradient {
        if gradientStops.isEmpty {
            return LinearGradient(
                colors: [Color.accentColor, Color.accentColor.opacity(0.75)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }

        return LinearGradient(
            gradient: Gradient(stops: gradientStops),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var leadingColor: Color {
        gradientStops.first?.color ?? Color.accentColor
    }

    private var borderOpacity: Double {
        min(backgroundOpacity + 0.15, 0.45)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * CGFloat(clampedValue)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(backgroundOpacity))

                if width > 0 {
                    Capsule()
                        .fill(progressGradient)
                        .frame(width: width)
                        .shadow(
                            color: leadingColor.opacity(0.35),
                            radius: 6,
                            x: 0,
                            y: 4
                        )
                }
            }
        }
        .frame(height: height)
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(borderOpacity), lineWidth: 1)
        )
    }
}

private enum TodayProgressCalculator {
    static func overallCompletion(from log: HabitLog) -> Double {
        let totalScore = CoreHabitType.allCases.reduce(0.0) { partial, type in
            guard let metric = log.metrics[type] else { return partial }
            return partial + completionScore(for: type, metric: metric)
        }
        let bucketCount = Double(CoreHabitType.allCases.count)
        guard bucketCount > 0 else { return 0 }
        let average = totalScore / bucketCount
        return max(0, min(average, 1))
    }

    static func displayRatio(for type: CoreHabitType, metric: HabitMetric) -> Double {
        guard metric.target > 0 else { return 0 }
        switch type {
        case .screenTime:
            let usageRatio = metric.progress / metric.target
            if usageRatio <= 1 { return usageRatio }
            return max(0, 1 - (usageRatio - 1))
        default:
            return min(metric.progress / metric.target, 1)
        }
    }

    static func completionScore(for type: CoreHabitType, metric: HabitMetric) -> Double {
        guard metric.target > 0 else { return 0 }
        switch type {
        case .screenTime:
            if metric.progress <= metric.target { return 1 }
            let minutesOver = max(metric.progress - metric.target, 0)
            let halfHourChunks = Int(ceil(minutesOver / 30))
            let penalty = Double(halfHourChunks) * 5
            return max(0, 1 - penalty / 100)
        default:
            return min(metric.progress / metric.target, 1)
        }
    }
}
