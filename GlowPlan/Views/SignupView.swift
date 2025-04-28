import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Foundation

struct SignupView: View {
    // MARK: - Properties
    
    // User entered data
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var selectedTab = 0 // 0 for signup, 1 for login
    @State private var navigateToRoutineSaveHandler = false
    @State private var navigateToHome = false
    @State private var errorMessage = ""
    @State private var isSigningUp = false
    @State private var isLoggingIn = false
    @State private var showFirebaseWarning = false
    @State private var showResetPassword = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    // Data to be passed to the RoutineSaveHandlerView
    @ObservedObject var skinProfile: UserSkinProfile
    var skinRoutine: [RoutineStep]
    
    // Properties for separate morning/evening routines
    var morningRoutine: [RoutineStep] = []
    var eveningRoutine: [RoutineStep] = []
    var hasSeparateRoutines = false
    
    // Access the NavigationManager - use navigation manager wrapper
    @StateObject private var navigationManager = NavigationManager.shared
    
    // Use this to detect if this view was presented from an onboarding flow
    private var isFromOnboarding: Bool {
        return !skinRoutine.isEmpty || hasSeparateRoutines
    }
    
    // MARK: - Initializers
    
    // Default initializer for combined routine
    init(skinProfile: UserSkinProfile, skinRoutine: [RoutineStep]) {
        self.skinProfile = skinProfile
        self.skinRoutine = skinRoutine
        self.morningRoutine = []
        self.eveningRoutine = []
        self.hasSeparateRoutines = false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Logo/Icon
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(Color("SalmonPink"))
                        .padding(.top, 40)
                    
                    // Tab selector
                    HStack(spacing: 0) {
                        SignupTabButton(title: "Sign Up", isSelected: selectedTab == 0) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 0
                                errorMessage = ""
                            }
                        }
                        
