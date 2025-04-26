import SwiftUI

struct ChatBubble: View {
    var message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }
            
            if message.isTypingIndicator {
                TypingIndicator()
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(18)
            } else {
                Text(message.text)
                    .padding(12)
                    .background(message.isFromUser ? Color.accentColor : Color.gray.opacity(0.1))
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(18)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.text
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                    }
            }
            
            if !message.isFromUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct TypingIndicator: View {
    @State private var animationAmount = 0.0
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .frame(width: 7, height: 7)
                .opacity(0.4 + 0.6 * sin(animationAmount))
            
            Circle()
                .frame(width: 7, height: 7)
                .opacity(0.4 + 0.6 * sin(animationAmount + 0.5))
            
            Circle()
                .frame(width: 7, height: 7)
                .opacity(0.4 + 0.6 * sin(animationAmount + 1.0))
        }
        .foregroundColor(.gray)
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationAmount = 2 * Double.pi
            }
        }
    }
}

struct ChatBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ChatBubble(message: ChatMessage(text: "Hello! How can I help with your skincare today?", isFromUser: false))
            ChatBubble(message: ChatMessage(text: "I need help with my routine", isFromUser: true))
            ChatBubble(message: ChatMessage(text: "", isFromUser: false)) // Typing indicator
        }
    }
} 