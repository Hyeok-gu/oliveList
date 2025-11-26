import SwiftUI

struct AddTaskView: View {
    @EnvironmentObject var store: OliveStore
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var selectedDate: Date

    init(initialDate: Date) {
        _selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("날짜")) {
                    DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                }

                Section(header: Text("할 일")) {
                    TextField("해야 할 일을 입력하세요", text: $title)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("새 올리브")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") { addTask() }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(action: addTask) {
                        Label("올리브 추가", systemImage: "plus")
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func addTask() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        store.addTask(title: trimmed, date: selectedDate)
        title = ""
        dismiss()
    }
}
