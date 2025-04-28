import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    var isTypingIndicator: Bool {
        return text.isEmpty && !isFromUser
    }
    
    init(text: String, isFromUser: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isFromUser = isFromUser
        self.timestamp = timestamp
    }
    
    static var typingIndicator: ChatMessage {
        ChatMessage(text: "", isFromUser: false)
    }
    
    static var sampleMessages: [ChatMessage] = [
        ChatMessage(text: "Hi there! Welcome to GlowPlan. How can I help you with your skincare routine today?", isFromUser: false, timestamp: Date().addingTimeInterval(-3600)),
        ChatMessage(text: "I'm looking for recommendations for dry skin", isFromUser: true, timestamp: Date().addingTimeInterval(-3500)),
        ChatMessage(text: "For dry skin, I recommend using a gentle cleanser, hydrating toner, and a rich moisturizer with ingredients like hyaluronic acid and ceramides. Would you like specific product recommendations?", isFromUser: false, timestamp: Date().addingTimeInterval(-3400))
    ]
    
    // Custom implementation of Equatable to handle UUID comparison
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id &&
               lhs.text == rhs.text &&
               lhs.isFromUser == rhs.isFromUser &&
               lhs.timestamp == rhs.timestamp
    }
}

// MARK: - Array Extension for Typing Indicators
extension Array where Element == ChatMessage {
    mutating func addTypingIndicator() {
        // Only add if there isn't already a typing indicator
        if !self.contains(where: { $0.isTypingIndicator }) {
            self.append(ChatMessage(text: "", isFromUser: false))
        }
    }
    
    mutating func removeTypingIndicator() {
        if let index = self.firstIndex(where: { $0.isTypingIndicator }) {
            self.remove(at: index)
        }
    }
} 