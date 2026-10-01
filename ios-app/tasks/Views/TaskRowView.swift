import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    var viewModel: TasksViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.headline)
                    .strikethrough(task.status == .completed)
                    .foregroundColor(task.status == .completed ? .secondary : .primary)

                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                HStack(spacing: 8) {
                    Text(task.status.displayName)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.2))
                        .foregroundColor(statusColor)
                        .cornerRadius(4)

                    if let deadline = task.deadline {
                        if let date = viewModel.parseDate(deadline) {
                            HStack(spacing: 2) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                Text(formatDisplayDate(date))
                                    .font(.caption)
                            }
                            .foregroundColor(isOverdue(date) ? .red : .secondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch task.status {
        case .pending:
            return .orange
        case .inProgress:
            return .blue
        case .completed:
            return .green
        }
    }

    private func formatDisplayDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    private func isOverdue(_ date: Date) -> Bool {
        return date < Date() && task.status != .completed
    }
}
