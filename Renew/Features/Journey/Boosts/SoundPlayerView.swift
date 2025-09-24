import SwiftUI
import AVFoundation

struct SoundPlayerView: View {
    @State private var isPlaying = false
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var playbackTimer: Timer?
    @State private var isClaimingBoost = false
    @State private var showElectricGlow = false
    @State private var hasClaimedBoost = false

    let session: ToolSession
    
    private var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    private var isAudioComplete: Bool {
        guard duration > 0 else { return false }
        return currentTime >= duration - 1.0 // Allow 1 second tolerance
    }

    var body: some View {
        ZStack {
            FluidSoundBackground(isPlaying: isPlaying)
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                VStack(spacing: 16) {
                    FluidOrbView(isPlaying: isPlaying)
                        .frame(width: 280, height: 280)
                        .scaleEffect(isPlaying ? 1.06 : 1.0)
                        .shadow(color: SoundPalette.accent.opacity(0.35), radius: 40, x: 0, y: 24)
                        .animation(.easeInOut(duration: 1.2), value: isPlaying)
                        .onTapGesture {
                            togglePlayback()
                        }

                    Text(isPlaying ? "Tap the orb to pause" : "Tap the orb to play")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                playbackControls
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
            .padding(.top, 32)
        }
        .navigationTitle(session.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .onAppear(perform: setupAudio)
        .onDisappear(perform: stopAudio)
    }

    private var playbackControls: some View {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    // Progress bar (non-interactive)
                    GeometryReader { geometry in
                        let barWidth = geometry.size.width * 0.67 // 2/3 of screen width
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: barWidth, height: 8)
                            
                            // Progress fill
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: SoundPalette.gradient),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: barWidth * progress, height: 8)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: 4)
                    .opacity(duration > 0 ? 1 : 0.4)

                    GeometryReader { geometry in
                        let barWidth = geometry.size.width * 0.67 // Same as progress bar
                        HStack {
                            Text(timeString(from: currentTime))
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.white.opacity(0.7))

                            Spacer()

                            Text(timeString(from: duration))
                                .font(.caption.monospacedDigit())
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .frame(width: barWidth)
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .frame(height: 20)
                }

                VStack(spacing: 16) {
                    // Play/pause button
                    Button(action: togglePlayback) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: SoundPalette.gradient),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                                .shadow(color: SoundPalette.accent.opacity(0.45), radius: 24, x: 0, y: 12)

                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    
                        // Claim Boost button
                        ZStack {
                            // Electric glow effect
                            if showElectricGlow {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
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
                                    .frame(width: 200, height: 60)
                                    .blur(radius: 20)
                                    .scaleEffect(showElectricGlow ? 1.5 : 0.5)
                                    .opacity(showElectricGlow ? 1.0 : 0.0)
                                    .animation(.easeInOut(duration: 0.6), value: showElectricGlow)
                            }
                            
                            Button(action: claimBoost) {
                                HStack(spacing: 8) {
                                    Image(systemName: (isClaimingBoost || hasClaimedBoost) ? "bolt.fill" : "plus.circle.fill")
                                        .font(.caption)
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                        .rotationEffect(.degrees(isClaimingBoost ? 360 : 0))
                                        .animation(.easeInOut(duration: 0.5), value: isClaimingBoost)
                                    
                                    Text((isClaimingBoost || hasClaimedBoost) ? "POWERED UP!" : "Claim Boost +3")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor((isClaimingBoost || hasClaimedBoost) ? Color(red: 0.2, green: 0.2, blue: 0.2) : .white)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .fill(
                                            isAudioComplete ?
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    (isClaimingBoost || hasClaimedBoost) ? 
                                                    Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.8) :
                                                    Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.8),
                                                    (isClaimingBoost || hasClaimedBoost) ? 
                                                    Color(red: 1.0, green: 0.95, blue: 0.6).opacity(0.6) :
                                                    Color(red: 0.7, green: 0.85, blue: 1.0).opacity(0.6)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ) :
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.gray.opacity(0.3)]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .strokeBorder(
                                            isAudioComplete ?
                                            Color.white.opacity(0.2) :
                                            Color.gray.opacity(0.2),
                                            lineWidth: 1
                                        )
                                )
                                .scaleEffect(isClaimingBoost ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isClaimingBoost)
                            }
                            .disabled(!isAudioComplete || isClaimingBoost)
                            .opacity(isAudioComplete ? 1.0 : 0.6)
                            .buttonStyle(PlainButtonStyle())
                            .contentShape(Rectangle())
                            .simultaneousGesture(
                                TapGesture()
                                    .onEnded { _ in
                                        if isAudioComplete && !isClaimingBoost {
                                            claimBoost()
                                        }
                                    }
                            )
                        }
                }
            }
        .padding(24)
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        guard timeInterval.isFinite, !timeInterval.isNaN else { return "00:00" }
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func setupAudio() {
        guard audioPlayer == nil else { return }

        // Try different possible file locations and formats
        let possibleFiles = [
            ("sound", "m4r"),
            ("sound", "m4a"), 
            ("sound", "mp3"),
            ("sound_meditation", "m4a"),
            ("sound_meditation", "mp3")
        ]

        var audioURL: URL?
        var foundFile: (String, String)?
        
        for (name, ext) in possibleFiles {
            if let url = Bundle.main.url(forResource: name, withExtension: ext) {
                audioURL = url
                foundFile = (name, ext)
                print("✅ Found audio file: \(name).\(ext)")
                break
            } else {
                print("❌ Not found: \(name).\(ext)")
            }
        }

        // If no file found in bundle, try direct path (for development)
        if audioURL == nil {
            let directPath = "/Users/johnhonochick/My Apps/Renew/Renew/Resources/Audio/sound.m4r"
            if FileManager.default.fileExists(atPath: directPath) {
                audioURL = URL(fileURLWithPath: directPath)
                foundFile = ("sound", "m4r")
                print("✅ Found audio file via direct path: \(directPath)")
            }
        }

        guard let url = audioURL, let file = foundFile else {
            print("❌ No audio file found anywhere. Tried: \(possibleFiles)")
            print("📁 Bundle path: \(Bundle.main.bundlePath)")
            print("📁 Bundle resources: \(Bundle.main.resourcePath ?? "nil")")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try AVAudioSession.sharedInstance().setActive(true)

            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = 0 // Don't loop - play once and stop
            player.prepareToPlay()

            audioPlayer = player
            duration = player.duration
            currentTime = 0
            
            print("🎵 Audio loaded successfully: \(file.0).\(file.1)")
            print("⏱️ Duration: \(duration) seconds")
        } catch {
            print("❌ Error loading audio: \(error)")
        }
    }

    private func togglePlayback() {
        if audioPlayer == nil {
            setupAudio()
        }
        guard let player = audioPlayer else { return }

        isPlaying.toggle()

        if isPlaying {
            player.currentTime = currentTime
            player.play()
            startPlaybackTimer()
        } else {
            player.pause()
            stopPlaybackTimer()
        }
    }

    private func stopAudio() {
        isPlaying = false
        playbackTimer?.invalidate()
        playbackTimer = nil
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        currentTime = 0
    }

    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentTime = audioPlayer?.currentTime ?? 0
            
            // Check if audio has finished
            if let player = audioPlayer, !player.isPlaying && isPlaying {
                // Audio finished playing
                isPlaying = false
                stopPlaybackTimer()
            }
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func claimBoost() {
        BoostClaimAnimation.performClaimAnimation(
            isClaimingBoost: $isClaimingBoost,
            showElectricGlow: $showElectricGlow,
            hasClaimedBoost: $hasClaimedBoost,
            boostPoints: 3
        )
    }
}

