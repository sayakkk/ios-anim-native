import SwiftUI

struct ContentView: View {
    @State private var search = ""
    @State private var activeCategory = "전체"

    // Hero expand state
    @Namespace private var hero
    @State private var selectedItem: AnimationItem? = nil
    @State private var selectedIndex: Int = 0
    @State private var selectedSection: AnimKind = .basic

    private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)
    private let categories = ["전체", "👆 버튼 · 탭 반응", "📱 화면 전환", "📋 리스트 · 등장",
                               "⏳ 로딩 · 대기", "🔔 알림 · 피드백", "🔄 반복 효과", "✋ 제스처", "⚙️ 타이밍 참고"]

    private func filtered(_ items: [AnimationItem]) -> [AnimationItem] {
        items.filter { item in
            let matchCat = activeCategory == "전체" || item.situationCategory == activeCategory
            let q = search.lowercased()
            let matchSearch = q.isEmpty ||
                item.feel.lowercased().contains(q) ||
                item.name.lowercased().contains(q) ||
                item.when.lowercased().contains(q) ||
                item.feelDesc.lowercased().contains(q)
            return matchCat && matchSearch
        }
    }

    private var filteredBasics: [AnimationItem] { filtered(AnimationData.basics) }
    private var filteredCombos: [AnimationItem] { filtered(AnimationData.combos) }

    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    Color(red: 0.05, green: 0.04, blue: 0.02).ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 0) {
                            // ── Category chips ──────────────────────────
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { cat in
                                        Button {
                                            withAnimation(.spring(response: 0.3)) {
                                                activeCategory = cat
                                            }
                                        } label: {
                                            Text(cat)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(activeCategory == cat
                                                    ? Color(red: 0.05, green: 0.04, blue: 0.02)
                                                    : Color(red: 0.45, green: 0.36, blue: 0.22))
                                                .padding(.horizontal, 13).padding(.vertical, 7)
                                                .background(activeCategory == cat
                                                    ? accent
                                                    : Color(red: 0.10, green: 0.08, blue: 0.04))
                                                .clipShape(Capsule())
                                                .overlay(
                                                    Capsule().stroke(
                                                        activeCategory == cat ? Color.clear : Color.white.opacity(0.07),
                                                        lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                        .scaleEffect(activeCategory == cat ? 1.0 : 0.97)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: activeCategory)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 20)

                            // ── 기본 Section ────────────────────────────
                            if !filteredBasics.isEmpty {
                                SectionHeader(title: "기본", subtitle: "SwiftUI 애니메이션 타입")
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)

                                LazyVGrid(
                                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                                    spacing: 10
                                ) {
                                    ForEach(filteredBasics) { item in
                                        AnimationCardView(item: item, namespace: hero) { tapped in
                                            let idx = filteredBasics.firstIndex(where: { $0.id == tapped.id }) ?? 0
                                            selectedIndex = idx
                                            selectedSection = .basic
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                                selectedItem = tapped
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 28)
                            }

                            // ── 조합 Section ────────────────────────────
                            if !filteredCombos.isEmpty {
                                SectionHeader(title: "조합", subtitle: "여러 애니메이션의 조합")
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)

                                VStack(spacing: 10) {
                                    ForEach(filteredCombos) { item in
                                        AnimationCardView(item: item, namespace: hero) { tapped in
                                            let idx = filteredCombos.firstIndex(where: { $0.id == tapped.id }) ?? 0
                                            selectedIndex = idx
                                            selectedSection = .combo
                                            withAnimation(.spring(response: 0.45, dampingFraction: 0.82)) {
                                                selectedItem = tapped
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 40)
                            }
                        }
                    }
                }
                .navigationTitle("iOS 움직임 사전")
                .navigationBarTitleDisplayMode(.large)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(Color(red: 0.05, green: 0.04, blue: 0.02), for: .navigationBar)
                .searchable(text: $search, prompt: "\"통통\", \"흔들\", \"spring\"...")
            }
            .preferredColorScheme(.dark)
            .tint(accent)

            // ── Hero Detail Overlay ──────────────────────────────────
            if let item = selectedItem {
                let sectionItems = selectedSection == .basic ? filteredBasics : filteredCombos

                HeroDetailView(
                    sectionItems: sectionItems,
                    currentIndex: $selectedIndex,
                    namespace: hero,
                    onDismiss: {
                        withAnimation(.spring(response: 0.42, dampingFraction: 0.85)) {
                            selectedItem = nil
                        }
                    }
                )
                .ignoresSafeArea()
                .transition(AnyTransition.asymmetric(
                    insertion: AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 0.94, anchor: .center)),
                    removal: AnyTransition.opacity.combined(with: AnyTransition.scale(scale: 0.94, anchor: .center))
                ))
                .zIndex(10)
                // Silence unused variable warning
                .id(item.id)
            }
        }
    }
}

// MARK: - Section Header

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color(red: 0.96, green: 0.91, blue: 0.79))
            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color(red: 0.35, green: 0.28, blue: 0.18))
            Spacer()
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
                .frame(maxWidth: 60)
        }
    }
}
