import SwiftUI

struct GuidedBoostSection: Identifiable {
    let id = UUID()
    let title: String
    let detail: String?
    let items: [String]
}

struct GuidedBoostView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ToolSession
    let headline: String?
    let sections: [GuidedBoostSection]
    let primaryButtonLabel: String
    let actionIcon: String
    let footnote: String?
    
    private let titleTextColor = Color(red: 0.16, green: 0.23, blue: 0.32)
    private let bodyTextColor = Color(red: 0.24, green: 0.3, blue: 0.38)
    
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false
    
    private var accentColor: Color { session.backgroundColor }
    private var rewardPoints: Int {
        switch session.difficulty {
        case .basic: return 1
        case .mid: return 2
        case .advanced: return 3
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let headline {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(session.title)
                            .font(.title.weight(.bold))
                            .foregroundColor(titleTextColor)
                        Text(headline)
                            .font(.body)
                            .foregroundColor(bodyTextColor)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 18)
                    .background(glassPanelBackground())
                }
                
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(section.title)
                            .font(.headline.weight(.semibold))
                            .foregroundColor(titleTextColor)
                        
                        if let detail = section.detail {
                            Text(detail)
                                .font(.subheadline)
                                .foregroundColor(bodyTextColor)
                        }
                        
                        if !section.items.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(section.items, id: \.self) { item in
                                    bulletRow(text: item)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(glassPanelBackground())
                }
                
                if let footnote {
                    Text(footnote)
                        .font(.footnote)
                        .foregroundColor(bodyTextColor.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                claimButton
                    .padding(.top, 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
        }
        .background(GradientBackground())
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var claimButton: some View {
        ZStack {
            if showElectricGlow {
                electricGlow
            }
            
            Button(action: claimBoost) {
                HStack(spacing: 12) {
                    Image(systemName: actionIcon)
                        .font(.title2)
                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : titleTextColor)
                        .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                        .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)
                    
                    Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : primaryButtonLabel)
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
    
    private func bulletRow(text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(accentColor.opacity(0.7))
                .frame(width: 10, height: 10)
                .padding(.top, 4)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(bodyTextColor)
                .multilineTextAlignment(.leading)
        }
    }
    
    private func claimBoost() {
        guard !isClaimingBoost, !hasClaimedBoost else { return }
        BoostClaimAnimation.performClaimAnimation(
            isClaimingBoost: $isClaimingBoost,
            showElectricGlow: $showElectricGlow,
            hasClaimedBoost: $hasClaimedBoost,
            boostPoints: rewardPoints,
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
                        Color.white.opacity(0.78),
                        Color.white.opacity(0.58)
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
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 12)
    }
}
