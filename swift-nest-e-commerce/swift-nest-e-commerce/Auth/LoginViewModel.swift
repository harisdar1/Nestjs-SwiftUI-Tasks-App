//
//  LoginViewModel.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//


import Foundation
internal import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    
    private let authManager = AuthManager.shared
    
    func login() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await authManager.login(email: email, password: password)
                
                if success {
                    // Success - navigation will be handled by AuthManager state
                    print("✅ Login successful!")
                    // Clear password for security
                    password = ""
                }
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    private func validateInputs() -> Bool {
        if email.isEmpty {
            errorMessage = "Please enter your email"
            showErrorAlert = true
            return false
        }
        
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address"
            showErrorAlert = true
            return false
        }
        
        if password.isEmpty {
            errorMessage = "Please enter your password"
            showErrorAlert = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showErrorAlert = true
            return false
        }
        
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleError(_ error: Error) {
        if let nsError = error as NSError? {
            if nsError.domain == "APIError" {
                errorMessage = nsError.localizedDescription
            } else if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    errorMessage = "No internet connection"
                case NSURLErrorTimedOut:
                    errorMessage = "Connection timeout"
                case NSURLErrorCannotConnectToHost:
                    errorMessage = "Cannot connect to server"
                default:
                    errorMessage = "Network error occurred"
                }
            } else {
                errorMessage = "Login failed. Please try again."
            }
        } else {
            errorMessage = error.localizedDescription
        }
        showErrorAlert = true
    }
}
