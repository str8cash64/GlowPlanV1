import SwiftUI

struct ChatAssistantView: View {
    @State private var messages: [ChatMessage] = ChatMessage.sampleMessages
    @State private var newMessage: String = ""
    @State private var showSheet: Bool = false
    @State private var scrollToBottom: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // Custom Navigation Bar
            VStack(spacing: 0) {
                HStack {
                    Text("Skincare Assistant")
                        .font(.headline)
                        .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        showSheet = true
                    }) {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                            .padding()
                    }
                }
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 5)
                
                Spacer()
            }
            
            // Main Chat Content
            VStack {
                // Add some padding to account for the custom navigation bar
                Spacer().frame(height: 56)
                
                ScrollViewReader { scrollView in
                    ScrollView {
                        LazyVStack {
                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                    }
                    // Use the new API for iOS 17+
                    #if swift(>=5.9) && canImport(SwiftUI)
                    // This branch will be taken for iOS 17 and later
                    .onChange(of: messages) { oldMessages, newMessages in
                        if scrollToBottom {
                            withAnimation {
                                if let lastMessage = newMessages.last {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                            scrollToBottom = false
                        }
                    }
                    #else
                    // This branch will be taken for iOS 16 and earlier
                    .onChange(of: messages) { _ in
                        if scrollToBottom {
                            withAnimation {
                                if let lastMessage = messages.last {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                            scrollToBottom = false
                        }
                    }
                    #endif
                }
                
                // Message Input
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(newMessage.isEmpty ? .gray : .accentColor)
                    }
                    .disabled(newMessage.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
            }
        }
        .sheet(isPresented: $showSheet) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Options")
                    .font(.headline)
                    .padding(.top)
                
                Button(action: {
                    messages = []
                    showSheet = false
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear conversation")
                    }
                }
                
                Button(action: {
                    // Report a concern
                    showSheet = false
                }) {
                    HStack {
                        Image(systemName: "flag")
                        Text("Report a concern")
                    }
                }
                
                Button(action: {
                    // About this assistant
                    showSheet = false
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                        Text("About this assistant")
                    }
                }
                
                Spacer()
            }
            .padding()
            .presentationDetents([.medium])
        }
    }
    
    private func sendMessage() {
        guard !newMessage.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(text: newMessage, isFromUser: true)
        messages.append(userMessage)
        scrollToBottom = true
        newMessage = ""
        
        // Simulate typing with a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            messages.addTypingIndicator()
            scrollToBottom = true
            
            // Simulate assistant response after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                messages.removeTypingIndicator()
                
                // Add assistant response
                let response = "Thanks for your message! This is a simulated response. In a real app, this would be connected to an AI assistant or backend service."
                let assistantMessage = ChatMessage(text: response, isFromUser: false)
                messages.append(assistantMessage)
                scrollToBottom = true
            }
        }
    }
}

struct ChatAssistantView_Previews: PreviewProvider {
    static var previews: some View {
        ChatAssistantView()
    }
} 