import SwiftUI

struct MonthGridDay: Identifiable {
    let id = UUID()
    let date: Date?
    let isToday: Bool
}

struct OliveCalendarView: View {
    @EnvironmentObject var store: OliveStore
    @Binding var selectedDate: Date
    @Binding var monthOffset: Int
    @State private var swipeDirection: Edge = .trailing

    private var displayMonth: Date {
        Calendar.current.date(byAdding: .month, value: monthOffset, to: Date()) ?? Date()
    }

    private var monthTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YYYY년 M월"
        return formatter.string(from: displayMonth)
    }

    private var days: [MonthGridDay] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: displayMonth) ?? 1..<31
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayMonth)) ?? displayMonth
        let offset = calendar.component(.weekday, from: firstDay) - calendar.firstWeekday
        let leading = offset < 0 ? offset + 7 : offset

        var cells: [MonthGridDay] = Array(repeating: MonthGridDay(date: nil, isToday: false), count: leading)
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                cells.append(MonthGridDay(date: date, isToday: date.isToday))
            }
        }
        return cells
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(monthTitle)
                    .font(.title3.bold())
                Spacer()
                HStack(spacing: 12) {
                    Button(action: {
                        swipeDirection = .leading
                        withAnimation(.easeInOut) { monthOffset -= 1 }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                    Button(action: {
                        swipeDirection = .trailing
                        withAnimation(.easeInOut) { monthOffset = 0 }
                    }) {
                        Text("오늘")
                            .font(.callout.weight(.semibold))
                    }
                    Button(action: {
                        swipeDirection = .trailing
                        withAnimation(.easeInOut) { monthOffset += 1 }
                    }) {
                        Image(systemName: "chevron.right")
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray5)))
                    }
                }
                .buttonStyle(.plain)
            }

            ZStack {
                monthGrid
                    .id(displayMonth)
                    .transition(.asymmetric(
                        insertion: .move(edge: swipeDirection == .leading ? .leading : .trailing),
                        removal: .move(edge: swipeDirection == .leading ? .trailing : .leading)
                    ))
            }
            .animation(.easeInOut, value: monthOffset)
        }
        .frame(height: 360)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.width < -40 {
                    swipeDirection = .trailing
                    withAnimation(.easeInOut) { monthOffset += 1 }
                } else if value.translation.width > 40 {
                    swipeDirection = .leading
                    withAnimation(.easeInOut) { monthOffset -= 1 }
                }
            }
        )
    }

    private var monthGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 12) {
            ForEach(days) { day in
                if let date = day.date {
                    Button {
                        selectedDate = date
                    } label: {
                        VStack(spacing: 6) {
                            Text("\(Calendar.current.component(.day, from: date))")
                                .font(.headline)
                                .foregroundColor(day.isToday ? .orange : .primary)
                            Circle()
                                .fill(store.statusColor(for: date) ?? Color.clear)
                                .frame(width: 8, height: 8)
                        }
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .padding(6)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(date.stripTime() == selectedDate.stripTime() ? Color(.systemGray6) : Color.clear)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer().frame(height: 48)
                }
            }
        }
    }
}
