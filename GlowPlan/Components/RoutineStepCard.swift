import SwiftUI

struct RoutineStepCard: View {
    let stepNumber: Int
    let title: String
    let description: String
    
    init(stepNumber: Int, title: String, description: String) {
        self.stepNumber = stepNumber
        self.title = title
        self.description = description
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(Color("SalmonPink"))
                        .frame(width: 36, height: 36)
                    
                    Text("\(stepNumber)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                Button {
                    // Edit action
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(Color("CharcoalGray").opacity(0.6))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

#if DEBUG
struct RoutineStepCard_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoutineStepCard(
                    stepNumber: 1,
                    title: "Cleanse",
                    description: "Gently wash your face with lukewarm water"
                )
                
                RoutineStepCard(
                    stepNumber: 2,
                    title: "Tone",
                    description: "Apply toner to balance skin pH"
                )
                
                RoutineStepCard(
                    stepNumber: 3,
                    title: "Moisturize",
                    description: "Lock in hydration with a moisturizer suitable for your skin type"
                )
            }
            .padding(.vertical)
        }
        .background(Color("SoftWhite"))
    }
}
#endif 