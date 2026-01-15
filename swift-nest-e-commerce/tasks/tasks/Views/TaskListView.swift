import SwiftUI

struct TaskListView: View {
    @State private var viewModel = TasksViewModel()
    @State private var showAddTask = false
    @State private var selectedTask: TaskItem?
    @State private var filterStatus: TaskStatus?

    var filteredTasks: [TaskItem] {
        if let filter = filterStatus {
            return viewModel.tasks.filter { $0.status == filter }
        }
        return viewModel.tasks
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "All", isSelected: filterStatus == nil) {
                            filterStatus = nil
                        }

                        ForEach(TaskStatus.allCases, id: \.self) { status in
                            FilterChip(
                                title: status.displayName,
                                isSelected: filterStatus == status,
                                color: statusColor(status)
                            ) {
                                filterStatus = status
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGroupedBackground))

                // Task list
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    Spacer()
                    ProgressView("Loading tasks...")
                    Spacer()
                } else if filteredTasks.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)

                        Text(filterStatus == nil ? "No tasks yet" : "No \(filterStatus!.displayName.lowercased()) tasks")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Text("Tap + to add your first task")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredTasks) { task in
                            TaskRowView(task: task, viewModel: viewModel)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedTask = task
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        if let id = task.id {
                                            Task {
                                                await viewModel.deleteTask(id: id)
                                            }
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        toggleTaskStatus(task)
                                    } label: {
                                        Label(
                                            task.status == .completed ? "Reopen" : "Complete",
                                            systemImage: task.status == .completed ? "arrow.uturn.backward" : "checkmark"
                                        )
                                    }
                                    .tint(task.status == .completed ? .orange : .green)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await viewModel.fetchTasks()
                    }
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddTask = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddTask) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $selectedTask) { task in
                EditTaskView(viewModel: viewModel, task: task)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "An unknown error occurred")
            }
            .task {
                await viewModel.fetchTasks()
            }
        }
    }

    private func statusColor(_ status: TaskStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }

    private func toggleTaskStatus(_ task: TaskItem) {
        guard let id = task.id else { return }

        let newStatus: TaskStatus = task.status == .completed ? .pending : .completed

        Task {
            await viewModel.updateTask(
                id: id,
                name: nil,
                description: nil,
                deadline: nil,
                status: newStatus
            )
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color(.systemBackground))
                .foregroundColor(isSelected ? color : .primary)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? color : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    TaskListView()
}
