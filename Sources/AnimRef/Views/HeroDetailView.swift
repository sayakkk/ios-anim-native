import SwiftUI
import AppKit

// MARK: - Detail Panel (macOS)

struct DetailPanelView: View {
    let item: AnimationItem

    @State private var copiedPrompt     = false
    @State private var copiedCode       = false
    @State private var showCode         = false
    @State private var selectedExample: RealAppExample? = nil
    @State private var propertyValues: [String: Double] = [:]
    @State private var previewTrigger   = UUID()

    private var sliders:  [AnimProperty] { item.properties.filter(\.isSlider) }
    private var infoOnly: [AnimProperty] { item.properties.filter { !$0.isSlider } }
    private var hasSliders: Bool { !sliders.isEmpty }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                // ── TOP CARD: demo preview + sliders ──────────────────
                VStack(spacing: 0) {
                    // Cream preview
                    ZStack(alignment: .bottomLeading) {
                        Group {
                            if hasSliders {
                                InteractiveDemoView(id: item.id, values: propertyValues)
                                    .id(previewTrigger)
                            } else {
                                AnimationDemoView(id: item.id)
                            }
                        }
                        .frame(height: hasSliders ? 345 : 480)

                        Text(item.situationCategory)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(Color.textSecondary)
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.white.opacity(0.88))
                            .clipShape(Capsule())
                            .padding(14)
                    }
                    .background(Color(red: 0.97, green: 0.97, blue: 0.96))

                    // Slider rows
                    if hasSliders {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(sliders, id: \.key) { prop in
                                SliderRow(
                                    prop: prop,
                                    value: Binding(
                                        get: { propertyValues[prop.paramKey ?? ""] ?? prop.defaultValue ?? 0.5 },
                                        set: { propertyValues[prop.paramKey ?? ""] = $0 }
                                    ),
                                    onEditEnd: { previewTrigger = UUID() }
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 20)
                        .padding(.bottom, 18)
                        .background(Color.white)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.cardBorder, lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 22)
                .padding(.top, 18)

                // ── 실시간 AI 프롬프트 (클릭하면 복사) ──────────────
                Button {
                    copyToClipboard(buildDynamicPrompt())
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.65)) { copiedPrompt = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { copiedPrompt = false }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("실시간 AI 프롬프트")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color.textTertiary)
                                .kerning(0.8)
                                .textCase(.uppercase)
                            Spacer()
                            Image(systemName: copiedPrompt ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(copiedPrompt ? Color.textPrimary : Color.textTertiary)
                                .scaleEffect(copiedPrompt ? 0.9 : 1.0)
                                .animation(.spring(response: 0.25, dampingFraction: 0.65), value: copiedPrompt)
                        }
                        Text(buildDynamicPrompt())
                            .font(.system(size: 12))
                            .italic()
                            .foregroundStyle(Color.textSecondary)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(12)
                    .background(copiedPrompt ? Color.textPrimary.opacity(0.04) : Color.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                        copiedPrompt ? Color.textPrimary.opacity(0.25) : Color.cardBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 22)
                .padding(.top, 10)

                // ── Title block ───────────────────────────────────────
                VStack(alignment: .leading, spacing: 6) {
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
                        .padding(.top, 2)
                }
                .padding(.horizontal, 22)
                .padding(.top, 22)
                .padding(.bottom, 8)

                Divider().overlay(Color.divider)
                    .padding(.horizontal, 22)
                    .padding(.top, 12).padding(.bottom, 2)