// MARK: - Sound Palette
private enum SoundPalette {
    static let aqua = Color(red: 0.36, green: 0.89, blue: 1.0)
    static let green = Color(red: 0.78, green: 0.98, blue: 0.67)
    static let yellow = Color(red: 1.0, green: 0.94, blue: 0.52)
    static let gradient: [Color] = [aqua, green, yellow]
    static let accent = aqua
}

// MARK: - Fluid Background
private struct FluidSoundBackground: View {
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let activity = isPlaying ? 1.0 : 0.35
            let baseSpeed = isPlaying ? 0.32 : 0.12

            let offset1 = CGSize(
                width: cos(time * baseSpeed) * 120 * activity,
                height: sin(time * baseSpeed * 1.2) * 90 * activity
            )

            let offset2 = CGSize(
                width: cos(time * baseSpeed * 0.8 + .pi / 3) * 140 * activity,
                height: sin(time * baseSpeed * 0.9 + .pi / 4) * 110 * activity
            )

            let offset3 = CGSize(
                width: cos(time * baseSpeed * 1.3 + .pi / 2) * 100 * activity,
                height: sin(time * baseSpeed * 1.1 + .pi / 6) * 120 * activity
            )

            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        SoundPalette.aqua.opacity(0.55),
                        Color(red: 0.04, green: 0.07, blue: 0.18),
                        SoundPalette.yellow.opacity(0.45)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                RadialGradient(
                    gradient: Gradient(colors: [SoundPalette.aqua.opacity(0.3), Color.clear]),
                    center: .topLeading,
                    startRadius: 60,
                    endRadius: 360
                )

                RadialGradient(
                    gradient: Gradient(colors: [SoundPalette.yellow.opacity(0.25), Color.clear]),
                    center: .bottomTrailing,
                    startRadius: 60,
                    endRadius: 340
                )

                ZStack {
                    Circle()
                        .fill(SoundPalette.aqua.opacity(0.45))
                        .frame(width: 560, height: 560)
                        .blur(radius: 160)
                        .offset(offset1)
                        .blendMode(.screen)

                    Circle()
                        .fill(SoundPalette.green.opacity(0.5))
                        .frame(width: 520, height: 520)
                        .blur(radius: 150)
                        .offset(offset2)
                        .blendMode(.screen)

                    Circle()
                        .fill(SoundPalette.yellow.opacity(0.45))
                        .frame(width: 540, height: 540)
                        .blur(radius: 140)
                        .offset(offset3)
                        .blendMode(.screen)
                }
                .compositingGroup()

