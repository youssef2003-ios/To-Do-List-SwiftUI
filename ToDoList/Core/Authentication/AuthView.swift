import SwiftUI

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var authStateManager: AuthStateManager
    @State private var isLoginMode = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            // Background color matching the todo list screen
            Color(UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0))
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo/App Title
                Text("To Do List")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 30)
                
                // Form fields in rounded cards
                VStack(spacing: 15) {
                    // Email field
                    RoundedCardField(iconName: "envelope.fill", placeholder: "Email", text: $email)
                    
                    // Password field
                    RoundedCardField(iconName: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                    
                    // Confirm password (signup only)
                    if !isLoginMode {
                        RoundedCardField(iconName: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                    }
                    
                    // Action button
                    Button(action: {
                        authenticateUser()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(isLoginMode ? "Log In" : "Sign Up")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color.green.opacity(0.7))
                    )
                    .padding(.top, 10)
                    .disabled(isLoading)
                    
                    // Toggle between login and signup
                    Button(action: {
                        withAnimation {
                            isLoginMode.toggle()
                            errorMessage = ""
                            showError = false
                        }
                    }) {
                        Text(isLoginMode ? "Need an account? Sign Up" : "Already have an account? Log In")
                            .foregroundColor(.white)
                            .underline()
                    }
                    .padding(.top, 8)
                    .disabled(isLoading)
                }
                .padding(.horizontal, 20)
            }
            .padding()
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func authenticateUser() {
        // Validate form
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        if !isLoginMode && password != confirmPassword {
            errorMessage = "Passwords don't match"
            showError = true
            return
        }
        
        isLoading = true
        
        Task {
            do {
                if isLoginMode {
                    // Login
                    let user = try await AuthService.shared.signIn(email: email, password: password)
                    print("Successfully logged in user with ID: \(user.id)")
                } else {
                    // Signup
                    let user = try await AuthService.shared.signUp(email: email, password: password)
                    print("Successfully created user with ID: \(user.id)")
                }
                
                await MainActor.run {
                    isLoading = false
                    authStateManager.isAuthenticated = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Authentication failed: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}

#Preview {
    AuthView()
}
