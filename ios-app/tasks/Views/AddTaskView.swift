import SwiftUI

struct AddTaskView: View {
    var viewModel: TasksViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var hasDeadline = false
    @State private var deadline = Date()
    @State private var status: TaskStatus = .pending
    @State private var isSaving = false

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
            }
            .navigationTitle("New Task")
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
        isSaving = true

        Task {
            let success = await viewModel.createTask(
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
}

#Preview {
    AddTaskView(viewModel: TasksViewModel())
}
