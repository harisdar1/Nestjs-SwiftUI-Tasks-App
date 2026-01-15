import Foundation
import Observation

@Observable
class TasksViewModel {
    var tasks: [TaskItem] = []
    var isLoading = false
    var errorMessage: String?
    var showError = false

    private let apiService = APIService.shared

    @MainActor
    func fetchTasks() async {
        isLoading = true
        errorMessage = nil

        do {
            tasks = try await apiService.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }

        isLoading = false
    }

    @MainActor
    func createTask(name: String, description: String?, deadline: Date?, status: TaskStatus) async -> Bool {
        isLoading = true
        errorMessage = nil

        let deadlineString = deadline.map { formatDateForAPI($0) }

        do {
            let newTask = try await apiService.createTask(
                name: name,
                description: description,
                deadline: deadlineString,
                status: status
            )
            tasks.insert(newTask, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }

    @MainActor
    func updateTask(id: Int, name: String?, description: String?, deadline: Date?, status: TaskStatus?) async -> Bool {
        isLoading = true
        errorMessage = nil

        let deadlineString = deadline.map { formatDateForAPI($0) }

        do {
            let updatedTask = try await apiService.updateTask(
                id: id,
                name: name,
                description: description,
                deadline: deadlineString,
                status: status
            )

            if let index = tasks.firstIndex(where: { $0.id == id }) {
                tasks[index] = updatedTask
            }

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }

    @MainActor
    func deleteTask(id: Int) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            try await apiService.deleteTask(id: id)
            tasks.removeAll { $0.id == id }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            isLoading = false
            return false
        }
    }

    @MainActor
    func deleteTask(at indexSet: IndexSet) async {
        for index in indexSet {
            if let id = tasks[index].id {
                _ = await deleteTask(id: id)
            }
        }
    }

    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }

    func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        if let date = formatter.date(from: dateString) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: dateString)
    }
}