                // ── Content sections ──────────────────────────────────
                VStack(alignment: .leading, spacing: 26) {

                    ContentSection(title: "언제 써요?") {
                        Text(item.when)
                            .font(.system(size: 14))
                            .foregroundStyle(Color.textSecondary)
                            .lineSpacing(5)
                    }

                    ContentSection(title: "실제 앱에서 보면") {
                        VStack(alignment: .leading, spacing: 12) {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 10) {
                                    ForEach(item.realApps, id: \.name) { example in
                                        AppExampleTile(
                                            text: example.name,
                                            isSelected: selectedExample?.name == example.name
                                        ) {
                                            withAnimation(.spring(response: 0.30, dampingFraction: 0.78)) {
                                                selectedExample = selectedExample?.name == example.name ? nil : example
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                            if let ex = selectedExample {
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("[\(ex.name)] 실제로 쓰이는 값")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Color.textTertiary)
                                        .textCase(.uppercase).kerning(0.8)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        Text(ex.code)
                                            .font(.system(size: 12, design: .monospaced))
                                            .foregroundStyle(Color.textSecondary)
                                            .padding(12)
                                    }
                                    .background(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.cardBorder, lineWidth: 1))
                                    HStack(alignment: .top, spacing: 6) {
                                        Image(systemName: "info.circle").font(.system(size: 11)).foregroundStyle(Color.textTertiary)
                                        Text(ex.note).font(.system(size: 12)).foregroundStyle(Color.textSecondary).lineSpacing(3)
                                    }
                                }
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                    }

                    if !infoOnly.isEmpty {
                        ContentSection(title: "세부조절 옵션") {
                            VStack(spacing: 0) {
                                ForEach(infoOnly, id: \.key) { PropRow(prop: $0) }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.80)) { showCode.toggle() }
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
                                    copyToClipboard(item.swiftui)
                                    withAnimation { copiedCode = true }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.44) {
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
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 60)
            }
        }
        .background(Color.appBg)
        .onAppear { initPropertyValues() }
    }

    // MARK: - Helpers

    private func initPropertyValues() {
        var values: [String: Double] = [:]
        for prop in item.properties {
            if let key = prop.paramKey, let def = prop.defaultValue { values[key] = def }
        }
        propertyValues = values
    }

    private func buildDynamicPrompt() -> String {
        guard hasSliders else { return item.prompt }
        var result = item.prompt
        // Replace [number] placeholders one-by-one in slider order (first match only each time)
        for prop in sliders {
            guard let key = prop.paramKey, let val = propertyValues[key] else { continue }
            let formatted = String(format: prop.format, val)
            if let range = result.range(of: "\\[[0-9.]+\\]", options: .regularExpression) {
                result.replaceSubrange(range, with: formatted)
            }
        }
        return result
    }

    private func copyToClipboard(_ text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

// MARK: - Slider row

private struct SliderRow: View {
    let prop: AnimProperty
    @Binding var value: Double
    var onEditEnd: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text(prop.label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                Text(prop.key)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.textTertiary)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.appBg)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                Spacer()
                Text(String(format: prop.format, value))
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color.textSecondary)
                    .frame(minWidth: 38, alignment: .trailing)
            }
            Slider(
                value: $value,
                in: (prop.minValue ?? 0)...(prop.maxValue ?? 1),
                step: prop.step ?? 0.01
            ) {
                EmptyView()
            } minimumValueLabel: {
                Text(String(format: prop.format, prop.minValue ?? 0))
                    .font(.system(size: 9)).foregroundStyle(Color.textTertiary)
            } maximumValueLabel: {
                Text(String(format: prop.format, prop.maxValue ?? 1))
                    .font(.system(size: 9)).foregroundStyle(Color.textTertiary)
            } onEditingChanged: { editing in
                if !editing { onEditEnd() }
            }
            .tint(Color.chipActive)
            // Description — deliberately subtle
            Text(prop.desc)
                .font(.system(size: 10))
                .foregroundStyle(Color.textTertiary.opacity(0.65))
                .lineSpacing(1)
        }
    }
}

// MARK: - Interactive Demo View

private let liveInk      = Color(red: 0.13, green: 0.12, blue: 0.11)
private let liveInkLight = Color(red: 0.13, green: 0.12, blue: 0.11).opacity(0.18)
private let liveSW: CGFloat = 2.0

private func liveCircle(_ size: CGFloat = 36) -> some View {
    Circle().stroke(liveInk, lineWidth: liveSW).frame(width: size, height: size)
}

