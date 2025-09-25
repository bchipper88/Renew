import SwiftUI

struct SquatsExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ToolSession
    
    private let titleTextColor = Color(red: 0.16, green: 0.23, blue: 0.32)
    private let bodyTextColor = Color(red: 0.24, green: 0.3, blue: 0.38)
    private let chipTextColor = Color(red: 0.2, green: 0.26, blue: 0.34)
    
    @State private var selectedDifficulty: SquatsDifficulty = .starter
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false
    
    enum SquatsDifficulty: CaseIterable {
        case starter, energizer
        
        var title: String {
            switch self {
            case .starter: return "10 Squats"
            case .energizer: return "25 Squats"
            }
        }
        
        var description: String {
            switch self {
            case .starter: return "Perfect for a quick activation"
            case .energizer: return "Go deeper for a bigger boost"
            }
        }
        
        var boostPoints: Int {
            switch self {
            case .starter: return 1
            case .energizer: return 3
            }
        }
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
                                        Color.white.opacity(0.22),
                                        Color.white.opacity(0.08)
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
        VStack(alignment: .center, spacing: 14) {
            Text("⚡ Squats Boost")
                .font(.largeTitle.weight(.bold))
                .foregroundColor(titleTextColor)
                .multilineTextAlignment(.center)
            
            Text("Wake up your legs, core, and energy in under two minutes.")
                .font(.title3)
                .foregroundColor(bodyTextColor.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
        }
        .padding(.vertical, 18)
    }
    
    private var difficultyOptionsSection: some View {
        VStack(spacing: 20) {
            Text("Choose Your Squat Set")
                .font(.headline.weight(.semibold))
                .foregroundColor(titleTextColor)
            
            ForEach(SquatsDifficulty.allCases, id: \.self) { difficulty in
                Button(action: { selectedDifficulty = difficulty }) {
                    difficultyCard(for: difficulty)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 12)
    }
    
    private var completionSection: some View {
        ZStack {
            if showElectricGlow {
                electricGlow
            }
            
            Button(action: claimBoost) {
                HStack(spacing: 12) {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : titleTextColor)
                        .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                        .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)
                    
                    Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Reps Completed")
                        .font(.title2.weight(.semibold))
                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : titleTextColor)
                }
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
            }
            .disabled(isClaimingBoost || hasClaimedBoost)
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    private func difficultyCard(for difficulty: SquatsDifficulty) -> some View {
        let isSelected = selectedDifficulty == difficulty
        
        return HStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text(difficulty.title)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(titleTextColor)
                
                Text(difficulty.description)
                    .font(.caption)
                    .foregroundColor(bodyTextColor.opacity(0.8))
                
                VStack(alignment: .leading, spacing: 6) {
                    bulletRow("Feet shoulder-width, toes slightly out.")
                    bulletRow("Lower hips back as if sitting in a chair.")
                    bulletRow("Drive through heels to rise tall and squeeze glutes.")
                }
            }
            
            Spacer(minLength: 16)
            
            Text("+\(difficulty.boostPoints) Boost")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(chipTextColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.white.opacity(0.75))
                )
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(difficultyBackground(isSelected: isSelected))
    }
    
    private func bulletRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(session.backgroundColor.opacity(0.6))
                .frame(width: 6, height: 6)
                .padding(.top, 6)
            Text(text)
                .font(.caption)
                .foregroundColor(bodyTextColor)
        }
    }
    
    private func claimBoost() {
        guard !isClaimingBoost, !hasClaimedBoost else { return }
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
    
    private var electricGlow: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.95, blue: 0.6),
                        Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.75),
                        Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.35),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: 120
                )
            )
            .frame(width: 260, height: 84)
            .blur(radius: 18)
            .animation(.easeInOut(duration: 0.6), value: showElectricGlow)
    }
    
    private func glassPanelBackground(cornerRadius: CGFloat = 28) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.82),
                        Color.white.opacity(0.6)
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
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}
