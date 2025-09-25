import SwiftUI

struct BoostClaimAnimation {
    static func performClaimAnimation(
        isClaimingBoost: Binding<Bool>,
        showElectricGlow: Binding<Bool>,
        hasClaimedBoost: Binding<Bool>,
        boostPoints: Int,
        onComplete: (() -> Void)? = nil
    ) {
        // Start animation
        isClaimingBoost.wrappedValue = true
        showElectricGlow.wrappedValue = true
        
        // Multiple haptic feedback for more vibration
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        // Additional vibration sequence
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            impactFeedback.impactOccurred()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            impactFeedback.impactOccurred()
        }
        
        // Stop glow after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            showElectricGlow.wrappedValue = false
        }
        
        // Set permanent claimed state with additional vibration
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isClaimingBoost.wrappedValue = false
            hasClaimedBoost.wrappedValue = true
            
            // Additional vibration for transition to permanent state
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
            
            print("🎯 Boost claimed! +\(boostPoints) points")
            onComplete?()
        }
        
        // TODO: Implement boost claiming logic
    }
}
