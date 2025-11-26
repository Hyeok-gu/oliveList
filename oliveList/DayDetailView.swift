import SwiftUI

struct DotPaperBackground: View {
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 12
            let diameter: CGFloat = 1.5
            let columns = Int(geometry.size.width / spacing)
            let rows = Int(geometry.size.height / spacing)

            ZStack {
                Color(red: 0.96, green: 0.96, blue: 0.95)
                Canvas { context, size in
                    for row in 0...rows {
                        for column in 0...columns {
                            let x = CGFloat(column) * spacing
                            let y = CGFloat(row) * spacing
                            let rect = CGRect(x: x, y: y, width: diameter, height: diameter)
                            context.fill(Path(ellipseIn: rect), with: .color(Color(.darkGray).opacity(0.25)))
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}

struct DayDetailView: View {
    @EnvironmentObject var store: OliveStore
    @State private var currentDate: Date
    @State private var showAddSheet = false

    init(date: Date) {
        _currentDate = State(initialValue: date.stripTime())
    }

    private var formatter: DateFormatter {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "M월 d일 (E)"
        return f
    }

    private var tasksForDay: [OliveTask] {
        store.tasks(for: currentDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(tasksForDay) { task in
                        OliveTaskRow(task: task) {
                            store.toggleTask(task)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                store.toggleTask(task)
                            } label: {
                                Label(task.isDone ? "취소" : "완료", systemImage: task.isDone ? "arrow.uturn.backward" : "checkmark")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                store.deleteTask(task)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal)
                    }

                    moodSelector
                }
                .padding(.vertical, 24)
            }
        }
        .background(DotPaperBackground())
        .sheet(isPresented: $showAddSheet) {
            AddTaskView(initialDate: currentDate)
                .environmentObject(store)
        }
        .gesture(DragGesture(minimumDistance: 20)
            .onEnded { value in
                if value.translation.width < -40 {
                    moveDay(by: 1)
                } else if value.translation.width > 40 {
                    moveDay(by: -1)
                }
            }
        )
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack {
                Text(formatter.string(from: currentDate))
                    .font(.themed(store.selectedTheme, size: 24 * store.fontScale))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                Spacer()
                Button {
                    showAddSheet = true
                } label: {
                    Label("올리브 추가", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(store.selectedTheme.oliveColor)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 16)
        .background(.ultraThinMaterial)
    }

    private var moodSelector: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 기분")
                .font(.headline)
                .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                .padding(.horizontal)

            HStack(spacing: 16) {
                ForEach(Array(Mood.allCases.enumerated()), id: \.0) { _, mood in
                    MoodRadioButton(isSelected: store.mood(for: currentDate) == mood, color: mood.color) {
                        store.setMood(store.mood(for: currentDate) == mood ? nil : mood, for: currentDate)
                    }
                    .accessibilityLabel(mood.label)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }

    private func moveDay(by value: Int) {
        if let nextDate = Calendar.current.date(byAdding: .day, value: value, to: currentDate) {
            currentDate = nextDate.stripTime()
        }
    }
}

struct OliveTaskRow: View {
    @EnvironmentObject var store: OliveStore
    var task: OliveTask
    var toggle: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            OliveCompletionButton(isCompleted: task.isDone, color: store.selectedTheme.oliveColor, style: store.selectedTheme.oliveStyle, action: toggle)
                .frame(width: 32, height: 32)

            Text(task.title)
                .font(.themed(store.selectedTheme, size: store.selectedTheme.fontSize * store.fontScale))
                .fontWeight(.medium)
                .foregroundColor(Color(#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)))
                .opacity(task.isDone ? 0.5 : 1)
                .strikethrough(task.isDone)

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct OliveCompletionButton: View {
    var isCompleted: Bool
    var color: Color
    var style: OliveTheme.OliveStyle
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                switch style {
                case .outline:
                    Circle()
                        .stroke(color, lineWidth: 2)
                        .frame(width: 28, height: 28)
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .foregroundStyle(color)
                    }
                case .filled:
                    Circle()
                        .fill(isCompleted ? color : Color.white)
                        .overlay(
                            Circle()
                                .stroke(color, lineWidth: 2)
                        )
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: isCompleted ? "checkmark" : "leaf")
                                .foregroundColor(isCompleted ? .white : color)
                        )
                case .drop:
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isCompleted ? color : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(color, lineWidth: 2)
                        )
                        .frame(width: 28, height: 32)
                        .overlay(
                            Image(systemName: isCompleted ? "checkmark" : "drop.fill")
                                .foregroundColor(isCompleted ? .white : color)
                        )
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct MoodRadioButton: View {
    var isSelected: Bool
    var color: Color
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                Circle()
                    .stroke(color, lineWidth: 2)
                if isSelected {
                    Circle()
                        .fill(color)
                        .frame(width: 12, height: 12)
                }
            }
            .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}
