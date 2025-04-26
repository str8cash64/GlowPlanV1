import SwiftUI

struct MessageBubble: View {
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    private var backgroundColor: Color {
        isUser ? Color("SalmonPink") : Color.white
    }
    
    private var textColor: Color {
        isUser ? Color.white : Color.black
    }
    
    private var alignment: Alignment {
        isUser ? .trailing : .leading
    }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(content)
                    .foregroundColor(textColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(backgroundColor)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
            }
            
            if !isUser { Spacer() }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

#if DEBUG
struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            MessageBubble(
                content: "Hello, how are you doing today?",
                isUser: false,
                timestamp: Date()
            )
            
            MessageBubble(
                content: "I'm doing great, thanks for asking!",
                isUser: true,
                timestamp: Date()
            )
        }
        .background(Color("SoftWhite"))
        .previewLayout(.sizeThatFits)
    }
}
#endif 