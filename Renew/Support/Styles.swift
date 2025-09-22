import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.68, green: 0.86, blue: 0.98),
                Color(red: 0.73, green: 0.93, blue: 0.86),
                Color(red: 0.95, green: 0.96, blue: 0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

enum RenewButtonVisualStyle {
    case primary
    case glass
}

struct RenewButtonStyle: ButtonStyle {
    let style: RenewButtonVisualStyle

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding()
            .background(background(configuration: configuration))
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(borderColor(configuration: configuration), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(color: Color.black.opacity(0.1), radius: configuration.isPressed ? 4 : 12, x: 0, y: configuration.isPressed ? 2 : 6)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch style {
        case .primary: return .white
        case .glass: return .primary
        }
    }

    private func background(configuration: Configuration) -> some View {
        let opacity = configuration.isPressed ? 0.8 : 1.0
        return Group {
            switch style {
            case .primary:
                LinearGradient(
                    colors: [
                        Color(red: 0.38, green: 0.78, blue: 0.98).opacity(opacity),
                        Color(red: 0.46, green: 0.89, blue: 0.83).opacity(opacity),
                        Color(red: 0.98, green: 0.93, blue: 0.67).opacity(opacity)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            case .glass:
                Color.white.opacity(0.45 * opacity)
            }
        }
    }

    private func borderColor(configuration: Configuration) -> Color {
        switch style {
        case .primary: return .white.opacity(0.2)
        case .glass: return .white.opacity(configuration.isPressed ? 0.0 : 0.4)
        }
    }
}
