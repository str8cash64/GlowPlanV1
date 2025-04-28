import Foundation
import SwiftUI

// This is a test utility to check if OpenAI is properly configured
struct OpenAITest {
    static func checkConfiguration() -> Bool {
        let isConfigured = OpenAIManager.shared.isApiKeySet()
        print("OpenAI API Key is configured: \(isConfigured)")
        return isConfigured
    }
    
    static func testKey() {
        // Create a simple profile for testing
        let testProfile = UserSkinProfile()
        testProfile.skinType = "Combination"
        testProfile.skinGoals = ["Hydration", "Brightening"]
        testProfile.sensitivityLevel = "Not sensitive"
        testProfile.experienceLevel = "Beginner"
        testProfile.primaryConcern = "Dryness"
        testProfile.usesSPF = true
        testProfile.desiredRoutineTime = "5-10 minutes"
        
        print("Testing OpenAI API with GPT-4-Turbo...")
        OpenAIManager.shared.generateMorningAndEveningRoutines(from: testProfile) { result in
            switch result {
            case .success(let routines):
                print("✅ OpenAI API test successful!")
                print("Morning routine has \(routines.morning.count) steps")
                print("Evening routine has \(routines.evening.count) steps")
                
                // Print first step of each routine as sample
                if let morningStep = routines.morning.first {
                    print("Morning sample: \(morningStep.name) - \(morningStep.product)")
                }
                
                if let eveningStep = routines.evening.first {
                    print("Evening sample: \(eveningStep.name) - \(eveningStep.product)")
                }
                
            case .failure(let error):
                print("❌ OpenAI API test failed with error: \(error.localizedDescription)")
            }
        }
    }
} 