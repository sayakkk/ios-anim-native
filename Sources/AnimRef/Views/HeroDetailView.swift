import SwiftUI

// MARK: - Scroll Offset Preference

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Hero Detail View

struct HeroDetailView: View {
    let sectionItems: [AnimationItem]   // all items in the same section (기본 or 조합)
    @Binding var currentIndex: Int
    var namespace: Namespace.ID
    var onDismiss: () -> Void

    @State private var scrollAtTop = true
    @GestureState private var dragOffset: CGFloat = 0
    @State private var dismissProgress: CGFloat = 0
    @State private var copiedPrompt = false
    @State private var copiedCode = false
    @State private var showCode = false
    @State private var tabSelection: Int

    private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)
    private let dismissThreshold: CGFloat = 90

    init(sectionItems: [AnimationItem], currentIndex: Binding<Int>, namespace: Namespace.ID, onDismiss: @escaping () -> Void) {
        self.sectionItems = sectionItems
        self._currentIndex = currentIndex
        self.namespace = namespace
        self.onDismiss = onDismiss
        self._tabSelection = State(initialValue: currentIndex.wrappedValue)
    }

    var body: some View {
        let item = sectionItems[tabSelection]

        ZStack(alignment: .top) {
            // ── Background ────────────────────────────────────
            Color(red: 0.05, green: 0.04, blue: 0.02)
                .ignoresSafeArea()
                .matchedGeometryEffect(id: sectionItems[currentIndex].id, in: namespace)

            // ── Paged content ─────────────────────────────────
            TabView(selection: $tabSelection) {
                ForEach(Array(sectionItems.enumerated()), id: \.offset) { idx, pageItem in
                    DetailPage(
                        item: pageItem,
                        accent: accent,
                        copiedPrompt: $copiedPrompt,
                        copiedCode: $copiedCode,
                        showCode: $showCode,
                        onScrollOffset: { offset in
                            if idx == tabSelection {
                                scrollAtTop = offset >= -8
                            }
                        }
                    )
                    .tag(idx)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .offset(y: max(0, dragOffset))
            .simultaneousGesture(
                scrollAtTop ?
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation.height * 0.6
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > dismissThreshold {
                            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                                onDismiss()
                            }
                        }
                    }
                : nil
            )

            // ── Close button ──────────────────────────────────
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                        onDismiss()
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 32, height: 32)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 16)
                .padding(.top, 56)
            }

            // ── Page indicator ────────────────────────────────
            if sectionItems.count > 1 {
                VStack {
                    Spacer()
                    HStack(spacing: 5) {
                        ForEach(0..<sectionItems.count, id: \.self) { i in
                            Capsule()
                                .fill(i == tabSelection ? accent : Color.white.opacity(0.2))
                                .frame(width: i == tabSelection ? 16 : 5, height: 5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: tabSelection)
                        }
                    }
                    .padding(.bottom, 28)
                }
            }

            // ── Pull hint (when dragging) ─────────────────────
            if dragOffset > 10 {
                VStack {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11, weight: .semibold))
                        Text("내려서 닫기")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .foregroundStyle(.white.opacity(min(1, Double(dragOffset) / Double(dismissThreshold))))
                    .padding(.vertical, 8).padding(.horizontal, 14)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(.top, 14)
                    Spacer()
                }
            }
        }
        .ignoresSafeArea()
        .onChange(of: tabSelection) { newVal in
            currentIndex = newVal
            copiedPrompt = false
            copiedCode = false
            showCode = false
        }
    }
}

// MARK: - Detail Page (per-item scroll content)

