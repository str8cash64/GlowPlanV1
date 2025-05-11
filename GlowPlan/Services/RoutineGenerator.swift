import Foundation
import FirebaseAuth
import FirebaseFirestore

class RoutineGenerator {
    // Singleton instance
    static let shared = RoutineGenerator()
    
    // Services
    private let openAIService = OpenAIService.shared
    private let firebaseManager = FirebaseManager.shared
    
    // State
    @Published var isGenerating = false
    
    // MARK: - Routine Generation Process
    
    /// Generates a routine using OpenAI and saves it to Firebase
    func generateAndSaveRoutine(
        skinProfile: UserSkinProfile,
        completion: @escaping (Result<[RoutineStep], Error>) -> Void
    ) {
        // Set generating state
        isGenerating = true
        
        // Extract routine information from skin profile
        let skinType = skinProfile.skinType
        let mainConcern = skinProfile.primaryConcern
        let sensitivity = skinProfile.sensitivityLevel
        let preferredTime = skinProfile.desiredRoutineTime
        
        // Call OpenAI to generate the routine
        openAIService.generateRoutine(
            skinType: skinType,
            mainConcern: mainConcern,
            sensitivityLevel: sensitivity,
            preferredTime: preferredTime
        ) { [weak self] result in
            guard let self = self else { return }
            
            // Reset generating state
            self.isGenerating = false
            
            switch result {
            case .success(let routineResponse):
                // Combine morning and evening routines
                var allSteps: [RoutineStep] = []
                
                // Add morning header
                allSteps.append(RoutineStep(
                    UUID(),
                    name: "Morning Routine",
                    product: "",
                    description: "Your personalized morning skincare steps"
                ))
                
                // Add morning steps
                allSteps.append(contentsOf: routineResponse.morning)
                
                // Add evening header
                allSteps.append(RoutineStep(
                    UUID(),
                    name: "Evening Routine",
                    product: "",
                    description: "Your personalized evening skincare steps"
                ))
                
                // Add evening steps
                allSteps.append(contentsOf: routineResponse.evening)
                
                // Save to Firebase if user is logged in
                if let userId = Auth.auth().currentUser?.uid {
                    // Save profile and routine
                    self.saveRoutineToFirebase(userId: userId, skinProfile: skinProfile, routineSteps: allSteps) { success in
                        if success {
                            print("Successfully saved routine to Firebase")
                            completion(.success(allSteps))
                        } else {
                            let error = NSError(domain: "RoutineGenerator", code: 1004, 
                                              userInfo: [NSLocalizedDescriptionKey: "Failed to save routine to Firebase"])
                            completion(.failure(error))
                        }
                    }
                } else {
                    // User not logged in, return steps without saving
                    completion(.success(allSteps))
                }
                
            case .failure(let error):
                print("Error generating routine: \(error.localizedDescription)")
                
                // Generate a fallback routine locally
                let fallbackSteps = self.generateFallbackRoutine(skinProfile: skinProfile)
                completion(.success(fallbackSteps))
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Saves the generated routine to Firebase
    private func saveRoutineToFirebase(
        userId: String,
        skinProfile: UserSkinProfile,
        routineSteps: [RoutineStep],
        completion: @escaping (Bool) -> Void
    ) {
        // Save both profile and routine data
        FirebaseManager.shared.saveOnboardingData(
            skinProfile: skinProfile,
            routineSteps: routineSteps,
            completion: completion
        )
    }
    
    /// Generates a fallback routine if the API call fails
    private func generateFallbackRoutine(skinProfile: UserSkinProfile) -> [RoutineStep] {
        // Use the existing generateRoutine method from UserSkinProfile 
        let steps = skinProfile.generateRoutine()
        
        // Split into morning and evening with headers
        var allSteps: [RoutineStep] = []
        
        // Add morning header
        allSteps.append(RoutineStep(
            UUID(),
            name: "Morning Routine",
            product: "",
            description: "Your personalized morning skincare steps"
        ))
        
        // Add morning steps (first half of steps)
        let morningCount = steps.count / 2
        allSteps.append(contentsOf: Array(steps.prefix(morningCount)))
        
        // Add evening header
        allSteps.append(RoutineStep(
            UUID(),
            name: "Evening Routine",
            product: "",
            description: "Your personalized evening skincare steps"
        ))
        
        // Add evening steps (second half of steps)
        allSteps.append(contentsOf: Array(steps.suffix(from: morningCount)))
        
        return allSteps
    }
} 