import SwiftUI

struct PushupsExerciseView: View {
    let session: ToolSession
    
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
            VStack(spacing: 32) {
                headerSection
                descriptionSection
                difficultyOptionsSection
                completionSection
                Spacer(minLength: 50)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(GradientBackground())
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            Text("⚡ Pushups Boost")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(.white)

            Text("A quick strength burst to recharge energy.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var descriptionSection: some View {
        VStack(spacing: 12) {
            Text("Exercise Description")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            Text("Movement changes mood — start with just a few pushups.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 20)
        .background(exerciseBackground)
    }

    private var difficultyOptionsSection: some View {
        VStack(spacing: 16) {
            Text("Choose Your Challenge")
                .font(.headline.weight(.semibold))
                .foregroundColor(.white)

            ForEach(PushupsDifficulty.allCases, id: \.self) { difficulty in
                difficultyCard(for: difficulty)
            }
        }
    }

    private var completionSection: some View {
        ZStack {
            if showElectricGlow {
                electricGlow
            }

            claimButton
        }
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
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)

                    Text(difficulty.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Text("+\(difficulty.boostPoints) Boost")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(boostTag)
            }
            .padding(20)
            .background(difficultyBackground(isSelected: isSelected))
        }
        .buttonStyle(.plain)
    }

    private var boostTag: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.3))
    }

    private func difficultyBackground(isSelected: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(isSelected ?
                  Color(red: 0.6, green: 0.9, blue: 0.7).opacity(0.2) :
                  Color.clear)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ?
                        Color(red: 0.6, green: 0.9, blue: 0.7).opacity(0.5) :
                        Color.white.opacity(0.2),
                        lineWidth: 1.5
                    )
            )
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
            HStack(spacing: 12) {
                Image(systemName: (isClaimingBoost || hasClaimedBoost) ? "bolt.fill" : "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                    .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                    .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)

                Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Reps Completed")
                    .font(.title2.weight(.semibold))
                    .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 40)
            .background(
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(buttonGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25, style: .continuous)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
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
            boostPoints: selectedDifficulty.boostPoints
        )
    }
}
