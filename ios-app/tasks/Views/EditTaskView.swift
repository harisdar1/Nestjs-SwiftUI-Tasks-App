import SwiftUI

struct EditTaskView: View {
    var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss
    let task: TaskItem

    @State private var name: String
    @State private var description: String
    @State private var hasDeadline: Bool
    @State private var deadline: Date
    @State private var status: TaskStatus
    @State private var isSaving = false

    init(viewModel: TasksViewModel, task: TaskItem) {
        self.viewModel = viewModel
        self.task = task
        _name = State(initialValue: task.name)
        _description = State(initialValue: task.description ?? "")
        _status = State(initialValue: task.status)

        if let deadlineString = task.deadline,
           let parsedDate = viewModel.parseDate(deadlineString) {
            _hasDeadline = State(initialValue: true)
            _deadline = State(initialValue: parsedDate)
        } else {
            _hasDeadline = State(initialValue: false)
            _deadline = State(initialValue: Date())
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Task Details") {
                    TextField("Task Name", text: $name)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Status") {
                    Picker("Status", selection: $status) {
                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            Text(status.displayName).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Deadline") {
                    Toggle("Set Deadline", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker("Deadline", selection: $deadline, displayedComponents: [.date, .hourAndMinute])
                    }
                }

                Section {
                    Button(role: .destructive) {
                        deleteTask()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Task")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(name.isEmpty || isSaving)
                }
            }
            .disabled(isSaving)
            .overlay {
                if isSaving {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
        }
    }

    private func saveTask() {
        guard let id = task.id else { return }
        isSaving = true

        Task {
            let success = await viewModel.updateTask(
                id: id,
                name: name,
                description: description.isEmpty ? nil : description,
                deadline: hasDeadline ? deadline : nil,
                status: status
            )

            if success {
                dismiss()
            }
            isSaving = false
        }
    }

    private func deleteTask() {
        guard let id = task.id else { return }
        isSaving = true

        Task {
            let success = await viewModel.deleteTask(id: id)

            if success {
                dismiss()
            }
            isSaving = false
        }
    }
}
