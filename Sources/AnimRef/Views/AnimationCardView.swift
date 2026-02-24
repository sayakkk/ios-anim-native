import SwiftUI

struct AnimationCardView: View {
    let item: AnimationItem
    @State private var expanded = false
    @State private var showCode = false
    @State private var copiedPrompt = false
    @State private var copiedCode = false

    private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)

    var body: some View {
        VStack(spacing: 0) {
            // ── Thumbnail ──────────────────────────────────
            ZStack(alignment: .topLeading) {
                AnimationDemoView(id: item.id)
                    .frame(height: 120)

                // Category badge
                Text(item.situationCategory)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
            }

            // ── Title area ─────────────────────────────────
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    expanded.toggle()
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.feel)
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(Color(red: 0.95, green: 0.90, blue: 0.78))
                            Text(item.name)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(accent)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.3))
                            .rotationEffect(.degrees(expanded ? 180 : 0))
                            .animation(.spring(response: 0.3), value: expanded)
                    }
                    Text(item.feelDesc)
                        .font(.system(size: 11))
                        .foregroundStyle(Color(red: 0.55, green: 0.46, blue: 0.32))
                        .lineLimit(expanded ? nil : 2)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            // ── Expanded ───────────────────────────────────
            if expanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider().overlay(Color.white.opacity(0.06))
                        .padding(.horizontal, 14)

                    // When
                    InfoSection(title: "📍 언제 써요?") {
                        Text(item.when)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 0.80, green: 0.70, blue: 0.52))
                            .lineSpacing(3)
                    }

                    // Real apps
                    InfoSection(title: "📱 실제 앱에서 보면") {
                        HStack(spacing: 6) {
                            ForEach(item.realApps, id: \.self) { app in
                                Text(app)
                                    .font(.system(size: 10.5, weight: .medium))
                                    .foregroundStyle(Color(red: 0.65, green: 0.55, blue: 0.38))
                                    .padding(.horizontal, 9).padding(.vertical, 4)
                                    .background(Color(red: 0.14, green: 0.12, blue: 0.07))
                                    .overlay(
                                        Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1)
                                    )
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Properties
                    InfoSection(title: "⚙️ 세부조절 옵션") {
                        VStack(spacing: 7) {
                            ForEach(item.properties, id: \.key) { prop in
                                PropertyRow(prop: prop, accent: accent)
                            }
                        }
                    }

                    // AI Prompt
                    InfoSection(title: "✨ AI 프롬프트 템플릿") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.prompt)
                                .font(.system(size: 13))
                                .italic()
                                .foregroundStyle(Color(red: 0.55, green: 0.80, blue: 0.60))
                                .lineSpacing(4)

                            Text("💡 [ ] 부분을 원하는 내용으로 바꿔서 AI에 붙여넣으세요")
                                .font(.system(size: 10))
                                .foregroundStyle(Color(red: 0.28, green: 0.50, blue: 0.34))

                            Button {
                                UIPasteboard.general.string = item.prompt
                                withAnimation { copiedPrompt = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                    withAnimation { copiedPrompt = false }
                                }
                            } label: {
                                Label(copiedPrompt ? "복사됨 ✓" : "프롬프트 복사",
                                      systemImage: copiedPrompt ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(copiedPrompt ? Color.green : accent)
                                    .padding(.horizontal, 14).padding(.vertical, 8)
                                    .background(copiedPrompt
                                        ? Color.green.opacity(0.12)
                                        : accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(copiedPrompt ? 0.96 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copiedPrompt)
                        }
                        .padding(12)
                        .background(Color(red: 0.05, green: 0.12, blue: 0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.15), lineWidth: 1))
                    }

                    // Code toggle
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            showCode.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: showCode ? "chevron.down" : "chevron.right")
                                .font(.system(size: 10, weight: .semibold))
                            Text(showCode ? "SwiftUI 코드 접기" : "SwiftUI 코드 보기")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.22))
                        .padding(.horizontal, 14)
                    }
                    .buttonStyle(.plain)

                    if showCode {
                        VStack(alignment: .leading, spacing: 8) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                Text(item.swiftui)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundStyle(Color(red: 0.75, green: 0.68, blue: 0.52))
                                    .padding(12)
                            }
                            .background(Color(red: 0.04, green: 0.03, blue: 0.02))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 1))

                            Button {
                                UIPasteboard.general.string = item.swiftui
                                withAnimation { copiedCode = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                    withAnimation { copiedCode = false }
                                }
                            } label: {
                                Label(copiedCode ? "복사됨 ✓" : "코드 복사",
                                      systemImage: copiedCode ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(copiedCode ? Color.green : Color(red: 0.65, green: 0.55, blue: 0.38))
                                    .padding(.horizontal, 12).padding(.vertical, 7)
                                    .background(Color.white.opacity(0.06))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(.bottom, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .background(Color(red: expanded ? 0.10 : 0.08, green: expanded ? 0.08 : 0.06, blue: expanded ? 0.04 : 0.03))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(expanded ? 0.10 : 0.05), lineWidth: 1)
        )
    }
}

// MARK: - Sub-components

struct InfoSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.22))
                .textCase(.uppercase)
                .kerning(0.8)
            content
        }
        .padding(.horizontal, 14)
    }
}

struct PropertyRow: View {
    let prop: AnimProperty
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                // Korean label - bold and prominent
                Text(prop.label)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(Color(red: 0.95, green: 0.90, blue: 0.78))

                Text("—")
                    .font(.system(size: 11))
                    .foregroundStyle(Color.white.opacity(0.15))

                // Code key
                Text(prop.key)
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Color(red: 0.12, green: 0.09, blue: 0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(accent.opacity(0.25), lineWidth: 1)
                    )
            }

            Text(prop.desc)
                .font(.system(size: 11.5))
                .foregroundStyle(Color(red: 0.50, green: 0.40, blue: 0.27))
                .lineSpacing(2)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.07, green: 0.06, blue: 0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
