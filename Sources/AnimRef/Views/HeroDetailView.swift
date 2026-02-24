import SwiftUI

// MARK: - Scroll offset tracking

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - Hero Detail View

struct HeroDetailView: View {
    let sectionItems: [AnimationItem]
    @Binding var currentIndex: Int
    var onDismiss: () -> Void

    @State private var appeared = false
    @State private var tabSelection: Int
    @State private var scrollAtTop = true
    @GestureState private var pullOffset: CGFloat = 0

    private let dismissThreshold: CGFloat = 88

    init(sectionItems: [AnimationItem], currentIndex: Binding<Int>, onDismiss: @escaping () -> Void) {
        self.sectionItems = sectionItems
        self._currentIndex = currentIndex
        self.onDismiss = onDismiss
        self._tabSelection = State(initialValue: currentIndex.wrappedValue)
    }

    var body: some View {
        ZStack(alignment: .top) {
            // ── Full-screen bg ─────────────────────────────
            Color.appBg.ignoresSafeArea()

            // ── Paged content ──────────────────────────────
            TabView(selection: $tabSelection) {
                ForEach(Array(sectionItems.enumerated()), id: \.offset) { idx, item in
                    DetailPage(
                        item: item,
                        onScrollOffset: { offset in
                            if idx == tabSelection { scrollAtTop = offset >= -6 }
                        },
                        onDismiss: dismiss
                    )
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: max(0, pullOffset * 0.55))
            .gesture(
                scrollAtTop
                ? DragGesture()
                    .updating($pullOffset) { val, state, _ in
                        if val.translation.height > 0 { state = val.translation.height }
                    }
                    .onEnded { val in
                        if val.translation.height > dismissThreshold { dismiss() }
                    }
                : nil
            )

            // ── Top bar ────────────────────────────────────
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 1)
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.top, 56)
            }

            // ── Page dots ──────────────────────────────────
            if sectionItems.count > 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0..<sectionItems.count, id: \.self) { i in
                            Capsule()
                                .fill(i == tabSelection ? Color.textPrimary : Color.textTertiary.opacity(0.4))
                                .frame(width: i == tabSelection ? 18 : 5, height: 5)
                                .animation(.spring(response: 0.28, dampingFraction: 0.72), value: tabSelection)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }

            // ── Pull hint ──────────────────────────────────
            if pullOffset > 12 {
                VStack {
                    Label("내려서 닫기", systemImage: "chevron.down")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Color.textSecondary.opacity(min(1, Double(pullOffset) / Double(dismissThreshold))))
                        .padding(.vertical, 7).padding(.horizontal, 13)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.06), radius: 4, y: 1)
                        .padding(.top, 12)
                    Spacer()
                }
            }
        }
        // ── Clean spring presentation ──────────────────────
        .scaleEffect(appeared ? 1.0 : 0.94)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                appeared = true
            }
        }
        .onChange(of: tabSelection) { newVal in
            currentIndex = newVal
        }
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            onDismiss()
        }
    }
}

// MARK: - Detail Page

private struct DetailPage: View {
    let item: AnimationItem
    var onScrollOffset: (CGFloat) -> Void
    var onDismiss: () -> Void

    @State private var copiedPrompt = false
    @State private var copiedCode   = false
    @State private var showCode     = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Scroll tracker
                GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                }
                .frame(height: 0)

                // ── Top white card ────────────────────────
                VStack(alignment: .leading, spacing: 0) {

                    // Demo
                    AnimationDemoView(id: item.id)
                        .frame(height: 230)
                        .overlay(alignment: .bottomLeading) {
                            Text(item.situationCategory)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Color.textSecondary)
                                .padding(.horizontal, 10).padding(.vertical, 4)
                                .background(Color.white.opacity(0.88))
                                .clipShape(Capsule())
                                .padding(14)
                        }

                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.system(size: 28, weight: .black))
                            .foregroundStyle(Color.textPrimary)

                        Text(item.feel)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)

                        Text(item.feelDesc)
                            .font(.system(size: 13))
                            .foregroundStyle(Color.textTertiary)
                            .lineSpacing(5)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 18)
                    .padding(.bottom, 22)
                }
                .background(Color.white)
                .clipShape(.rect(
                    topLeadingRadius: 0, bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20, topTrailingRadius: 0
                ))
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)

                // ── Content sections ──────────────────────
                VStack(alignment: .leading, spacing: 24) {

                    // 언제 써요?
                    ContentSection(title: "언제 써요?") {
                        Text(item.when)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                            .lineSpacing(5)
                    }

                    // 실제 앱
                    ContentSection(title: "실제 앱에서 보면") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                ForEach(item.realApps, id: \.self) { app in
                                    Text(app)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.textSecondary)
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.cardBorder, lineWidth: 1))
                                }
                            }
                        }
                    }

                    // 세부조절 옵션
                    if !item.properties.isEmpty {
                        ContentSection(title: "세부조절 옵션") {
                            VStack(spacing: 8) {
                                ForEach(item.properties, id: \.key) { prop in
                                    PropRow(prop: prop)
                                }
                            }
                        }
                    }

                    // AI 프롬프트
                    ContentSection(title: "AI 프롬프트") {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.prompt)
                                .font(.system(size: 13))
                                .italic()
                                .foregroundStyle(Color.textSecondary)
                                .lineSpacing(5)

                            Text("[ ] 부분을 원하는 내용으로 바꿔서 AI에 붙여넣으세요")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.textTertiary)

                            Button {
                                UIPasteboard.general.string = item.prompt
                                withAnimation { copiedPrompt = true }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                                    withAnimation { copiedPrompt = false }
                                }
                            } label: {
                                Label(copiedPrompt ? "복사됨 ✓" : "프롬프트 복사",
                                      systemImage: copiedPrompt ? "checkmark" : "doc.on.doc")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(copiedPrompt ? .white : Color.textPrimary)
                                    .padding(.horizontal, 16).padding(.vertical, 9)
                                    .background(copiedPrompt ? Color.textPrimary : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.cardBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(copiedPrompt ? 0.96 : 1.0)
                            .animation(.spring(response: 0.28, dampingFraction: 0.65), value: copiedPrompt)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
                    }

                    // SwiftUI 코드
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.80)) {
                                showCode.toggle()
                            }
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: showCode ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                Text(showCode ? "코드 접기" : "SwiftUI 코드 보기")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color.textTertiary)
                        }
                        .buttonStyle(.plain)

                        if showCode {
                            VStack(alignment: .leading, spacing: 8) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(item.swiftui)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundStyle(Color.textSecondary)
                                        .padding(14)
                                }
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 1))

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
                                        .foregroundStyle(Color.textSecondary)
                                        .padding(.horizontal, 12).padding(.vertical, 7)
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))
                                }
                                .buttonStyle(.plain)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 26)
                .padding(.bottom, 80)
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetKey.self) { onScrollOffset($0) }
        .background(Color.appBg)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Subviews

private struct ContentSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.textTertiary)
                .kerning(0.8)
            content
        }
    }
}

private struct PropRow: View {
    let prop: AnimProperty

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Text(prop.label)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color.textPrimary)

                Text(prop.key)
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .foregroundStyle(Color.textSecondary)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Color.appBg)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.cardBorder, lineWidth: 1))
            }
            Text(prop.desc)
                .font(.system(size: 12))
                .foregroundStyle(Color.textTertiary)
                .lineSpacing(3)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 1))
    }
}
