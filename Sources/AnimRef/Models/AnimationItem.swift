import SwiftUI

// MARK: - Kind

enum AnimKind { case basic, combo }

// MARK: - Prop Kind

enum PropKind {
    case info
    case picker(key: String, options: [(label: String, value: Double)], defaultIndex: Int)
    case toggle(key: String, defaultOn: Bool)
    case preset(key: String, options: [(label: String, values: [String: Double])], defaultIndex: Int)
}

// MARK: - Data Model

struct AnimProperty {
    let label: String
    let key: String
    let desc: String
    var kind: PropKind = .info
    // Slider fields (nil = not a slider)
    var paramKey: String? = nil
    var minValue: Double? = nil
    var maxValue: Double? = nil
    var defaultValue: Double? = nil
    var step: Double? = nil
    var format: String = "%.2f"

    var isSlider: Bool {
        paramKey != nil && minValue != nil && maxValue != nil && defaultValue != nil
    }
    var isInteractive: Bool {
        if isSlider { return true }
        switch kind {
        case .info: return false
        default: return true
        }
    }
}

struct RealAppExample {
    let name: String
    let code: String
    let note: String
}

struct AnimationItem: Identifiable {
    let kind: AnimKind
    let id: String
    let name: String
    let situationCategory: String
    let feel: String
    let feelDesc: String
    let when: String
    let realApps: [RealAppExample]
    let properties: [AnimProperty]
    let swiftui: String
    let prompt: String
}

// MARK: - Seed Data

struct AnimationData {
    static let basics: [AnimationItem] = all.filter { $0.kind == .basic }
    static let combos: [AnimationItem] = all.filter { $0.kind == .combo }

