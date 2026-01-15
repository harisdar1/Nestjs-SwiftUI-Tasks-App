//
//  RegisterViewModel.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//


import Foundation
internal import Combine

@MainActor
class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showErrorAlert: Bool = false
    @Published var showSuccessAlert: Bool = false
    @Published var registrationSuccess: Bool = false
    
    private let authManager = AuthManager.shared
    
    func register() {
        guard validateInputs() else { return }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.register(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName
                )
                
                // Registration successful
                print("✅ Registration successful for: \(response.email)")
                
                // Auto-login after registration
                try await autoLoginAfterRegistration()
                
            } catch {
                handleError(error)
            }
            isLoading = false
        }
    }
    
    private func autoLoginAfterRegistration() async throws {
        do {
            let success = try await authManager.login(email: email, password: password)
            if success {
                registrationSuccess = true
                showSuccessAlert = true
                // Clear form
                clearForm()
            }
        } catch {
            // Registration succeeded but auto-login failed
            // User can still login manually
            registrationSuccess = true
            showSuccessAlert = true
            clearForm()
        }
    }
    
    private func validateInputs() -> Bool {
        // Email validation
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
        
        // First name validation
        if firstName.isEmpty {
            errorMessage = "Please enter your first name"
            showErrorAlert = true
            return false
        }
        
        if firstName.count < 2 {
            errorMessage = "First name must be at least 2 characters"
            showErrorAlert = true
            return false
        }
        
        // Last name validation
        if lastName.isEmpty {
            errorMessage = "Please enter your last name"
            showErrorAlert = true
            return false
        }
        
        if lastName.count < 2 {
            errorMessage = "Last name must be at least 2 characters"
            showErrorAlert = true
            return false
        }
        
        // Password validation
        if password.isEmpty {
            errorMessage = "Please enter a password"
            showErrorAlert = true
            return false
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            showErrorAlert = true
            return false
        }
        
        // Confirm password validation
        if confirmPassword.isEmpty {
            errorMessage = "Please confirm your password"
            showErrorAlert = true
            return false
        }
        
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
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
    
//    private func isPasswordStrong(_ password: String) -> Bool {
//        // At least one uppercase, one lowercase, one number
//        let passwordRegEx = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d).{6,}$"
//        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
//        return passwordPred.evaluate(with: password)
//    }
    
    private func handleError(_ error: Error) {
        if let nsError = error as NSError? {
            if nsError.domain == "APIError" {
                // Extract error message from server
                if nsError.code == 409 {
                    errorMessage = "Email already registered. Please use a different email or login."
                } else {
                    errorMessage = nsError.localizedDescription
                }
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
                errorMessage = "Registration failed. Please try again."
            }
        } else {
            errorMessage = error.localizedDescription
        }
        showErrorAlert = true
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        firstName = ""
        lastName = ""
    }
}
