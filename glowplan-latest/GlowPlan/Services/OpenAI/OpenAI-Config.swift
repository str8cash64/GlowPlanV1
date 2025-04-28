import Foundation

// IMPORTANT: Never commit API keys to version control!
// This file should be included in .gitignore
struct OpenAIConfig {
    // API key for OpenAI
    // In a production app, this should be stored in a secure location or retrieved from a backend service
    static let apiKey = "THIS_IS_A_PLACEHOLDER_NOT_A_REAL_KEY" // Replace with your actual API key in local development
    
    // Initialize the OpenAI service when the app starts
    static func setupOpenAI() {
        OpenAIManager.setupWithApiKey(apiKey)
    }
} 