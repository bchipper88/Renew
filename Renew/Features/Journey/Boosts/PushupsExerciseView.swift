import SwiftUI

struct PushupsExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ToolSession
    
    private let titleTextColor = Color(red: 0.16, green: 0.23, blue: 0.32)
    private let bodyTextColor = Color(red: 0.24, green: 0.3, blue: 0.38)
    private let chipTextColor = Color(red: 0.2, green: 0.26, blue: 0.34)
    
    @State private var selectedDifficulty: PushupsDifficulty = .beginner
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false
    
    enum PushupsDifficulty: CaseIterable {
        case beginner, intermediate
        
        var title: String {
            switch self {
            case .beginner: return "10 Pushups"
            case .intermediate: return "25 Pushups"
            }
        }
        
        var boostPoints: Int {
            switch self {
            case .beginner: return 1
            case .intermediate: return 3
            }
        }
        
        var description: String {
            switch self {
            case .beginner: return "Perfect for getting started"
            case .intermediate: return "Challenge yourself"
            }
        }
    }
    
    private var buttonGradient: LinearGradient {
        let isClaimed = isClaimingBoost || hasClaimedBoost
        let topColor = isClaimed ? 
            Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.8) :
            Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.8)
        let bottomColor = isClaimed ? 
            Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.6) :
            Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.6)
        
        return LinearGradient(
            gradient: Gradient(colors: [topColor, bottomColor]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                introSection
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(glassPanelBackground(cornerRadius: 28))

                difficultyOptionsSection
                    .background(
                        glassPanelBackground(cornerRadius: 28)
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )

                completionSection
                    .padding(.top, 12)

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .background(GradientBackground())
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introSection: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(spacing: 8) {
         
                Text("Movement changes mood — start with just a few pushups.")
                    .font(.title3)
                    .foregroundColor(bodyTextColor.opacity(0.9))
                    .multilineTextAlignment(.center)
            }

          

           
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
    }

    private var difficultyOptionsSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Challenge")
                .font(.headline.weight(.semibold))
                .foregroundColor(titleTextColor)

            ForEach(PushupsDifficulty.allCases, id: \.self) { difficulty in
                difficultyCard(for: difficulty)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
    }

    private var completionSection: some View {
        ZStack {
            if showElectricGlow {
                electricGlow
            }

            claimButton
        }
        .padding(.top, 8)
    }

    private var exerciseBackground: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.2)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
    }

    @ViewBuilder
    private func difficultyCard(for difficulty: PushupsDifficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty

        Button(action: { selectedDifficulty = difficulty }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(difficulty.title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(titleTextColor)

                    Text(difficulty.description)
                        .font(.caption)
                        .foregroundColor(bodyTextColor.opacity(0.85))
                }

                Spacer()

                Text("+\(difficulty.boostPoints) Boost")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(chipTextColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(boostTag)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 18)
            .background(difficultyBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private func difficultyBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: isSelected ?
                                        [
                                            Color(red: 0.65, green: 0.9, blue: 0.75).opacity(0.55),
                                            Color(red: 0.45, green: 0.78, blue: 0.61).opacity(0.45)
                                        ] :
                                        [
                                            Color.white.opacity(0.72),
                                            Color.white.opacity(0.52)
                                        ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(isSelected ? 0.85 : 0.45),
                                Color.white.opacity(isSelected ? 0.35 : 0.18)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.2
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 14, x: 0, y: 6)
    }

    private func glassPanelBackground(cornerRadius: CGFloat = 28) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.32),
                        Color.white.opacity(0.12)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.35), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 28, x: 0, y: 16)
    }

    private var boostTag: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color.white.opacity(0.75))
    }

    private var electricGlow: some View {
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.6),
                        Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.8),
                        Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.4),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 100
                )
            )
            .frame(width: 250, height: 80)
            .blur(radius: 20)
            .scaleEffect(showElectricGlow ? 1.5 : 0.5)
            .opacity(showElectricGlow ? 1.0 : 0.0)
            .animation(.easeInOut(duration: 0.6), value: showElectricGlow)
    }

    private var claimButton: some View {
        Button(action: claimBoost) {
            Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Reps Completed")
                .font(.title2.weight(.semibold))
                .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : titleTextColor)
                .padding(.vertical, 18)
                .padding(.horizontal, 30)
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(buttonGradient)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        )
                )
                .scaleEffect(isClaimingBoost ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isClaimingBoost)
        }
        .disabled(isClaimingBoost)
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    if !isClaimingBoost {
                        claimBoost()
                    }
                }
        )
    }
    
    private func claimBoost() {
        BoostClaimAnimation.performClaimAnimation(
            isClaimingBoost: $isClaimingBoost,
            showElectricGlow: $showElectricGlow,
            hasClaimedBoost: $hasClaimedBoost,
            boostPoints: selectedDifficulty.boostPoints,
            onComplete: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        )
    }
}

private extension View {
    func panelStyle(cornerRadius: CGFloat = 28) -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.white.opacity(0.85))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(Color.white.opacity(0.45), lineWidth: 1.1)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 22, x: 0, y: 12)
            )
    }
}
