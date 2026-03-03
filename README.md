# iOS 움직임 사전
### A macOS reference app for iOS/macOS SwiftUI animations — built for designers and developers
![demo](https://github.com/user-attachments/assets/cce3629d-56f3-4e69-84fc-a03b945ba21e)


---

## Overview

**iOS 움직임 사전** is a native macOS app that serves as an interactive animation reference for designers and developers working with SwiftUI. Instead of memorizing parameter names or digging through documentation, you can feel each animation in real time, tweak its properties with sliders, and instantly copy a ready-to-use AI prompt or SwiftUI code snippet.

The app prioritizes **feel over technical naming** — animations are described by what they feel like ("통통 튀며 제자리 잡는 느낌") rather than their API names, making it approachable for designers who don't write code. (KO/EN available)

---

## Features

### 🎬 13 Animations with Live Preview

**Basic (기본)**
| Name | Feel |
|------|------|
| Spring | 통통 튀며 제자리 잡는 느낌 |
| Bouncy | 고무공처럼 통통통 튀는 느낌 |
| Fade | 스르르 나타나거나 사라지는 느낌 |
| Slide | 밀려 들어오는 느낌 |
| Ease | 천천히 시작해서 빠르다가 다시 느려지는 느낌 |
| Linear | 처음부터 끝까지 일정한 속도로 움직이는 느낌 |

**Combo (조합)**
| Name | Feel |
|------|------|
| Scale + Spring | 눌리는 느낌 |
| Keyframe Animator | 틀렸을 때 고개 젓는 느낌 |
| Scale + Opacity (반복) | 숨쉬듯 커졌다 작아지는 느낌 |
| Spring + Delay (순차) | 아이템이 하나씩 차례로 나타나는 느낌 |
| EaseInOut + Delay (반복) | 파도처럼 물결치는 느낌 |
| Scale + Opacity Transition | 뿅 하고 나타나는 느낌 |
| DragGesture + Spring | 당기면 늘어나다가 돌아오는 느낌 |
| Matched Geometry | 카드가 자연스럽게 다음 화면이 되는 느낌 |
| 3D Flip | 카드가 뒤집히는 느낌 |
| Blur + Fade | 뒤가 흐려지며 패널이 등장하는 느낌 |
| Symbol Effect | 아이콘이 살아 움직이는 느낌 |

### 🎛 Interactive Controls
- **Sliders** — response, dampingFraction, duration, amplitude, and more
- **Pickers** — easing curve, slide direction, flip axis, symbol effect type
- **Toggles** — opacity combination, repeat direction
- **Presets** — `.bouncy` / `.smooth` / `.snappy` quick-select

All controls update the mini live preview in real time. The preview restarts (not just plays) only when you release a slider, keeping it smooth during drag.

### 🤖 AI Prompt Copy
Each animation card includes a dynamic AI prompt that automatically bakes in the current slider/picker values. Tap to copy → paste into ChatGPT, Claude, or Cursor.

```
SwiftUI 버튼에 spring 애니메이션을 적용해줘. response 0.35, dampingFraction 0.62로.
```

### 📐 Native macOS Layout
- Two-column split: sidebar (card grid) + detail panel
- Flat design — no visual sidebar panel material, single 1px divider
- Warm light gray theme (`#EDECE9`), white cards
- Minimum window size: 1120 × 740

### 📱 Real App Examples
Every animation includes 2 real-world examples from iOS system apps (Settings, Photos, App Store, Safari, FaceTime, etc.) with the actual parameter values used and a note explaining the context.

---

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Platform**: macOS 14.0+ (Sonoma)
- **Build**: Xcode 15+, no external dependencies
- **Architecture**: MVVM-lite — `AnimationItem` data model drives all views
- **Key APIs**:
  - `NSViewRepresentable` — window configuration via `WindowAccessor`
  - `NSPasteboard` — AI prompt / SwiftUI code copy
  - `KeyframeAnimator` — shake demo
  - `symbolEffect` — SF Symbols animation (macOS 14+)
  - `matchedGeometryEffect` — hero transition demo

---

## Project Structure

```
Sources/AnimRef/
├── AnimRefApp.swift          # App entry, window size, color scheme
├── ContentView.swift         # Root layout, WindowAccessor, color tokens
├── Models/
│   └── AnimationItem.swift   # All animation data (AnimKind, AnimProperty, seed data)
└── Views/
    ├── AnimationCardView.swift   # Grid card with hover + selection state
    ├── AnimationDemoView.swift   # Static fallback demo view
    └── HeroDetailView.swift      # Detail panel, sliders, mini live demos
```

---

## Build & Run

```bash
git clone https://github.com/sayakkk/ios-anim-native.git
cd ios-anim-native
open AnimRef.xcodeproj
```

Select the **AnimRef** scheme with **My Mac** destination, then ⌘R.

Or via command line:
```bash
xcodebuild -project AnimRef.xcodeproj -scheme AnimRef \
  -destination 'platform=macOS' -configuration Debug build
```

---

## Design Decisions

**Feel-first naming** — Animations are introduced by what they feel like, not their API name. Technical names appear as secondary labels.

**No NavigationSplitView** — Replaced with a plain `HStack(spacing: 0)` to avoid macOS sidebar panel visual and material. Gives full control over layout and background color.

**Slider restarts preview on release** — Dragging doesn't constantly restart the animation. Only `onEditingChanged(false)` triggers `previewTrigger = UUID()`, making live adjustment smooth.

**Dynamic prompt** — `buildDynamicPrompt()` uses regex to replace `[0.00]` placeholders with current slider values and `{key}` tokens with picker/toggle selections.

---

---

## 개요

**iOS 움직임 사전**은 SwiftUI 애니메이션을 실시간으로 느끼고, 조작하고, 바로 코드로 가져갈 수 있는 macOS 레퍼런스 앱입니다. 디자이너와 개발자가 함께 쓸 수 있도록, 기술 용어 대신 느낌 중심으로 애니메이션을 설명합니다.

"이 버튼이 왜 탭했을 때 이런 느낌이지?" 라는 질문에서 출발해 → 슬라이더로 직접 조절 → AI 프롬프트 복사 → 바로 적용하는 흐름을 목표로 했습니다.

---

## 기능

### 애니메이션 13종 + 인터랙티브 컨트롤

**기본 6종**: Spring / Bouncy / Fade / Slide / Ease / Linear

**조합 11종**: 눌리는 느낌 / 흔들림(shake) / Pulse / 순차 등장(stagger) / 파도(wave) / Pop-in / 고무줄 복귀 / Hero 전환 / 3D 뒤집기 / Blur+Fade 모달 / SF Symbol 효과

각 애니메이션마다:
- **슬라이더** — 타이밍, 탄성, 크기 등 직접 조절
- **피커** — 커브 종류, 방향 선택
- **미니 라이브 프리뷰** — 슬라이더 놓는 순간 즉시 재시작
- **실제 앱 예시** — iOS 기본 앱(설정, 사진, 앱스토어 등)에서 쓰이는 실제 파라미터 값

### AI 프롬프트 자동 생성

현재 슬라이더/피커 값이 자동으로 반영된 프롬프트를 한 탭으로 복사. ChatGPT, Claude, Cursor에 바로 붙여넣기 가능.

---

## 기술 스택

- **언어**: Swift 5.9+
- **UI**: SwiftUI (macOS 14.0+)
- **빌드**: Xcode 15+, 외부 의존성 없음
- **구조**: MVVM-lite — `AnimationItem` 데이터 모델이 모든 뷰를 구동
- **주요 API**: `NSViewRepresentable`, `NSPasteboard`, `KeyframeAnimator`, `symbolEffect`, `matchedGeometryEffect`

---

## 라이선스

MIT License, Copyright (c) 까야
