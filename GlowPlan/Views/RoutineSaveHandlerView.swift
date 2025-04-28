import SwiftUI
import Foundation
import FirebaseFirestore

struct RoutineSaveHandlerView: View {
    @State private var isSaving = false
    @State private var isComplete = false
    @State private var navigateToSignup = false
    @State private var navigateToHome = false
    @State private var errorMessage = ""
    
    // Access the NavigationManager
    @StateObject private var navigationManager = NavigationManager.shared
    
    let skinProfile: UserSkinProfile
    let morningRoutine: [RoutineStep]
    let eveningRoutine: [RoutineStep]
    
    // Initialize with morning and evening routines
    init(skinProfile: UserSkinProfile, morningRoutine: [RoutineStep], eveningRoutine: [RoutineStep]) {
        self.skinProfile = skinProfile
        self.morningRoutine = morningRoutine
        self.eveningRoutine = eveningRoutine
    }
    
    // Backwards compatibility initializer with combined routines
    init(skinProfile: UserSkinProfile, routineSteps: [RoutineStep]) {
        self.skinProfile = skinProfile
        
        // Just use the combined routine as morning routine for now
        self.morningRoutine = routineSteps
        self.eveningRoutine = []
    }
    
    var body: some View {
        ZStack {
            Color("SoftWhite").ignoresSafeArea()
            
            VStack(spacing: 24) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .padding(.bottom, 24)
                    
                    Text("Generating your personalized routine...")
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("SalmonPink"))
                        .padding(.bottom, 24)
                    
                    Text("Your personalized routine is ready!")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Create an account to save it for later")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(Color("CharcoalGray").opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    
                    Button {
                        // Mark that we're coming from the onboarding flow
                        navigationManager.comingFromOnboardingFlow = true
                        navigateToSignup = true
                    } label: {
                        Text("Sign Up / Login")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color("SalmonPink"))
                                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                    }
                    
                    Button {
                        navigateToHome = true
                    } label: {
                        Text("Continue Without Saving")
                            .font(.subheadline)
                            .foregroundColor(Color("CharcoalGray"))
                            .padding(.top, 8)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .padding(.top, 16)
                }
            }
        }
        .onAppear {
            // Check if user is already logged in first
            if FirebaseManager.shared.isLoggedIn {
                saveRoutineForLoggedInUser()
            } else {
                // Start the saving animation sequence
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isSaving = true
                    
                    // Simulate saving delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        isSaving = false
                        isComplete = true
                    }
                }
            }
            
            // Add observer for home navigation
            NotificationCenter.default.addObserver(forName: Notification.Name("ForceNavigateToHome"), 
                                                  object: nil, 
                                                  queue: .main) { _ in
                self.navigateToHome = true
            }
        }
        // Simple presentation order - signup first for the natural quiz flow
        .fullScreenCover(isPresented: $navigateToSignup) {
            // Pass the skin profile and routines to SignupView
            SignupView(
                skinProfile: skinProfile,
                morningRoutine: morningRoutine,
                eveningRoutine: eveningRoutine
            )
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            MainTabView()
        }
        // Observe NavigationManager's shouldShowHome to trigger home navigation
        .onChange(of: navigationManager.shouldShowHome) { newValue in
            if newValue {
                navigateToHome = true
            }
        }
    }
    
    private func saveRoutineForLoggedInUser() {
        isSaving = true
        
        guard let userId = FirebaseManager.shared.userId else {
            isSaving = false
            isComplete = true
            return
        }
        
        // If we have both morning and evening routines, save them separately
        if !morningRoutine.isEmpty && !eveningRoutine.isEmpty {
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
        } else {
            // Use the legacy method for combined routine
            FirebaseManager.shared.saveOnboardingData(
                skinProfile: skinProfile, 
                routineSteps: morningRoutine
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
} 