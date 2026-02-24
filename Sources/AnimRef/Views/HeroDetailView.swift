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
                let demoH = UIScreen.main.bounds.height * 0.58
                ZStack(alignment: .bottomLeading) {
                    AnimationDemoView(id: item.id)
                        .frame(height: demoH)

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

// MARK: - App example tile (animated mini scene in border frame)

private struct AppExampleTile: View {
    let text: String

    var body: some View {
        VStack(spacing: 7) {
            ZStack {
                RoundedRectangle(cornerRadius: 9)
                    .fill(Color(red: 0.97, green: 0.97, blue: 0.96))
                RoundedRectangle(cornerRadius: 9)
                    .stroke(Color.cardBorder, lineWidth: 1)
                MiniAnimScene(text: text)
                    .frame(width: 56, height: 48)
                    .clipped()
            }
            .frame(width: 68, height: 58)

            Text(text)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundStyle(Color.textTertiary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(width: 72)
        }
    }
}

// MARK: - Mini animated scene dispatcher

private struct MiniAnimScene: View {
    let text: String

    private enum Kind {
        case heart, button, pin, waveform, bottomSheet, list, badge, spinner, progress, transition, chat, pullRefresh
    }
    private var kind: Kind {
        let s = text.lowercased()
        if s.contains("하트") || s.contains("좋아요") { return .heart }
        if s.contains("비밀번호") || s.contains("핀") || s.contains("잠금") { return .pin }
        if s.contains("음성") || s.contains("siri") || s.contains("재생 바") || s.contains("spotify") { return .waveform }
        if s.contains("당겨") || s.contains("pull") { return .pullRefresh }
        if s.contains("시트") || s.contains("알림 센터") { return .bottomSheet }
        if s.contains("설정") || s.contains("리스트") || s.contains("목록") || s.contains("추천") { return .list }
        if s.contains("배지") || s.contains("뱃지") { return .badge }
        if s.contains("로딩") || s.contains("스피너") || s.contains("연결") || s.contains("페어링") { return .spinner }
        if s.contains("프로그레스") { return .progress }
        if s.contains("화면 전환") || s.contains("전환") { return .transition }
        if s.contains("카카오") || s.contains("메시지") { return .chat }
        return .button
    }

    var body: some View {
        switch kind {
        case .heart:       MiniHeart()
        case .button:      MiniButton()
        case .pin:         MiniPin()
        case .waveform:    MiniWaveform()
        case .pullRefresh: MiniPullRefresh()
        case .bottomSheet: MiniBottomSheet()
        case .list:        MiniList()
        case .badge:       MiniBadge()
        case .spinner:     MiniSpinner()
        case .progress:    MiniProgress()
        case .transition:  MiniTransition()
        case .chat:        MiniChat()
        }
    }
}

private let mc = Color(red: 0.13, green: 0.12, blue: 0.11)

// Heart — pop scale
private struct MiniHeart: View {
    @State private var popped = false
    var body: some View {
        Image(systemName: "heart.fill")
            .font(.system(size: 20))
            .foregroundStyle(mc.opacity(0.25))
            .scaleEffect(popped ? 1.35 : 0.85)
            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: popped)
            .onAppear { Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in
                popped = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { popped = false }
            }}
    }
}

// Button — press scale
private struct MiniButton: View {
    @State private var pressed = false
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(mc.opacity(0.18))
            .frame(width: 38, height: 16)
            .scaleEffect(pressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.55), value: pressed)
            .onAppear { Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in
                pressed = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.38) { pressed = false }
            }}
    }
}

// Pin — shake left/right + red
private struct MiniPin: View {
    @State private var trigger = false
    @State private var err = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<4) { _ in
                Circle()
                    .fill(err ? Color(red: 0.88, green: 0.20, blue: 0.18).opacity(0.6) : mc.opacity(0.28))
                    .frame(width: 7, height: 7)
            }
        }
        .keyframeAnimator(initialValue: 0.0, trigger: trigger) { v, x in v.offset(x: x) } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(0,   duration: 0.03)
                LinearKeyframe(-8,  duration: 0.06)
                LinearKeyframe(8,   duration: 0.06)
                LinearKeyframe(-5,  duration: 0.05)
                LinearKeyframe(5,   duration: 0.05)
                LinearKeyframe(0,   duration: 0.04)
            }
        }
        .onAppear { Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            err = true; trigger.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { err = false }
        }}
    }
}

