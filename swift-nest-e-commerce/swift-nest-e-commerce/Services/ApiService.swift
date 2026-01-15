//
//  ApiService.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//

import Foundation
import UIKit

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(String)
}



class APIService {
    static let shared = APIService()
    private init() {}
    
    private let baseURL = "http://localhost:3000"
    
    // Generic request
    
    
    static var accessToken: String? {
         UserDefaults.standard.string(forKey: "accessToken")
     }

     static var authHeaders: [String: String] {
         if let token = accessToken {
             return ["Authorization": "Bearer \(token)"]
         } else {
             return [:]
         }
     }
 

    private func statusCheckRequest<U: Encodable>(
        endpoint: String,
        method: String = "POST",
        body: U,
        headers: [String: String] = [:]
    ) async throws -> Bool {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        request.httpBody = try JSONEncoder().encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        return httpResponse.statusCode == 200
    }

    private func request<T: Decodable, U: Encodable>(
        endpoint: String,
        method: String = "POST",
        body: U,
        responseType: T.Type,
        headers: [String: String] = [:]
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
   
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        do {
            
            if(method == "POST"){
                request.httpBody = try JSONEncoder().encode(body)
                
                if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                    print("Request Body: \(jsonString)")
                }

            }
       
            
        } catch {
            throw error
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NSError(domain: "APIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorResponse.message ?? "Unknown error"])
            } else {
                throw URLError(.badServerResponse)
            }
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    
    func uploadMultipart<T: Decodable>(
        endpoint: String,
        parameters: [String: String],
        image: UIImage?,
        imageFieldName: String = "profileImage",
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T{

        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Boundary for multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Add custom headers (like Authorization)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Build multipart body
        var body = Data()

        // Add text parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add image if provided
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(imageFieldName)\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    func uploadMultipartWithImages<T: Decodable>(
        endpoint: String,
        jsonData: [String: Any],
        images: [UIImage],
        headers: [String: String] = [:],
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Boundary for multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Add custom headers (like Authorization)
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Build multipart body
        var body = Data()

        // Add JSON data as string
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonData, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"jsonData\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(jsonString)\r\n".data(using: .utf8)!)
        }

        // Add images
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"images\"; filename=\"parcel_\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }

        // End boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        // Perform request
        let (data, response) = try await URLSession.shared.data(for: request)

        if let httpResponse = response as? HTTPURLResponse {
            print("Status Code: \(httpResponse.statusCode)")
        }

        if let responseString = String(data: data, encoding: .utf8) {
            print("Response Data: \(responseString)")
        }

        guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }



    struct ErrorResponse: Codable {
        let message: String?
        let success: Bool?
    }
    func register(email: String, password: String, firstName: String, lastName: String) async throws -> RegisterResponse {
        let registerRequest = RegisterRequest(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName
        )
        
        return try await request(
            endpoint: "/auth/register",
            method: "POST",
            body: registerRequest,
            responseType: RegisterResponse.self
        )
    }

    func login(email: String, password: String) async throws -> LoginResponse {
            let loginRequest = LoginRequest(email: email, password: password)
            
            return try await request(
                endpoint: "/auth/login",
                method: "POST",
                body: loginRequest,
                responseType: LoginResponse.self
            )
        }
    
    func getCategories() async throws -> [Category] {
           return try await request(
               endpoint: "/categories",
               method: "GET",
               body: "",
               responseType: [Category].self,
               headers: APIService.authHeaders
           )
       }
       
       func getProducts() async throws -> [Product] {
           return try await request(
               endpoint: "/products",
               method: "GET",
               body: "",
               responseType: [Product].self,
               headers: APIService.authHeaders
           )
       }
    func getMyCart() async throws -> CartResponse {
           return try await request(
               endpoint: "/carts/my-cart",
               method: "GET",
               body: "",
               responseType: CartResponse.self,
               headers: APIService.authHeaders
           )
       }
       
       // Add product to cart
       func addToCart(productId: String, quantity: Int) async throws -> CartResponse {
           let requestBody = AddToCartRequest(productId: productId, quantity: quantity)
           
           return try await request(
               endpoint: "/carts/add",
               method: "POST",
               body: requestBody,
               responseType: CartResponse.self,
               headers: APIService.authHeaders
           )
       }
       
       // Remove product from cart
       func removeFromCart(productId: String) async throws -> CartResponse {
           return try await request(
               endpoint: "/carts/remove/\(productId)",
               method: "DELETE",
               body: "",
               responseType: CartResponse.self,
               headers: APIService.authHeaders
           )
       }
       
       // Clear entire cart
       func clearCart() async throws -> Bool {
           return try await statusCheckRequest(
               endpoint: "/carts/clear",
               method: "DELETE",
               body: "",
               headers: APIService.authHeaders
           )
       }

    // MARK: - Orders

    // Get all orders for current user
    func getMyOrders() async throws -> [Order] {
        return try await request(
            endpoint: "/orders",
            method: "GET",
            body: "",
            responseType: [Order].self,
            headers: APIService.authHeaders
        )
    }

    // Get single order by ID
    func getOrder(id: String) async throws -> Order {
        return try await request(
            endpoint: "/orders/\(id)",
            method: "GET",
            body: "",
            responseType: Order.self,
            headers: APIService.authHeaders
        )
    }

    // Create order from cart
    func createOrder() async throws -> Order {
        return try await request(
            endpoint: "/orders",
            method: "POST",
            body: "",
            responseType: Order.self,
            headers: APIService.authHeaders
        )
    }

        static func saveToken(_ token: String) {
            UserDefaults.standard.set(token, forKey: "accessToken")
            print("✅ Token saved: \(token.prefix(20))...")
        }
        
        static func clearToken() {
            UserDefaults.standard.removeObject(forKey: "accessToken")
            print("🗑️ Token cleared")
        }
        
        static func isLoggedIn() -> Bool {
            return accessToken != nil
        }
  
}
