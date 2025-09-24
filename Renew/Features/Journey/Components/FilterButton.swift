import SwiftUI

struct FilterButton: View {
    let filter: ToolFilter
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(filter.title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? filter.textColor : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    ZStack {
                        // Glassmorphic background
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(
                                        isSelected ? 
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                filter.backgroundColor.opacity(0.8),
                                                filter.backgroundColor.opacity(0.6)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ) :
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.white.opacity(0.15),
                                                Color.white.opacity(0.05)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                        
                        // Glassmorphic border
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(isSelected ? 0.5 : 0.2),
                                        Color.white.opacity(isSelected ? 0.2 : 0.05)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                )
        }
        .buttonStyle(.plain)
    }
}
