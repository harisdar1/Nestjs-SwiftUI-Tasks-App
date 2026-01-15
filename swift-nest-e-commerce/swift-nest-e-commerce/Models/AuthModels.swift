//
//  AuthModels.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//

import Foundation

// MARK: - Login Models
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let access_token: String
    let user: User
}



// Add to your existing models file or create new
struct RegisterRequest: Codable {
    let email: String
    let password: String
    let firstName: String
    let lastName: String
}

struct RegisterResponse: Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let role: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, role
        case firstName = "firstName"
        case lastName = "lastName"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let firstName: String?
    let lastName: String?
    let role: String
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, email, role
        case firstName = "firstName"
        case lastName = "lastName"
        case createdAt = "createdAt"
        case updatedAt = "updatedAt"
    }
}




