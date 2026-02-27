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

// MARK: - Sidebar width preference

private struct SidebarWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 300
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

// MARK: - Root

struct ContentView: View {
    @State private var search        = ""
    @State private var activeCategory = "전체"
    @State private var selectedItem: AnimationItem? = nil
    @State private var sidebarWidth: CGFloat = 300

    var body: some View {
        HStack(spacing: 0) {
            SidebarView(
                search: $search,
                activeCategory: $activeCategory,
                selectedItem: $selectedItem
            )
            .frame(minWidth: 260, idealWidth: 300, maxWidth: 380)
            .background(GeometryReader { geo in
                Color.clear.preference(key: SidebarWidthKey.self, value: geo.size.width)
            })

            Color.clear.frame(width: 1)   // placeholder gap

            Group {
                if let item = selectedItem {
                    DetailPanelView(item: item)
                        .id(item.id)
                } else {
                    EmptyDetailPlaceholder()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.appBg.ignoresSafeArea())
        .onPreferenceChange(SidebarWidthKey.self) { sidebarWidth = $0 }
        .overlay { DividerLineView(x: sidebarWidth).allowsHitTesting(false) }
        .preferredColorScheme(.light)
        .toolbarBackground(Color.appBg, for: .windowToolbar)
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
            .background(Color.black.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
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
        } // VStack
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

// MARK: - Full-height divider line (bypasses SwiftUI safe area)

private struct DividerLineView: NSViewRepresentable {
    let x: CGFloat

    func makeNSView(context: Context) -> DividerNSView {
        DividerNSView(x: x)
    }
    func updateNSView(_ nsView: DividerNSView, context: Context) {
        nsView.updateX(x)
    }

    class DividerNSView: NSView {
        private var divider: NSView?
        private var targetX: CGFloat

        init(x: CGFloat) {
            self.targetX = x
            super.init(frame: .zero)
        }
        required init?(coder: NSCoder) { fatalError() }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let window, divider == nil else { return }
            placeDivider(in: window)
        }

        func updateX(_ x: CGFloat) {
            targetX = x
            divider?.frame.origin.x = x
        }

        private func placeDivider(in window: NSWindow) {
            guard let contentView = window.contentView else { return }
            let h = window.frame.height          // full window height incl. titlebar
            let line = NSView(frame: CGRect(x: targetX, y: 0, width: 1, height: h))
            line.wantsLayer = true
            line.layer?.backgroundColor = NSColor(red: 0.72, green: 0.70, blue: 0.67, alpha: 1).cgColor
            line.autoresizingMask = [.height]
            contentView.addSubview(line)
            divider = line
        }
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

            let appBgColor = NSColor(srgbRed: 0.93, green: 0.92, blue: 0.91, alpha: 1)

            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.styleMask.insert(.fullSizeContentView)
            window.toolbar = nil
            window.backgroundColor = appBgColor
            window.isOpaque = true

            // 타이틀바 컨테이너에 직접 배경색 레이어 삽입
            if let titlebarContainer = window.standardWindowButton(.closeButton)?
                    .superview?.superview {
                let bg = NSView()
                bg.wantsLayer = true
                bg.layer?.backgroundColor = appBgColor.cgColor
                bg.autoresizingMask = [.width, .height]
                bg.frame = titlebarContainer.bounds
                titlebarContainer.addSubview(bg, positioned: .below, relativeTo: nil)
            }
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
