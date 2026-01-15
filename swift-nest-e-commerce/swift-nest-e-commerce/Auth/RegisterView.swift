//
//  RegisterView.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()
    @Environment(\.dismiss) var dismiss
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, lastName, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Gradient Background
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        RegisterHeaderSection(dismiss: dismiss)
                        
                        // Registration Form
                        RegisterFormSection(viewModel: viewModel, focusedField: $focusedField)
                        
                        // Terms & Conditions
                        TermsSection()
                        
                        // Register Button
                        RegisterButtonSection(viewModel: viewModel)
                        
                        Spacer(minLength: 40)
                        
                        // Login Link
                        LoginSection(dismiss: dismiss)
                    }
                    .padding(.horizontal, 24)
                }
                .scrollDismissesKeyboard(.interactively)
                .scrollIndicators(.hidden)
                
                // Loading Overlay
                if viewModel.isLoading {
                    LoadingOverlay()
                }
            }
            .alert("Registration Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .alert("Registration Successful", isPresented: $viewModel.showSuccessAlert) {
                Button("Continue", role: .cancel) {
                    // Dismiss to login or navigate to main app
                    // AuthManager will handle navigation
                }
            } message: {
                if viewModel.registrationSuccess {
                    Text("Your account has been created successfully! You're now logged in.")
                } else {
                    Text("Account created! Please login with your credentials.")
                }
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Register Subviews

struct RegisterHeaderSection: View {
    let dismiss: DismissAction
    
    var body: some View {
        VStack(spacing: 20) {
            // Back button and title
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.15))
                    )
                }
                
                Spacer()
                
                Text("Create Account")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(0)
                
                Spacer()
                
                // Invisible spacer for symmetry
                Color.clear
                    .frame(width: 70)
            }
            .padding(.top, 20)
            
            // Logo
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                
                Image(systemName: "person.badge.plus.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
            
            // Welcome Text
            VStack(spacing: 8) {
                Text("Join Us Today")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text("Create your account to get started")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.bottom, 30)
    }
}

struct RegisterFormSection: View {
    @ObservedObject var viewModel: RegisterViewModel
    @FocusState.Binding var focusedField: RegisterView.Field?
    
    var body: some View {
        VStack(spacing: 20) {
            // Name Fields (Horizontal)
            HStack(spacing: 16) {
                // First Name
                VStack(alignment: .leading, spacing: 8) {
                    FloatingLabelTextField(
                        title: "First Name",
                        text: $viewModel.firstName,
                        icon: "person",
                        isFocused: focusedField == .firstName
                    )
                    .focused($focusedField, equals: .firstName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .lastName
                    }
                }
                
                // Last Name
                VStack(alignment: .leading, spacing: 8) {
                    FloatingLabelTextField(
                        title: "Last Name",
                        text: $viewModel.lastName,
                        icon: "person.fill",
                        isFocused: focusedField == .lastName
                    )
                    .focused($focusedField, equals: .lastName)
                    .submitLabel(.next)
                    .onSubmit {
                        focusedField = .email
                    }
                }
            }
            
            // Email Field
            FloatingLabelTextField(
                title: "Email Address",
                text: $viewModel.email,
                icon: "envelope",
                keyboardType: .emailAddress,
                textContentType: .emailAddress,
                isFocused: focusedField == .email
            )
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit {
                focusedField = .password
            }
            
            // Password Field with strength indicator
            VStack(alignment: .leading, spacing: 8) {
                FloatingLabelTextField(
                    title: "Password",
                    text: $viewModel.password,
                    icon: "lock",
                    isSecure: true,
                    isFocused: focusedField == .password
                )
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .confirmPassword
                }
                
                // Password Strength Indicator
                if !viewModel.password.isEmpty {
                    PasswordStrengthIndicator(password: viewModel.password)
                }
            }
            
            // Confirm Password Field
            FloatingLabelTextField(
                title: "Confirm Password",
                text: $viewModel.confirmPassword,
                icon: "lock.fill",
                isSecure: true,
                isFocused: focusedField == .confirmPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
                viewModel.register()
            }
            
            // Password Match Indicator
            if !viewModel.confirmPassword.isEmpty && !viewModel.password.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.password == viewModel.confirmPassword ?
                          "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(viewModel.password == viewModel.confirmPassword ?
                                       .green : .red)
                    
