import SwiftUI
import OSLog

struct OnboardingFlowView: View {
    @EnvironmentObject private var container: AppContainer
    @EnvironmentObject private var state: AppState
    @StateObject private var viewModel = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $viewModel.currentStep) {
                ForEach(OnboardingStep.allCases) { step in
                    OnboardingStepView(step: step, viewModel: viewModel)
                        .tag(step)
                        .padding(.horizontal)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            Button(action: { viewModel.handlePrimaryAction(container: container, state: state) }) {
                Text(viewModel.primaryButtonTitle(for: viewModel.currentStep))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(RenewButtonStyle(style: .primary))
            .padding(.horizontal)
            .disabled(viewModel.isProcessing)

            if viewModel.showSecondaryButton {
                Button("Skip for now") {
                    viewModel.skipCurrentStep()
                }
                .buttonStyle(RenewButtonStyle(style: .glass))
                .padding(.horizontal)
            }
        }
        .padding(.vertical, 32)
        .background(GradientBackground())
        .onAppear {
            AppLogger.onboarding.debug("OnboardingFlowView appeared")
        }
        .task {
            await viewModel.prepare(container: container)
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message))
        }
    }
}

final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedGoals: Set<CoreHabitType> = []
    @Published var isProcessing = false
    @Published var alert: FlowAlert?

    var showSecondaryButton: Bool {
        currentStep != .startTrial
    }

    func prepare(container: AppContainer) async {
        AppLogger.onboarding.debug("Preparing onboarding flow")
        selectedGoals = Set(container.habitService.defaultGoals())
    }

    func primaryButtonTitle(for step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "Get Started"
        case .goals: return "Continue"
        case .healthPermissions: return "Connect Health"
        case .notifications: return "Enable Notifications"
        case .startTrial: return "Start 3-Day Trial"
        }
    }

    func handlePrimaryAction(container: AppContainer, state: AppState) {
        Task {
            await advance(container: container, state: state)
        }
    }

    @MainActor
    func advance(container: AppContainer, state: AppState) async {
        isProcessing = true
        defer { isProcessing = false }

        do {
            switch currentStep {
            case .welcome:
                currentStep = .goals
            case .goals:
                AppLogger.onboarding.debug("Goals step completed with: \(self.selectedGoals.map(\.rawValue))")
                try await container.habitService.saveGoals(Array(selectedGoals))
                currentStep = .healthPermissions
            case .healthPermissions:
                AppLogger.onboarding.debug("Health permissions requested")
                try await container.habitService.requestHealthPermissions()
                currentStep = .notifications
            case .notifications:
                AppLogger.onboarding.debug("Notification permissions requested")
                try await container.notificationScheduler.requestAuthorization()
                currentStep = .startTrial
            case .startTrial:
                AppLogger.onboarding.debug("Starting trial")
                try await container.subscriptionService.startTrial()
                state.onboardingCompleted = true
            }
        } catch {
            AppLogger.onboarding.error("Onboarding error: \(error.localizedDescription)")
            alert = FlowAlert(title: "Something went wrong", message: error.localizedDescription)
        }
    }

    func skipCurrentStep() {
        guard let next = currentStep.next else { return }
        currentStep = next
    }
}

enum OnboardingStep: Int, CaseIterable, Identifiable {
    case welcome
    case goals
    case healthPermissions
    case notifications
    case startTrial

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .welcome: return "Welcome to Renew"
        case .goals: return "Choose Your Core Focus"
        case .healthPermissions: return "Connect Health Data"
        case .notifications: return "Stay on Track"
        case .startTrial: return "Unlock Your Trial"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Build science-backed habits that nurture energy, sunlight, movement, and mindful rest."
        case .goals:
            return "Pick up to three habits you want Renew to remind you about first."
        case .healthPermissions:
            return "Sync steps, sleep, and mindfulness from HealthKit for effortless tracking."
        case .notifications:
            return "We will nudge you with gentle reminders throughout the day."
        case .startTrial:
            return "Start your 3-day premium trial to unlock the full Renew experience."
        }
    }

    var illustrationSystemImage: String {
        switch self {
        case .welcome: return "sun.max"
        case .goals: return "target"
        case .healthPermissions: return "heart.text.square"
        case .notifications: return "bell.badge"
        case .startTrial: return "sparkles"
        }
    }

    var next: OnboardingStep? {
        switch self {
        case .welcome: return .goals
        case .goals: return .healthPermissions
        case .healthPermissions: return .notifications
        case .notifications: return .startTrial
        case .startTrial: return nil
        }
    }
}

struct OnboardingStepView: View {
    let step: OnboardingStep
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: step.illustrationSystemImage)
                .font(.system(size: 64))
                .foregroundStyle(.white)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            VStack(spacing: 12) {
                Text(step.title)
                    .font(.title2.weight(.semibold))
                Text(step.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if step == .goals {
                GoalsPicker(selectedGoals: $viewModel.selectedGoals)
            }
        }
        .padding(.vertical, 24)
    }
}

struct GoalsPicker: View {
    @Binding var selectedGoals: Set<CoreHabitType>

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(CoreHabitType.allCases) { habit in
                Toggle(isOn: Binding(
                    get: { selectedGoals.contains(habit) },
                    set: { isSelected in
                        if isSelected {
                            selectedGoals.insert(habit)
                        } else {
                            selectedGoals.remove(habit)
                        }
                    }
                )) {
                    Text(habit.title)
                        .font(.headline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .teal))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct FlowAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
