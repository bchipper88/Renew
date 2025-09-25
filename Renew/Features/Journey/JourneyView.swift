import SwiftUI
import Combine
import AVFoundation

struct ToolsView: View {
    @State private var selectedFilter: ToolFilter = .all
    private let sessions = ToolSession.examples

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Horizontal filter bar
                HorizontalFilterBar(selectedFilter: $selectedFilter)
                    .padding(.vertical, 16)
                
                // Content cards
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredSessions) { session in
                            NavigationLink(destination: destinationView(for: session)) {
                                ToolSessionCard(session: session)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .background(GradientBackground())
            .navigationTitle("Boosts")
            .scrollContentBackground(.hidden)
        }
    }
    
    private var filteredSessions: [ToolSession] {
        switch selectedFilter {
        case .all:
            return sessions
        case .mind:
            return sessions.filter { $0.category == .mind }
        case .body:
            return sessions.filter { $0.category == .body }
        case .mood:
            return sessions.filter { $0.category == .mood }
        case .vibe:
            return sessions.filter { $0.category == .vibe }
        case .social:
            return sessions.filter { $0.category == .social }
        }
    }
    
    @ViewBuilder
    private func destinationView(for session: ToolSession) -> some View {
        switch session.title {
        case "Sound":
            SoundPlayerView(session: session)
        case "Calm":
            SoundPlayerView(session: session)
        case "Breathe":
            BreathingExerciseView(session: session)
        case "Grounding":
            GroundingExerciseView(session: session)
        case "Pushups":
            PushupsExerciseView(session: session)
        case "Squats":
            SquatsExerciseView(session: session)
        case "Jumping Jacks":
            JumpingJacksExerciseView(session: session)
        default:
            // Placeholder for other sessions
            VStack {
                Text(session.title)
                    .font(.largeTitle)
                Text("Coming Soon")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            .navigationTitle(session.title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

enum ToolFilter: String, CaseIterable, Identifiable {
    case all = "All Type"
    case mind = "Mind"
    case body = "Body"
    case mood = "Mood"
    case vibe = "Vibe"
    case social = "Social"
    
    var id: String { rawValue }
    
    var title: String { rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .all:
            return Color.primary
        case .mind:
            return Color(red: 0.7, green: 0.85, blue: 1.0) // Soft Blue
        case .body:
            return Color(red: 0.6, green: 0.9, blue: 0.7) // Fresh Green
        case .mood:
            return Color(red: 1.0, green: 0.8, blue: 0.6) // Bright Peach
        case .vibe:
            return Color(red: 0.8, green: 0.7, blue: 1.0) // Soft Purple
        case .social:
            return Color(red: 1.0, green: 0.95, blue: 0.6) // Soft Yellow
        }
    }
    
    var textColor: Color {
        switch self {
        case .all:
            return .white
        default:
            return .primary
        }
    }
}

enum ToolCategory: String, CaseIterable {
    case mind
    case body
    case mood
    case vibe
    case social
    
    var title: String {
        switch self {
        case .mind: return "Mind"
        case .body: return "Body"
        case .mood: return "Mood"
        case .vibe: return "Vibe"
        case .social: return "Social"
        }
    }
}

struct ToolSession: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let instructor: String
    let instructorTitle: String
    let category: ToolCategory
    let difficulty: ToolDifficulty
    let imageName: String
    let backgroundColor: Color
    
    static let examples: [ToolSession] = [
        // Mind Category
        ToolSession(
            title: "Breathe",
            subtitle: "Breathe deep, feel renewed.",
            instructor: "Anna Juliane",
            instructorTitle: "Mind Coach",
            category: .mind,
            difficulty: .basic,
            imageName: "breatheWoman",
            backgroundColor: Color(red: 0.7, green: 0.85, blue: 1.0) // Soft Blue
        ),
        ToolSession(
            title: "Calm",
            subtitle: "A 3-minute meditation to quiet your mind.",
            instructor: "Anna Juliane",
            instructorTitle: "Mind Coach",
            category: .mind,
            difficulty: .mid,
            imageName: "calmMan",
            backgroundColor: Color(red: 0.7, green: 0.85, blue: 1.0) // Soft Blue
        ),
        ToolSession(
            title: "Focus",
            subtitle: "Visualize clarity in just 60 seconds.",
            instructor: "Anna Juliane",
            instructorTitle: "Mind Coach",
            category: .mind,
            difficulty: .basic,
            imageName: "focusMan",
            backgroundColor: Color(red: 0.7, green: 0.85, blue: 1.0) // Soft Blue
        ),
        
        // Body Category
        ToolSession(
            title: "Pushups",
            subtitle: "A quick strength burst to recharge energy.",
            instructor: "Rachel Jules",
            instructorTitle: "Fitness Guide",
            category: .body,
            difficulty: .mid,
            imageName: "pushupsMan",
            backgroundColor: Color(red: 0.6, green: 0.9, blue: 0.7) // Fresh Green
        ),
        ToolSession(
            title: "Squats",
            subtitle: "Boost circulation and wake up your body.",
            instructor: "Rachel Jules",
            instructorTitle: "Fitness Guide",
            category: .body,
            difficulty: .basic,
            imageName: "squatsMan",
            backgroundColor: Color(red: 0.6, green: 0.9, blue: 0.7) // Fresh Green
        ),
        ToolSession(
            title: "Jumping Jacks",
            subtitle: "Energize your body instantly.",
            instructor: "Rachel Jules",
            instructorTitle: "Fitness Guide",
            category: .body,
            difficulty: .basic,
            imageName: "jumpingJacksWoman",
            backgroundColor: Color(red: 0.6, green: 0.9, blue: 0.7) // Fresh Green
        ),
        
        // Mood Category
        ToolSession(
            title: "Gratitude",
            subtitle: "Write one thing you're thankful for today.",
            instructor: "Michaela Andy",
            instructorTitle: "Wellness Expert",
            category: .mood,
            difficulty: .basic,
            imageName: "gratitudeJournal",
            backgroundColor: Color(red: 1.0, green: 0.8, blue: 0.6) // Bright Peach
        ),
        ToolSession(
            title: "Confidence",
            subtitle: "Strengthen self-talk with an affirmation.",
            instructor: "Michaela Andy",
            instructorTitle: "Wellness Expert",
            category: .mood,
            difficulty: .basic,
            imageName: "confidenceWoman",
            backgroundColor: Color(red: 1.0, green: 0.8, blue: 0.6) // Bright Peach
        ),
        ToolSession(
            title: "Grounding",
            subtitle: "Use 5-4-3-2-1 senses to find your center.",
            instructor: "Michaela Andy",
            instructorTitle: "Wellness Expert",
            category: .mood,
            difficulty: .mid,
            imageName: "groundingMan",
            backgroundColor: Color(red: 1.0, green: 0.8, blue: 0.6) // Bright Peach
        ),
        
        // Vibe Category
        ToolSession(
            title: "Sound",
            subtitle: "Relax with calming nature or ambient tones.",
            instructor: "Sarah Chen",
            instructorTitle: "Meditation Guide",
            category: .vibe,
            difficulty: .basic,
            imageName: "soundWoman",
            backgroundColor: Color(red: 0.8, green: 0.7, blue: 1.0) // Soft Purple
        ),
        ToolSession(
            title: "Music",
            subtitle: "Shift your mood with a single song.",
            instructor: "Sarah Chen",
            instructorTitle: "Meditation Guide",
            category: .vibe,
            difficulty: .basic,
            imageName: "musicWoman",
            backgroundColor: Color(red: 0.8, green: 0.7, blue: 1.0) // Soft Purple
        ),
        ToolSession(
            title: "Create",
            subtitle: "Express yourself in 60 seconds of doodling or notes.",
            instructor: "Sarah Chen",
            instructorTitle: "Meditation Guide",
            category: .vibe,
            difficulty: .basic,
            imageName: "createMan",
            backgroundColor: Color(red: 0.8, green: 0.7, blue: 1.0) // Soft Purple
        ),
        
        // Social Category
        ToolSession(
            title: "Connect",
            subtitle: "Reach out to a friend or loved one.",
            instructor: "Emma Wilson",
            instructorTitle: "Community Builder",
            category: .social,
            difficulty: .basic,
            imageName: "connectWomen",
            backgroundColor: Color(red: 1.0, green: 0.95, blue: 0.6) // Soft Yellow
        ),
        ToolSession(
            title: "Kindness",
            subtitle: "Do one small act to brighten someone's day.",
            instructor: "Emma Wilson",
            instructorTitle: "Community Builder",
            category: .social,
            difficulty: .basic,
            imageName: "kindnessWoman",
            backgroundColor: Color(red: 1.0, green: 0.95, blue: 0.6) // Soft Yellow
        ),
        ToolSession(
            title: "Purpose",
            subtitle: "Reflect on your why for today.",
            instructor: "Emma Wilson",
            instructorTitle: "Community Builder",
            category: .social,
            difficulty: .mid,
            imageName: "purposeWoman",
            backgroundColor: Color(red: 1.0, green: 0.95, blue: 0.6) // Soft Yellow
        )
    ]
}

enum ToolDifficulty: String, CaseIterable {
    case basic = "Basic"
    case mid = "Mid"
    case advanced = "Advance"
    
    var color: Color {
        switch self {
        case .basic: return .green
        case .mid: return .yellow
        case .advanced: return .pink
        }
    }
}






@MainActor
final class JourneyViewModel: ObservableObject {
    @Published var dailyScores: [DailyJourneyScore] = []
    @Published var selectedMode: JourneyViewMode = .calendar
    private var cancellables: Set<AnyCancellable> = []

    func connect(container: AppContainer) async {
        guard cancellables.isEmpty else { return }
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




// MARK: - Coming Soon View
private struct ComingSoonView: View {
    let session: ToolSession
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Coming Soon")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
