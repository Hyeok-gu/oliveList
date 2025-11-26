import SwiftUI

struct MyPageView: View {
    @EnvironmentObject var store: OliveStore

    private let themes: [OliveTheme] = [.classic, .modern, .playful]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("테마")) {
                    Picker("올리브 버튼", selection: $store.selectedTheme) {
                        ForEach(themes) { theme in
                            HStack {
                                OliveCompletionButton(isCompleted: true, color: theme.oliveColor, style: theme.oliveStyle, action: {})
                                Text(theme.name)
                            }
                            .tag(theme)
                        }
                    }
                }

                Section(header: Text("폰트")) {
                    Stepper(value: $store.fontScale, in: 0.8...1.4, step: 0.05) {
                        Text("폰트 크기 배율: \(String(format: "%.2f", store.fontScale))x")
                            .font(.themed(store.selectedTheme, size: store.selectedTheme.fontSize * store.fontScale))
                    }
                    Text("폰트 스타일: \(store.selectedTheme.fontName)")
                        .font(.themed(store.selectedTheme))
                        .foregroundColor(.secondary)
                }

                Section(header: Text("가이드"), footer: Text("테마 변경은 메인, 상세, 작성 페이지에 모두 적용됩니다.")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("- 올리브 버튼 디자인을 바꿔보세요")
                        Text("- 잉크톤 컬러로 눈부심을 줄였어요")
                        Text("- AOS 지원을 대비해 색상 대비를 충분히 확보했습니다")
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
            }
            .navigationTitle("마이 페이지")
        }
    }
}
