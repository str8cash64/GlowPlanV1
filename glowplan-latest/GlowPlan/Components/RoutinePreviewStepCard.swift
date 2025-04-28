import SwiftUI

struct RoutinePreviewStepCard: View {
    let stepNumber: Int
    let stepName: String
    let productName: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(Color("SalmonPink").opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Text("\(stepNumber)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SalmonPink"))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Step name and product
                HStack {
                    Text(stepName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text("→")
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(Color("CharcoalGray").opacity(0.7))
                    
                    Text(productName)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SalmonPink"))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Description
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(Color("CharcoalGray").opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

#if DEBUG
struct RoutinePreviewStepCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RoutinePreviewStepCard(
                stepNumber: 1, 
                stepName: "Cleanse", 
                productName: "Gentle Hydrating Cleanser",
                description: "Gently wash your face to remove impurities"
            )
            
            RoutinePreviewStepCard(
                stepNumber: 2, 
                stepName: "Treat", 
                productName: "Vitamin C Serum",
                description: "Brightens and evens skin tone"
            )
            
            RoutinePreviewStepCard(
                stepNumber: 3, 
                stepName: "Moisturize", 
                productName: "Fragrance-Free Calming Cream",
                description: "Lock in hydration and strengthen skin barrier"
            )
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 