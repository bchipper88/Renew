import SwiftUI

struct BreathingExerciseView: View {
    let session: ToolSession
    
    @State private var selectedDifficulty: BreathingDifficulty = .beginner
    @State private var isExercising = false
    @State private var currentPhase: BreathingPhase = .inhale
    @State private var timeRemaining = 0
    @State private var totalCycles = 0
    @State private var completedCycles = 0
    @State private var timer: Timer?
    @State private var canClaimBoost = false
    @State private var currentCycleProgress: Double = 0.0
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false
    
    enum BreathingDifficulty: CaseIterable {
        case beginner, advanced
        
        var title: String {
            switch self {
            case .beginner: return "2-8-4 - Claim Boost +1"
            case .advanced: return "4-16-8 - Claim Boost +3"
            }
        }
        
        var inhaleTime: Int {
            switch self {
            case .beginner: return 2
            case .advanced: return 4
            }
        }
        
        var holdTime: Int {
            switch self {
            case .beginner: return 8
            case .advanced: return 16
            }
        }
        
        var exhaleTime: Int {
            switch self {
            case .beginner: return 4
            case .advanced: return 8
            }
        }
        
        var boostPoints: Int {
            switch self {
            case .beginner: return 1
            case .advanced: return 3
            }
        }
    }
    
    enum BreathingPhase {
        case inhale, hold, exhale, rest
        
        var instruction: String {
            switch self {
            case .inhale: return "Breathe In"
            case .hold: return "Hold"
            case .exhale: return "Breathe Out"
            case .rest: return "Rest"
            }
        }
        
        var color: Color {
            switch self {
            case .inhale: return .blue
            case .hold: return .green
            case .exhale: return .orange
            case .rest: return .purple
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Use the same GradientBackground as the main Boosts page
            GradientBackground()
            
            VStack(spacing: 32) {
                if !isExercising {
                    // Difficulty selection
                    VStack(spacing: 24) {
                        Text("Choose Your Breathing Exercise")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        VStack(spacing: 16) {
                            ForEach(BreathingDifficulty.allCases, id: \.self) { difficulty in
                                Button(action: {
                                    selectedDifficulty = difficulty
                                    startExercise()
                                }) {
                                    VStack(spacing: 8) {
                                        Text(difficulty.title)
                                            .font(.headline.weight(.medium))
                                            .foregroundColor(.white)
                                        
                                        HStack(spacing: 4) {
                                            Text("Inhale")
                                                .font(.caption)
                                            Text("\(difficulty.inhaleTime)s")
                                                .font(.caption.weight(.semibold))
                                            
                                            Text("•")
                                                .font(.caption)
                                            
                                            Text("Hold")
                                                .font(.caption)
                                            Text("\(difficulty.holdTime)s")
                                                .font(.caption.weight(.semibold))
                                            
                                            Text("•")
                                                .font(.caption)
                                            
                                            Text("Exhale")
                                                .font(.caption)
                                            Text("\(difficulty.exhaleTime)s")
                                                .font(.caption.weight(.semibold))
                                        }
                                        .foregroundColor(.white.opacity(0.8))
                                    }
                                    .padding(.vertical, 20)
                                    .padding(.horizontal, 24)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [
                                                        session.backgroundColor.opacity(0.8),
                                                        session.backgroundColor.opacity(0.6)
                                                    ]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                } else {
                    // Exercise in progress
                    VStack(spacing: 32) {
                        Spacer()
                        
                        // Breathing circle
                        ZStack {
                            // Outer ring
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                .frame(width: 280, height: 280)
                            
                            // Animated circle
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            currentPhase.color.opacity(0.6),
                                            currentPhase.color.opacity(0.2),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 20,
                                        endRadius: 140
                                    )
                                )
                                .frame(width: animatedCircleSize, height: animatedCircleSize)
                                .animation(.easeInOut(duration: Double(timeRemaining)), value: animatedCircleSize)
                            
                            // Center content
                            VStack(spacing: 8) {
                                Text(currentPhase.instruction)
                                    .font(.title.weight(.bold))
                                    .foregroundColor(.white)
                                
                                Text("\(timeRemaining)")
                                    .font(.largeTitle.weight(.bold))
                                    .foregroundColor(.white)
                                    .monospacedDigit()
                                
                                Text("seconds")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        
                        // Progress indicator
                        VStack(spacing: 12) {
                            HStack {
                                Text("Cycle \(completedCycles + 1) of \(totalCycles)")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Spacer()
                                
                                Text("\(Int((Double(completedCycles) + currentCycleProgress) / Double(totalCycles) * 100))%")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            
                            ProgressView(value: Double(completedCycles) + currentCycleProgress, total: Double(totalCycles))
                                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                                .scaleEffect(x: 1, y: 2, anchor: .center)
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer()
                    }
                }
                
                // Claim boost button (only shown when exercise is complete)
                if canClaimBoost {
                    VStack(spacing: 16) {
                        Text("Exercise Complete!")
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.white)
                        
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
                                HStack(spacing: 8) {
                                    Image(systemName: (isClaimingBoost || hasClaimedBoost) ? "bolt.fill" : "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                        .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                                        .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)
                                    
                                    Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Claim Boost +\(selectedDifficulty.boostPoints)")
                                        .font(.headline.weight(.semibold))
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                }
                                .padding(.vertical, 16)
                                .padding(.horizontal, 32)
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
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private var animatedCircleSize: CGFloat {
        switch currentPhase {
        case .inhale:
            return 280
        case .hold:
            return 280
        case .exhale:
            return 100
        case .rest:
            return 100
        }
    }
    
    private func startExercise() {
        isExercising = true
        canClaimBoost = false
        completedCycles = 0
        totalCycles = 4 // 4 cycles for a complete exercise
        
        startBreathingCycle()
    }
    
    private func startBreathingCycle() {
        currentPhase = .inhale
        timeRemaining = selectedDifficulty.inhaleTime
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeRemaining -= 1
            updateProgress()
            
            if timeRemaining <= 0 {
                nextPhase()
            }
        }
    }
    
    private func updateProgress() {
        let totalPhaseTime = selectedDifficulty.inhaleTime + selectedDifficulty.holdTime + selectedDifficulty.exhaleTime + 2 // +2 for rest
        let currentPhaseTime = getCurrentPhaseTime()
        let elapsedInPhase = currentPhaseTime - timeRemaining
        let totalElapsed = (completedCycles * totalPhaseTime) + elapsedInPhase
        let totalTime = totalCycles * totalPhaseTime
        
        currentCycleProgress = Double(totalElapsed) / Double(totalTime)
    }
    
    private func getCurrentPhaseTime() -> Int {
        switch currentPhase {
        case .inhale: return selectedDifficulty.inhaleTime
        case .hold: return selectedDifficulty.holdTime
        case .exhale: return selectedDifficulty.exhaleTime
        case .rest: return 2
        }
    }
    
    private func nextPhase() {
        switch currentPhase {
        case .inhale:
            currentPhase = .hold
            timeRemaining = selectedDifficulty.holdTime
        case .hold:
            currentPhase = .exhale
            timeRemaining = selectedDifficulty.exhaleTime
        case .exhale:
            currentPhase = .rest
            timeRemaining = 2 // 2 second rest
        case .rest:
            completedCycles += 1
            if completedCycles >= totalCycles {
                completeExercise()
            } else {
                startBreathingCycle()
            }
        }
    }
    
    private func completeExercise() {
        timer?.invalidate()
        timer = nil
        isExercising = false
        canClaimBoost = true
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
