import SwiftUI

struct ContentView: View {
    @StateObject private var store = OliveStore()

    var body: some View {
        TabView {
            MainDashboardView()
                .environmentObject(store)
                .tabItem {
                    Label("홈", systemImage: "calendar")
                }

            DayDetailView(date: Date())
                .environmentObject(store)
                .tabItem {
                    Label("Today", systemImage: "list.bullet")
                }

            MyPageView()
                .environmentObject(store)
                .tabItem {
                    Label("마이", systemImage: "person.crop.circle")
                }
        }
        .accentColor(store.selectedTheme.oliveColor)
    }
}

#Preview {
    ContentView()
}
