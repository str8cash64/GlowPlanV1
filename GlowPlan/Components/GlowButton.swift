import SwiftUI

struct GlowButton: View {
    let title: String
    let action: () -> Void
    var isPrimary: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isPrimary ? Color("SalmonPink") : Color("Peach"))
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .foregroundColor(isPrimary ? .white : Color("CharcoalGray"))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

struct GlowButtonWithIcon: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    var isPrimary: Bool = true
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPrimary ? Color("SalmonPink") : Color("Peach"))
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
            .foregroundColor(isPrimary ? .white : Color("CharcoalGray"))
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal)
    }
}

#if DEBUG
struct GlowButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            GlowButton(title: "Primary Button", action: {})
            GlowButton(title: "Secondary Button", action: {}, isPrimary: false)
            GlowButtonWithIcon(title: "Button with Icon", systemImage: "heart.fill", action: {})
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 