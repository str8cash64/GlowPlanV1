import SwiftUI
import Foundation
import FirebaseFirestore

struct RoutineSaveHandlerView: View {
    @State private var isSaving = false
    @State private var isComplete = false
    @State private var navigateToSignup = false
    @State private var navigateToHome = false
    @State private var errorMessage = ""
    
    let skinProfile: UserSkinProfile
    let routineSteps: [RoutineStep]
    
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
        }
        .fullScreenCover(isPresented: $navigateToSignup) {
            SignupView(skinProfile: skinProfile, skinRoutine: routineSteps)
        }
        .fullScreenCover(isPresented: $navigateToHome) {
            MainTabView()
        }
    }
    
    private func saveRoutineForLoggedInUser() {
        isSaving = true
        
        guard let userId = FirebaseManager.shared.userId else {
            isSaving = false
            isComplete = true
            return
        }
        
        FirebaseManager.shared.saveOnboardingData(
            skinProfile: skinProfile, 
            routineSteps: routineSteps
        ) { result in
            DispatchQueue.main.async {
                // Always navigate to home regardless of save result
                navigateToHome = true
            }
        }
    }
} 