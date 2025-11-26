import SwiftUI

struct OliveTask: Identifiable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var isDone: Bool

    init(id: UUID = UUID(), title: String, date: Date, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.date = date
        self.isDone = isDone
    }
}

enum Mood: String, CaseIterable, Identifiable {
    case joy, calm, focus, tired, anxious, grateful

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .joy: return Color.orange
        case .calm: return Color.blue
        case .focus: return Color.green
        case .tired: return Color.gray
        case .anxious: return Color.red
        case .grateful: return Color.purple
        }
    }

    var label: String {
        switch self {
        case .joy: return "기쁨"
        case .calm: return "차분"
        case .focus: return "집중"
        case .tired: return "피곤"
        case .anxious: return "걱정"
        case .grateful: return "감사"
        }
    }
}

struct OliveTheme: Identifiable, Equatable, Hashable {
    let id = UUID()
    var name: String
    var oliveColor: Color
    var fontName: String
    var fontSize: CGFloat
    var oliveStyle: OliveStyle

    enum OliveStyle: String, CaseIterable, Identifiable {
        case outline
        case filled
        case drop

        var id: String { rawValue }
    }

    static let classic = OliveTheme(
        name: "클래식",
        oliveColor: Color(#colorLiteral(red: 0.3568627536, green: 0.6156862974, blue: 0.2823529541, alpha: 1)),
        fontName: "NewYork", // fallback handled in view
        fontSize: 18,
        oliveStyle: .filled
    )

    static let modern = OliveTheme(
        name: "모던",
        oliveColor: Color(#colorLiteral(red: 0.870588243, green: 0.5803921819, blue: 0.1882352978, alpha: 1)),
        fontName: "SFProRounded-Regular",
        fontSize: 17,
        oliveStyle: .outline
    )

    static let playful = OliveTheme(
        name: "플레이풀",
        oliveColor: Color(#colorLiteral(red: 0.2549019754, green: 0.5098039508, blue: 0.3372549117, alpha: 1)),
        fontName: "AvenirNext-DemiBold",
        fontSize: 19,
        oliveStyle: .drop
    )
}

final class OliveStore: ObservableObject {
    @Published var tasks: [OliveTask]
    @Published var moods: [Date: Mood]
    @Published var selectedTheme: OliveTheme
    @Published var fontScale: CGFloat

    init(
        tasks: [OliveTask] = OliveStore.sampleTasks,
        moods: [Date: Mood] = [:],
        selectedTheme: OliveTheme = .classic,
        fontScale: CGFloat = 1.0
    ) {
        self.tasks = tasks
        self.moods = moods
        self.selectedTheme = selectedTheme
        self.fontScale = fontScale
    }

    func tasks(for date: Date) -> [OliveTask] {
        let day = date.stripTime()
        return tasks.filter { $0.date.stripTime() == day }
    }

    func addTask(title: String, date: Date) {
        let newTask = OliveTask(title: title, date: date)
        tasks.append(newTask)
    }

    func toggleTask(_ task: OliveTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else { return }
        tasks[index].isDone.toggle()
    }

    func deleteTask(_ task: OliveTask) {
        tasks.removeAll { $0.id == task.id }
    }

    func statusColor(for date: Date) -> Color? {
        let dayTasks = tasks(for: date)
        guard !dayTasks.isEmpty else { return nil }
        return dayTasks.allSatisfy { $0.isDone } ? .green : .orange
    }

    func setMood(_ mood: Mood?, for date: Date) {
        let key = date.stripTime()
        moods[key] = mood
    }

    func mood(for date: Date) -> Mood? {
        moods[date.stripTime()]
    }
}

extension OliveStore {
    static let sampleTasks: [OliveTask] = {
        let calendar = Calendar.current
        let today = Date().stripTime()
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? today

        return [
            OliveTask(title: "아침 요가", date: today, isDone: false),
            OliveTask(title: "코어모듈 리팩토링", date: today, isDone: false),
            OliveTask(title: "친구와 점심", date: tomorrow, isDone: false),
            OliveTask(title: "주간 리뷰 작성", date: yesterday, isDone: true)
        ]
    }()
}

extension Date {
    func stripTime() -> Date {
        Calendar.current.startOfDay(for: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
}

extension Font {
    static func themed(_ theme: OliveTheme, size: CGFloat? = nil) -> Font {
        let fontSize = size ?? theme.fontSize
        return Font.custom(theme.fontName, size: fontSize)
    }
}
