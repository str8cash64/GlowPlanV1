import SwiftUI

struct ChatInputView: View {
    @Binding var message: String
    var onSend: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            TextField("Type a message...", text: $message, axis: .vertical)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                )
                .focused($isFocused)
                .lineLimit(5)
            
            Button(action: {
                if !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onSend()
                }
            }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(
                        message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.gray.opacity(0.5)
                        : Color("SalmonPink")
                    )
            }
            .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("SoftWhite"))
    }
}

#if DEBUG
struct ChatInputView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            ChatInputView(
                message: .constant("Hello, how can I help you with your skincare routine today?"),
                onSend: {}
            )
        }
        .background(Color("SoftWhite"))
        .previewLayout(.sizeThatFits)
    }
}
#endif 