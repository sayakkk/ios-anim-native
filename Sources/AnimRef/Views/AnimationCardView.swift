import SwiftUI

// MARK: - Card

struct AnimationCardView: View {
    let item: AnimationItem
    var isSelected: Bool = false
    var onTap: (AnimationItem) -> Void

    @State private var isHovered = false

    var body: some View {
        Button { onTap(item) } label: {
            VStack(alignment: .leading, spacing: 0) {

                // ── Thumbnail ─────────────────────────────────
                ZStack(alignment: .topTrailing) {
                    AnimationDemoView(id: item.id)
                        .frame(height: item.kind == .combo ? 100 : 92)
                        .clipShape(UnevenRoundedRectangle(
                            topLeadingRadius: 12, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0, topTrailingRadius: 12
                        ))

                    Text(item.kind == .basic ? "기본" : "조합")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color.white.opacity(0.82))
                        .clipShape(Capsule())
                        .padding(8)
                }

                // ── Label ─────────────────────────────────────
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(item.feel)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 10)
                .padding(.top, 9)
                .padding(.bottom, 11)
            }
            .background(Color.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        isSelected ? Color.textSecondary : (isHovered ? Color.cardBorder.opacity(1.5) : Color.cardBorder),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: .black.opacity(isSelected ? 0.10 : 0.05),
                radius: isSelected ? 8 : 4,
                x: 0, y: 2
            )
        }
        .buttonStyle(CardPressStyle())
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.15)) { isHovered = hovering }
        }
    }
}

// MARK: - Press style (scale feedback)
private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(
                configuration.isPressed
                    ? .spring(response: 0.18, dampingFraction: 0.72)
                    : .spring(response: 0.35, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }
}
