import SwiftUI
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var displayName = ""
    @State private var selectedTab = 0 // 0 for signup, 1 for login
    @State private var navigateToRoutineSaveHandler = false
    @State private var navigateToQuiz = false
    @State private var navigateToHome = false
    @State private var errorMessage = ""
    @State private var isSigningUp = false
    @State private var isLoggingIn = false
    @State private var showFirebaseWarning = false
    @State private var showResetPassword = false
    @Environment(\.presentationMode) var presentationMode
    
    // Data to be passed to the RoutineSaveHandlerView
    var skinProfile: UserSkinProfile? = nil
    var skinRoutine: [RoutineStep]? = nil
    
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
            // First, handle QuizView navigation
            .fullScreenCover(isPresented: $navigateToQuiz) {
                OnboardingQuizView()
            }
            // Then handle RoutineSaveHandler navigation
            .fullScreenCover(isPresented: $navigateToRoutineSaveHandler) {
                if let skinProfile = skinProfile, let routineSteps = skinRoutine {
                    RoutineSaveHandlerView(skinProfile: skinProfile, routineSteps: routineSteps)
                } else {
                    MainTabView() // Fallback if no data to save
                }
            }
            // Finally, handle direct home navigation which should have highest priority
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
        
        // Sign up using Firebase
        FirebaseManager.shared.signUp(email: email, password: password, displayName: displayName) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Success: If we have skin profile and routine, save it
                    if let skinProfile = self.skinProfile, let routineSteps = self.skinRoutine {
                        // Save profile and routine, then navigate to home
                        FirebaseManager.shared.saveOnboardingData(
                            skinProfile: skinProfile,
                            routineSteps: routineSteps
                        ) { result in
                            DispatchQueue.main.async {
                                self.isSigningUp = false
                                // Always navigate to home regardless of save result
                                // Order matters here - set navigateToHome last
                                self.navigateToRoutineSaveHandler = false
                                self.navigateToQuiz = false
                                // Set navigateToHome to true immediately
                                self.navigateToHome = true
                            }
                        }
                    } else {
                        // No routine data, but still mark onboarding as completed for the user
                        if let userId = FirebaseManager.shared.userId {
                            // Explicitly set quizCompleted to true to prevent onboarding from showing again
                            let db = Firestore.firestore()
                            db.collection("users").document(userId).setData(["quizCompleted": true], merge: true) { _ in
                                DispatchQueue.main.async {
                                    self.isSigningUp = false
                                    // Set navigateToHome to true immediately
                                    self.navigateToRoutineSaveHandler = false
                                    self.navigateToQuiz = false
                                    self.navigateToHome = true
                                }
                            }
                        } else {
                            // Fallback if userId not available
                            self.isSigningUp = false
                            self.navigateToRoutineSaveHandler = false
                            self.navigateToQuiz = false
                            self.navigateToHome = true
                        }
                    }
                } else {
                    // Handle sign up error
                    self.isSigningUp = false
                    self.errorMessage = error ?? "Error creating account."
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
                    // Order matters here - set navigateToHome last
                    self.navigateToRoutineSaveHandler = false
                    self.navigateToQuiz = false
                    
                    // Ensure the user's onboarding status is properly set
                    if let userId = FirebaseManager.shared.userId {
                        // Check if user has completed onboarding
                        let db = Firestore.firestore()
                        db.collection("users").document(userId).getDocument { document, error in
                            if let document = document, document.exists {
                                // If document exists but quizCompleted is not set, set it to true to prevent onboarding
                                if document.data()?["quizCompleted"] == nil {
                                    db.collection("users").document(userId).setData(["quizCompleted": true], merge: true) { _ in }
                                }
                            }
                            
                            // Dismiss the current view first
                            self.presentationMode.wrappedValue.dismiss()
                            // Navigate to home after a slight delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.navigateToHome = true
                            }
                        }
                    } else {
                        // Fallback if userId not available
                        self.presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.navigateToHome = true
                        }
                    }
                } else {
                    self.errorMessage = error ?? "Error signing in."
                }
            }
        }
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

#if DEBUG
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
#endif 