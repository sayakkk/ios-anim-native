import SwiftUI

struct AnimationCardView: View {
    let item: AnimationItem
    var onTap: (AnimationItem) -> Void

    @State private var pressed = false

    var body: some View {
        Button {
            onTap(item)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                // ── Thumbnail ──────────────────────────────────
                ZStack(alignment: .topTrailing) {
                    AnimationDemoView(id: item.id)
                        .frame(height: item.kind == .combo ? 108 : 100)

                    // Kind badge
                    Text(item.kind == .basic ? "기본" : "조합")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.textTertiary)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Color.white.opacity(0.82))
                        .clipShape(Capsule())
                        .padding(8)
                }

                // ── Label ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 3) {
                    // Official name — always primary
                    Text(item.name)
                        .font(.system(size: 15, weight: .black))
                        .foregroundStyle(Color.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)

                    // Feel as description
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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.cardBorder, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.72), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}