// Waveform — equalizer bars
private struct MiniWaveform: View {
    @State private var on = false
    let bases: [CGFloat] = [0.08, 0.18, 0.06, 0.16, 0.10, 0.14, 0.08]
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(Array(bases.enumerated()), id: \.offset) { i, b in
                RoundedRectangle(cornerRadius: 2)
                    .fill(mc.opacity(0.28))
                    .frame(width: 4, height: on ? CGFloat.random(in: 8...26) : b * 40 + 5)
                    .animation(
                        .easeInOut(duration: Double.random(in: 0.3...0.55))
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.08),
                        value: on
                    )
            }
        }
        .onAppear { on = true }
    }
}

// Pull to refresh — arrow + list pull
private struct MiniPullRefresh: View {
    @State private var pulling = false
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.clockwise")
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(mc.opacity(pulling ? 0.45 : 0.15))
                .rotationEffect(.degrees(pulling ? 360 : 0))
                .animation(.linear(duration: 0.7).repeatForever(autoreverses: false), value: pulling)
            VStack(spacing: 3) {
                ForEach(0..<3) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(mc.opacity(0.15))
                        .frame(width: CGFloat(28 - i * 4), height: 4)
                }
            }
            .offset(y: pulling ? -4 : 0)
            .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulling)
        }
        .onAppear { pulling = true }
    }
}

// Bottom sheet — slides up/down
private struct MiniBottomSheet: View {
    @State private var shown = false
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 4)
                .stroke(mc.opacity(0.15), lineWidth: 1)
                .frame(width: 34, height: 42)
            if shown {
                RoundedRectangle(cornerRadius: 4)
                    .fill(mc.opacity(0.20))
                    .frame(width: 34, height: 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: shown)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in shown.toggle() }}
    }
}

// List — stagger appear
private struct MiniList: View {
    @State private var appeared = false
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<4) { i in
                HStack(spacing: 3) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(mc.opacity(0.22))
                        .frame(width: CGFloat(20 + i * 3), height: 4)
                    Spacer()
                }
                .frame(width: 40)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 8)
                .animation(.spring(response: 0.35, dampingFraction: 0.72).delay(Double(i) * 0.07), value: appeared)
            }
        }
        .onAppear { Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in
            appeared = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { appeared = true }
        }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { appeared = true }}
    }
}

// Badge — pop in/out
private struct MiniBadge: View {
    @State private var show = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 6)
                .fill(mc.opacity(0.15))
                .frame(width: 26, height: 26)
            if show {
                Circle()
                    .fill(mc.opacity(0.42))
                    .frame(width: 11, height: 11)
                    .offset(x: 4, y: -4)
                    .transition(.scale(scale: 0.05).combined(with: .opacity))
            }
        }
        .animation(.spring(bounce: 0.5), value: show)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
            show = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { show = true }
        }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { show = true }}
    }
}

// Spinner — rotating arc
private struct MiniSpinner: View {
    @State private var rotating = false
    var body: some View {
        ZStack {
            Circle().stroke(mc.opacity(0.10), lineWidth: 2).frame(width: 22, height: 22)
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(mc.opacity(0.32), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 22, height: 22)
                .rotationEffect(.degrees(rotating ? 360 : 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotating)
        }
        .onAppear { rotating = true }
    }
}

// Progress — fill animation
private struct MiniProgress: View {
    @State private var progress: CGFloat = 0
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3).fill(mc.opacity(0.10)).frame(width: 40, height: 5)
            RoundedRectangle(cornerRadius: 3).fill(mc.opacity(0.32)).frame(width: 40 * progress, height: 5)
        }
        .animation(.easeInOut(duration: 1.2), value: progress)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in
            progress = 0; DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { progress = 1.0 }
        }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { progress = 1.0 }}
    }
}

// Transition — slide in
private struct MiniTransition: View {
    @State private var shown = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.10)).frame(width: 26, height: 34)
            if shown {
                RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.24)).frame(width: 26, height: 34)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.5), value: shown)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in shown.toggle() }}
    }
}

// Chat — bubbles appearing
private struct MiniChat: View {
    @State private var step = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Circle().fill(mc.opacity(0.18)).frame(width: 8, height: 8)
                RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.15)).frame(width: 20, height: 8)
            }
            .opacity(step >= 1 ? 1 : 0).offset(x: step >= 1 ? 0 : -10)
            HStack(spacing: 2) {
                Spacer()
                RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.24)).frame(width: 16, height: 8)
            }
            .frame(width: 40)
            .opacity(step >= 2 ? 1 : 0).offset(x: step >= 2 ? 0 : 10)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: step)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { _ in
            step = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { step = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { step = 2 }
        }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { step = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { step = 2 }}
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
