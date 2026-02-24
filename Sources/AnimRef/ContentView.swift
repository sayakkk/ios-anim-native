import SwiftUI

// MARK: - App-wide light theme tokens
extension Color {
    static let appBg        = Color(red: 0.93, green: 0.92, blue: 0.91)
    static let cardBg       = Color.white
    static let cardBorder   = Color(red: 0.86, green: 0.84, blue: 0.82)
    static let textPrimary  = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let textSecondary = Color(red: 0.42, green: 0.40, blue: 0.37)
    static let textTertiary = Color(red: 0.62, green: 0.60, blue: 0.57)
    static let chipActive   = Color(red: 0.13, green: 0.12, blue: 0.11)
    static let divider      = Color(red: 0.88, green: 0.86, blue: 0.83)
}

struct ContentView: View {
    @State private var search = ""
    @State private var activeCategory = "전체"

    // Hero expand state
    @State private var selectedItem: AnimationItem? = nil
    @State private var selectedIndex: Int = 0
    @State private var selectedSection: AnimKind = .basic

    private let categories = ["전체", "👆 버튼·탭 반응", "📱 화면 전환", "📋 리스트·등장",
                               "⏳ 로딩·대기", "🔔 알림·피드백", "🔄 반복 효과", "✋ 제스처", "⚙️ 타이밍"]

    private func filtered(_ items: [AnimationItem]) -> [AnimationItem] {
        items.filter { item in
            let matchCat = activeCategory == "전체" || item.situationCategory.hasPrefix(String(activeCategory.prefix(2)))
            let q = search.lowercased()
            let matchSearch = q.isEmpty ||
                item.name.lowercased().contains(q) ||
                item.feel.lowercased().contains(q) ||
                item.feelDesc.lowercased().contains(q) ||
                item.when.lowercased().contains(q)
            return matchCat && matchSearch
        }
    }

    private var filteredBasics: [AnimationItem] { filtered(AnimationData.basics) }
    private var filteredCombos: [AnimationItem]  { filtered(AnimationData.combos) }

    var body: some View {
        ZStack {
            // ── Main list ──────────────────────────────────────────────
            NavigationStack {
                ZStack {
                    Color.appBg.ignoresSafeArea()

                    ScrollView {
                        VStack(spacing: 0) {
                            // Category chips
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 7) {
                                    ForEach(categories, id: \.self) { cat in
                                        Button {
                                            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                                activeCategory = cat
                                            }
                                        } label: {
                                            Text(cat)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundStyle(activeCategory == cat
                                                    ? Color.white
                                                    : Color.textSecondary)
                                                .padding(.horizontal, 13).padding(.vertical, 7)
                                                .background(activeCategory == cat
                                                    ? Color.chipActive
                                                    : Color.cardBg)
                                                .clipShape(Capsule())
                                                .overlay(Capsule().stroke(Color.cardBorder, lineWidth: 1))
                                        }
                                        .buttonStyle(.plain)
                                        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: activeCategory)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 22)

                            // ── 기본 section ──────────────────────────
                            if !filteredBasics.isEmpty {
                                ListSectionHeader(title: "기본", subtitle: "SwiftUI Animation Types")
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)

                                LazyVGrid(
                                    columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                                    spacing: 10
                                ) {
                                    ForEach(filteredBasics) { item in
                                        AnimationCardView(item: item) { tapped in
                                            let idx = filteredBasics.firstIndex { $0.id == tapped.id } ?? 0
                                            selectedIndex = idx
                                            selectedSection = .basic
                                            withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                                                selectedItem = tapped
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 30)
                            }

                            // ── 조합 section ──────────────────────────
                            if !filteredCombos.isEmpty {
                                ListSectionHeader(title: "조합", subtitle: "Combined Effects")
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 12)

                                VStack(spacing: 10) {
                                    ForEach(filteredCombos) { item in
                                        AnimationCardView(item: item) { tapped in
                                            let idx = filteredCombos.firstIndex { $0.id == tapped.id } ?? 0
                                            selectedIndex = idx
                                            selectedSection = .combo
                                            withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
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
                .searchable(text: $search, prompt: "\"Spring\", \"Shake\", \"슬라이드\"...")
            }
            .preferredColorScheme(.light)
            .tint(Color.textPrimary)

            // ── Hero Detail Overlay ────────────────────────────────────
            if selectedItem != nil {
                let sectionItems = selectedSection == .basic ? filteredBasics : filteredCombos

                HeroDetailView(
                    sectionItems: sectionItems,
                    currentIndex: $selectedIndex,
                    onDismiss: {
                        withAnimation(.spring(response: 0.38, dampingFraction: 0.88)) {
                            selectedItem = nil
                        }
                    }
                )
                .ignoresSafeArea()
                .zIndex(10)
            }
        }
    }
}

// MARK: - Section header

private struct ListSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .black))
                .foregroundStyle(Color.textPrimary)
            Text(subtitle)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.textTertiary)
            Spacer()
        }
    }
}
