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

                Spacer(minLength: 12)

                NavigationLink(destination: DayDetailView(date: selectedDate).environmentObject(store)) {
                    previewCard
                }
                .buttonStyle(.plain)

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

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("선택한 날짜")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(dateString(for: selectedDate))
                .font(.system(size: 22 * store.fontScale, weight: .bold))
                .foregroundColor(.primary)
            if store.tasks(for: selectedDate).isEmpty {
                Text("아직 등록된 올리브가 없어요. 추가 버튼을 눌러보세요")
                    .foregroundColor(.secondary)
                    .font(.callout)
            } else {
                ForEach(store.tasks(for: selectedDate).prefix(3)) { task in
                    HStack {
                        OliveCompletionButton(isCompleted: task.isDone, color: store.selectedTheme.oliveColor, style: store.selectedTheme.oliveStyle) {
                            store.toggleTask(task)
                        }
                        Text(task.title)
                            .font(.themed(store.selectedTheme, size: store.selectedTheme.fontSize * store.fontScale))
                        Spacer()
                    }
                }
                if store.tasks(for: selectedDate).count > 3 {
                    Text("외 \(store.tasks(for: selectedDate).count - 3)개의 올리브")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E)"
        return formatter.string(from: date)
    }
}