struct InteractiveDemoView: View {
    let id: String
    let values: [String: Double]

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)
            Group {
                switch id {
                case "spring":
                    LiveSpringDemo(
                        response: values["response"] ?? 0.4,
                        dampingFraction: values["dampingFraction"] ?? 0.7
                    )
                case "bouncy":
                    LiveBouncyDemo(extraBounce: values["extraBounce"] ?? 0.25)
                case "fade":
                    LiveFadeDemo(duration: values["duration"] ?? 0.3)
                case "ease":
                    LiveEaseDemo(duration: values["duration"] ?? 0.3)
                case "linear":
                    LiveLinearDemo(duration: values["duration"] ?? 1.0)
                case "scale":
                    LiveScaleDemo(
                        scaleAmount: values["scaleEffect"] ?? 0.92,
                        response: values["response"] ?? 0.3,
                        dampingFraction: values["dampingFraction"] ?? 0.6
                    )
                case "shake":
                    LiveShakeDemo(
                        amplitude: values["amplitude"] ?? 12,
                        shakeDuration: values["shakeDuration"] ?? 0.08
                    )
                case "pulse":
                    LivePulseDemo(
                        scaleMax: values["scaleMax"] ?? 1.15,
                        cycleDuration: values["cycleDuration"] ?? 1.2
                    )
                case "stagger":
                    LiveStaggerDemo(delayInterval: values["delayInterval"] ?? 0.06)
                case "wave":
                    LiveWaveDemo(delayInterval: values["delayInterval"] ?? 0.1)
                case "pop-in":
                    LivePopInDemo(
                        startScale: values["startScale"] ?? 0.1,
                        bounce: values["bounce"] ?? 0.5
                    )
                case "rubber-band":
                    LiveRubberBandDemo(
                        resistanceFactor: values["resistanceFactor"] ?? 3.0,
                        dampingFraction: values["dampingFraction"] ?? 0.6
                    )
                default:
                    liveCircle()
                }
            }
            .scaleEffect(1.1)
        }
    }
}

// MARK: - Parameterized live demos

private let errorRed = Color(red: 0.88, green: 0.20, blue: 0.18)

private struct LiveSpringDemo: View {
    let response: Double
    let dampingFraction: Double
    @State private var up = false
    var body: some View {
        liveCircle()
            .offset(y: up ? -28 : 28)
            .animation(.spring(response: response, dampingFraction: dampingFraction), value: up)
            .onAppear {
                let interval = max(response * 2.5, 0.7)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { up.toggle() }
                Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in up.toggle() }
            }
    }
}

private struct LiveBouncyDemo: View {
    let extraBounce: Double
    @State private var big = false
    var body: some View {
        liveCircle()
            .scaleEffect(big ? 1.55 : 0.45)
            .animation(.bouncy(duration: 0.5, extraBounce: extraBounce), value: big)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { big.toggle() }
                Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in big.toggle() }
            }
    }
}

private struct LiveFadeDemo: View {
    let duration: Double
    @State private var visible = false
    var body: some View {
        liveCircle()
            .opacity(visible ? 1 : 0.05)
            .animation(.easeInOut(duration: duration), value: visible)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { visible.toggle() }
                Timer.scheduledTimer(withTimeInterval: duration + 0.5, repeats: true) { _ in visible.toggle() }
            }
    }
}

private struct LiveEaseDemo: View {
    let duration: Double
    @State private var moved = false
    var body: some View {
        ZStack {
            Rectangle().fill(liveInkLight).frame(width: 72, height: liveSW)
            liveCircle()
                .offset(x: moved ? 28 : -28)
                .animation(.easeInOut(duration: duration), value: moved)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { moved.toggle() }
            Timer.scheduledTimer(withTimeInterval: duration + 0.4, repeats: true) { _ in moved.toggle() }
        }
    }
}

private struct LiveLinearDemo: View {
    let duration: Double
    @State private var rotating = false
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.72)
            .stroke(liveInk, style: StrokeStyle(lineWidth: liveSW, lineCap: .round))
            .frame(width: 38, height: 38)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: rotating)
            .onAppear { rotating = true }
    }
}

