import SwiftUI

// MARK: - Compact Card (tap → hero expand)

struct AnimationCardView: View {
    let item: AnimationItem
    var namespace: Namespace.ID
    var onTap: (AnimationItem) -> Void

    @State private var pressed = false

    private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)

    var body: some View {
        Button {
            onTap(item)
        } label: {
            VStack(spacing: 0) {
                // ── Thumbnail ──────────────────────────────────
                ZStack(alignment: .topLeading) {
                    AnimationDemoView(id: item.id)
                        .frame(height: item.kind == .combo ? 110 : 100)

                    // Category badge
                    Text(item.situationCategory)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(8)
                }

                // ── Label ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 3) {
                    if item.kind == .basic {
                        // 기본: animation name first
                        Text(item.name)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(Color(red: 0.96, green: 0.91, blue: 0.79))
                            .lineLimit(1)
                        Text(item.feel)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.50, green: 0.40, blue: 0.27))
                            .lineLimit(2)
                    } else {
                        // 조합: feel name first
                        Text(item.feel)
                            .font(.system(size: 15, weight: .black))
                            .foregroundStyle(Color(red: 0.96, green: 0.91, blue: 0.79))
                            .lineLimit(2)
                        Text(item.name)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundStyle(accent)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 11)
                .padding(.vertical, 10)
            }
            .background(Color(red: 0.08, green: 0.07, blue: 0.04))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
            .matchedGeometryEffect(id: item.id, in: namespace)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
