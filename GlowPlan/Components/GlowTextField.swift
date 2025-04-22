import SwiftUI

struct GlowTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("CharcoalGray"))
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color("CharcoalGray"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Color("CharcoalGray"))
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal)
    }
}

#if DEBUG
struct GlowTextField_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GlowTextField(title: "Email", placeholder: "Enter your email", text: .constant(""))
            GlowTextField(title: "Password", placeholder: "Enter your password", text: .constant(""), isSecure: true)
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 