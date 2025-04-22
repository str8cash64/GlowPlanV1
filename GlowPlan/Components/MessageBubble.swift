import SwiftUI

struct MessageBubble: View {
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    private var backgroundColor: Color {
        isUser ? Color("SalmonPink") : Color("SoftWhite")
    }
    
    private var textColor: Color {
        isUser ? .white : Color("CharcoalGray")
    }
    
    private var alignment: Alignment {
        isUser ? .trailing : .leading
    }
    
    var body: some View {
        HStack {
            if isUser {
                Spacer()
            }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(backgroundColor)
                    )
                    .foregroundColor(textColor)
                
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
            }
            
            if !isUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

struct TypingIndicator: View {
    @State private var dotHeight: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 8) {
            Text("GlowBot is typing")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 3) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(Color("SalmonPink"))
                        .frame(width: 6, height: 6)
                        .offset(y: index % 2 == 0 ? -2 : 2)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubble(content: "Hello! How can I help you with your skincare routine today?", isUser: false, timestamp: Date())
            
            MessageBubble(content: "I've been breaking out lately and I'm not sure what products to use.", isUser: true, timestamp: Date())
            
            MessageBubble(content: "I understand! Let's find the right products for your skin concerns. First, could you tell me about your skin type?", isUser: false, timestamp: Date())
            
            TypingIndicator()
        }
        .padding(.vertical)
        .background(Color.white)
    }
}
#endif 