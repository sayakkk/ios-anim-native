import SwiftUI

// MARK: - Demo dispatcher

struct AnimationDemoView: View {
    let id: String

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.04, blue: 0.02)
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
            default:              DefaultDemo()
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - Accent color helper
private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)
private func dot(_ size: CGFloat = 38, radius: CGFloat = 19) -> some View {
    Circle()
        .fill(
            LinearGradient(colors: [accent, Color(red: 0.88, green: 0.36, blue: 0.16)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .frame(width: size, height: size)
        .shadow(color: accent.opacity(0.5), radius: 8, y: 4)
}

// MARK: - Scale
struct ScaleDemo: View {
    @State private var pressed = false
    var body: some View {
        dot()
            .scaleEffect(pressed ? 0.88 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: pressed)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.6, repeats: true) { _ in
                    pressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { pressed = false }
                }
            }
    }
}

// MARK: - Spring
struct SpringDemo: View {
    @State private var up = false
    var body: some View {
        dot()
            .offset(y: up ? -28 : 28)
            .animation(.spring(response: 0.45, dampingFraction: 0.55), value: up)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in up.toggle() }
            }
    }
}

// MARK: - Bouncy
struct BouncyDemo: View {
    @State private var big = false
    var body: some View {
        dot()
            .scaleEffect(big ? 1.5 : 0.5)
            .animation(.bouncy(duration: 0.5, extraBounce: 0.3), value: big)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in big.toggle() }
            }
    }
}

// MARK: - Fade
struct FadeDemo: View {
    @State private var visible = false
    var body: some View {
        dot()
            .opacity(visible ? 1 : 0.05)
            .animation(.easeInOut(duration: 0.8), value: visible)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.4, repeats: true) { _ in visible.toggle() }
            }
    }
}

// MARK: - Slide
struct SlideDemo: View {
    @State private var shown = false
    var body: some View {
        ZStack {
            if shown {
                dot()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.72), value: shown)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in shown.toggle() }
        }
    }
}

// MARK: - Shake
struct ShakeDemo: View {
    @State private var errorTrigger = false
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color(red: 0.12, green: 0.10, blue: 0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(errorTrigger ? Color.red.opacity(0.7) : Color.white.opacity(0.08), lineWidth: 1.5)
            )
            .frame(width: 80, height: 32)
            .overlay(Text("••••••").font(.system(size: 16)).foregroundStyle(.white.opacity(0.5)))
            .keyframeAnimator(initialValue: 0.0, trigger: errorTrigger) { v, x in
                v.offset(x: x)
            } keyframes: { _ in
                KeyframeTrack {
                    LinearKeyframe(0,    duration: 0.04)
                    LinearKeyframe(-12,  duration: 0.08)
                    LinearKeyframe(12,   duration: 0.08)
                    LinearKeyframe(-8,   duration: 0.07)
                    LinearKeyframe(8,    duration: 0.07)
                    LinearKeyframe(-4,   duration: 0.06)
                    LinearKeyframe(0,    duration: 0.05)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    errorTrigger.toggle()
                }
            }
    }
}

// MARK: - Pulse
struct PulseDemo: View {
    @State private var pulsing = false
    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.2))
                .frame(width: 56, height: 56)
                .scaleEffect(pulsing ? 1.4 : 0.9)
                .opacity(pulsing ? 0.15 : 0.4)
            dot(32)
                .scaleEffect(pulsing ? 1.12 : 0.92)
                .opacity(pulsing ? 1.0 : 0.6)
        }
        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulsing)
        .onAppear { pulsing = true }
    }
}

// MARK: - Stagger
struct StaggerDemo: View {
    @State private var appeared = false

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<4, id: \.self) { i in
                dot(22, radius: 11)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 18)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.7)
                            .delay(Double(i) * 0.08),
                        value: appeared
                    )
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 2.4, repeats: true) { _ in
                appeared = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    appeared = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appeared = true
            }
        }
    }
}

// MARK: - Wave
struct WaveDemo: View {
    @State private var animating = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<5, id: \.self) { i in
                Capsule()
                    .fill(
                        LinearGradient(colors: [accent, Color(red: 0.88, green: 0.36, blue: 0.16)],
                                       startPoint: .top, endPoint: .bottom)
                    )
                    .frame(width: 5, height: animating ? 32 : 7)
                    .animation(
                        .easeInOut(duration: 0.45)
                            .repeatForever(autoreverses: true)
                            .delay(Double(i) * 0.1),
                        value: animating
                    )
                    .shadow(color: accent.opacity(0.4), radius: 3)
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
                dot()
                    .transition(
                        .scale(scale: 0.05).combined(with: .opacity)
                    )
            }
        }
        .animation(.spring(bounce: 0.55), value: show)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1.8, repeats: true) { _ in
                show = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    show = true
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { show = true }
        }
    }
}

// MARK: - Rubber Band
struct RubberBandDemo: View {
    @State private var offset: CGFloat = 0
    @State private var stretching = false

    var body: some View {
        dot()
            .offset(y: offset)
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                    // Simulate drag then release
                    withAnimation(.linear(duration: 0.5)) {
                        offset = 35 // drag down (rubber band effect simulated)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.55)) {
                            offset = 0
                        }
                    }
                }
            }
    }
}

// MARK: - Default
struct DefaultDemo: View {
    var body: some View { dot() }
}
