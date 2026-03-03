import SwiftUI

// MARK: - Language Environment Key

struct AppLangKey: EnvironmentKey {
    static let defaultValue = "ko"
}

extension EnvironmentValues {
    var appLang: String {
        get { self[AppLangKey.self] }
        set { self[AppLangKey.self] = newValue }
    }
}

// MARK: - Property Label Translations

let propLabelEn: [String: String] = [
    "빠르기": "Speed",
    "탄성": "Elasticity",
    "빠른 설정": "Quick Preset",
    "기본 바운스": "Basic Bounce",
    "바운스 강도": "Bounce Amount",
    "방향": "Direction",
    "속도": "Duration",
    "opacity 조합": "With Opacity",
    "커브": "Curve",
    "회전 속도": "Rotation Speed",
    "반전 반복": "Reverse Loop",
    "눌림 크기": "Press Scale",
    "반응 빠르기": "Response",
    "흔들림 폭": "Amplitude",
    "흔들림 속도": "Shake Duration",
    "팽창 크기": "Max Scale",
    "주기": "Cycle Duration",
    "시차 간격": "Stagger Delay",
    "시작 위치": "Start Offset",
    "파도 간격": "Wave Delay",
    "높낮이": "Max Height",
    "시작 크기": "Start Scale",
    "탄성 강도": "Bounce",
    "저항 강도": "Resistance",
    "복귀 탄성": "Return Damping",
    "spring 빠르기": "Response",
    "블러 강도": "Blur Radius",
    "페이드 속도": "Fade Duration",
    "효과 종류": "Effect Type",
    "트리거": "Trigger",
    "회전 축": "Rotation Axis",
    "회전 기준점": "Pivot Point",
]

// MARK: - Category Translations

let categoryEn: [String: String] = [
    "전체": "All",
    "👆 버튼·탭 반응": "👆 Button · Tap",
    "📱 화면 전환": "📱 Transitions",
    "📋 리스트·등장": "📋 List · Appear",
    "⏳ 로딩·대기": "⏳ Loading",
    "🔔 알림·피드백": "🔔 Feedback",
    "🔄 반복 효과": "🔄 Repeating",
    "✋ 제스처": "✋ Gesture",
    "⚙️ 타이밍": "⚙️ Timing",
]

// MARK: - UI String Helpers

func L(_ ko: String, _ en: String, lang: String) -> String {
    lang == "en" ? en : ko
}

extension AnimProperty {
    func localLabel(_ lang: String) -> String {
        lang == "en" ? (propLabelEn[label] ?? label) : label
    }
}
