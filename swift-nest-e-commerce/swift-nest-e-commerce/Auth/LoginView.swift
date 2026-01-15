//
//  LoginView.swift
//  swift-nest-e-commerce
//
//  Created by Haris Dar on 11/01/2026.
//


import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var showingRegister = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case email, password
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Gradient Background
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section
                        HeaderSection()
                        
                        // Login Form
                        LoginFormSection(viewModel: viewModel, focusedField: $focusedField)
                        
                  
                        
                        Spacer()
                        
                        // Register Link
                        RegisterSection(showingRegister: $showingRegister)
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
            .navigationDestination(isPresented: $showingRegister) {
                RegisterView()
                    .navigationBarBackButtonHidden(true)
            }
            .alert("Login Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An error occurred")
            }
            .onTapGesture {
                focusedField = nil
            }
        }
    }
}

// MARK: - Subviews

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "667eea").opacity(0.8),
                Color(hex: "764ba2").opacity(0.6),
                Color(hex: "f093fb").opacity(0.4)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .animation(
            .easeInOut(duration: 3.0)
            .repeatForever(autoreverses: true),
            value: animateGradient
        )
        .onAppear {
            animateGradient.toggle()
        }
        .overlay(
            Color.black.opacity(0.1)
                .ignoresSafeArea()
        )
    }
}

struct HeaderSection: View {
    var body: some View {
        VStack(spacing: 20) {
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
                
                Image(systemName: "lock.shield.fill")
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
            .padding(.top, 50)
            
            // Welcome Text
            VStack(spacing: 8) {
                Text("Welcome Back")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                Text("Sign in to continue to your account")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.bottom, 40)
    }
}

struct LoginFormSection: View {
    @ObservedObject var viewModel: LoginViewModel
    @FocusState.Binding var focusedField: LoginView.Field?
    
    var body: some View {
        VStack(spacing: 24) {
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
            
            // Password Field
            FloatingLabelTextField(
                title: "Password",
                text: $viewModel.password,
                icon: "lock",
                isSecure: true,
                isFocused: focusedField == .password
            )
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit {
                viewModel.login()
            }
            
            // Forgot Password
            HStack {
                Spacer()
                Button(action: {
                    // Handle forgot password
                }) {
                    Text("Forgot Password?")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, -8)
            
            // Login Button
            Button(action: {
                viewModel.login()
            }) {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
            }
            .buttonStyle(GradientButtonStyle())
            .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty)
            .opacity(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.isEmpty ? 0.7 : 1)
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

//struct SocialLoginSection: View {
//    var body: some View {
//        VStack(spacing: 20) {
//            // Divider with text
//            HStack {
//                line
//                Text("Or continue with")
//                    .font(.caption)
//                    .foregroundColor(.white.opacity(0.7))
//                line
//            }
//            .padding(.top, 32)
//            
//            // Social buttons
//            HStack(spacing: 16) {
//                SocialButton(icon: "apple.logo", text: "Apple")
//                SocialButton(icon: "g.circle.fill", text: "Google")
//            }
//        }
//    }
//    
//    private var line: some View {
//        Rectangle()
//            .fill(Color.white.opacity(0.3))
//            .frame(height: 1)
//            .frame(maxWidth: .infinity)
//    }
//}

struct RegisterSection: View {
    @Binding var showingRegister: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundColor(.white.opacity(0.8))
            
            Button(action: {
                showingRegister = true
            }) {
                Text("Sign Up")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
        .font(.system(size: 15))
        .padding(.bottom, 30)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .blur(radius: 2)
            
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                )
        }
    }
}

// MARK: - Custom Components

struct FloatingLabelTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    var textContentType: UITextContentType?
    var isSecure: Bool = false
    var isFocused: Bool = false
    
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
                                .keyboardType(keyboardType)
                                .textContentType(textContentType)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .frame(height: 24)
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
            
            if isFocused && !title.contains("Password") {
                Text("Required field")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.horizontal, 16)
            }
        }
    }
}

struct GradientButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: configuration.isPressed ? 
                        [Color(hex: "667eea"), Color(hex: "764ba2")] :
                        [Color(hex: "764ba2"), Color(hex: "667eea")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: .black.opacity(0.2), radius: configuration.isPressed ? 5 : 10, x: 0, y: configuration.isPressed ? 2 : 5)
    }
}

struct SocialButton: View {
    let icon: String
    let text: String
    
    var body: some View {
        Button(action: {
            // Handle social login
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(text)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            .foregroundColor(.white)
        }
    }
}

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
