import SwiftUI

// MARK: - Card

struct AnimationCardView: View {
    let item: AnimationItem
    var onTap: (AnimationItem) -> Void

    var body: some View {
        Button { onTap(item) } label: {
            VStack(alignment: .leading, spacing: 0) {
                // ── Thumbnail ────────────────────────────────
                ZStack(alignment: .topTrailing) {
                    AnimationDemoView(id: item.id)
                        .frame(height: item.kind == .combo ? 108 : 100)
                        .clipShape(UnevenRoundedRectangle(
                            topLeadingRadius: 15, bottomLeadingRadius: 0,
                            bottomTrailingRadius: 0, topTrailingRadius: 15
                        ))

                    Text(item.kind == .basic ? "기본" : "조합")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color.white.opacity(0.82))
                        .clipShape(Capsule())
                        .padding(8)
                }

                // ── Label ────────────────────────────────────
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    Text(item.feel)
                        .font(.system(size: 11))
                        .foregroundStyle(Color.textTertiary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 11)
                .padding(.top, 10)
                .padding(.bottom, 12)
            }
            .background(Color.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.cardBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(CardPressStyle())
    }
}

// MARK: - Press style (doesn't block ScrollView)
private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(
                configuration.isPressed
                    ? .spring(response: 0.18, dampingFraction: 0.72)
                    : .spring(response: 0.35, dampingFraction: 0.72),
                value: configuration.isPressed
            )
    }
}