private struct DetailPage: View {
    let item: AnimationItem
    let accent: Color
    @Binding var copiedPrompt: Bool
    @Binding var copiedCode: Bool
    @Binding var showCode: Bool
    var onScrollOffset: (CGFloat) -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Scroll offset tracker
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ScrollOffsetKey.self,
                                    value: geo.frame(in: .named("detailScroll")).minY)
                }
                .frame(height: 0)

                // ── Demo ─────────────────────────────────
                ZStack(alignment: .bottomLeading) {
                    AnimationDemoView(id: item.id)
                        .frame(height: 260)

                    // Category badge
                    Text(item.situationCategory)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(14)
                }

                // ── Header ───────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.feel)
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(Color(red: 0.96, green: 0.91, blue: 0.79))

                    HStack(spacing: 8) {
                        Text(item.name)
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundStyle(accent)
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(accent.opacity(0.25), lineWidth: 1))

                        Text(item.kind == .basic ? "기본" : "조합")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.3))
                            .padding(.horizontal, 6).padding(.vertical, 3)
                            .background(Color.white.opacity(0.05))
                            .clipShape(Capsule())
                    }

                    Text(item.feelDesc)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.55, green: 0.46, blue: 0.32))
                        .lineSpacing(4)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 18)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider().overlay(Color.white.opacity(0.06)).padding(.horizontal, 18)

                // ── Sections ─────────────────────────────
                VStack(alignment: .leading, spacing: 22) {

                    // 언제 써요?
                    DetailSection(title: "📍 언제 써요?") {
                        Text(item.when)
                            .font(.system(size: 14))
                            .foregroundStyle(Color(red: 0.80, green: 0.70, blue: 0.52))
                            .lineSpacing(4)
                    }

                    // 실제 앱
                    DetailSection(title: "📱 실제 앱에서 보면") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 7) {
                                ForEach(item.realApps, id: \.self) { app in
                                    Text(app)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color(red: 0.65, green: 0.55, blue: 0.38))
                                        .padding(.horizontal, 10).padding(.vertical, 5)
                                        .background(Color(red: 0.14, green: 0.12, blue: 0.07))
                                        .overlay(Capsule().stroke(Color.white.opacity(0.07), lineWidth: 1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // 세부조절 옵션
                    if !item.properties.isEmpty {
                        DetailSection(title: "⚙️ 세부조절 옵션") {
                            VStack(spacing: 8) {
                                ForEach(item.properties, id: \.key) { prop in
                                    PropertyRowDetail(prop: prop, accent: accent)
                                }
                            }
                        }
                    }

                    // AI 프롬프트
                    DetailSection(title: "✨ AI 프롬프트 템플릿") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(item.prompt)
                                .font(.system(size: 14))
                                .italic()
                                .foregroundStyle(Color(red: 0.55, green: 0.80, blue: 0.60))
                                .lineSpacing(5)

                            Text("💡 [ ] 부분을 원하는 내용으로 바꿔서 AI에 붙여넣으세요")
                                .font(.system(size: 11))
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
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(copiedPrompt ? Color.green : accent)
                                    .padding(.horizontal, 16).padding(.vertical, 9)
                                    .background(copiedPrompt ? Color.green.opacity(0.12) : accent.opacity(0.12))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(copiedPrompt ? 0.96 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: copiedPrompt)
                        }
                        .padding(14)
                        .background(Color(red: 0.05, green: 0.12, blue: 0.07))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.green.opacity(0.15), lineWidth: 1))
                    }

                    // SwiftUI 코드
                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showCode.toggle()
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: showCode ? "chevron.down" : "chevron.right")
                                    .font(.system(size: 10, weight: .semibold))
                                Text(showCode ? "SwiftUI 코드 접기" : "SwiftUI 코드 보기")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.22))
                        }
                        .buttonStyle(.plain)

                        if showCode {
                            VStack(alignment: .leading, spacing: 8) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    Text(item.swiftui)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundStyle(Color(red: 0.75, green: 0.68, blue: 0.52))
                                        .padding(14)
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
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundStyle(copiedCode ? Color.green : Color(red: 0.65, green: 0.55, blue: 0.38))
                                        .padding(.horizontal, 14).padding(.vertical, 8)
                                        .background(Color.white.opacity(0.06))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 80)
            }
        }
        .coordinateSpace(name: "detailScroll")
        .onPreferenceChange(ScrollOffsetKey.self) { value in
            onScrollOffset(value)
        }
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - Sub-components

private struct DetailSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(red: 0.45, green: 0.36, blue: 0.22))
                .textCase(.uppercase)
                .kerning(0.8)
            content
        }
    }
}

private struct PropertyRowDetail: View {
    let prop: AnimProperty
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(prop.label)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(Color(red: 0.96, green: 0.91, blue: 0.79))

                Text(prop.key)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundStyle(accent)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(Color(red: 0.12, green: 0.09, blue: 0.04))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(accent.opacity(0.25), lineWidth: 1))
            }
            Text(prop.desc)
                .font(.system(size: 12.5))
                .foregroundStyle(Color(red: 0.50, green: 0.40, blue: 0.27))
                .lineSpacing(3)
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.07, green: 0.06, blue: 0.03))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
