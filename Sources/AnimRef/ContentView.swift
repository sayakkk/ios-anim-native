import SwiftUI

struct ContentView: View {
    @State private var search = ""
    @State private var activeCategory = "전체"

    private let accent = Color(red: 0.94, green: 0.66, blue: 0.26)
    private let categories = ["전체", "👆 버튼 · 탭 반응", "📱 화면 전환", "📋 리스트 · 등장",
                               "⏳ 로딩 · 대기", "🔔 알림 · 피드백", "🔄 반복 효과", "✋ 제스처"]

    private var filtered: [AnimationItem] {
        AnimationData.all.filter { item in
            let matchCat = activeCategory == "전체" || item.situationCategory == activeCategory
            let q = search.lowercased()
            let matchSearch = q.isEmpty ||
                item.feel.lowercased().contains(q) ||
                item.name.lowercased().contains(q) ||
                item.when.lowercased().contains(q)
            return matchCat && matchSearch
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.04, blue: 0.02).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        // Category scroll
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

                        // Grid
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(filtered) { item in
                                AnimationCardView(item: item)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("iOS 움직임 사전")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.05, green: 0.04, blue: 0.02), for: .navigationBar)
            .searchable(text: $search, prompt: "\"통통\", \"흔들\", \"슬라이드\"...")
        }
        .preferredColorScheme(.dark)
        .tint(accent)
    }
}