private struct LiveScaleDemo: View {
    let scaleAmount: Double
    let response: Double
    let dampingFraction: Double
    @State private var pressed = false
    var body: some View {
        ZStack {
            Circle().stroke(liveInk, lineWidth: liveSW).frame(width: 46, height: 46)
                .scaleEffect(pressed ? scaleAmount : 1.0)
                .animation(.spring(response: response, dampingFraction: dampingFraction), value: pressed)
            if pressed {
                Circle().fill(liveInkLight).frame(width: 42, height: 42).transition(.opacity)
            }
        }
        .onAppear {
            func pulse() {
                pressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { pressed = false }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { pulse() }
            Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { _ in pulse() }
        }
    }
}

private struct LiveShakeDemo: View {
    let amplitude: Double
    let shakeDuration: Double
    @State private var trigger = false
    @State private var isError = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(errorRed.opacity(isError ? 0.10 : 0))
                .frame(width: 80, height: 44)
            RoundedRectangle(cornerRadius: 8)
                .stroke(isError ? errorRed : liveInk, lineWidth: isError ? 1.8 : liveSW)
                .frame(width: 80, height: 44)
            HStack(spacing: 6) {
                ForEach(0..<5) { _ in
                    Circle().fill(isError ? errorRed : liveInk).frame(width: 6, height: 6).opacity(0.55)
                }
            }
        }
        .keyframeAnimator(initialValue: 0.0, trigger: trigger) { v, x in v.offset(x: x) } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(0,                        duration: 0.04)
                LinearKeyframe(-amplitude,               duration: shakeDuration)
                LinearKeyframe(amplitude,                duration: shakeDuration)
                LinearKeyframe(-amplitude * 0.65,        duration: shakeDuration)
                LinearKeyframe(amplitude * 0.65,         duration: shakeDuration)
                LinearKeyframe(0,                        duration: shakeDuration * 0.6)
            }
        }
        .onAppear {
            func shake() {
                isError = true; trigger.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isError = false }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shake() }
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in shake() }
        }
    }
}

private struct LivePulseDemo: View {
    let scaleMax: Double
    let cycleDuration: Double
    @State private var pulsing = false
    var body: some View {
        ZStack {
            Circle().fill(liveInk.opacity(pulsing ? 0.04 : 0.14)).frame(width: 64, height: 64)
                .scaleEffect(pulsing ? scaleMax + 0.18 : 0.82)
            Circle().fill(liveInk.opacity(pulsing ? 0.28 : 0.62)).frame(width: 38, height: 38)
                .scaleEffect(pulsing ? scaleMax : 0.88)
        }
        .animation(.easeInOut(duration: cycleDuration).repeatForever(autoreverses: true), value: pulsing)
        .onAppear { pulsing = true }
    }
}

private struct LiveStaggerDemo: View {
    let delayInterval: Double
    @State private var appeared = false
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { i in
                liveCircle(22)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(
                        .spring(response: 0.38, dampingFraction: 0.70)
                            .delay(Double(i) * delayInterval),
                        value: appeared
                    )
            }
        }
        .onAppear {
            let cycle = Double(4) * delayInterval + 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { appeared = true }
            Timer.scheduledTimer(withTimeInterval: cycle, repeats: true) { _ in
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { appeared = true }
            }
        }
    }
}

private struct LiveWaveDemo: View {
    let delayInterval: Double
    @State private var animating = false
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .stroke(liveInk, lineWidth: liveSW)
                    .frame(width: 6, height: animating ? 34 : 8)
                    .animation(
                        .easeInOut(duration: 0.44)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * delayInterval),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

private struct LivePopInDemo: View {
    let startScale: Double
    let bounce: Double
    @State private var show = false
    var body: some View {
        ZStack {
            if show {
                liveCircle()
                    .transition(.scale(scale: startScale).combined(with: .opacity))
            }
        }
        .animation(.spring(bounce: bounce), value: show)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { show = true }
            Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
                show = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { show = true }
            }
        }
    }
}

