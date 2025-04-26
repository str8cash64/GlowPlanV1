import Foundation
import SwiftUI

// MARK: - Onboarding Models
struct OnboardingQuizQuestion {
    let id: Int
    let question: String
    let questionType: QuestionType
    let options: [String]
    var textFieldPlaceholder: String = ""
    
    enum QuestionType {
        case singleSelect
        case multiSelect
        case toggle
        case textField
    }
}

// MARK: - User Responses
class UserSkinProfile: ObservableObject {
    @Published var skinType: String = ""
    @Published var skinGoals: [String] = []
    @Published var sensitivityLevel: String = ""
    @Published var routineFrequency: String = ""
    @Published var experienceLevel: String = ""
    @Published var primaryConcern: String = ""
    @Published var allergies: String = ""
    @Published var preferredIngredients: String = ""
    @Published var usingPrescription: Bool = false
    @Published var climate: String = ""
    @Published var desiredRoutineTime: String = ""
    @Published var usesSPF: Bool = false
    @Published var doubleCleanses: Bool = false
    @Published var fragrancePreference: String = ""
    @Published var wantsProductRecommendations: Bool = false
    
    // For saving responses to each question
    func saveResponse(for questionID: Int, response: Any) {
        switch questionID {
        case 1: // Skin Type
            if let selectedOption = response as? String {
                skinType = selectedOption
            }
        case 2: // Skin Goals
            if let selectedOptions = response as? [String] {
                skinGoals = selectedOptions
            }
        case 3: // Sensitivity Level
            if let selectedOption = response as? String {
                sensitivityLevel = selectedOption
            }
        case 4: // Routine Frequency
            if let selectedOption = response as? String {
                routineFrequency = selectedOption
            }
        case 5: // Experience Level
            if let selectedOption = response as? String {
                experienceLevel = selectedOption
            }
        case 6: // Primary Skin Concern
            if let selectedOption = response as? String {
                primaryConcern = selectedOption
            }
        case 7: // Allergies
            if let text = response as? String {
                allergies = text
            }
        case 8: // Preferred Ingredients
            if let text = response as? String {
                preferredIngredients = text
            }
        case 9: // Using Prescription Treatments
            if let isOn = response as? Bool {
                usingPrescription = isOn
            }
        case 10: // Climate
            if let selectedOption = response as? String {
                climate = selectedOption
            }
        case 11: // Desired Routine Time
            if let selectedOption = response as? String {
                desiredRoutineTime = selectedOption
            }
        case 12: // Uses SPF Regularly
            if let isOn = response as? Bool {
                usesSPF = isOn
            }
        case 13: // Double Cleanses at Night
            if let isOn = response as? Bool {
                doubleCleanses = isOn
            }
        case 14: // Fragrance Preference
            if let selectedOption = response as? String {
                fragrancePreference = selectedOption
            }
        case 15: // Want Product Recommendations
            if let isOn = response as? Bool {
                wantsProductRecommendations = isOn
            }
        default:
            break
        }
    }
    
    // Generate a routine based on user profile
    func generateRoutine() -> [RoutineStep] {
        var steps: [RoutineStep] = []
        
        // Morning routine steps
        steps.append(RoutineStep(
            name: "Cleanse",
            product: doubleCleanses ? "Gentle Foaming Cleanser" : "Hydrating Cleanser",
            description: "Gently cleanse to remove impurities"
        ))
        
        // Add toner if skin is oily or combination
        if skinType == "Oily" || skinType == "Combination" {
            steps.append(RoutineStep(
                name: "Tone",
                product: "Balancing Toner",
                description: "Balance skin pH and prep for treatments"
            ))
        }
        
        // Add treatment based on skin concern
        if !primaryConcern.isEmpty {
            let treatment: String
            let description: String
            
            switch primaryConcern {
            case "Acne":
                treatment = "Salicylic Acid Serum"
                description = "Targets breakouts and prevents new ones"
            case "Dryness":
                treatment = "Hyaluronic Acid Serum"
                description = "Deeply hydrates and plumps skin"
            case "Dullness":
                treatment = "Vitamin C Serum"
                description = "Brightens and evens skin tone"
            case "Redness":
                treatment = "Centella Serum"
                description = "Calms and soothes irritation"
            case "Fine Lines":
                treatment = "Peptide Serum"
                description = "Firms and reduces appearance of fine lines"
            case "Uneven Tone":
                treatment = "Niacinamide Serum"
                description = "Evens skin tone and reduces dark spots"
            default:
                treatment = "Antioxidant Serum"
                description = "Protects skin from environmental damage"
            }
            
            steps.append(RoutineStep(
                name: "Treat",
                product: treatment,
                description: description
            ))
        }
        
        // Add moisturizer based on skin type
        let moisturizer: String
        switch skinType {
        case "Dry":
            moisturizer = "Rich Moisturizing Cream"
        case "Oily":
            moisturizer = "Oil-Free Gel Moisturizer"
        case "Combination":
            moisturizer = "Balanced Lotion"
        case "Sensitive":
            moisturizer = "Fragrance-Free Calming Cream"
        default:
            moisturizer = "Daily Moisturizer"
        }
        
        steps.append(RoutineStep(
            name: "Moisturize",
            product: moisturizer,
            description: "Lock in hydration and strengthen skin barrier"
        ))
        
        // Add SPF if user wants it
        if usesSPF {
            steps.append(RoutineStep(
                name: "Protect",
                product: "SPF 50 Sunscreen",
                description: "Protect skin from UV damage"
            ))
        }
        
        return steps
    }
}

