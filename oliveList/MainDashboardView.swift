import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var store: OliveStore
    @State private var selectedDate: Date = Date().stripTime()
    @State private var monthOffset: Int = 0
    @State private var navigateToToday = false
    @State private var showAddSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header
                OliveCalendarView(selectedDate: $selectedDate, monthOffset: $monthOffset)
                    .environmentObject(store)

                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $navigateToToday) {
                DayDetailView(date: Date())
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
                navigateToToday = true
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
