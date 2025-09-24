import SwiftUI

struct ToolSessionCard: View {
    let session: ToolSession

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Hero image background
            Image(session.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 280)
                .frame(maxWidth: .infinity)
                .clipped()
                        .overlay(
                            // Gradient overlay for better text readability
                LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: .clear, location: 0.4),
                                    .init(color: session.backgroundColor.opacity(0.3), location: 0.6),
                                    .init(color: session.backgroundColor.opacity(0.7), location: 0.8),
                                    .init(color: session.backgroundColor.opacity(0.85), location: 1.0)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
            
                    // Text overlay on bottom left
                    VStack(alignment: .leading, spacing: 8) {
                        Text(session.title)
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)

                        Text(session.subtitle)
                    .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.leading, 24)
                    .padding(.bottom, 24)
        }
        .background(
            ZStack {
                // Glassmorphic background with blur
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
                
                // Glassmorphic border with gradient
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
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.1), radius: 30, x: 0, y: 15)
        .shadow(color: Color.white.opacity(0.1), radius: 1, x: 0, y: 1)
    }
}
