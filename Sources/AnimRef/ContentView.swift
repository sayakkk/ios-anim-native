import SwiftUI
import AppKit

// MARK: - App-wide color tokens
extension Color {
    static let appBg         = Color(red: 0.93, green: 0.92, blue: 0.91)
    static let cardBg        = Color.white
    static let cardBorder    = Color(red: 0.86, green: 0.84, blue: 0.82)
    static let textPrimary   = Color(red: 0.12, green: 0.11, blue: 0.10)
    static let textSecondary = Color(red: 0.42, green: 0.40, blue: 0.37)
    static let textTertiary  = Color(red: 0.62, green: 0.60, blue: 0.57)
    static let chipActive    = Color(red: 0.13, green: 0.12, blue: 0.11)
    static let divider       = Color(red: 0.88, green: 0.86, blue: 0.83)
}

// MARK: - Root

struct ContentView: View {
    @State private var search        = ""
    @State private var activeCategory = "전체"
    @State private var selectedItem: AnimationItem? = nil

    var body: some View {
        NavigationSplitView {
            SidebarView(
                search: $search,
                activeCategory: $activeCategory,
                selectedItem: $selectedItem
            )
            .navigationSplitViewColumnWidth(min: 300, ideal: 360, max: 460)
            .navigationTitle("iOS 움직임 사전")
        } detail: {
            if let item = selectedItem {
                DetailPanelView(item: item)
                    .id(item.id)                       // re-render on card switch
                    .navigationTitle("")
            } else {
                EmptyDetailPlaceholder()
                    .navigationTitle("")
            }
        }
        .preferredColorScheme(.light)
        .background(WindowAccessor())
    }
}

// MARK: - Sidebar

private struct SidebarView: View {
    @Binding var search: String
    @Binding var activeCategory: String
    @Binding var selectedItem: AnimationItem?

    private let categories = [
        "전체", "👆 버튼·탭 반응", "📱 화면 전환", "📋 리스트·등장",
        "⏳ 로딩·대기", "🔔 알림·피드백", "🔄 반복 효과", "✋ 제스처", "⚙️ 타이밍"
    ]

    private func filtered(_ items: [AnimationItem]) -> [AnimationItem] {
        items.filter { item in
            let matchCat = activeCategory == "전체" ||
                item.situationCategory.hasPrefix(String(activeCategory.prefix(2)))
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
        VStack(spacing: 0) {

            // ── Search ─────────────────────────────────────────────
            HStack(spacing: 7) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.textTertiary)
                TextField("Spring, Shake, 슬라이드...", text: $search)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.textPrimary)
                if !search.isEmpty {
                    Button { search = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(Color.textTertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.cardBorder, lineWidth: 1))
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 10)

            // ── Category chips ──────────────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(categories, id: \.self) { cat in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                                activeCategory = cat
                            }
                        } label: {
                            Text(cat)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(activeCategory == cat ? Color.white : Color.textSecondary)
                                .padding(.horizontal, 11).padding(.vertical, 6)
                                .background(activeCategory == cat ? Color.chipActive : Color.cardBg)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Color.cardBorder, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .animation(.spring(response: 0.28, dampingFraction: 0.72), value: activeCategory)
                    }
                }
                .padding(.horizontal, 14)
            }
            .padding(.bottom, 10)

            Divider().overlay(Color.divider)

            // ── Card grid ────────────────────────────────────────────
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    if !filteredBasics.isEmpty {
                        SectionHeader(title: "기본", subtitle: "SwiftUI Animation Types")
                            .padding(.horizontal, 14)
                            .padding(.top, 16)
                            .padding(.bottom, 10)

                        LazyVGrid(
                            columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)],
                            spacing: 8
                        ) {
                            ForEach(filteredBasics) { item in
                                AnimationCardView(
                                    item: item,
                                    isSelected: selectedItem?.id == item.id
                                ) { tapped in
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.80)) {
                                        selectedItem = tapped
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 24)
                    }

                    if !filteredCombos.isEmpty {
                        SectionHeader(title: "조합", subtitle: "Combined Effects")
                            .padding(.horizontal, 14)
                            .padding(.bottom, 10)

                        VStack(spacing: 8) {
                            ForEach(filteredCombos) { item in
                                AnimationCardView(
                                    item: item,
                                    isSelected: selectedItem?.id == item.id
                                ) { tapped in
                                    withAnimation(.spring(response: 0.28, dampingFraction: 0.80)) {
                                        selectedItem = tapped
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 40)
                    }

                    if filteredBasics.isEmpty && filteredCombos.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.textTertiary)
                            Text("결과 없음")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                    }
                }
            }
            .background(Color.appBg)
        }
        .background(Color.appBg)
    }
}

// MARK: - Empty state

private struct EmptyDetailPlaceholder: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "cursorarrow.click")
                .font(.system(size: 36))
                .foregroundStyle(Color.textTertiary)
            Text("왼쪽에서 애니메이션을 선택하세요")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.textSecondary)
            Text("클릭하면 데모와 코드가 여기에 나타납니다")
                .font(.system(size: 13))
                .foregroundStyle(Color.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBg)
    }
}

// MARK: - Window accessor (traffic lights visible, toolbar hidden)

private struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { AccessorView() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    class AccessorView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window else { return }
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            window.toolbar = nil
        }
    }
}

// MARK: - Section header

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .black))
                .foregroundStyle(Color.textPrimary)
            Text(subtitle)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.textTertiary)
            Spacer()
        }
    }
}
