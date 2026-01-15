//
//  AuthManager.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//


import Foundation
import SwiftUI
internal import Combine

@MainActor
class AuthManager: ObservableObject {
    static let shared = AuthManager()
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    private init() {
        // Check if user is already logged in on app launch
        self.isAuthenticated = APIService.isLoggedIn()
        // You might want to fetch user data here if token exists
    }
    
    func login(email: String, password: String) async throws -> Bool {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.shared.login(email: email, password: password)
            
            // Save token
            APIService.saveToken(response.access_token)
            
            // Update auth state
            self.currentUser = response.user
            self.isAuthenticated = true
            
            // Save user data for persistence
            saveUserData(response.user)
            
            print("✅ Login successful for: \(response.user.email)")
            return true
            
        } catch {
            print("❌ Login failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
    func logout() {
        APIService.clearToken()
        clearUserData()
        isAuthenticated = false
        currentUser = nil
    }
    
    // MARK: - User Data Persistence
    private func saveUserData(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    private func clearUserData() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
    
    func loadUserData() -> User? {
        guard let data = UserDefaults.standard.data(forKey: "currentUser"),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            return nil
        }
        return user
    }
}