// MARK: - Routine Models
struct RoutineStep: Identifiable {
    let id = UUID()
    let name: String
    let product: String
    let description: String
}

// MARK: - Quiz Data
struct OnboardingQuizData {
    static let allQuestions: [OnboardingQuizQuestion] = [
        OnboardingQuizQuestion(
            id: 1,
            question: "What's your skin type?",
            questionType: .singleSelect,
            options: ["Dry", "Oily", "Combination", "Normal", "Sensitive", "Not sure"]
        ),
        OnboardingQuizQuestion(
            id: 2,
            question: "What are your skin goals?",
            questionType: .multiSelect,
            options: ["Hydration", "Brightening", "Acne", "Anti-Aging", "Glow", "Texture", "Even Tone"]
        ),
        OnboardingQuizQuestion(
            id: 3,
            question: "How sensitive is your skin?",
            questionType: .singleSelect,
            options: ["Not sensitive", "Slightly sensitive", "Very sensitive"]
        ),
        OnboardingQuizQuestion(
            id: 4,
            question: "How often do you currently do skincare?",
            questionType: .singleSelect,
            options: ["Daily", "Once a day", "Few times/week", "Rarely", "Never"]
        ),
        OnboardingQuizQuestion(
            id: 5,
            question: "What's your skincare experience level?",
            questionType: .singleSelect,
            options: ["Beginner", "Intermediate", "Obsessed"]
        ),
        OnboardingQuizQuestion(
            id: 6,
            question: "What's your primary skin concern?",
            questionType: .singleSelect,
            options: ["Acne", "Dryness", "Dullness", "Redness", "Fine Lines", "Uneven Tone"]
        ),
        OnboardingQuizQuestion(
            id: 7,
            question: "Any allergies or ingredients to avoid?",
            questionType: .textField,
            options: [],
            textFieldPlaceholder: "List ingredients here (optional)"
        ),
        OnboardingQuizQuestion(
            id: 8,
            question: "Any favorite ingredients you prefer?",
            questionType: .textField,
            options: [],
            textFieldPlaceholder: "List ingredients here (optional)"
        ),
        OnboardingQuizQuestion(
            id: 9,
            question: "Are you using any prescription treatments?",
            questionType: .toggle,
            options: ["Yes", "No"]
        ),
        OnboardingQuizQuestion(
            id: 10,
            question: "What climate do you live in?",
            questionType: .singleSelect,
            options: ["Dry", "Humid", "Seasonal", "I travel a lot"]
        ),
        OnboardingQuizQuestion(
            id: 11,
            question: "How much time do you want to spend on your routine?",
            questionType: .singleSelect,
            options: ["Under 5 min", "5–10 min", "10–15 min", "As long as it takes"]
        ),
        OnboardingQuizQuestion(
            id: 12,
            question: "Do you use sunscreen regularly?",
            questionType: .toggle,
            options: ["Yes", "No"]
        ),
        OnboardingQuizQuestion(
            id: 13,
            question: "Do you double cleanse at night?",
            questionType: .toggle,
            options: ["Yes", "No"]
        ),
        OnboardingQuizQuestion(
            id: 14,
            question: "Do you prefer fragranced products?",
            questionType: .singleSelect,
            options: ["Fragrance-Free", "Scented", "No Preference"]
        ),
        OnboardingQuizQuestion(
            id: 15,
            question: "Would you like product recommendations?",
            questionType: .toggle,
            options: ["Yes", "No"]
        )
    ]
} 