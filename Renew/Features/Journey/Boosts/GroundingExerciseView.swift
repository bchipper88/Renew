import SwiftUI

struct GroundingExerciseView: View {
    @Environment(\.dismiss) private var dismiss
    let session: ToolSession
    
    @State private var currentCardIndex = 0
    @State private var checkedItems: [Int: Set<Int>] = [:]
    @State private var showClaimButton = false
    @State private var cardOffsets: [CGFloat] = [0, 20, 40, 60, 80]
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false
    
    private let groundingSteps = [
        GroundingStep(title: "Name 5 things you can see", itemCount: 5),
        GroundingStep(title: "Name 4 things you can touch", itemCount: 4),
        GroundingStep(title: "Name 3 things you can hear", itemCount: 3),
        GroundingStep(title: "Name 2 things you can smell", itemCount: 2),
        GroundingStep(title: "Name 1 thing you can taste", itemCount: 1)
    ]
    
    struct GroundingStep {
        let title: String
        let itemCount: Int
    }
    
    var body: some View {
        ZStack {
            // Use the same GradientBackground as the main Boosts page
            GradientBackground()
            
            VStack {
                Spacer()
                
                // Card stack
                ZStack {
                    // Claim Boost button (behind all cards)
                    if showClaimButton {
                        ZStack {
                            // Electric glow effect
                            if showElectricGlow {
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
                                            endRadius: 120
                                        )
                                    )
                                    .frame(width: 250, height: 80)
                                    .blur(radius: 25)
                                    .scaleEffect(showElectricGlow ? 1.5 : 0.5)
                                    .opacity(showElectricGlow ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.6), value: showElectricGlow)
                            }
                            
                            Button(action: claimBoost) {
                                HStack(spacing: 12) {
                                    Image(systemName: (isClaimingBoost || hasClaimedBoost) ? "bolt.fill" : "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                        .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                                        .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)
                                    
                                    Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Claim Boost +3")
                                        .font(.title2.weight(.semibold))
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    (isClaimingBoost || hasClaimedBoost) ? 
                                                    Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.8) :
                                                    Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.8),
                                                    (isClaimingBoost || hasClaimedBoost) ? 
                                                    Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.6) :
                                                    Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.6)
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
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
                        .scaleEffect(showClaimButton ? 1.0 : 0.8)
                        .opacity(showClaimButton ? 1.0 : 0.0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showClaimButton)
                    }
                    
                    // Current card only
                    if currentCardIndex < groundingSteps.count {
                        GroundingCard(
                            step: groundingSteps[currentCardIndex],
                            cardIndex: currentCardIndex,
                            checkedItems: checkedItems[currentCardIndex] ?? [],
                            onItemChecked: { itemIndex in
                                checkItem(cardIndex: currentCardIndex, itemIndex: itemIndex)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentCardIndex)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func checkItem(cardIndex: Int, itemIndex: Int) {
        if checkedItems[cardIndex] == nil {
            checkedItems[cardIndex] = Set<Int>()
        }
        checkedItems[cardIndex]?.insert(itemIndex)
        
        // Check if all items in current card are checked
        if let checked = checkedItems[cardIndex], checked.count == groundingSteps[cardIndex].itemCount {
            // Move to next card after a brief delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if cardIndex < groundingSteps.count - 1 {
                    currentCardIndex += 1
                } else {
                    // All cards completed, hide the last card and show claim button
                    currentCardIndex = groundingSteps.count // This will hide the card
                    showClaimButton = true
                }
            }
        }
    }
    
    private func claimBoost() {
        BoostClaimAnimation.performClaimAnimation(
            isClaimingBoost: $isClaimingBoost,
            showElectricGlow: $showElectricGlow,
            hasClaimedBoost: $hasClaimedBoost,
            boostPoints: 3,
            onComplete: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        )
    }
}

// MARK: - Grounding Card
private struct GroundingCard: View {
    let step: GroundingExerciseView.GroundingStep
    let cardIndex: Int
    let checkedItems: Set<Int>
    let onItemChecked: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            // Title
            Text(step.title)
                .font(.title.weight(.bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
            
            // Numbered mini cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(0..<step.itemCount, id: \.self) { index in
                    Button(action: {
                        onItemChecked(index)
                    }) {
                        ZStack {
                            // Mini card background
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(checkedItems.contains(index) ? Color.green : Color.clear)
                                .frame(width: 80, height: 80)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(checkedItems.contains(index) ? Color.green : Color.gray, lineWidth: 2)
                                )
                            
                            // Number
                            Text("\(index + 1)")
                                .font(.title.weight(.bold))
                                .foregroundColor(checkedItems.contains(index) ? .white : .primary)
                            
                            // Checkmark overlay
                            if checkedItems.contains(index) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .background(
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 24, height: 24)
                                    )
                                    .offset(x: 25, y: -25)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(checkedItems.contains(index))
                }
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
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
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
        .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
