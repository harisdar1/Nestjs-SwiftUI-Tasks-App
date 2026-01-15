import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"

    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    var color: String {
        switch self {
        case .pending: return "orange"
        case .inProgress: return "blue"
        case .completed: return "green"
        }
    }
}

struct TaskItem: Identifiable, Codable {
    let id: Int?
    var name: String
    var description: String?
    var deadline: String?
    var status: TaskStatus
    let createdAt: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, description, deadline, status, createdAt, updatedAt
    }

    init(id: Int? = nil, name: String, description: String? = nil, deadline: String? = nil, status: TaskStatus = .pending, createdAt: String? = nil, updatedAt: String? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.deadline = deadline
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct CreateTaskRequest: Codable {
    let name: String
    let description: String?
    let deadline: String?
    let status: String?
}

struct UpdateTaskRequest: Codable {
    let name: String?
    let description: String?
    let deadline: String?
    let status: String?
}
