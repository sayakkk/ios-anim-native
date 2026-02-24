import SwiftUI

// MARK: - Scroll offset

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - Hero Detail View

struct HeroDetailView: View {
    let sectionItems: [AnimationItem]
    @Binding var currentIndex: Int
    var onDismiss: () -> Void

    @State private var appeared  = false
    @GestureState private var swipeDelta: CGFloat = 0

    private let dismissThreshold: CGFloat = 80

    private var item: AnimationItem { sectionItems[min(currentIndex, sectionItems.count - 1)] }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.appBg.ignoresSafeArea()

            DetailPage(item: item)
                .offset(x: max(0, swipeDelta * 0.65))
                .gesture(
                    DragGesture()
                        .updating($swipeDelta) { val, state, _ in
                            let isH = abs(val.translation.width) > abs(val.translation.height)
                            if isH && val.translation.width > 0 { state = val.translation.width }
                        }
                        .onEnded { val in
                            let isH = abs(val.translation.width) > abs(val.translation.height)
                            let fast = val.predictedEndTranslation.width > 200
                            if isH && (val.translation.width > dismissThreshold || fast) {
                                dismiss()
                            }
                        }
                )

            // Close button
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.textSecondary)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.07), radius: 4, y: 1)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 16)
            .padding(.top, 56)
        }
        .ignoresSafeArea()
        // Smooth spring presentation (no jitter)
        .scaleEffect(appeared ? 1.0 : 0.94)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.36, dampingFraction: 0.90)) {
                appeared = true
            }
        }
        // Slide feedback while swiping
        .shadow(
            color: .black.opacity(swipeDelta > 0 ? 0.08 : 0),
            radius: 20, x: -4, y: 0
        )
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.30, dampingFraction: 0.90)) {
            appeared = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.26) { onDismiss() }
    }
}

// MARK: - Detail Page

private struct DetailPage: View {
    let item: AnimationItem

    @State private var copiedPrompt = false
    @State private var copiedCode   = false
    @State private var showCode     = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── Animation only — isolated white card ──────────
                ZStack(alignment: .bottomLeading) {
                    AnimationDemoView(id: item.id)
                        .frame(height: 240)

                    Text(item.situationCategory)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.white.opacity(0.88))
                        .clipShape(Capsule())
                        .padding(14)
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.96))
                .clipShape(.rect(
                    topLeadingRadius: 0, bottomLeadingRadius: 22,
                    bottomTrailingRadius: 22, topTrailingRadius: 0
                ))
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)

                // ── Title block ───────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.name)
                        .font(.system(size: 30, weight: .black))
                        .foregroundStyle(Color.textPrimary)

                    Text(item.feel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.textSecondary)

                    Text(item.feelDesc)
                        .font(.system(size: 13))
                        .foregroundStyle(Color.textTertiary)
                        .lineSpacing(5)
                        .padding(.top, 2)
                }
                .padding(.horizontal, 18)
                .padding(.top, 22)
                .padding(.bottom, 8)

                Divider()
                    .overlay(Color.divider)
                    .padding(.horizontal, 18)
                    .padding(.top, 14)
                    .padding(.bottom, 2)

                // ── Content sections ──────────────────────────────
                VStack(alignment: .leading, spacing: 26) {

                    ContentSection(title: "언제 써요?") {
                        Text(item.when)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                            .lineSpacing(5)
                    }

                    ContentSection(title: "실제 앱에서 보면") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(item.realApps, id: \.self) { app in
                                    AppExampleTile(text: app)
                                }
                            }
                        }
                    }

                    if !item.properties.isEmpty {
                        ContentSection(title: "세부조절 옵션") {
                            VStack(spacing: 8) {
                                ForEach(item.properties, id: \.key) { prop in
                                    PropRow(prop: prop)
                                }
                            }
                        }
                    }

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
                                    .overlay(RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.cardBorder, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                            .scaleEffect(copiedPrompt ? 0.96 : 1.0)
                            .animation(.spring(response: 0.25, dampingFraction: 0.65), value: copiedPrompt)
                        }
                        .padding(14)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.cardBorder, lineWidth: 1))
                    }

                    // SwiftUI code toggle
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
                .padding(.top, 24)
                .padding(.bottom, 80)
            }
        }
        .background(Color.appBg)
        .ignoresSafeArea(edges: .top)
    }
}

// MARK: - App example tile (silhouette + label)

private struct AppExampleTile: View {
    let text: String

    var body: some View {
        VStack(spacing: 7) {
            SceneSilhouette(text: text)
                .frame(width: 48, height: 40)
            Text(text)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 60)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
    }
}

// MARK: - Scene silhouette

private struct SceneSilhouette: View {
    let text: String

    private enum Kind {
        case heart, button, pin, waveform, list, bottomSheet, badge, pullRefresh, spinner, progress, transition, chat
    }

    private var kind: Kind {
        let s = text.lowercased()
        if s.contains("하트") || s.contains("좋아요") { return .heart }
        if s.contains("비밀번호") || s.contains("핀") || s.contains("잠금") { return .pin }
        if s.contains("음성") || s.contains("siri") || s.contains("재생 바") || s.contains("spotify") { return .waveform }
        if s.contains("당겨") || s.contains("pull") { return .pullRefresh }
        if s.contains("시트") || s.contains("알림 센터") { return .bottomSheet }
        if s.contains("설정") || s.contains("리스트") || s.contains("목록") || s.contains("추천") { return .list }
        if s.contains("배지") || s.contains("뱃지") || s.contains("badge") { return .badge }
        if s.contains("로딩") || s.contains("스피너") || s.contains("연결") || s.contains("페어링") { return .spinner }
        if s.contains("프로그레스") || s.contains("progress") { return .progress }
        if s.contains("화면 전환") || s.contains("전환") || s.contains("화면") { return .transition }
        if s.contains("카카오") || s.contains("메시지") || s.contains("채팅") { return .chat }
        return .button
    }

