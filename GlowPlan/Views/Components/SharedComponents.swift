import SwiftUI

// MARK: - UI Components for reuse across views

// Feature Card for the carousel
struct FeatureCardComponent: View {
    let title: String
    let description: String
    let imageName: String
    let backgroundColor: Color
    let cardID: String
    
    init(title: String, description: String, imageName: String, backgroundColor: Color, cardID: String = UUID().uuidString) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.backgroundColor = backgroundColor
        self.cardID = cardID
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(backgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .id("FeatureCardBG-\(cardID)")
            
            HStack {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .id("FeatureCardTitle-\(cardID)")
                    
                    Text(description)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                        .id("FeatureCardDesc-\(cardID)")
                }
                .padding(20)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .id("FeatureCardIconBG-\(cardID)")
                    
                    Image(systemName: imageName)
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .id("FeatureCardIcon-\(cardID)")
                }
                .padding(.trailing, 20)
            }
        }
        .padding(.horizontal)
    }
}

// Quick Action Button
struct QuickActionButtonComponent: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button {
            // Button action
        } label: {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color("CharcoalGray"))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
} 