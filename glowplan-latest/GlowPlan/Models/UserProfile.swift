import Foundation
#if canImport(FirebaseFirestore)
import FirebaseFirestore
#endif

struct UserProfile: Codable {
    var skinType: String
    var goals: [String]
    var sensitivity: String
    var routineExperience: String
    var routineFrequency: String
    var primaryConcern: String
    var preferredIngredients: [String]
    var allergies: [String]
    var usesSPF: Bool
    var likesFragranceFree: Bool
    var climate: String
    var routineDuration: String
    var doubleCleanses: Bool
    var wantsRecommendations: Bool
    var quizCompleted: Bool
    
    // Default initializer
    init(
        skinType: String = "",
        goals: [String] = [],
        sensitivity: String = "",
        routineExperience: String = "",
        routineFrequency: String = "",
        primaryConcern: String = "",
        preferredIngredients: [String] = [],
        allergies: [String] = [],
        usesSPF: Bool = false,
        likesFragranceFree: Bool = false,
        climate: String = "",
        routineDuration: String = "",
        doubleCleanses: Bool = false,
        wantsRecommendations: Bool = false,
        quizCompleted: Bool = false
    ) {
        self.skinType = skinType
        self.goals = goals
        self.sensitivity = sensitivity
        self.routineExperience = routineExperience
        self.routineFrequency = routineFrequency
        self.primaryConcern = primaryConcern
        self.preferredIngredients = preferredIngredients
        self.allergies = allergies
        self.usesSPF = usesSPF
        self.likesFragranceFree = likesFragranceFree
        self.climate = climate
        self.routineDuration = routineDuration
        self.doubleCleanses = doubleCleanses
        self.wantsRecommendations = wantsRecommendations
        self.quizCompleted = quizCompleted
    }
    
    // Conversion from UserSkinProfile
    init(from skinProfile: UserSkinProfile) {
        self.skinType = skinProfile.skinType
        self.goals = skinProfile.skinGoals
        self.sensitivity = skinProfile.sensitivityLevel
        self.routineExperience = skinProfile.experienceLevel
        self.routineFrequency = skinProfile.routineFrequency
        self.primaryConcern = skinProfile.primaryConcern
        self.preferredIngredients = [skinProfile.preferredIngredients]
        self.allergies = [skinProfile.allergies]
        self.usesSPF = skinProfile.usesSPF
        self.likesFragranceFree = skinProfile.fragrancePreference == "Fragrance-Free"
        self.climate = skinProfile.climate
        self.routineDuration = skinProfile.desiredRoutineTime
        self.doubleCleanses = skinProfile.doubleCleanses
        self.wantsRecommendations = skinProfile.wantsProductRecommendations
        self.quizCompleted = true
    }
    
    // Convert to Dictionary for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "skinType": skinType,
            "goals": goals,
            "sensitivity": sensitivity,
            "routineExperience": routineExperience,
            "routineFrequency": routineFrequency,
            "primaryConcern": primaryConcern,
            "preferredIngredients": preferredIngredients,
            "allergies": allergies,
            "usesSPF": usesSPF,
            "likesFragranceFree": likesFragranceFree,
            "climate": climate,
            "routineDuration": routineDuration,
            "doubleCleanses": doubleCleanses,
            "wantsRecommendations": wantsRecommendations,
            "quizCompleted": quizCompleted
        ]
    }
}

// Extension for RoutineStep
extension RoutineStep: Codable {
    // Private wrapper for encoding/decoding
    private struct CodableRoutineStep: Codable {
        let id: String
        let name: String
        let product: String
        let description: String
        
        init(from routineStep: RoutineStep) {
            self.id = routineStep.id.uuidString
            self.name = routineStep.name
            self.product = routineStep.product
            self.description = routineStep.description
        }
    }
    
    public init(from decoder: Decoder) throws {
        // Decode into a temporary container first
        let container = try decoder.singleValueContainer()
        let tempStep = try container.decode(CodableRoutineStep.self)
        
        // Initialize with standard initializer 
        self.init(
            name: tempStep.name,
            product: tempStep.product,
            description: tempStep.description
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(CodableRoutineStep(from: self))
    }
} 