                        SignupTabButton(title: "Login", isSelected: selectedTab == 1) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = 1
                                errorMessage = ""
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
                    )
                    .padding(.horizontal, 24)
                    
                    // Welcome text
                    VStack(spacing: 8) {
                        Text(selectedTab == 0 ? "Create your GlowPlan account" : "Welcome Back")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                        
                        Text(selectedTab == 0 ? "Save your personalized skincare routine and track your progress" : "Sign in to access your saved routines")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(Color("CharcoalGray"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    
                    // Form fields
                    VStack(spacing: 20) {
                        if selectedTab == 0 {
                            GlowTextField(
                                title: "Name",
                                placeholder: "Enter your name",
                                text: $displayName,
                                icon: "person.fill"
                            )
                        }
                        
                        GlowTextField(
                            title: "Email",
                            placeholder: "Enter your email",
                            text: $email,
                            icon: "envelope.fill",
                            keyboardType: .emailAddress,
                            autocapitalization: .none
                        )
                        
                        GlowTextField(
                            title: "Password",
                            placeholder: "Enter your password",
                            text: $password,
                            isSecure: true,
                            icon: "lock.fill"
                        )
                        
                        if selectedTab == 0 {
                            GlowTextField(
                                title: "Confirm Password",
                                placeholder: "Confirm your password",
                                text: $confirmPassword,
                                isSecure: true,
                                icon: "lock.shield.fill"
                            )
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Reset password link (login tab only)
                    if selectedTab == 1 {
                        Button(action: {
                            showResetPassword = true
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color("SalmonPink"))
                        }
                        .padding(.top, 4)
                        .sheet(isPresented: $showResetPassword) {
                            ResetPasswordView()
                        }
                    }
                    
                    Spacer()
                    
                    // Sign up/Login button
                    Button(action: {
                        // Check Firebase configuration before proceeding
                        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
                            showFirebaseWarning = true
                            return
                        }
                        
                        if selectedTab == 1 {
                            loginUser()
                        } else {
                            signupUser()
                        }
                    }) {
                        if isSigningUp || isLoggingIn {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(selectedTab == 1 ? "Login" : "Sign Up")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("SalmonPink"))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .disabled(isSigningUp || isLoggingIn)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            // We ONLY need the home navigation now
            .fullScreenCover(isPresented: $navigateToHome) {
                MainTabView()
            }
            .alert("Firebase Configuration Required", isPresented: $showFirebaseWarning) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please add your GoogleService-Info.plist file to the project before continuing. See Firebase-Setup.md for instructions.")
            }
            .onAppear {
                checkFirebaseConfiguration()
                
                // Check if user is already logged in and skip quiz if needed
                if FirebaseManager.shared.isLoggedIn {
                    navigationManager.forceSkipQuiz()
                }
                
                // Add observer for emergency navigation
                NotificationCenter.default.addObserver(forName: Notification.Name("ForceNavigateToHome"), 
                                                      object: nil, 
                                                      queue: .main) { _ in
                    self.navigateToHome = true
                }
            }
            // Listen for navigation events from NavigationManager
            .onChange(of: navigationManager.shouldShowHome) { newValue in
                if newValue {
                    // Just navigate directly to home
                    navigateToHome = true
                }
            }
        }
    }
    
    private func checkFirebaseConfiguration() {
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") == nil {
            showFirebaseWarning = true
        }
    }
    
    private func signupUser() {
        // Clear previous errors
        errorMessage = ""
        
        // Validate inputs
        if email.isEmpty {
            errorMessage = "Please enter your email"
            return
        }
        
        if password.isEmpty {
            errorMessage = "Please enter a password"
            return
        }
        
        // Validate username for signup
        if displayName.isEmpty {
            errorMessage = "Please enter your name"
            return
        }
        
        isSigningUp = true
        
        // Check password requirements
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters"
            isSigningUp = false
            return
        }
        
        // Check that passwords match for signup
        if selectedTab == 0 && password != confirmPassword {
            errorMessage = "Passwords do not match"
            isSigningUp = false
            return
        }
        
        // Use Task to handle the async function
        Task {
            do {
                let success = try await FirebaseManager.shared.signUp(email: email, password: password, fullName: displayName)
                
                DispatchQueue.main.async {
                    if success {
                        if self.hasSeparateRoutines && !self.morningRoutine.isEmpty && !self.eveningRoutine.isEmpty {
                            // Save morning and evening routines separately
                            FirebaseManager.shared.saveMorningAndEveningRoutines(
                                morningRoutine: self.morningRoutine,
                                eveningRoutine: self.eveningRoutine
                            ) { result in
                                DispatchQueue.main.async {
                                    self.isSigningUp = false
                                    
                                    // Mark user as having completed onboarding
                                    self.markUserOnboardingComplete()
                                    
                                    // Go directly to home page
                                    self.navigateToHome = true
                                }
                            }
                        } else if !self.skinRoutine.isEmpty {
                            // Coming from quiz flow with a combined routine - save profile and routine, then navigate to home
                            FirebaseManager.shared.saveOnboardingData(
                                skinProfile: self.skinProfile,
                                routineSteps: self.skinRoutine
                            ) { result in
                                DispatchQueue.main.async {
                                    self.isSigningUp = false
                                    
                                    // Mark user as having completed onboarding
                                    self.markUserOnboardingComplete()
                                    
                                    // Go directly to home page
                                    self.navigateToHome = true
                                }
                            }
                        } else {
                            // Regular signup flow - navigate to home
                            self.isSigningUp = false
                            
                            // Mark as having completed onboarding
                            self.markUserOnboardingComplete()
                            
                            // Go directly to home page
                            self.navigateToHome = true
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    // Handle sign up error
                    self.isSigningUp = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loginUser() {
        // Clear previous errors
        errorMessage = ""
        
        // Validate inputs
        if email.isEmpty {
            errorMessage = "Please enter your email"
            return
        }
        
        if password.isEmpty {
            errorMessage = "Please enter a password"
            return
        }
        
        isLoggingIn = true
        
        // Sign in using Firebase
        FirebaseManager.shared.signIn(email: email, password: password) { success, error in
            DispatchQueue.main.async {
                self.isLoggingIn = false
                if success {
                    // Mark user as having completed onboarding
                    self.markUserOnboardingComplete()
                    
                    // Go directly to home page
                    self.navigateToHome = true
                } else {
                    self.errorMessage = error ?? "Error signing in."
                }
            }
        }
    }
    
    // Helper to mark user as having completed onboarding
    private func markUserOnboardingComplete() {
        // Make sure we note if user is coming from onboarding flow
        if isFromOnboarding {
            navigationManager.comingFromOnboardingFlow = true
        }
        
        navigationManager.markUserAsOnboarded()
    }
}

// Custom TabButton
struct SignupTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: isSelected ? .semibold : .medium, design: .rounded))
                .foregroundColor(isSelected ? Color("SalmonPink") : Color.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    ZStack {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                            
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color("SalmonPink"))
                                    .frame(height: 3)
                            }
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Reset Password View
struct ResetPasswordView: View {
    @State private var email = ""
    @State private var message = ""
    @State private var isSuccess = false
    @State private var isProcessing = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("SoftWhite").ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Reset Password")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .padding(.top, 40)
                    
                    Text("Enter your email address and we'll send you a link to reset your password")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    GlowTextField(
                        title: "Email",
                        placeholder: "Enter your email",
                        text: $email,
                        icon: "envelope.fill",
                        keyboardType: .emailAddress,
                        autocapitalization: .none
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    if !message.isEmpty {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(isSuccess ? .green : .red)
                            .padding(.horizontal, 24)
                    }
                    
                    Button(action: sendResetEmail) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Send Reset Link")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("SalmonPink"))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .disabled(isProcessing)
                    
                    Spacer()
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(Color("CharcoalGray"))
                    }
                }
            }
        }
    }
    
    private func sendResetEmail() {
        guard !email.isEmpty else {
            message = "Please enter your email"
            return
        }
        
        isProcessing = true
        
        #if canImport(FirebaseAuth)
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                isProcessing = false
                
                if let error = error {
                    message = error.localizedDescription
                    isSuccess = false
                } else {
                    message = "Password reset email sent. Please check your inbox."
                    isSuccess = true
                }
            }
        }
        #else
        // Simulate response for preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isProcessing = false
            message = "Password reset email sent. Please check your inbox."
            isSuccess = true
        }
        #endif
    }
}

// MARK: - Previews

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = UserSkinProfile()
        profile.skinType = "Normal"
        profile.primaryConcern = "Dryness"
        return SignupView(skinProfile: profile, skinRoutine: [])
    }
} 