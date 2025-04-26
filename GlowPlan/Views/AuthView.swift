import SwiftUI
import FirebaseAuth
import UIKit

struct AuthView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0 // 0 = Login, 1 = Sign Up
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToHome = false
    @State private var navigateToQuiz = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill.badge.checkmark")
                            .font(.system(size: 60))
                            .foregroundColor(Color("SalmonPink"))
                            .padding(.top, 40)
                        
                        Text(selectedTab == 0 ? "Welcome Back" : "Create Account")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .padding(.horizontal)
                        
                        Text(selectedTab == 0 ? "Sign in to access your routines" : "Join GlowPlan to save and track your skincare journey")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.bottom, 32)
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        TabButton(title: "Login", isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        
                        TabButton(title: "Sign Up", isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                    
                    // Form fields
                    ScrollView {
                        VStack(spacing: 24) {
                            // Only show name field for sign up
                            if selectedTab == 1 {
                                AuthTextField(
                                    title: "Name",
                                    placeholder: "Enter your name",
                                    text: $displayName,
                                    icon: "person.fill"
                                )
                            }
                            
                            AuthTextField(
                                title: "Email",
                                placeholder: "Enter your email",
                                text: $email,
                                icon: "envelope.fill",
                                keyboardType: .emailAddress,
                                autocapitalization: .none
                            )
                            
                            AuthTextField(
                                title: "Password",
                                placeholder: "Enter your password",
                                text: $password,
                                icon: "lock.fill",
                                isSecure: true
                            )
                            
                            // Confirm password only for sign up
                            if selectedTab == 1 {
                                AuthTextField(
                                    title: "Confirm Password",
                                    placeholder: "Confirm your password",
                                    text: $confirmPassword,
                                    icon: "lock.shield.fill",
                                    isSecure: true
                                )
                            }
                            
                            // Only show forgot password for login
                            if selectedTab == 0 {
                                Button(action: {
                                    sendPasswordReset()
                                }) {
                                    Text("Forgot Password?")
                                        .font(.system(size: 14, design: .rounded))
                                        .foregroundColor(Color("SalmonPink"))
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.trailing, 8)
                            }
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 32)
                        .padding(.bottom, 16)
                    }
                    
                    Spacer()
                    
                    // Action button
                    Button(action: {
                        selectedTab == 0 ? handleLogin() : handleSignUp()
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .tint(.white)
                        } else {
                            Text(selectedTab == 0 ? "Sign In" : "Create Account")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("SalmonPink"))
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                    .disabled(isLoading)
                    
                    // Continue as guest button
                    Button(action: {
                        navigateToQuiz = true
                    }) {
                        Text("Continue as Guest")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray").opacity(0.8))
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("CharcoalGray"))
                    }
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(alertTitle),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .fullScreenCover(isPresented: $navigateToHome) {
                MainTabView()
            }
            .fullScreenCover(isPresented: $navigateToQuiz) {
                OnboardingQuizView()
            }
        }
    }
    
    // MARK: - Authentication Methods
    
    private func handleLogin() {
        // Validate fields
        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter your email address")
            return
        }
        
        guard !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please enter your password")
            return
        }
        
        isLoading = true
        
        FirebaseManager.shared.signIn(email: email, password: password) { success, error in
            isLoading = false
            
            if success {
                // Login successful, navigate to home
                navigateToHome = true
            } else {
                // Show error
                showAlert(title: "Login Failed", message: error ?? "Unable to sign in. Please check your email and password.")
            }
        }
    }
    
    private func handleSignUp() {
        // Validate fields
        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter your email address")
            return
        }
        
        guard !password.isEmpty else {
            showAlert(title: "Missing Password", message: "Please enter your password")
            return
        }
        
        guard password.count >= 6 else {
            showAlert(title: "Password Too Short", message: "Password must be at least 6 characters")
            return
        }
        
        guard password == confirmPassword else {
            showAlert(title: "Passwords Don't Match", message: "Please make sure your passwords match")
            return
        }
        
        isLoading = true
        
        FirebaseManager.shared.signUp(email: email, password: password, displayName: displayName) { success, error in
            isLoading = false
            
            if success {
                // Signup successful, navigate to home
                navigateToHome = true
            } else {
                // Show error
                showAlert(title: "Sign Up Failed", message: error ?? "Unable to create account. Please try again.")
            }
        }
    }
    
    private func sendPasswordReset() {
        guard !email.isEmpty else {
            showAlert(title: "Missing Email", message: "Please enter your email address to reset your password")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                showAlert(title: "Password Reset Failed", message: error.localizedDescription)
            } else {
                showAlert(title: "Password Reset Email Sent", message: "Check your email for instructions to reset your password")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        self.alertTitle = title
        self.alertMessage = message
        self.showAlert = true
    }
}

// MARK: - Supporting Views

private struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundColor(isSelected ? Color("SalmonPink") : Color("CharcoalGray").opacity(0.5))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    isSelected ? 
                        Color("SalmonPink").opacity(0.1) : 
                        Color.clear
                )
                .cornerRadius(12)
        }
    }
}

private struct AuthTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .words
    
    @State private var showPassword: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.8))
            
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color("SalmonPink"))
                    .frame(width: 20)
                
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16, design: .rounded))
                        .autocapitalization(autocapitalization)
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16, design: .rounded))
                        .keyboardType(keyboardType)
                        .autocapitalization(autocapitalization)
                }
                
                if isSecure {
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color("CharcoalGray").opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
} 