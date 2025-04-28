import SwiftUI
import Foundation
#if canImport(FirebaseAuth)
import FirebaseAuth
#endif
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

// Define an enum for result type if needed in other parts of the code
enum SaveResult {
    case success
    case failure(Error)
}

struct RoutinePreviewView: View {
    @ObservedObject var skinProfile: UserSkinProfile
    @State private var skinRoutine: [RoutineStep] = []
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToSignup = false
    @State private var navigateToHome = false
    @State private var showFirebaseWarning = false
    @State private var isCheckingFirebase = true
    @State private var isFirebaseConfigured = false
    @State private var isUserLoggedIn = false
    
    // Access NavigationManager
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some View {
        ZStack {
            // Background
            Color("SoftWhite").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Congratulations header
                    congratulationsHeader
                    
                    // Routine breakdown
                    routineContent
                    
                    // Save routine button
                    saveRoutineButton
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            // Generate the routine when the view appears
            skinRoutine = skinProfile.generateRoutine()
            
            // Check if Firebase is properly configured
            checkFirebaseConfiguration()
            
            // Check if user is logged in
            isUserLoggedIn = Auth.auth().currentUser != nil
            
            // Force skip the quiz for any existing user
            if isUserLoggedIn {
                navigationManager.forceSkipQuiz()
            }
            
            // Add observer for emergency navigation
            NotificationCenter.default.addObserver(forName: Notification.Name("ForceNavigateToHome"), 
                                                  object: nil, 
                                                  queue: .main) { _ in
                self.navigateToHome = true
            }
        }
        .navigationTitle("Your Personalized Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // For direct navigation to home after signup is complete
        .fullScreenCover(isPresented: $navigateToHome) {
            MainTabView()
        }
        // Then handle SignupView
        .fullScreenCover(isPresented: $navigateToSignup) {
            // Pass the skin profile and routine to SignupView and set up a completion handler
            SignupView(skinProfile: skinProfile, skinRoutine: skinRoutine)
                .environmentObject(navigationManager)
        }
        .alert("Firebase Configuration Required", isPresented: $showFirebaseWarning) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please add your GoogleService-Info.plist file to the project before continuing. See Firebase-Setup.md for instructions.")
        }
        // Observe NavigationManager's shouldShowHome to trigger home navigation
        .onChange(of: navigationManager.shouldShowHome) { newValue in
            if newValue {
                navigateToHome = true
            }
        }
    }
    
    private func checkFirebaseConfiguration() {
        // Check for GoogleService-Info.plist
        let hasGoogleServiceInfo = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil
        
        // Check if Firebase is initialized
        if !hasGoogleServiceInfo {
            showFirebaseWarning = true
            isFirebaseConfigured = false
        } else {
            isFirebaseConfigured = true
        }
        
        isCheckingFirebase = false
    }
    
    // MARK: - View Components
    
    private var congratulationsHeader: some View {
        VStack(spacing: 16) {
            // Success circle with checkmark
            ZStack {
                Circle()
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(Color("SalmonPink"))
            }
            .padding(.top, 24)
            
            // Congratulations text
            Text("Your personalized routine is ready!")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .multilineTextAlignment(.center)
            
            Text("Based on your skin profile, we've created a routine just for you.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal)
            
            // Skin type and goals summary
            routineSummary
        }
        .padding(.vertical)
        .padding(.horizontal, 8)
    }
    
    private var routineSummary: some View {
        VStack(spacing: 12) {
            // Display information about skin type and concerns
            if !skinProfile.skinType.isEmpty {
                HStack {
                    Text("Skin Type:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(skinProfile.skinType)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
            
            // Primary concern
            if !skinProfile.primaryConcern.isEmpty {
                HStack {
                    Text("Main Concern:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(skinProfile.primaryConcern)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
            
            // Sensitivity level
            if !skinProfile.sensitivityLevel.isEmpty {
                HStack {
                    Text("Sensitivity:")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(skinProfile.sensitivityLevel)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.top, 8)
    }
    
    private var routineContent: some View {
        VStack(spacing: 20) {
            // Section header
            Text("Your Morning Routine")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
            
            if skinRoutine.isEmpty {
                // Loading or empty state
                Text("Generating your routine...")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
                    .padding()
            } else {
                // Routine steps
                ForEach(Array(skinRoutine.enumerated()), id: \.element.id) { index, step in
                    RoutinePreviewStepCard(
                        stepNumber: index + 1,
                        stepName: step.name,
                        productName: step.product,
                        description: step.description
                    )
                }
            }
        }
    }
    
    private var saveRoutineButton: some View {
        VStack(spacing: 16) {
            // Main action button
            Button(action: {
                if isUserLoggedIn {
                    // If user is already logged in, save routine and go to home directly
                    saveRoutineAndNavigateHome()
                } else {
                    // If not logged in, navigate to signup
                    // Mark that we're coming from onboarding flow
                    navigationManager.comingFromOnboardingFlow = true
                    navigateToSignup = true
                }
            }) {
                Text("Save My Routine")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("SalmonPink"))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    )
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Only shown when user is already logged in from a previous session
            if isUserLoggedIn {
                Button("Skip for now") {
                    navigateToHome = true
                }
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                .padding(.bottom, 8)
            }
            
            // Show a message about what happens next
            Text(isUserLoggedIn ? "This will save your routine to your account" : "You'll need to create an account to save your personalized routine")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
    }
    
    // Function to save routine and navigate home for logged in users
    private func saveRoutineAndNavigateHome() {
        // Save the routine to Firestore
        FirebaseManager.shared.saveOnboardingData(
            skinProfile: skinProfile,
            routineSteps: skinRoutine
        ) { _ in
            // Always navigate to home regardless of result
            DispatchQueue.main.async {
                // Use NavigationManager to ensure quiz is skipped
                self.navigationManager.forceSkipQuiz()
                
                // Then navigate to home
                self.navigateToHome = true
            }
        }
    }
}

// MARK: - Supporting Views

struct RoutinePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let skinProfile = UserSkinProfile()
            // Set some sample data
            skinProfile.skinType = "Combination"
            skinProfile.primaryConcern = "Acne"
            skinProfile.sensitivityLevel = "Slightly sensitive"
            skinProfile.usesSPF = true
            
            return RoutinePreviewView(skinProfile: skinProfile)
        }
    }
} 