private struct LiveRubberBandDemo: View {
    let resistanceFactor: Double
    let dampingFraction: Double
    @State private var offset: CGFloat = 0
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(liveInkLight).frame(width: liveSW, height: 30)
            liveCircle().offset(y: offset)
        }
        .onAppear {
            func snap() {
                let pull = 32.0 / resistanceFactor * 3
                withAnimation(.linear(duration: 0.5)) { offset = pull }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.52) {
                    withAnimation(.spring(response: 0.38, dampingFraction: dampingFraction)) { offset = 0 }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { snap() }
            Timer.scheduledTimer(withTimeInterval: 2.2, repeats: true) { _ in snap() }
        }
    }
}

// MARK: - App example tile (animated mini scene in border frame)

private struct AppExampleTile: View {
    let text: String
    var isSelected: Bool = false
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .center, spacing: 7) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(Color(red: 0.97, green: 0.97, blue: 0.96))
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(isSelected ? Color.textSecondary : Color.cardBorder,
                                lineWidth: isSelected ? 1.5 : 1)
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
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(width: 72, alignment: .top)
            }
            .frame(width: 76, height: 98, alignment: .top)
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.70), value: isSelected)
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

private struct MiniHeart: View {
    @State private var popped = false
    var body: some View {
        Image(systemName: "heart.fill").font(.system(size: 20)).foregroundStyle(mc.opacity(0.25))
            .scaleEffect(popped ? 1.35 : 0.85)
            .animation(.spring(response: 0.28, dampingFraction: 0.52), value: popped)
            .onAppear { Timer.scheduledTimer(withTimeInterval: 1.12, repeats: true) { _ in
                popped = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) { popped = false }
            }}
    }
}
private struct MiniButton: View {
    @State private var pressed = false
    var body: some View {
        RoundedRectangle(cornerRadius: 5).fill(mc.opacity(0.18)).frame(width: 38, height: 16)
            .scaleEffect(pressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.22, dampingFraction: 0.55), value: pressed)
            .onAppear { Timer.scheduledTimer(withTimeInterval: 1.12, repeats: true) { _ in
                pressed = true; DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { pressed = false }
            }}
    }
}
private struct MiniPin: View {
    @State private var trigger = false; @State private var err = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<4) { _ in Circle().fill(err ? Color(red: 0.88, green: 0.20, blue: 0.18).opacity(0.6) : mc.opacity(0.28)).frame(width: 7, height: 7) }
        }
        .keyframeAnimator(initialValue: 0.0, trigger: trigger) { v, x in v.offset(x: x) } keyframes: { _ in
            KeyframeTrack { LinearKeyframe(0, duration: 0.03); LinearKeyframe(-8, duration: 0.06); LinearKeyframe(8, duration: 0.06); LinearKeyframe(-5, duration: 0.05); LinearKeyframe(5, duration: 0.05); LinearKeyframe(0, duration: 0.04) }
        }
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
            err = true; trigger.toggle(); DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { err = false }
        }}
    }
}
private struct MiniWaveform: View {
    @State private var on = false
    let bases: [CGFloat] = [0.08, 0.18, 0.06, 0.16, 0.10, 0.14, 0.08]
    var body: some View {
        HStack(alignment: .center, spacing: 3) {
            ForEach(Array(bases.enumerated()), id: \.offset) { i, b in
                RoundedRectangle(cornerRadius: 2).fill(mc.opacity(0.28))
                    .frame(width: 4, height: on ? CGFloat.random(in: 8...26) : b * 40 + 5)
                    .animation(.easeInOut(duration: Double.random(in: 0.3...0.55)).repeatForever(autoreverses: true).delay(Double(i) * 0.08), value: on)
            }
        }
        .onAppear { on = true }
    }
}
private struct MiniPullRefresh: View {
    @State private var pulling = false
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: "arrow.clockwise").font(.system(size: 9, weight: .semibold))
                .foregroundStyle(mc.opacity(pulling ? 0.45 : 0.15))
                .rotationEffect(.degrees(pulling ? 360 : 0))
                .animation(.linear(duration: 0.7).repeatForever(autoreverses: false), value: pulling)
            VStack(spacing: 3) { ForEach(0..<3) { i in RoundedRectangle(cornerRadius: 2).fill(mc.opacity(0.15)).frame(width: CGFloat(28 - i * 4), height: 4) } }
                .offset(y: pulling ? -4 : 0)
                .animation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: pulling)
        }
        .onAppear { pulling = true }
    }
}
private struct MiniBottomSheet: View {
    @State private var shown = false
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 4).stroke(mc.opacity(0.15), lineWidth: 1).frame(width: 34, height: 42)
            if shown { RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.20)).frame(width: 34, height: 20).transition(.move(edge: .bottom).combined(with: .opacity)) }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: shown)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in shown.toggle() }}
    }
}
private struct MiniList: View {
    @State private var appeared = false
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(0..<4) { i in
                HStack(spacing: 3) { RoundedRectangle(cornerRadius: 2).fill(mc.opacity(0.22)).frame(width: CGFloat(20 + i * 3), height: 4); Spacer() }
                    .frame(width: 40).opacity(appeared ? 1 : 0).offset(y: appeared ? 0 : 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.72).delay(Double(i) * 0.07), value: appeared)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.76, repeats: true) { _ in appeared = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { appeared = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) { appeared = true }
        }
    }
}
private struct MiniBadge: View {
    @State private var show = false
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 6).fill(mc.opacity(0.15)).frame(width: 26, height: 26)
            if show { Circle().fill(mc.opacity(0.42)).frame(width: 11, height: 11).offset(x: 4, y: -4).transition(.scale(scale: 0.05).combined(with: .opacity)) }
        }
        .animation(.spring(bounce: 0.5), value: show)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.28, repeats: true) { _ in show = false; DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { show = true } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { show = true }
        }
    }
}
private struct MiniSpinner: View {
    @State private var rotating = false
    var body: some View {
        ZStack {
            Circle().stroke(mc.opacity(0.10), lineWidth: 2).frame(width: 22, height: 22)
            Circle().trim(from: 0, to: 0.7).stroke(mc.opacity(0.32), style: StrokeStyle(lineWidth: 2, lineCap: .round)).frame(width: 22, height: 22)
                .rotationEffect(.degrees(rotating ? 360 : 0))
                .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: rotating)
        }
        .onAppear { rotating = true }
    }
}
private struct MiniProgress: View {
    @State private var progress: CGFloat = 0
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3).fill(mc.opacity(0.10)).frame(width: 40, height: 5)
            RoundedRectangle(cornerRadius: 3).fill(mc.opacity(0.32)).frame(width: 40 * progress, height: 5)
        }
        .animation(.easeInOut(duration: 1.2), value: progress)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in progress = 0; DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { progress = 1.0 } }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { progress = 1.0 }
        }
    }
}
private struct MiniTransition: View {
    @State private var shown = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.10)).frame(width: 26, height: 34)
            if shown { RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.24)).frame(width: 26, height: 34).transition(.move(edge: .trailing).combined(with: .opacity)) }
        }
        .animation(.easeInOut(duration: 0.5), value: shown)
        .onAppear { Timer.scheduledTimer(withTimeInterval: 1.28, repeats: true) { _ in shown.toggle() }}
    }
}
private struct MiniChat: View {
    @State private var step = 0
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) { Circle().fill(mc.opacity(0.18)).frame(width: 8, height: 8); RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.15)).frame(width: 20, height: 8) }
                .opacity(step >= 1 ? 1 : 0).offset(x: step >= 1 ? 0 : -10)
            HStack(spacing: 2) { Spacer(); RoundedRectangle(cornerRadius: 4).fill(mc.opacity(0.24)).frame(width: 16, height: 8) }
                .frame(width: 40).opacity(step >= 2 ? 1 : 0).offset(x: step >= 2 ? 0 : 10)
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.75), value: step)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.92, repeats: true) { _ in
                step = 0; DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { step = 1 }; DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) { step = 2 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { step = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.72) { step = 2 }
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
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
