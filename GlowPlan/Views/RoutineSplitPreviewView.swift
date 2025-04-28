import SwiftUI
import FirebaseAuth

struct RoutineSplitPreviewView: View {
    @ObservedObject var skinProfile: UserSkinProfile
    @State private var isGeneratingRoutines = true
    @State private var generationError: Error?
    @State private var morningRoutine: [RoutineStep] = []
    @State private var eveningRoutine: [RoutineStep] = []
    @State private var navigateToSignup = false
    @State private var navigateToHome = false
    @State private var isUserLoggedIn = false
    @Environment(\.dismiss) private var dismiss
    
    // Access NavigationManager
    @StateObject private var navigationManager = NavigationManager.shared
    
    var body: some View {
        ZStack {
            // Background
            Color("SoftWhite").edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile summary
                    routineSummary
                    
                    if isGeneratingRoutines {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding(.vertical, 40)
                            
                            Text("Generating your personalized routines...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else if let error = generationError {
                        // Error state
                        VStack(spacing: 20) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                                .padding(.top, 20)
                            
                            Text("There was an error generating your routine")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(error.localizedDescription)
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(Color("CharcoalGray").opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.bottom, 20)
                            
                            Button(action: {
                                // Retry generating the routine
                                generationError = nil
                                generateRoutines()
                            }) {
                                Text("Try Again")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color("SalmonPink"))
                                    .cornerRadius(12)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 60)
                    } else {
                        // Morning routine
                        routineSection(
                            title: "Your Morning Routine",
                            icon: "sun.max.fill",
                            routineSteps: morningRoutine
                        )
                        
                        // Evening routine
                        routineSection(
                            title: "Your Evening Routine",
                            icon: "moon.stars.fill",
                            routineSteps: eveningRoutine
                        )
                        
                        // Action buttons
                        actionButtons
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Your Personalized Routine")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color("SalmonPink"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Check if user is logged in
            isUserLoggedIn = FirebaseManager.shared.isLoggedIn
            // Generate routines
            generateRoutines()
        }
        // For direct navigation to home after signup is complete
        .fullScreenCover(isPresented: $navigateToHome) {
            MainTabView()
        }
        // Then handle SignupView
        .fullScreenCover(isPresented: $navigateToSignup) {
            // Pass the skin profile to SignupView
            SignupView(
                skinProfile: skinProfile,
                morningRoutine: morningRoutine,
                eveningRoutine: eveningRoutine
            )
        }
        // Observe NavigationManager's shouldShowHome to trigger home navigation
        .onChange(of: navigationManager.shouldShowHome) { newValue in
            if newValue {
                navigateToHome = true
            }
        }
    }
    
    // MARK: - Supporting Views
    
    // Profile summary view
    private var routineSummary: some View {
        VStack(spacing: 16) {
            // Header
            Text("Your Skin Profile")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Profile details card
            HStack(spacing: 20) {
                // Left column - profile items
                VStack(alignment: .leading, spacing: 12) {
                    profileItem(title: "Skin Type", value: skinProfile.skinType)
                    profileItem(title: "Main Concern", value: skinProfile.primaryConcern)
                    profileItem(title: "Sensitivity", value: skinProfile.sensitivityLevel)
                }
                
                Spacer()
                
                // Right column - additional details
                VStack(alignment: .leading, spacing: 12) {
                    profileItem(title: "Experience", value: skinProfile.experienceLevel)
                    
                    // Show routine time preference if available
                    if !skinProfile.desiredRoutineTime.isEmpty {
                        profileItem(title: "Routine Time", value: skinProfile.desiredRoutineTime)
                    }
                    
                    // Show SPF usage if recorded
                    profileItem(title: "Uses SPF", value: skinProfile.usesSPF ? "Yes" : "No")
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
    
    // Helper for profile items
    private func profileItem(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.7))
            
            Text(value.isEmpty ? "Not specified" : value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
        }
    }
    
    // Routine section builder
    private func routineSection(title: String, icon: String, routineSteps: [RoutineStep]) -> some View {
        VStack(spacing: 16) {
            // Header with icon
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Color("SalmonPink"))
                
                Text(title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                
                Spacer()
            }
            
            // Steps list
            VStack(spacing: 12) {
                ForEach(Array(zip(routineSteps.indices, routineSteps)), id: \.0) { index, step in
                    HStack(spacing: 16) {
                        // Step number
                        Text("\(index + 1)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(Color("SalmonPink"))
                            .frame(width: 28, height: 28)
                            .background(Color("SalmonPink").opacity(0.2))
                            .clipShape(Circle())
                        
                        // Step details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(step.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("CharcoalGray"))
                                .fixedSize(horizontal: false, vertical: true)
                            
                            if !step.product.isEmpty {
                                Text(step.product)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(Color("CharcoalGray").opacity(0.7))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
            }
        }
    }
    
    // Action buttons (save or skip)
    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Save routine button
            Button(action: {
                if isUserLoggedIn {
                    // User is logged in, save routines and navigate home
                    saveRoutinesAndNavigateHome()
                } else {
                    // Navigate to signup
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
            .padding(.top, 16)
            
            // Skip button (optional)
            Button("Skip for now") {
                if isUserLoggedIn {
                    // Navigate home if logged in
                    navigateToHome = true
                } else {
                    // Go back to previous screen
                    dismiss()
                }
            }
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(Color("CharcoalGray").opacity(0.7))
            .padding(.bottom, 8)
            
            // Info text
            Text(isUserLoggedIn ? "This will save your routine to your account" : "You'll need to create an account to save your personalized routine")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(Color("CharcoalGray").opacity(0.5))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
        }
        .padding(.top, 32)
    }
    
    // Generate both morning and evening routines using OpenAI
    private func generateRoutines() {
        isGeneratingRoutines = true
        generationError = nil
        
        OpenAIManager.shared.generateRoutinesForFirebase(from: skinProfile) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let routines):
                    self.morningRoutine = routines.morning
                    self.eveningRoutine = routines.evening
                    self.isGeneratingRoutines = false
                    
                case .failure(let error):
                    self.generationError = error
                    self.isGeneratingRoutines = false
                }
            }
        }
    }
    
    // Function for logged-in users to save routines and go to home
    private func saveRoutinesAndNavigateHome() {
        FirebaseManager.shared.saveMorningAndEveningRoutines(
            morningRoutine: morningRoutine,
            eveningRoutine: eveningRoutine
        ) { result in
            DispatchQueue.main.async {
                // Mark user as having completed onboarding
                self.navigationManager.markUserAsOnboarded()
                
                // Navigate to home
                self.navigateToHome = true
            }
        }
    }
}

// MARK: - Extension for SignupView to support morning and evening routines
extension SignupView {
    // Add a convenience initializer that takes morning and evening routines
    init(skinProfile: UserSkinProfile, morningRoutine: [RoutineStep], eveningRoutine: [RoutineStep]) {
        self.init(skinProfile: skinProfile, skinRoutine: []) // Initialize with empty array
        self.morningRoutine = morningRoutine
        self.eveningRoutine = eveningRoutine
        self.hasSeparateRoutines = true
    }
}

struct RoutineSplitPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            let skinProfile = UserSkinProfile()
            // Set some sample data
            skinProfile.skinType = "Sensitive"
            skinProfile.primaryConcern = "Dullness"
            skinProfile.sensitivityLevel = "Very sensitive"
            skinProfile.usesSPF = true
            
            return RoutineSplitPreviewView(skinProfile: skinProfile)
        }
    }
} 