                Circle()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    .scaleEffect(1.3)
                    .blur(radius: 12)
            }
        }
    }
}

// MARK: - Fluid Orb
private struct FluidOrbView: View {
    let isPlaying: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let time = timeline.date.timeIntervalSinceReferenceDate
            let activity = isPlaying ? 1.0 : 0.2
            let speed = isPlaying ? 1.15 : 0.35
            let swirl = time * speed
            
            // Slow breathing pulse (very slow)
            let breathPulse = sin(time * 0.3) * 0.15 + 1.0
            let slowPulse = sin(time * 0.2) * 0.1 + 1.0
            let deepPulse = sin(time * 0.15) * 0.08 + 1.0

            let wave1 = sin(swirl * 1.1) * activity
            let wave2 = sin(swirl * 0.9 + .pi / 2) * activity
            let wave3 = sin(swirl * 1.4 + .pi / 3) * activity

            ZStack {
                // Outer breathing glow
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                SoundPalette.aqua.opacity(0.25),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 80,
                            endRadius: 280
                        )
                    )
                    .blur(radius: 60)
                    .scaleEffect(breathPulse * 1.2)
                    .opacity(0.6)
                    .blendMode(.screen)

                // Main outer glow with slow pulse
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                SoundPalette.aqua.opacity(0.35),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 60,
                            endRadius: 200
                        )
                    )
                    .blur(radius: 45)
                    .scaleEffect((1.1 + CGFloat(wave1) * 0.08) * slowPulse)
                    .opacity(0.9)
                    .blendMode(.screen)

                // Flowing energy circles with breathing
                ForEach(0..<3, id: \.self) { index in
                    let color = SoundPalette.gradient[index]
                    let pulseMultiplier = 1.0 + sin(time * (0.25 + Double(index) * 0.1)) * 0.12
                    Circle()
                        .fill(color.opacity(0.55))
                        .frame(width: 220, height: 220)
                        .blur(radius: 70)
                        .scaleEffect(pulseMultiplier)
                        .offset(
                            x: CGFloat(cos(swirl * (1.2 + Double(index) * 0.35) + Double(index)) * 48 * activity),
                            y: CGFloat(sin(swirl * (0.9 + Double(index) * 0.4) + Double(index) * 1.2) * 48 * activity)
                        )
                        .blendMode(.screen)
                }

                // Main orb with deep breathing
                Circle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: SoundPalette.gradient + [SoundPalette.gradient.first!]),
                            center: .center,
                            startAngle: .degrees(swirl * 40),
                            endAngle: .degrees(swirl * 40 + 360)
                        )
                    )
                    .scaleEffect(deepPulse)
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.22), lineWidth: 2)
                            .blur(radius: 1)
                            .opacity(0.8)
                    )
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.25), lineWidth: 1.5)
                            .scaleEffect((1.08 + CGFloat(wave2) * 0.04) * slowPulse)
                            .opacity(0.4)
                    )

                // Inner glow with breathing
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.05)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 18)
                    .scaleEffect(breathPulse)
                    .offset(x: CGFloat(wave2 * 18), y: CGFloat(wave3 * 18))
                    .opacity(0.9)

                // Rotating highlight with slow pulse
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.0),
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.0)
                            ]),
                            center: .center,
                            startAngle: .degrees(swirl * 60),
                            endAngle: .degrees(swirl * 60 + 180)
                        ),
                        lineWidth: 6
                    )
                    .scaleEffect((1.16 + CGFloat(wave1) * 0.05) * slowPulse)
                    .opacity(0.5)

                // Energy rays with breathing
                ForEach(0..<4, id: \.self) { index in
                    let rayPulse = 1.0 + sin(time * (0.2 + Double(index) * 0.05)) * 0.15
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 8, height: 140)
                        .blur(radius: 6)
                        .scaleEffect(rayPulse)
                        .rotationEffect(.degrees(Double(index) * 45 + wave3 * 12))
                        .opacity(0.5 - Double(index) * 0.08)
                }
                
                // Additional slow pulsing rings
                ForEach(0..<2, id: \.self) { index in
                    let ringPulse = 1.0 + sin(time * (0.18 + Double(index) * 0.08)) * 0.2
                    Circle()
                        .strokeBorder(
                            Color.white.opacity(0.08 - Double(index) * 0.03),
                            lineWidth: 2 - CGFloat(index)
                        )
                        .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                        .scaleEffect(ringPulse)
                        .opacity(0.6 - Double(index) * 0.2)
                }
            }
            .compositingGroup()
            .shadow(color: SoundPalette.aqua.opacity(0.15), radius: 18, x: 0, y: 10)
        }
    }
}