    static let all: [AnimationItem] = [

        // ─── 기본 ────────────────────────────────────────────

        AnimationItem(
            kind: .basic,
            id: "spring",
            name: "Spring",
            situationCategory: "📋 리스트 · 등장",
            feel: "통통 튀며 제자리 잡는 느낌",
            feelDesc: "iOS 앱 어디서나 느껴지는 살아있는 탄성감",
            when: "모든 곳. iOS 앱에서 기본으로 쓰이는 애니메이션",
            realApps: [
                RealAppExample(
                    name: "iOS 화면전환",
                    code: ".spring(response: 0.45,\n dampingFraction: 0.94)",
                    note: "NavigationStack push/pop. 거의 안 튀고 매끄럽게 착지"
                ),
                RealAppExample(
                    name: "앱 폴더 열고 닫기",
                    code: ".spring(response: 0.38,\n dampingFraction: 0.68)",
                    note: "폴더 확대/축소 시 살짝 통통 튀는 효과"
                ),
                RealAppExample(
                    name: "위젯 이동",
                    code: ".spring(response: 0.48,\n dampingFraction: 0.80)",
                    note: "드래그 후 그리드 착지, 주변 위젯이 자리 비켜줄 때"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "빠르기", key: "response:",
                    desc: "낮을수록 빠름. 0.3~0.5. 0.3이면 빠릿, 0.6이면 묵직",
                    paramKey: "response", minValue: 0.1, maxValue: 1.0, defaultValue: 0.4, step: 0.01
                ),
                AnimProperty(
                    label: "탄성", key: "dampingFraction:",
                    desc: "1.0이면 안 튐, 0.5면 많이 통통 튐. 보통 0.6~0.8",
                    paramKey: "dampingFraction", minValue: 0.1, maxValue: 1.0, defaultValue: 0.7, step: 0.01
                ),
                AnimProperty(
                    label: "빠른 설정", key: ".bouncy / .smooth / .snappy",
                    desc: "탭하면 response/탄성 값이 같이 바뀜",
                    kind: .preset(key: "__presetSpring", options: [
                        (label: ".bouncy", values: ["response": 0.35, "dampingFraction": 0.52]),
                        (label: ".smooth", values: ["response": 0.40, "dampingFraction": 0.92]),
                        (label: ".snappy", values: ["response": 0.22, "dampingFraction": 0.87]),
                    ], defaultIndex: -1)
                ),
            ],
            swiftui: """
// iOS 17+ 간단 버전
.animation(.bouncy, value: state)
.animation(.smooth, value: state)
.animation(.snappy, value: state)

// 세밀 조절
.animation(
    .spring(response: 0.4, dampingFraction: 0.7),
    value: state
)
""",
            prompt: "SwiftUI [뷰]의 변화에 spring 애니메이션을 적용해줘. response [0.4], dampingFraction [0.7]로."
        ),

        AnimationItem(
            kind: .basic,
            id: "bouncy",
            name: "Bouncy",
            situationCategory: "📋 리스트 · 등장",
            feel: "고무공처럼 통통통 튀는 느낌",
            feelDesc: "스프링보다 더 과장되게 튀어오르는, 재미있고 생동감 있는 움직임",
            when: "팝업 등장, 버튼 눌림 후 원상복귀",
            realApps: [
                RealAppExample(
                    name: "Duolingo 캐릭터",
                    code: ".bouncy(duration: 0.4,\n extraBounce: 0.30)",
                    note: "정답 맞출 때 캐릭터가 3번 통통 튀는 효과"
                ),
                RealAppExample(
                    name: "어린이 앱 인터랙션",
                    code: ".bouncy(duration: 0.35,\n extraBounce: 0.25)",
                    note: "탭할 때마다 과장된 bounce로 재미 표현"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "기본 바운스", key: ".bouncy",
                    desc: "iOS 17+. 이거 하나면 충분"
                ),
                AnimProperty(
                    label: "바운스 강도", key: "extraBounce:",
                    desc: "0이면 기본, 0.4면 더 많이 통통. 0~0.5",
                    paramKey: "extraBounce", minValue: 0.0, maxValue: 0.5, defaultValue: 0.25, step: 0.01
                ),
            ],
            swiftui: """
// iOS 17+
.animation(.bouncy, value: isExpanded)

// 더 통통
.animation(
    .bouncy(duration: 0.4, extraBounce: 0.25),
    value: isExpanded
)
""",
            prompt: "SwiftUI [뷰]에 .bouncy 애니메이션을 적용해서 고무공처럼 통통 튀는 느낌을 줘. extraBounce [0.25]로."
        ),

        AnimationItem(
            kind: .basic,
            id: "fade",
            name: "Fade",
            situationCategory: "📱 화면 전환",
            feel: "스르르 나타나거나 사라지는 느낌",
            feelDesc: "요소가 서서히 보이거나 사라지는, 가장 자연스럽고 무난한 전환",
            when: "화면 전환, 오버레이, 토스트 메시지",
            realApps: [
                RealAppExample(
                    name: "잠금 해제 후 홈",
                    code: ".easeInOut(duration: 0.35)",
                    note: "잠금화면 fade out → 홈화면 fade in 동시에"
                ),
                RealAppExample(
                    name: "사진 로딩 완료",
                    code: ".easeIn(duration: 0.25)",
                    note: "이미지가 로드되며 opacity 0→1로"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "투명도", key: ".opacity(0~1)",
                    desc: "0이면 안 보임, 1이면 완전히 보임"
                ),
                AnimProperty(
                    label: "속도", key: "duration:",
                    desc: "0.2~0.4초가 자연스러움",
                    paramKey: "duration", minValue: 0.1, maxValue: 2.0, defaultValue: 0.3, step: 0.05, format: "%.1f"
                ),
            ],
            swiftui: """
if isVisible {
    Text("안녕하세요")
        .transition(.opacity)
}

SomeView()
    .opacity(isVisible ? 1 : 0)
    .animation(.easeInOut(duration: 0.3), value: isVisible)
""",
            prompt: "SwiftUI [뷰]가 나타날 때/사라질 때 fade 애니메이션을 적용해줘. [0.3]초, easeInOut 커브로."
        ),

        AnimationItem(
            kind: .basic,
            id: "slide",
            name: "Slide",
            situationCategory: "📱 화면 전환",
            feel: "밀려 들어오는 느낌",
            feelDesc: "화면이나 패널이 특정 방향에서 밀려 들어오거나 나가는 효과",
            when: "바텀 시트, 드로어 메뉴, 다음 화면",
            realApps: [
                RealAppExample(
                    name: "카카오톡 설정",
                    code: ".spring(response: 0.42,\n dampingFraction: 0.90)\n+ .move(edge: .trailing)",
                    note: "오른쪽에서 밀려오는 네비게이션 전환. 거의 안 튐"
                ),
                RealAppExample(
                    name: "iOS 알림 센터",
                    code: ".spring(response: 0.38,\n dampingFraction: 0.85)\n+ .move(edge: .top)",
                    note: "위에서 당겨 내리는 느낌. 빠르게 열고 닫힘"
                ),
                RealAppExample(
                    name: "바텀 시트",
                    code: ".spring(response: 0.40,\n dampingFraction: 0.78)\n+ .move(edge: .bottom)",
                    note: "아래서 올라오는 시트. 약간 탄성 있는 착지"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "방향", key: "move(edge:)",
                    desc: "방향 선택. bottom이 바텀 시트, trailing이 화면 전환",
                    kind: .picker(key: "slideEdge", options: [
                        (label: "아래", value: 0),
                        (label: "위",   value: 1),
                        (label: "왼쪽", value: 2),
                        (label: "오른쪽", value: 3),
                    ], defaultIndex: 0)
                ),
                AnimProperty(
                    label: "opacity 조합", key: ".combined(with: .opacity)",
                    desc: "켜면 슬라이드 + 페이드 동시. 끄면 슬라이드만",
                    kind: .toggle(key: "withOpacity", defaultOn: true)
                ),
            ],
            swiftui: """
if showSheet {
    BottomCard()
        .transition(
            .move(edge: .bottom)
            .combined(with: .opacity)
        )
        .animation(
            .spring(response: 0.4, dampingFraction: 0.75),
            value: showSheet
        )
}
""",
            prompt: "SwiftUI [바텀시트/패널/뷰]가 {slideEdge}에서 slide로 나타나게 해줘. opacity 조합: {withOpacity}."
        ),

        AnimationItem(
            kind: .basic,
            id: "ease",
            name: "Ease",
            situationCategory: "⚙️ 타이밍",
            feel: "천천히 시작해서 빠르다가 다시 느려지는 느낌",
            feelDesc: "iOS 기본 전환에 많이 쓰이는 S자 곡선. 가장 무난한 선택",
            when: "화면 전환, 요소 이동, 기본 상태 변화",
            realApps: [
                RealAppExample(
                    name: "앱 기본 화면전환",
                    code: ".easeInOut(duration: 0.30)",
                    note: "앱 실행/종료. UIKit의 기본 transition 커브"
                ),
                RealAppExample(
                    name: "설정 메뉴 이동",
                    code: ".easeInOut(duration: 0.25)",
                    note: "설정값 변경 시 레이아웃 재배치"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "속도", key: "duration:",
                    desc: "0.2~0.4초가 가장 자연스러운 범위",
                    paramKey: "duration", minValue: 0.1, maxValue: 2.0, defaultValue: 0.3, step: 0.05, format: "%.1f"
                ),
                AnimProperty(
                    label: "커브", key: ".easeIn / .easeInOut / .easeOut",
                    desc: "easeIn=빠르게 시작, easeInOut=S자 곡선, easeOut=천천히 끝",
                    kind: .picker(key: "easeKind", options: [
                        (label: ".easeIn",    value: 0),
                        (label: ".easeInOut", value: 1),
                        (label: ".easeOut",   value: 2),
                    ], defaultIndex: 1)
                ),
            ],
            swiftui: """
.animation(.easeInOut(duration: 0.3), value: state)
.animation(.easeIn(duration: 0.2), value: state)
.animation(.easeOut(duration: 0.25), value: state)
""",
            prompt: "SwiftUI [뷰]에 {easeKind} 애니메이션을 적용해줘. [0.3]초로."
        ),

        AnimationItem(
            kind: .basic,
            id: "linear",
            name: "Linear",
            situationCategory: "⚙️ 타이밍",
            feel: "처음부터 끝까지 일정한 속도로 움직이는 느낌",
            feelDesc: "기계적으로 일정한 속도. 반복 애니메이션이나 로딩 인디케이터에 적합",
            when: "회전하는 로딩 스피너, 프로그레스 바, 연속 반복 효과",
            realApps: [
                RealAppExample(
                    name: "로딩 스피너 회전",
                    code: ".linear(duration: 0.9)\n.repeatForever(autoreverses: false)",
                    note: "UIActivityIndicatorView와 유사. 일정한 속도로 무한 회전"
                ),
                RealAppExample(
                    name: "프로그레스 바",
                    code: ".linear(duration: 1.0~2.0)",
                    note: "파일 다운로드 등 실제 진행률과 선형 동기화"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "회전 속도", key: "duration:",
                    desc: "1회전 시간. 낮을수록 빠름",
                    paramKey: "duration", minValue: 0.3, maxValue: 3.0, defaultValue: 1.0, step: 0.1, format: "%.1f"
                ),
                AnimProperty(
                    label: "반전 반복", key: ".repeatForever",
                    desc: "off = 같은 방향 계속 / on = 왔다갔다 반복",
                    kind: .toggle(key: "autoreverses", defaultOn: false)
                ),
            ],
            swiftui: """
@State var isRotating = false

Circle()
    .trim(from: 0, to: 0.7)
    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
    .rotationEffect(.degrees(isRotating ? 360 : 0))
    .animation(
        .linear(duration: 1.0)
            .repeatForever(autoreverses: false),
        value: isRotating
    )
    .onAppear { isRotating = true }
""",
            prompt: "SwiftUI [뷰]를 linear 애니메이션으로 무한 회전시켜줘. autoreverses: {autoreverses}, duration [1.0]초."
        ),

        // ─── 조합 ────────────────────────────────────────────

        AnimationItem(
            kind: .combo,
            id: "scale",
            name: "Scale + Spring",
            situationCategory: "👆 버튼 · 탭 반응",
            feel: "눌리는 느낌",
            feelDesc: "버튼을 탭했을 때 살짝 눌리는 물리적인 반응감",
            when: "버튼, 카드, 아이콘을 탭했을 때",
            realApps: [
                RealAppExample(
                    name: "트위터 하트 탭",
                    code: ".scaleEffect(0.88)\n.spring(response: 0.22,\n dampingFraction: 0.55)",
                    note: "탭 순간 빠르게 작아지고 즉시 통통 복귀. 짧고 강한 반응"
                ),
                RealAppExample(
                    name: "앱 아이콘 꾹 누를 때",
                    code: ".scaleEffect(0.94)\n.spring(response: 0.30,\n dampingFraction: 0.75)",
                    note: "홈 화면 롱프레스 시 살짝 작아지는 효과. 부드러운 착지"
                ),
                RealAppExample(
                    name: "결제 버튼 확인",
                    code: ".scaleEffect(0.92)\n.spring(response: 0.25,\n dampingFraction: 0.65)",
                    note: "확인 버튼 탭 후 눌림 → 복귀. 탄성으로 확인 피드백 강조"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "눌림 크기", key: "scaleEffect:",
                    desc: "0.90~0.95가 자연스러운 탭 반응",
                    paramKey: "scaleEffect", minValue: 0.80, maxValue: 0.99, defaultValue: 0.92, step: 0.01
                ),
                AnimProperty(
                    label: "반응 빠르기", key: "response:",
                    desc: "낮을수록 빠른 반응감",
                    paramKey: "response", minValue: 0.1, maxValue: 0.8, defaultValue: 0.3, step: 0.01
                ),
                AnimProperty(
                    label: "탄성", key: "dampingFraction:",
                    desc: "0.5면 통통 복귀, 0.8이면 부드럽게 복귀",
                    paramKey: "dampingFraction", minValue: 0.1, maxValue: 1.0, defaultValue: 0.6, step: 0.01
                ),
            ],
            swiftui: """
@State var isPressed = false

Button("확인") { }
    .scaleEffect(isPressed ? 0.92 : 1.0)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    .simultaneousGesture(
        DragGesture(minimumDistance: 0)
            .onChanged { _ in isPressed = true }
            .onEnded { _ in isPressed = false }
    )
""",
            prompt: "SwiftUI [버튼/카드]를 탭했을 때 살짝 눌리는 scale 피드백을 만들어줘. scaleEffect [0.92], response [0.3], dampingFraction [0.6]."
        ),

        AnimationItem(
            kind: .combo,
            id: "shake",
            name: "Keyframe Animator",
            situationCategory: "🔔 알림 · 피드백",
            feel: "틀렸을 때 고개 젓는 느낌",
            feelDesc: "입력이 잘못됐을 때 뷰가 좌우로 빠르게 떨리는 부정 피드백",
            when: "비밀번호 틀렸을 때, 잘못된 입력",
            realApps: [
                RealAppExample(
                    name: "잠금 비밀번호 오류",
                    code: "keyframes: -10, 10, -6, 6, 0\n각 0.06~0.08s",
                    note: "4번 흔들림. iPhone 잠금화면에서 그대로 관찰 가능"
                ),
                RealAppExample(
                    name: "핀 번호 오류",
                    code: "keyframes: -8, 8, -5, 5, 0\n각 0.07s",
                    note: "은행 앱 PIN 입력 오류 시 입력 필드가 짧게 흔들림"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "흔들림 폭", key: "amplitude:",
                    desc: "8~15pt가 자연스러움",
                    paramKey: "amplitude", minValue: 4, maxValue: 24, defaultValue: 12, step: 1, format: "%.0f"
                ),
                AnimProperty(
                    label: "흔들림 속도", key: "keyframe duration:",
                    desc: "0.06~0.1초가 iOS 비밀번호 오류와 비슷",
                    paramKey: "shakeDuration", minValue: 0.04, maxValue: 0.15, defaultValue: 0.08, step: 0.01
                ),
            ],
            swiftui: """
TextField("비밀번호", text: $password)
    .keyframeAnimator(
        initialValue: 0.0,
        trigger: isError
    ) { view, offset in
        view.offset(x: offset)
    } keyframes: { _ in
        KeyframeTrack {
            LinearKeyframe(0,   duration: 0.05)
            LinearKeyframe(-12, duration: 0.08)
            LinearKeyframe(12,  duration: 0.08)
            LinearKeyframe(-8,  duration: 0.08)
            LinearKeyframe(8,   duration: 0.08)
            LinearKeyframe(0,   duration: 0.05)
        }
    }
""",
            prompt: "SwiftUI [입력창/뷰]에서 오류 시 좌우로 흔들리는 shake 애니메이션을 만들어줘. amplitude [12]pt, duration [0.08]s."
        ),

        AnimationItem(
            kind: .combo,
            id: "pulse",
            name: "Scale + Opacity (반복)",
            situationCategory: "⏳ 로딩 · 대기",
            feel: "숨쉬듯 커졌다 작아지는 느낌",
            feelDesc: "살아있는 것처럼 천천히 맥박치는 효과",
            when: "연결 대기 중, 온라인 상태 표시",
            realApps: [
                RealAppExample(
                    name: "FaceTime 연결 중",
                    code: ".easeInOut(duration: 1.4)\n.repeatForever(autoreverses: true)\nscale: 1.0 → 1.18",
                    note: "상대방 연결 대기 중 원형 영역이 천천히 숨쉬듯 커졌다 작아짐"
                ),
                RealAppExample(
                    name: "에어팟 페어링 중",
                    code: ".easeInOut(duration: 1.2)\n.repeatForever(autoreverses: true)\nopacity: 0.4 → 1.0",
                    note: "Bluetooth 아이콘이 천천히 밝아졌다 어두워지며 연결 대기 표시"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "팽창 크기", key: "scaleEffect max:",
                    desc: "1.05~1.2 범위가 자연스러움",
                    paramKey: "scaleMax", minValue: 1.02, maxValue: 1.35, defaultValue: 1.15, step: 0.01
                ),
                AnimProperty(
                    label: "주기", key: "duration:",
                    desc: "0.8~1.5초가 자연스러운 숨쉬기 속도",
                    paramKey: "cycleDuration", minValue: 0.4, maxValue: 2.5, defaultValue: 1.2, step: 0.1, format: "%.1f"
                ),
            ],
            swiftui: """
@State var isPulsing = false

Circle()
    .scaleEffect(isPulsing ? 1.15 : 0.9)
    .opacity(isPulsing ? 1.0 : 0.5)
    .animation(
        .easeInOut(duration: 1.2)
            .repeatForever(autoreverses: true),
        value: isPulsing
    )
    .onAppear { isPulsing = true }
""",
            prompt: "SwiftUI [원/뷰]가 숨쉬듯 천천히 커지고 작아지는 pulse 애니메이션을 만들어줘. scaleMax [1.15], duration [1.2]초."
        ),

        AnimationItem(
            kind: .combo,
            id: "stagger",
            name: "Spring + Delay (순차)",
            situationCategory: "📋 리스트 · 등장",
            feel: "아이템이 하나씩 차례로 나타나는 느낌",
            feelDesc: "리스트나 그리드가 도미노처럼 순서대로 나타나는 효과",
            when: "리스트 화면 진입, 메뉴 열릴 때",
            realApps: [
                RealAppExample(
                    name: "iOS 설정 앱 진입",
                    code: ".spring(response: 0.38,\n dampingFraction: 0.75)\n.delay(Double(i) * 0.04)",
                    note: "각 설정 행이 0.04초 간격으로 아래에서 스르르 올라옴"
                ),
                RealAppExample(
                    name: "앱스토어 추천 목록",
                    code: ".spring(response: 0.42,\n dampingFraction: 0.78)\n.delay(Double(i) * 0.06)",
                    note: "추천 카드들이 0.06초 간격으로 순서대로 등장"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "시차 간격", key: "delay interval:",
                    desc: "0.04~0.08초가 자연스러운 순차 속도",
                    paramKey: "delayInterval", minValue: 0.01, maxValue: 0.15, defaultValue: 0.06, step: 0.01
                ),
                AnimProperty(
                    label: "시작 위치", key: ".offset(y:)",
                    desc: "아래에서 올라오는 거리. 클수록 더 멀리서 등장",
                    paramKey: "startOffset", minValue: 5, maxValue: 40, defaultValue: 16, step: 1, format: "%.0f"
                ),
            ],
            swiftui: """
ForEach(Array(items.enumerated()), id: \\.offset) { index, item in
    ItemRow(item: item)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(
            .spring(response: 0.4, dampingFraction: 0.75)
                .delay(Double(index) * 0.06),
            value: appeared
        )
}
""",
            prompt: "SwiftUI ForEach 리스트 아이템이 [0.06]초 간격으로 [16]pt 아래에서 순차적으로 나타나게 해줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "wave",
            name: "EaseInOut + Delay (반복)",
            situationCategory: "🔄 반복 효과",
            feel: "파도처럼 물결치는 느낌",
            feelDesc: "여러 요소가 파도처럼 순서대로 위아래로 움직이는 리드미컬한 반복",
            when: "음악 재생 중 표시, 음성 입력 중",
            realApps: [
                RealAppExample(
                    name: "Siri 음성 인식 중",
                    code: ".easeInOut(duration: 0.35)\n.repeatForever(autoreverses: true)\n.delay(Double(i) * 0.07)",
                    note: "5개 원형 막대가 파도처럼 높이 변화. 음성 입력 시각화"
                ),
                RealAppExample(
                    name: "Spotify 재생 바",
                    code: ".easeInOut(duration: 0.40)\n.repeatForever(autoreverses: true)\n.delay(Double(i) * 0.09)",
                    note: "3개 막대 이퀄라이저. 현재 재생 중인 트랙 표시"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "파도 간격", key: "delay interval:",
                    desc: "0.08~0.12초가 자연스러운 파도",
                    paramKey: "delayInterval", minValue: 0.03, maxValue: 0.2, defaultValue: 0.1, step: 0.01
                ),
                AnimProperty(
                    label: "높낮이", key: "height range:",
                    desc: "막대 최대 높이. 클수록 파도가 극적으로 보임",
                    paramKey: "maxHeight", minValue: 10, maxValue: 48, defaultValue: 34, step: 1, format: "%.0f"
                ),
            ],
            swiftui: """
@State var isAnimating = false

HStack(spacing: 4) {
    ForEach(0..<5) { i in
        Capsule()
            .frame(width: 4, height: isAnimating ? 24 : 6)
            .animation(
                .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(Double(i) * 0.1),
                value: isAnimating
            )
    }
}
.onAppear { isAnimating = true }
""",
            prompt: "SwiftUI에서 파도처럼 위아래로 움직이는 wave 이퀄라이저 애니메이션을 만들어줘. delay [0.1]초 간격, 최대 높이 [34]pt."
        ),

        AnimationItem(
            kind: .combo,
            id: "pop-in",
            name: "Scale + Opacity Transition",
            situationCategory: "👆 버튼 · 탭 반응",
            feel: "뿅 하고 나타나는 느낌",
            feelDesc: "작은 점에서 갑자기 크게 튀어나오는 재미있는 등장",
            when: "좋아요 뱃지, 알림 카운트, 새 아이템 추가",
            realApps: [
                RealAppExample(
                    name: "인스타그램 좋아요 하트",
                    code: ".spring(bounce: 0.55)\n.scale(scale: 0.05)\n.combined(with: .opacity)",
                    note: "하트를 누르는 순간 점에서 커지며 통통 튀며 등장"
                ),
                RealAppExample(
                    name: "앱 아이콘 뱃지",
                    code: ".spring(bounce: 0.45)\n.scale(scale: 0.10)\n.combined(with: .opacity)",
                    note: "새 알림 뱃지가 10%에서 시작해 뿅 하고 나타남"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "시작 크기", key: "startScale:",
                    desc: "0.1 = 10%에서 시작. 작을수록 더 극적인 등장",
                    paramKey: "startScale", minValue: 0.01, maxValue: 0.4, defaultValue: 0.1, step: 0.01
                ),
                AnimProperty(
                    label: "탄성 강도", key: "bounce:",
                    desc: "0.5면 적당히 통통. iOS 17+",
                    paramKey: "bounce", minValue: 0.1, maxValue: 0.9, defaultValue: 0.5, step: 0.05
                ),
            ],
            swiftui: """
if showBadge {
    BadgeView()
        .transition(
            .scale(scale: 0.1)
            .combined(with: .opacity)
        )
        .animation(.spring(bounce: 0.5), value: showBadge)
}
""",
            prompt: "SwiftUI [뱃지/아이콘]이 나타날 때 뿅 하고 통통 튀며 등장하는 pop in 애니메이션을 만들어줘. startScale [0.1], bounce [0.5]."
        ),

        AnimationItem(
            kind: .combo,
            id: "rubber-band",
            name: "DragGesture + Spring 복귀",
            situationCategory: "✋ 제스처",
            feel: "당기면 늘어나다가 손 떼면 돌아오는 느낌",
            feelDesc: "스크롤이 끝에 달했을 때 고무줄처럼 저항감 있게 늘어나는 효과",
            when: "당겨서 새로고침, 바텀 시트 닫기",
            realApps: [
                RealAppExample(
                    name: "iOS 스크롤 끝 늘어남",
                    code: "offset = translation / 3.0\n(저항계수 3)",
                    note: "스크롤 끝에서 실제 드래그의 1/3만 움직임. 저항감 표현"
                ),
                RealAppExample(
                    name: "Pull to Refresh",
                    code: ".spring(response: 0.38,\n dampingFraction: 0.58)",
                    note: "당기다 놓으면 spring으로 원위치로 통통 튀어 돌아감"
                ),
            ],
            properties: [
                AnimProperty(
                    label: "저항 강도", key: "resistanceFactor:",
                    desc: "나눗수가 클수록 저항 강함. 3이 iOS와 비슷",
                    paramKey: "resistanceFactor", minValue: 1.0, maxValue: 8.0, defaultValue: 3.0, step: 0.5, format: "%.1f"
                ),
                AnimProperty(
                    label: "복귀 탄성", key: "dampingFraction:",
                    desc: "낮을수록 복귀할 때 더 통통 튐",
                    paramKey: "dampingFraction", minValue: 0.1, maxValue: 1.0, defaultValue: 0.6, step: 0.01
                ),
            ],
            swiftui: """
@State var dragOffset: CGFloat = 0

SomeView()
    .offset(y: dragOffset)
    .gesture(
        DragGesture()
            .onChanged { val in
                dragOffset = val.translation.height / 3.0
            }
            .onEnded { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    dragOffset = 0
                }
            }
    )
""",
            prompt: "SwiftUI 뷰를 드래그하면 고무줄처럼 저항감 있게 늘어나다가 손 떼면 spring으로 복귀하게 해줘. resistanceFactor [3.0], dampingFraction [0.6]."
        ),
    ]
}
