import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let error):
            return "Request failed: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}

class APIService {
    static let shared = APIService()

    // Change this to your computer's local IP if testing on physical device
    // Use localhost for simulator
    private let baseURL = "http://localhost:3000"

    private init() {}

    private func createRequest(endpoint: String, method: String, body: Data? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        return request
    }

    // MARK: - Tasks API

    func fetchTasks() async throws -> [TaskItem] {
        let request = try createRequest(endpoint: "/tasks", method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            let tasks = try JSONDecoder().decode([TaskItem].self, from: data)
            return tasks
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func fetchTask(id: Int) async throws -> TaskItem {
        let request = try createRequest(endpoint: "/tasks/\(id)", method: "GET")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            let task = try JSONDecoder().decode(TaskItem.self, from: data)
            return task
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func createTask(name: String, description: String?, deadline: String?, status: TaskStatus) async throws -> TaskItem {
        let createRequest = CreateTaskRequest(
            name: name,
            description: description,
            deadline: deadline,
            status: status.rawValue
        )

        let body = try JSONEncoder().encode(createRequest)
        let request = try self.createRequest(endpoint: "/tasks", method: "POST", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            let task = try JSONDecoder().decode(TaskItem.self, from: data)
            return task
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func updateTask(id: Int, name: String?, description: String?, deadline: String?, status: TaskStatus?) async throws -> TaskItem {
        let updateRequest = UpdateTaskRequest(
            name: name,
            description: description,
            deadline: deadline,
            status: status?.rawValue
        )

        let body = try JSONEncoder().encode(updateRequest)
        let request = try self.createRequest(endpoint: "/tasks/\(id)", method: "PATCH", body: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }

        do {
            let task = try JSONDecoder().decode(TaskItem.self, from: data)
            return task
        } catch {
            throw APIError.decodingFailed(error)
        }
    }

    func deleteTask(id: Int) async throws {
        let request = try createRequest(endpoint: "/tasks/\(id)", method: "DELETE")

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
    }
}
