import SwiftUI
import UIKit

struct GlowTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: UITextAutocapitalizationType = .sentences
    
    @State private var showPassword: Bool = false
    @State private var isFocused: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Field title
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("CharcoalGray"))
                .padding(.leading, 4)
            
            // Text field
            HStack(spacing: 12) {
                // Optional icon
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(Color("SalmonPink"))
                        .frame(width: 20)
                }
                
                // Text field or secure field
                if isSecure && !showPassword {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.black)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .onTapGesture {
                            isFocused = true
                        }
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(.black)
                        .autocapitalization(autocapitalization)
                        .keyboardType(keyboardType)
                        .onTapGesture {
                            isFocused = true
                        }
                }
                
                // Show/hide password button
                if isSecure {
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(Color("CharcoalGray").opacity(0.6))
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: isFocused ? Color("SalmonPink").opacity(0.2) : Color.black.opacity(0.05), 
                            radius: isFocused ? 6 : 4, 
                            x: 0, 
                            y: isFocused ? 2 : 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isFocused ? Color("SalmonPink") : Color.clear, lineWidth: 1)
            )
            .onAppear {
                // Reset focus state when view appears
                isFocused = false
            }
        }
    }
}

struct GlowTextField_Previews: PreviewProvider {
    @State static var text = ""
    
    static var previews: some View {
        VStack(spacing: 24) {
            GlowTextField(
                title: "Email",
                placeholder: "Enter your email",
                text: $text,
                icon: "envelope.fill",
                keyboardType: .emailAddress,
                autocapitalization: .none
            )
            
            GlowTextField(
                title: "Password",
                placeholder: "Enter your password",
                text: $text,
                isSecure: true,
                icon: "lock.fill"
            )
            
            GlowTextField(
                title: "Name",
                placeholder: "Enter your name",
                text: $text
            )
        }
        .padding()
        .background(Color("SoftWhite"))
        .previewLayout(.sizeThatFits)
    }
} 