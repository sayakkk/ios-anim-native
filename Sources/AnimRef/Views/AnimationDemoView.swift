import SwiftUI

// MARK: - Demo dispatcher

struct AnimationDemoView: View {
    let id: String

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.97, blue: 0.96)  // off-white thumbnail bg
            Group {
                switch id {
                case "scale":         ScaleDemo()
                case "spring":        SpringDemo()
                case "bouncy":        BouncyDemo()
                case "fade":          FadeDemo()
                case "slide":         SlideDemo()
                case "shake":         ShakeDemo()
                case "pulse":         PulseDemo()
                case "stagger":       StaggerDemo()
                case "wave":          WaveDemo()
                case "pop-in":        PopInDemo()
                case "rubber-band":   RubberBandDemo()
                case "ease":          EaseDemo()
                case "linear":        LinearDemo()
                default:              DefaultDemo()
                }
            }
            .scaleEffect(1.2)
        }
    }
}

// MARK: - Shared style

private let ink = Color(red: 0.13, green: 0.12, blue: 0.11)
private let inkLight = Color(red: 0.13, green: 0.12, blue: 0.11).opacity(0.18)
private let strokeW: CGFloat = 2.0

private func circle(_ size: CGFloat = 36) -> some View {
    Circle()
        .stroke(ink, lineWidth: strokeW)
        .frame(width: size, height: size)
}

private func rect(_ w: CGFloat = 52, _ h: CGFloat = 36, r: CGFloat = 8) -> some View {
    RoundedRectangle(cornerRadius: r)
        .stroke(ink, lineWidth: strokeW)
        .frame(width: w, height: h)
}

// MARK: - Scale
struct ScaleDemo: View {
    @State private var pressed = false
    var body: some View {
        ZStack {
            Circle()
                .stroke(ink, lineWidth: strokeW)
                .frame(width: 46, height: 46)
                .scaleEffect(pressed ? 0.82 : 1.0)
                .animation(.spring(response: 0.28, dampingFraction: 0.52), value: pressed)
            if pressed {
                // inner fill hint
                Circle()
                    .fill(inkLight)
                    .frame(width: 42, height: 42)
                    .transition(.opacity)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.28, repeats: true) { _ in
                pressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { pressed = false }
            }
        }
    }
}

// MARK: - Spring
struct SpringDemo: View {
    @State private var up = false
    var body: some View {
        circle()
            .offset(y: up ? -26 : 26)
            .animation(.spring(response: 0.42, dampingFraction: 0.52), value: up)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in up.toggle() }
            }
    }
}

// MARK: - Bouncy
struct BouncyDemo: View {
    @State private var big = false
    var body: some View {
        circle()
            .scaleEffect(big ? 1.55 : 0.45)
            .animation(.bouncy(duration: 0.5, extraBounce: 0.28), value: big)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in big.toggle() }
            }
    }
}

// MARK: - Fade
struct FadeDemo: View {
    @State private var visible = false
    var body: some View {
        circle()
            .opacity(visible ? 1 : 0.05)
            .animation(.easeInOut(duration: 0.9), value: visible)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in visible.toggle() }
            }
    }
}

// MARK: - Slide
struct SlideDemo: View {
    @State private var shown = false
    var body: some View {
        ZStack {
            // Track line
            Rectangle()
                .fill(inkLight)
                .frame(width: strokeW, height: 40)
                .offset(y: 10)

            if shown {
                circle()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.38, dampingFraction: 0.70), value: shown)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in shown.toggle() }
        }
    }
}

// MARK: - Shake
private let errorRed = Color(red: 0.88, green: 0.20, blue: 0.18)

struct ShakeDemo: View {
    @State private var trigger  = false
    @State private var isError  = false

