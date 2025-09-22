import SwiftUI
import Combine

struct JourneyView: View {
    @EnvironmentObject private var container: AppContainer
    @StateObject private var viewModel = JourneyViewModel()
    @State private var displayedMonth = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Progress Overview")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary.opacity(0.9))

                            Picker("View Mode", selection: $viewModel.selectedMode) {
                                ForEach(JourneyViewMode.allCases) { mode in
                                    Text(mode.title)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            switch viewModel.selectedMode {
                            case .calendar:
                                JourneyCalendarView(
                                    scores: viewModel.dailyScores,
                                    displayedMonth: $displayedMonth
                                )
                            case .graph:
                                JourneyGraphView(scores: viewModel.dailyScores)
                            }
                        }
                    }

                    ForEach(viewModel.snapshots) { snapshot in
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(snapshot.dateRangeDescription)
                                    .font(.headline)
                                    .foregroundStyle(.secondary)

                                JourneyRow(title: "Core 4 Completion", value: snapshot.core4CompletionRate.asPercent)
                                JourneyRow(title: "Mood Average", value: snapshot.averageMood.formatted(.number.precision(.fractionLength(1))))
                                JourneyRow(title: "Energy Average", value: snapshot.averageEnergy.formatted(.number.precision(.fractionLength(1))))
                                JourneyRow(title: "Longest Streak", value: "\(snapshot.longestStreak) days")
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(GradientBackground())
            .navigationTitle("Journey")
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
        }
        .task {
            await viewModel.connect(container: container)
        }
    }
}

struct JourneyRow: View {
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
final class JourneyViewModel: ObservableObject {
    @Published var snapshots: [JourneySnapshot] = []
    @Published var dailyScores: [DailyJourneyScore] = []
    @Published var selectedMode: JourneyViewMode = .calendar
    private var cancellables: Set<AnyCancellable> = []

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
        container.journeyService.snapshotsPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$snapshots)

        container.journeyService.dailyScoresPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] scores in
                self?.dailyScores = scores.sorted { $0.date < $1.date }
            }
            .store(in: &cancellables)
    }
}

enum JourneyViewMode: String, CaseIterable, Identifiable {
    case calendar
    case graph

    var id: String { rawValue }

    var title: String {
        switch self {
        case .calendar: return "Calendar"
        case .graph: return "Graph"
        }
    }
}

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

struct JourneyCalendarView: View {
    let scores: [DailyJourneyScore]
    @Binding var displayedMonth: Date

    private let calendar = Calendar.current

    private var monthMetadata: MonthMetadata {
        MonthMetadata(calendar: calendar, month: displayedMonth)
    }

    private var scoresByDay: [Date: DailyJourneyScore] {
        Dictionary(uniqueKeysWithValues: scores.map { ($0.date.startOfDay, $0) })
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols
        let firstWeekdayIndex = calendar.firstWeekday - 1
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex])
    }

    var body: some View {
        VStack(spacing: 16) {
            header

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }

                ForEach(Array(monthMetadata.days.enumerated()), id: \.offset) { _, day in
                    CalendarDayCell(day: day, score: day.flatMap { scoresByDay[$0.startOfDay]?.score })
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: displayedMonth)
    }

    private var header: some View {
        HStack {
            Button(action: { displayedMonth = updateMonth(by: -1) }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }

            Spacer()

            VStack(spacing: 4) {
                Text(displayedMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.title3.weight(.semibold))
                Text("Tap a day to review")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(action: { displayedMonth = updateMonth(by: 1) }) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.08)))
            }
        }
    }

    private func updateMonth(by offset: Int) -> Date {
        guard let shifted = calendar.date(byAdding: .month, value: offset, to: displayedMonth) else { return displayedMonth }
        let components = calendar.dateComponents([.year, .month], from: shifted)
        return calendar.date(from: components) ?? shifted
    }
}

private struct CalendarDayCell: View {
    let day: Date?
    let score: Double?

    private let softRed = Color(red: 0.98, green: 0.56, blue: 0.60)
    private let softYellow = Color(red: 0.99, green: 0.88, blue: 0.64)
    private let softGreen = Color(red: 0.64, green: 0.88, blue: 0.72)

    var body: some View {
        VStack(spacing: 6) {
            if let day {
                Text(day.formatted(.dateTime.day()))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)

                Circle()
                    .fill(color(for: score))
                    .frame(width: 12, height: 12)
                    .opacity(score == nil ? 0.2 : 1)
            } else {
                Text("")
                    .frame(height: 24)
                Circle()
                    .fill(Color.clear)
                    .frame(width: 12, height: 12)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(day == nil ? 0 : 0.05))
        )
    }

    private func color(for score: Double?) -> Color {
        guard let score else { return Color.white.opacity(0.25) }
        if score < 50 { return softRed }
        if score <= 75 { return softYellow }
        return softGreen
    }
}

