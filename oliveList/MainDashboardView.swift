import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var store: OliveStore
    @State private var selectedDate: Date = Date().stripTime()
    @State private var monthOffset: Int = 0
    @State private var showAddSheet = false
    @State private var navigationPath: [Date] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 16) {
                header
                OliveCalendarView(selectedDate: $selectedDate, monthOffset: $monthOffset) { date in
                    navigationPath.append(date.stripTime())
                }
                    .environmentObject(store)

                Spacer()
            }
            .padding()
            .navigationDestination(for: Date.self) { date in
                DayDetailView(date: date)
                    .environmentObject(store)
            }
            .sheet(isPresented: $showAddSheet) {
                AddTaskView(initialDate: Date())
                    .environmentObject(store)
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            Text("Olive")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(store.selectedTheme.oliveColor)

            Spacer()

            Button {
                showAddSheet = true
            } label: {
                Label("올리브 추가", systemImage: "plus.circle.fill")
                    .labelStyle(.titleAndIcon)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(store.selectedTheme.oliveColor.opacity(0.15)))
            }
            .buttonStyle(.plain)

            Button {
                navigationPath.append(Date().stripTime())
            } label: {
                Text("Today")
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray5)))
            }
            .buttonStyle(.plain)
        }
    }

}