    var body: some View {
        ZStack {
            // subtle red bg flash
            RoundedRectangle(cornerRadius: 8)
                .fill(errorRed.opacity(isError ? 0.10 : 0))
                .frame(width: 80, height: 44)
                .animation(.easeOut(duration: 0.25), value: isError)

            // field outline
            RoundedRectangle(cornerRadius: 8)
                .stroke(isError ? errorRed : ink, lineWidth: isError ? 1.8 : strokeW)
                .frame(width: 80, height: 44)
                .animation(.easeOut(duration: 0.18), value: isError)

            // dots
            HStack(spacing: 6) {
                ForEach(0..<5) { _ in
                    Circle()
                        .fill(isError ? errorRed : ink)
                        .frame(width: 6, height: 6)
                        .opacity(0.55)
                }
            }
            .animation(.easeOut(duration: 0.18), value: isError)
        }
        .keyframeAnimator(initialValue: 0.0, trigger: trigger) { v, x in
            v.offset(x: x)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(0,    duration: 0.04)
                LinearKeyframe(-11,  duration: 0.07)
                LinearKeyframe(11,   duration: 0.07)
                LinearKeyframe(-7,   duration: 0.06)
                LinearKeyframe(7,    duration: 0.06)
                LinearKeyframe(-3,   duration: 0.05)
                LinearKeyframe(0,    duration: 0.05)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.76, repeats: true) { _ in
                isError = true
                trigger.toggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.44) {
                    isError = false
                }
            }
        }
    }
}

// MARK: - Pulse (filled — breathing volume feel)
struct PulseDemo: View {
    @State private var pulsing = false
    var body: some View {
        ZStack {
            // outer halo
            Circle()
                .fill(ink.opacity(pulsing ? 0.04 : 0.14))
                .frame(width: 64, height: 64)
                .scaleEffect(pulsing ? 1.38 : 0.82)

            // main filled circle
            Circle()
                .fill(ink.opacity(pulsing ? 0.28 : 0.62))
                .frame(width: 38, height: 38)
                .scaleEffect(pulsing ? 1.14 : 0.88)
        }
        .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: pulsing)
        .onAppear { pulsing = true }
    }
}

// MARK: - Stagger
struct StaggerDemo: View {
    @State private var appeared = false
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { i in
                circle(22)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)
                    .animation(
                        .spring(response: 0.38, dampingFraction: 0.70)
                            .delay(Double(i) * 0.08),
                        value: appeared
                    )
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.92, repeats: true) { _ in
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) { appeared = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { appeared = true }
        }
    }
}

// MARK: - Wave
struct WaveDemo: View {
    @State private var animating = false
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<5, id: \.self) { i in
                RoundedRectangle(cornerRadius: 2)
                    .stroke(ink, lineWidth: strokeW)
                    .frame(width: 6, height: animating ? 34 : 8)
                    .animation(
                        .easeInOut(duration: 0.44)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.09),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
    }
}

// MARK: - Pop In
struct PopInDemo: View {
    @State private var show = false
    var body: some View {
        ZStack {
            if show {
                circle()
                    .transition(
                        .scale(scale: 0.05).combined(with: .opacity)
                    )
            }
        }
        .animation(.spring(bounce: 0.52), value: show)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.44, repeats: true) { _ in
                show = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.36) { show = true }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { show = true }
        }
    }
}

// MARK: - Rubber Band
struct RubberBandDemo: View {
    @State private var offset: CGFloat = 0
    var body: some View {
        VStack(spacing: 0) {
            // Dotted track
            Rectangle()
                .fill(inkLight)
                .frame(width: strokeW, height: 30)
            circle()
                .offset(y: offset)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
                withAnimation(.linear(duration: 0.5)) { offset = 32 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.44) {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.52)) { offset = 0 }
                }
            }
        }
    }
}

// MARK: - Ease
struct EaseDemo: View {
    @State private var moved = false
    var body: some View {
        ZStack {
            // Track
            Rectangle()
                .fill(inkLight)
                .frame(width: 72, height: strokeW)
            circle()
                .offset(x: moved ? 28 : -28)
                .animation(.easeInOut(duration: 0.82), value: moved)
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: true) { _ in moved.toggle() }
        }
    }
}

// MARK: - Linear
struct LinearDemo: View {
    @State private var rotating = false
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.72)
            .stroke(
                ink,
                style: StrokeStyle(lineWidth: strokeW, lineCap: .round)
            )
            .frame(width: 38, height: 38)
            .rotationEffect(.degrees(rotating ? 360 : 0))
            .animation(
                .linear(duration: 1.1).repeatForever(autoreverses: false),
                value: rotating
            )
            .onAppear { rotating = true }
    }
}

// MARK: - Default
struct DefaultDemo: View {
    var body: some View { circle() }
}