                    Text(viewModel.password == viewModel.confirmPassword ?
                         "Passwords match" : "Passwords don't match")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.password == viewModel.confirmPassword ?
                                       .green : .red)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.top, -8)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
    }
}

struct PasswordStrengthIndicator: View {
    let password: String
    
    private var strength: (color: Color, text: String, width: CGFloat) {
        if password.isEmpty {
            return (.gray, "Enter password", 0.1)
        } else if password.count < 6 {
            return (.red, "Weak", 0.25)
        } else if password.count < 10 {
            return (.orange, "Fair", 0.5)
        } else if !hasUppercaseLowercaseNumber(password) {
            return (.yellow, "Good", 0.75)
        } else {
            return (.green, "Strong", 1.0)
        }
    }
    
    private func hasUppercaseLowercaseNumber(_ password: String) -> Bool {
        let uppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let lowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let number = password.rangeOfCharacter(from: .decimalDigits) != nil
        return uppercase && lowercase && number
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(strength.color)
                        .frame(width: geometry.size.width * strength.width, height: 4)
                        .animation(.spring(response: 0.3), value: password)
                }
            }
            .frame(height: 4)
            
            // Strength text
            HStack {
                Text("Strength: \(strength.text)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(strength.color)
                
                Spacer()
                
                if password.count > 0 {
                    Text("\(password.count) characters")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct TermsSection: View {
    @State private var acceptedTerms = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: {
                acceptedTerms.toggle()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(acceptedTerms ? Color.blue : Color.white.opacity(0.1))
                        .frame(width: 20, height: 20)
                    
                    if acceptedTerms {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("I agree to the ")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8)) +
                Text("Terms of Service")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white) +
                Text(" and ")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.8)) +
                Text("Privacy Policy")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                
                // Optional: Make terms and privacy policy tappable
                // You would add NavigationLinks or sheets here
            }
            
            Spacer()
        }
        .padding(.top, 20)
        .padding(.horizontal, 24)
    }
}

struct RegisterButtonSection: View {
    @ObservedObject var viewModel: RegisterViewModel
    
    var body: some View {
        Button(action: {
            viewModel.register()
        }) {
            HStack(spacing: 12) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
        }
        .buttonStyle(GradientButtonStyle())
        .disabled(viewModel.isLoading ||
                 viewModel.email.isEmpty ||
                 viewModel.password.isEmpty ||
                 viewModel.confirmPassword.isEmpty ||
                 viewModel.firstName.isEmpty ||
                 viewModel.lastName.isEmpty)
        .opacity(viewModel.isLoading ||
                viewModel.email.isEmpty ||
                viewModel.password.isEmpty ||
                viewModel.confirmPassword.isEmpty ||
                viewModel.firstName.isEmpty ||
                viewModel.lastName.isEmpty ? 0.7 : 1)
        .padding(.top, 30)
        .padding(.horizontal, 24)
    }
}

struct LoginSection: View {
    let dismiss: DismissAction
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                dismiss()
            }) {
                Text("Sign In")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .font(.system(size: 15))
        .padding(.bottom, 30)
    }
}

// MARK: - Additional UI Components

struct SecureTextFieldWithToggle: View {
    let title: String
    @Binding var text: String
    let icon: String
    var isFocused: Bool = false
    
    @State private var isSecure: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(isFocused ? .white : .white.opacity(0.6))
                    .frame(width: 24)
                
                ZStack(alignment: .leading) {
                    if text.isEmpty && !isFocused {
                        Text(title)
                            .foregroundColor(.white.opacity(0.5))
                            .font(.system(size: 16))
                    }
                    
                    Group {
                        if isSecure {
                            SecureField("", text: $text)
                        } else {
                            TextField("", text: $text)
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 24)
                }
                
                // Show/Hide toggle
                Button(action: {
                    isSecure.toggle()
                }) {
                    Image(systemName: isSecure ? "eye.slash" : "eye")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 24)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isFocused ? Color.white.opacity(0.8) : Color.white.opacity(0.2), lineWidth: isFocused ? 2 : 1)
                    )
            )
        }
    }
}
