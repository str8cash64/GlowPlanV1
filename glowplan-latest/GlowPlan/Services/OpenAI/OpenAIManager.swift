import Foundation
import SwiftUI

struct OpenAIRoutineStep: Identifiable, Codable {
    let id = UUID()
    let stepName: String
    let productName: String
    var description: String = ""
    
    enum CodingKeys: String, CodingKey {
        case stepName, productName
    }
}

struct GeneratedRoutine: Codable {
    var morningRoutine: [OpenAIRoutineStep]
    var eveningRoutine: [OpenAIRoutineStep]
}

class OpenAIManager {
    // Singleton instance
    static let shared = OpenAIManager()
    
    // API Key
    private var apiKey: String = ""
    
    // Endpoints
    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Initialize with empty API key
    }
    
    // Set API key manually
    func setApiKey(_ key: String) {
        self.apiKey = key
    }
    
    // Check if API key is set
    func isApiKeySet() -> Bool {
        return !apiKey.isEmpty
    }
    
    // Convenience method to check and set OpenAI API key
    static func setupWithApiKey(_ apiKey: String) -> Bool {
        if apiKey.isEmpty {
            return false
        }
        
        OpenAIManager.shared.setApiKey(apiKey)
        return true
    }
    
    // Generate skincare routine
    func generateRoutine(from skinProfile: UserSkinProfile, completion: @escaping (Result<[OpenAIRoutineStep], Error>) -> Void) {
        // Create prompt based on user profile
        let prompt = createPrompt(from: skinProfile)
        
        // Prepare API request
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4-turbo",
            "messages": [
                ["role": "system", "content": "You are a world-class dermatologist and skincare routine expert."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 2000
        ]
        
        // Convert request body to JSON
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating request: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API request error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "OpenAIManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                completion(.failure(error))
                return
            }
            
            // Debug response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                let apiResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                
                guard let responseText = apiResponse.choices.first?.message.content else {
                    let error = NSError(domain: "OpenAIManager", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])
                    completion(.failure(error))
                    return
                }
                
                // Extract JSON from the response
                if let jsonData = self.extractJSONFromResponse(responseText).data(using: .utf8) {
                    do {
                        let generatedRoutine = try JSONDecoder().decode(GeneratedRoutine.self, from: jsonData)
                        
                        // Combine morning and evening routines and add descriptions
                        var combinedRoutine = [OpenAIRoutineStep]()
                        
                        // Add morning routine steps with descriptions
                        for var step in generatedRoutine.morningRoutine {
                            step.description = self.generateDescription(for: step.stepName, productName: step.productName)
                            combinedRoutine.append(step)
                        }
                        
                        // Add evening routine steps with descriptions
                        for var step in generatedRoutine.eveningRoutine {
                            step.description = self.generateDescription(for: step.stepName, productName: step.productName)
                            combinedRoutine.append(step)
                        }
                        
                        completion(.success(combinedRoutine))
                    } catch {
                        print("JSON decoding error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else {
                    let error = NSError(domain: "OpenAIManager", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not extract JSON from response"])
                    completion(.failure(error))
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }
    
    private func extractJSONFromResponse(_ response: String) -> String {
        if let startIndex = response.firstIndex(of: "{"),
           let endIndex = response.lastIndex(of: "}") {
            return String(response[startIndex...endIndex])
        }
        return response
    }
    
    private func generateDescription(for stepName: String, productName: String) -> String {
        switch stepName {
        case "Cleanse":
            return "Gently wash your face to remove impurities"
        case "Double Cleanse":
            return "First cleanse to remove makeup and sunscreen, second to cleanse the skin"
        case "Tone":
            return "Balance your skin's pH and prep for treatments"
        case "Treat", "Serum":
            return "Apply targeted treatment for your specific skin concerns"
        case "Moisturize":
            return "Lock in hydration and strengthen your skin barrier"
        case "Protect", "SPF":
            return "Shield your skin from harmful UV rays"
        case "Eye Cream":
            return "Nourish the delicate skin around your eyes"
        case "Mask":
            return "Deep treatment for intensive skin nourishment"
        case "Exfoliate":
            return "Remove dead skin cells to reveal brighter skin"
        default:
            return "Apply \(productName) as directed"
        }
    }
    
    private func createPrompt(from skinProfile: UserSkinProfile) -> String {
        return """
        📋 Updated SMART Prompt: GlowPlan Routine Generation (with Morning + Evening)

        You are a world-class dermatologist and skincare routine expert.

        Your task is to create a **personalized skincare routine** for the following user based on their profile information.

        User Profile:
        - Skin Type: \(skinProfile.skinType)
        - Goals: \(skinProfile.skinGoals.joined(separator: ", "))
        - Sensitivity: \(skinProfile.sensitivityLevel)
        - Routine Experience: \(skinProfile.experienceLevel)
        - Primary Concern: \(skinProfile.primaryConcern)
        - Preferred Ingredients: \(skinProfile.preferredIngredients)
        - Allergies: \(skinProfile.allergies)
        - Uses SPF: \(skinProfile.usesSPF ? "Yes" : "No")
        - Likes Fragrance-Free: \(skinProfile.fragrancePreference == "Fragrance-Free" ? "Yes" : "No")
        - Climate: \(skinProfile.climate)
        - Preferred Routine Duration: \(skinProfile.desiredRoutineTime)
        - Double Cleanses: \(skinProfile.doubleCleanses ? "Yes" : "No")

        Rules:
        - Base the number of steps on the user's preferred routine duration:
          - Under 5 min → 2–3 total steps per routine (Morning and Evening)
          - 5–10 min → 4–6 total steps per routine
          - 10+ min → 6–8 total steps per routine
        - Create both a **Morning Routine** and an **Evening Routine**
        - In Morning Routine:
          - Always include SPF step if the user uses SPF
        - In Evening Routine:
          - Suggest gentler treatments if user has high sensitivity
          - Include Double Cleanse only if user selected it
        - Only recommend fragrance-free products if the user prefers it
        - Use preferred ingredients
        - Avoid all listed allergies
        - Adjust recommendations based on user's climate (e.g., prioritize hydration for cold climates)
        - Suggest affordable and easy-to-find products
        - Keep all instructions beginner-friendly

        Output Format:

        Return a JSON object structured like this:

        ```json
        {
          "morningRoutine": [
            { "stepName": "Cleanse", "productName": "Gentle Hydrating Cleanser" },
            { "stepName": "Treat", "productName": "Hyaluronic Acid Serum" },
            { "stepName": "Protect", "productName": "SPF 50 Fragrance-Free Sunscreen" }
          ],
          "eveningRoutine": [
            { "stepName": "Cleanse", "productName": "Gentle Hydrating Cleanser" },
            { "stepName": "Moisturize", "productName": "Night Repair Moisturizer with Ceramides" }
          ]
        }
        ```

        Important:
        - Only return the JSON object as shown.
        - No additional explanations, notes, or text outside the JSON.
        """
    }
}

// Structures to decode OpenAI API response
struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
} 