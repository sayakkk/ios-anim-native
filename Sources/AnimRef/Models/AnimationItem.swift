import SwiftUI

// MARK: - Kind

enum AnimKind { case basic, combo }

// MARK: - Data Model

struct AnimProperty {
    let label: String       // 한글 이름 (빠르기, 탄성...)
    let key: String         // 코드 (response:, dampingFraction:...)
    let desc: String        // 설명
}

struct AnimationItem: Identifiable {
    let kind: AnimKind
    let id: String
    let name: String
    let situationCategory: String
    let feel: String
    let feelDesc: String
    let when: String
    let realApps: [String]
    let properties: [AnimProperty]
    let swiftui: String
    let prompt: String
}

// MARK: - Seed Data

struct AnimationData {

    static let basics: [AnimationItem] = all.filter { $0.kind == .basic }
    static let combos: [AnimationItem] = all.filter { $0.kind == .combo }

    static let all: [AnimationItem] = [

        // ─── 기본 ───────────────────────────────────────────

        AnimationItem(
            kind: .basic,
            id: "spring",
            name: "Spring",
            situationCategory: "📋 리스트 · 등장",
            feel: "통통 튀며 제자리 잡는 느낌",
            feelDesc: "iOS 앱 어디서나 느껴지는 그 살아있는 탄성감",
            when: "모든 곳. iOS 앱에서 기본으로 쓰이는 애니메이션",
            realApps: ["iOS 전반의 모든 화면 전환", "앱 폴더 열고 닫기", "위젯 이동"],
            properties: [
                AnimProperty(label: "빠르기", key: "response:", desc: "낮을수록 빠름. 보통 0.3~0.5. 0.3이면 빠릿빠릿, 0.6이면 묵직"),
                AnimProperty(label: "탄성", key: "dampingFraction:", desc: "1.0이면 안 튐(부드럽게 정착), 0.5면 많이 통통 튐. 보통 0.6~0.8"),
                AnimProperty(label: "빠른 설정", key: ".bouncy / .smooth / .snappy", desc: "iOS 17+. bouncy=통통, smooth=부드럽게, snappy=빠르게"),
            ],
            swiftui: """
// iOS 17+ 간단 버전 (추천)
.animation(.bouncy, value: state)
.animation(.smooth, value: state)
.animation(.snappy, value: state)

// 세밀하게 조절
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
            realApps: ["Duolingo 캐릭터 반응", "어린이 앱 인터랙션"],
            properties: [
                AnimProperty(label: "기본 바운스", key: ".bouncy", desc: "이거 하나면 충분. iOS 17+에서 가장 iOS다운 느낌"),
                AnimProperty(label: "바운스 강도", key: "extraBounce: 0~0.4", desc: "0이면 기본, 0.4면 더 많이 통통. 0.3 이상은 약간 과장된 느낌"),
            ],
            swiftui: """
// iOS 17+ (추천)
.animation(.bouncy, value: isExpanded)

// 더 통통 튀게
.animation(
    .bouncy(duration: 0.4, extraBounce: 0.25),
    value: isExpanded
)
""",
            prompt: "SwiftUI [뷰]에 .bouncy 애니메이션을 적용해서 고무공처럼 통통 튀는 느낌을 줘."
        ),

        AnimationItem(
            kind: .basic,
            id: "fade",
            name: "Fade",
            situationCategory: "📱 화면 전환",
            feel: "스르르 나타나거나 사라지는 느낌",
            feelDesc: "요소가 서서히 보이거나 사라지는, 가장 자연스럽고 무난한 전환",
            when: "화면 전환, 오버레이, 토스트 메시지",
            realApps: ["iOS 잠금 해제 후 홈 화면", "사진 로딩 완료"],
            properties: [
                AnimProperty(label: "투명도", key: ".opacity(0 ~ 1)", desc: "0이면 안 보임, 1이면 완전히 보임"),
                AnimProperty(label: "속도", key: ".easeInOut(duration: 0.3)", desc: "0.2~0.4초가 자연스러움"),
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
            realApps: ["카카오톡 설정 화면", "iOS 알림 센터", "바텀 시트"],
            properties: [
                AnimProperty(label: "방향", key: ".move(edge: .bottom)", desc: "bottom이 가장 많이 쓰임"),
                AnimProperty(label: "조합", key: ".combined(with: .opacity)", desc: "슬라이드만 쓰면 약간 어색함. opacity 같이 쓰면 훨씬 자연스러움"),
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
            prompt: "SwiftUI [바텀시트/패널/뷰]가 [아래/위/왼쪽/오른쪽]에서 slide로 나타나게 transition을 만들어줘."
        ),

        AnimationItem(
            kind: .basic,
            id: "ease",
            name: "Ease",
            situationCategory: "⚙️ 타이밍 참고",
            feel: "천천히 시작해서 빠르다가 다시 느려지는 느낌",
            feelDesc: "iOS 기본 전환에 많이 쓰이는 S자 곡선. 가장 무난하고 자연스러운 선택",
            when: "화면 전환, 요소 이동, 기본 상태 변화",
            realApps: ["iOS 앱 기본 화면 전환", "설정 메뉴 항목 이동"],
            properties: [
                AnimProperty(label: "기본", key: ".easeInOut(duration: 0.3)", desc: "가장 무난하고 자연스러운 선택"),
                AnimProperty(label: "들어올 때만", key: ".easeIn(duration: 0.25)", desc: "빠르게 나타날 때"),
                AnimProperty(label: "나갈 때만", key: ".easeOut(duration: 0.25)", desc: "부드럽게 사라질 때"),
            ],
            swiftui: """
// 기본 (가장 많이 쓰임)
.animation(.easeInOut(duration: 0.3), value: state)

// 빠르게 등장
.animation(.easeIn(duration: 0.2), value: state)

// 부드럽게 퇴장
.animation(.easeOut(duration: 0.25), value: state)
""",
            prompt: "SwiftUI [뷰]에 easeInOut 애니메이션을 적용해줘. [0.3]초로."
        ),

        AnimationItem(
            kind: .basic,
            id: "linear",
            name: "Linear",
            situationCategory: "⚙️ 타이밍 참고",
            feel: "처음부터 끝까지 일정한 속도로 움직이는 느낌",
            feelDesc: "기계적으로 일정한 속도. 반복 애니메이션이나 로딩 인디케이터에 적합",
            when: "회전하는 로딩 스피너, 프로그레스 바, 연속 반복 효과",
            realApps: ["로딩 스피너 회전", "프로그레스 바 채워짐"],
            properties: [
                AnimProperty(label: "기본 사용", key: ".linear(duration: 1.0)", desc: "반복 애니메이션에 가장 자연스러움"),
                AnimProperty(label: "무한 반복", key: ".repeatForever(autoreverses: false)", desc: "autoreverses: false = 같은 방향 반복"),
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
            prompt: "SwiftUI [뷰]를 linear 애니메이션으로 [회전/이동]시켜줘. 무한 반복."
        ),

        // ─── 조합 ───────────────────────────────────────────

        AnimationItem(
            kind: .combo,
            id: "scale",
            name: "Scale + Spring",
            situationCategory: "👆 버튼 · 탭 반응",
            feel: "눌리는 느낌",
            feelDesc: "버튼을 탭했을 때 살짝 눌리는 물리적인 반응감",
            when: "버튼, 카드, 아이콘을 탭했을 때",
            realApps: ["트위터 하트 버튼 탭", "앱 아이콘 누를 때", "결제 버튼 확인"],
            properties: [
                AnimProperty(label: "크기", key: ".scaleEffect(0.92)", desc: "1.0이 원래 크기. 탭 반응엔 0.90~0.95가 자연스러워요"),
                AnimProperty(label: "반응 방식", key: ".spring(response:dampingFraction:)", desc: "spring을 써야 진짜 눌리는 느낌이 남. easeInOut은 어색함"),
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
            prompt: "SwiftUI [버튼/카드]를 탭했을 때 살짝 눌리는 scale 피드백 애니메이션을 만들어줘. 자연스럽게."
        ),

        AnimationItem(
            kind: .combo,
            id: "shake",
            name: "KeyframeAnimator + Offset",
            situationCategory: "🔔 알림 · 피드백",
            feel: "틀렸을 때 고개 젓는 느낌",
            feelDesc: "입력이 잘못됐을 때 뷰가 좌우로 빠르게 떨리는 부정 피드백",
            when: "비밀번호 틀렸을 때, 잘못된 입력",
            realApps: ["iPhone 잠금 비밀번호 틀렸을 때", "핀 번호 오류"],
            properties: [
                AnimProperty(label: "흔들림 폭", key: "LinearKeyframe(-12)", desc: "8~15pt가 자연스러움. 클수록 더 격렬하게 흔들림"),
                AnimProperty(label: "흔들림 속도", key: "duration: 0.08", desc: "0.06~0.1초가 iOS 비밀번호 오류와 비슷한 속도"),
                AnimProperty(label: "트리거", key: "trigger: isError", desc: "이 값이 바뀔 때마다 애니메이션 실행"),
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
            prompt: "SwiftUI [입력창/뷰]에서 오류 시 좌우로 흔들리는 shake 애니메이션을 만들어줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "pulse",
            name: "Scale + Opacity (반복)",
            situationCategory: "⏳ 로딩 · 대기",
            feel: "숨쉬듯 커졌다 작아지는 느낌",
            feelDesc: "살아있는 것처럼 천천히 맥박치는 효과",
            when: "연결 대기 중, 온라인 상태 표시",
            realApps: ["FaceTime 연결 중", "에어팟 페어링 중"],
            properties: [
                AnimProperty(label: "숨쉬기 크기", key: ".scaleEffect(1.15)", desc: "1.05~1.2 범위가 자연스러움"),
                AnimProperty(label: "주기", key: ".easeInOut(duration: 1.2)", desc: "0.8~1.5초가 자연스러운 숨쉬기 속도"),
                AnimProperty(label: "반복 방식", key: "repeatForever(autoreverses: true)", desc: "true = 커졌다 작아졌다 반복"),
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
            prompt: "SwiftUI [원/뷰]가 숨쉬듯 천천히 커지고 작아지는 pulse 애니메이션을 만들어줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "stagger",
            name: "Spring + Delay (순차)",
            situationCategory: "📋 리스트 · 등장",
            feel: "아이템이 하나씩 차례로 나타나는 느낌",
            feelDesc: "리스트나 그리드가 도미노처럼 순서대로 나타나는 효과",
            when: "리스트 화면 진입, 메뉴 열릴 때",
            realApps: ["iOS 설정 앱 진입", "앱스토어 추천 목록"],
            properties: [
                AnimProperty(label: "시차 간격", key: "Double(index) * 0.06", desc: "0.04~0.08초가 자연스러운 순차 속도"),
                AnimProperty(label: "시작 위치", key: ".offset(y: 20 → 0)", desc: "15~25pt 아래에서 올라오는 게 자연스러움"),
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
            prompt: "SwiftUI ForEach 리스트 아이템이 [0.06]초 간격으로 아래에서 순차적으로 나타나게 해줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "wave",
            name: "EaseInOut + Delay (반복)",
            situationCategory: "🔄 반복 효과",
            feel: "파도처럼 물결치는 느낌",
            feelDesc: "여러 요소가 파도처럼 순서대로 위아래로 움직이는 리드미컬한 반복",
            when: "음악 재생 중 표시, 음성 입력 중",
            realApps: ["Siri 음성 인식 중", "Spotify 재생 바"],
            properties: [
                AnimProperty(label: "파도 간격", key: ".delay(Double(i) * 0.1)", desc: "0.08~0.12초가 자연스러운 파도"),
                AnimProperty(label: "높낮이", key: "height: 6 → 24", desc: "차이가 클수록 파도가 극적으로 보임"),
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
            prompt: "SwiftUI에서 파도처럼 위아래로 움직이는 wave 이퀄라이저 애니메이션을 만들어줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "pop-in",
            name: "Scale + Opacity Transition",
            situationCategory: "👆 버튼 · 탭 반응",
            feel: "뿅 하고 나타나는 느낌",
            feelDesc: "작은 점에서 갑자기 크게 튀어나오는 재미있는 등장",
            when: "좋아요 뱃지, 알림 카운트, 새 아이템 추가",
            realApps: ["인스타그램 좋아요 빨간 하트", "앱 아이콘 뱃지"],
            properties: [
                AnimProperty(label: "시작 크기", key: ".transition(.scale(scale: 0.1))", desc: "0.1 = 10%에서 시작. 작을수록 더 극적인 등장"),
                AnimProperty(label: "탄성", key: ".spring(bounce: 0.5)", desc: "0.0이면 안 튐, 1.0에 가까울수록 많이 통통 튐 (iOS 17+)"),
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
            prompt: "SwiftUI [뱃지/아이콘]이 나타날 때 뿅 하고 통통 튀며 등장하는 pop in 애니메이션을 만들어줘."
        ),

        AnimationItem(
            kind: .combo,
            id: "rubber-band",
            name: "DragGesture + Spring 복귀",
            situationCategory: "✋ 제스처",
            feel: "당기면 늘어나다가 손 떼면 돌아오는 느낌",
            feelDesc: "스크롤이 끝에 달했을 때 고무줄처럼 저항감 있게 늘어나는 효과",
            when: "당겨서 새로고침, 바텀 시트 닫기",
            realApps: ["iOS 스크롤 끝 부분 늘어남", "Pull to Refresh"],
            properties: [
                AnimProperty(label: "저항 강도", key: "translation / 3.0", desc: "나눗수가 클수록 저항이 강함. 3이 iOS와 비슷한 느낌"),
                AnimProperty(label: "복귀 탄성", key: ".spring(dampingFraction: 0.6)", desc: "dampingFraction 낮을수록 복귀할 때 더 통통 튐"),
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
            prompt: "SwiftUI 뷰를 드래그하면 고무줄처럼 저항감 있게 늘어나다가 손 떼면 spring으로 복귀하게 해줘."
        ),
    ]
}