    private let c = Color(red: 0.13, green: 0.12, blue: 0.11)

    var body: some View {
        ZStack {
            switch kind {
            case .heart:       HeartSilhouette(c: c)
            case .button:      ButtonSilhouette(c: c)
            case .pin:         PinSilhouette(c: c)
            case .waveform:    WaveformSilhouette(c: c)
            case .pullRefresh: PullRefreshSilhouette(c: c)
            case .bottomSheet: BottomSheetSilhouette(c: c)
            case .list:        ListSilhouette(c: c)
            case .badge:       BadgeSilhouette(c: c)
            case .spinner:     SpinnerSilhouette(c: c)
            case .progress:    ProgressSilhouette(c: c)
            case .transition:  TransitionSilhouette(c: c)
            case .chat:        ChatSilhouette(c: c)
            }
        }
    }
}

// Individual silhouette shapes
private struct HeartSilhouette: View {
    let c: Color
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 22))
            .foregroundStyle(c.opacity(0.22))
    }
}

private struct ButtonSilhouette: View {
    let c: Color
    var body: some View {
        VStack(spacing: 5) {
            RoundedRectangle(cornerRadius: 5)
                .fill(c.opacity(0.15))
                .frame(width: 36, height: 16)
            // tap ring
            Circle()
                .stroke(c.opacity(0.20), lineWidth: 1.2)
                .frame(width: 10, height: 10)
        }
    }
}

private struct PinSilhouette: View {
    let c: Color
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<4) { _ in
                Circle()
                    .fill(c.opacity(0.25))
                    .frame(width: 7, height: 7)
            }
        }
    }
}

private struct WaveformSilhouette: View {
    let c: Color
    let heights: [CGFloat] = [8, 18, 26, 20, 12, 22, 16, 10]
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(Array(heights.enumerated()), id: \.offset) { _, h in
                RoundedRectangle(cornerRadius: 2)
                    .fill(c.opacity(0.22))
                    .frame(width: 3, height: h)
            }
        }
    }
}

private struct PullRefreshSilhouette: View {
    let c: Color
    var body: some View {
        VStack(spacing: 3) {
            Image(systemName: "arrow.down")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(c.opacity(0.22))
            VStack(spacing: 3) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(c.opacity(0.15))
                        .frame(width: 32, height: 5)
                }
            }
        }
    }
}

private struct BottomSheetSilhouette: View {
    let c: Color
    var body: some View {
        ZStack(alignment: .bottom) {
            // phone frame
            RoundedRectangle(cornerRadius: 4)
                .stroke(c.opacity(0.15), lineWidth: 1)
                .frame(width: 28, height: 36)
            // sheet rising
            RoundedRectangle(cornerRadius: 4)
                .fill(c.opacity(0.18))
                .frame(width: 28, height: 16)
        }
    }
}

private struct ListSilhouette: View {
    let c: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<4) { i in
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(c.opacity(0.20))
                        .frame(width: i == 0 ? 28 : CGFloat(16 + i * 4), height: 5)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 6, weight: .semibold))
                        .foregroundStyle(c.opacity(0.15))
                }
                .frame(width: 40)
            }
        }
    }
}

private struct BadgeSilhouette: View {
    let c: Color
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 8)
                .fill(c.opacity(0.15))
                .frame(width: 28, height: 28)
            Circle()
                .fill(c.opacity(0.35))
                .frame(width: 11, height: 11)
                .offset(x: 3, y: -3)
        }
    }
}

private struct SpinnerSilhouette: View {
    let c: Color
    var body: some View {
        ZStack {
            Circle()
                .stroke(c.opacity(0.10), lineWidth: 2.5)
                .frame(width: 24, height: 24)
            Circle()
                .trim(from: 0, to: 0.72)
                .stroke(c.opacity(0.28), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-60))
        }
    }
}

private struct ProgressSilhouette: View {
    let c: Color
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(c.opacity(0.12))
                    .frame(width: 38, height: 5)
                RoundedRectangle(cornerRadius: 3)
                    .fill(c.opacity(0.30))
                    .frame(width: 22, height: 5)
            }
        }
    }
}

private struct TransitionSilhouette: View {
    let c: Color
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(c.opacity(0.10))
                .frame(width: 24, height: 32)
                .offset(x: -6)
            RoundedRectangle(cornerRadius: 4)
                .fill(c.opacity(0.22))
                .frame(width: 24, height: 32)
                .offset(x: 6)
        }
    }
}

private struct ChatSilhouette: View {
    let c: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // received
            HStack(spacing: 3) {
                Circle().fill(c.opacity(0.18)).frame(width: 10, height: 10)
                RoundedRectangle(cornerRadius: 5)
                    .fill(c.opacity(0.15)).frame(width: 22, height: 10)
            }
            // sent (right)
            HStack(spacing: 3) {
                Spacer()
                RoundedRectangle(cornerRadius: 5)
                    .fill(c.opacity(0.22)).frame(width: 18, height: 10)
            }
            .frame(width: 44)
        }
    }
}

// MARK: - Reusable sub-components

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