struct JourneyGraphView: View {
    let scores: [DailyJourneyScore]

    private let gradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.54, green: 0.82, blue: 0.99),
            Color(red: 0.99, green: 0.88, blue: 0.64),
            Color(red: 0.98, green: 0.56, blue: 0.60)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    private let fillGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.62, green: 0.85, blue: 1.0).opacity(0.35),
            Color(red: 1.0, green: 0.93, blue: 0.75).opacity(0.4),
            Color(red: 1.0, green: 0.72, blue: 0.73).opacity(0.45)
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    private var sortedScores: [DailyJourneyScore] {
        scores.sorted { $0.date < $1.date }
    }

    private var displayedScores: [DailyJourneyScore] {
        let tail = sortedScores.suffix(7)
        return Array(tail)
    }

    private var axisDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }

    private var axisDates: [Date] {
        displayedScores.map(\.date)
    }

    private let yAxisValues: [Int] = [100, 75, 50, 25, 0]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Score")
                .font(.headline)
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                ZStack {
                    GridBackground()

                    if let pathData = GraphPathGenerator(points: displayedScores).path(in: geometry.size) {
                        pathData.fill
                            .fill(fillGradient)

                        pathData.line
                            .stroke(gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        ForEach(Array(pathData.markers.enumerated()), id: \.offset) { _, marker in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                                )
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                .position(marker)
                        }
                    } else {
                        Text("Not enough data")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .overlay(alignment: .trailing) {
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(yAxisValues, id: \.self) { value in
                            Text("\(value)")
                                .font(.caption2.weight(value == 0 || value == 100 ? .semibold : .regular))
                                .foregroundStyle(.secondary)
                            if value != yAxisValues.last {
                                Spacer()
                            }
                        }
                    }
                    .frame(height: geometry.size.height, alignment: .top)
                    .padding(.trailing, 4)
                }
            }
            .frame(height: 220)

            if !axisDates.isEmpty {
                HStack(alignment: .top) {
                    ForEach(Array(axisDates.enumerated()), id: \.offset) { _, date in
                        VStack(spacing: 2) {
                            Text(axisDateFormatter.string(from: date))
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(weekdayFormatter.string(from: date).lowercased())
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

private struct GridBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width

            Path { path in
                for index in 0..<5 {
                    let y = height * CGFloat(index) / 4
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.12), lineWidth: 1)
        }
    }
}

private struct GraphPath {
    let line: Path
    let fill: Path
    let markers: [CGPoint]
}

private struct GraphPathGenerator {
    let points: [DailyJourneyScore]

    func path(in size: CGSize) -> GraphPath? {
        guard points.count > 1 else { return nil }

        let sortedPoints = points.sorted { $0.date < $1.date }
        let minScore: Double = 0
        let maxScore: Double = 100
        let range = maxScore - minScore

        let width = size.width
        let height = size.height
        let stepX = width / CGFloat(sortedPoints.count - 1)

        var linePath = Path()
        var fillPath = Path()
        var markerPoints: [CGPoint] = []

        for (index, point) in sortedPoints.enumerated() {
            let x = stepX * CGFloat(index)
            let clampedScore = min(max(point.score, minScore), maxScore)
            let normalized = (clampedScore - minScore) / range
            let y = height * (1 - CGFloat(normalized))
            let cgPoint = CGPoint(x: x, y: y)

            if index == 0 {
                linePath.move(to: cgPoint)
                fillPath.move(to: CGPoint(x: 0, y: height))
                fillPath.addLine(to: cgPoint)
            } else {
                linePath.addLine(to: cgPoint)
                fillPath.addLine(to: cgPoint)
            }

            markerPoints.append(cgPoint)
        }

        fillPath.addLine(to: CGPoint(x: width, y: height))
        fillPath.closeSubpath()

        return GraphPath(line: linePath, fill: fillPath, markers: markerPoints)
    }
}

private struct MonthMetadata {
    let calendar: Calendar
    let month: Date

    var days: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let firstDay = monthInterval.start
        let daysRange = calendar.range(of: .day, in: .month, for: firstDay) ?? 1..<32

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let leadingPadding = (firstWeekday - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leadingPadding)

        for day in daysRange {
            if let date = calendar.date(byAdding: DateComponents(day: day - 1), to: firstDay) {
                days.append(date)
            }
        }

        while days.count % 7 != 0 {
            days.append(nil)
        }

        return days
    }
}

private extension Date {
    var startOfDay: Date { Calendar.current.startOfDay(for: self) }
}

private extension Double {
    var asPercent: String {
        (self * 100).formatted(.number.precision(.fractionLength(0...1))) + "%"
    }
}
