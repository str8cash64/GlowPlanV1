import SwiftUI

struct CustomTypingIndicator: View {
    @State private var showFirstDot = false
    @State private var showSecondDot = false
    @State private var showThirdDot = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.7))
                    .frame(width: 8, height: 8)
                    .opacity(dotOpacity(for: index))
                    .animation(
                        Animation
                            .easeInOut(duration: 0.4)
                            .repeatForever(autoreverses: true)
                            .delay(0.2 * Double(index)),
                        value: dotOpacity(for: index)
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            showFirstDot = true
            showSecondDot = true
            showThirdDot = true
        }
    }
    
    private func dotOpacity(for index: Int) -> Double {
        switch index {
        case 0: return showFirstDot ? 1.0 : 0.3
        case 1: return showSecondDot ? 1.0 : 0.3
        case 2: return showThirdDot ? 1.0 : 0.3
        default: return 0.3
        }
    }
}

#if DEBUG
struct CustomTypingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        CustomTypingIndicator()
            .background(Color("SoftWhite"))
            .previewLayout(.sizeThatFits)
    }
}
#endif 