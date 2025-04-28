import SwiftUI

struct RoutineStepView: View {
    let stepNumber: Int
    let stepTitle: String
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Step number circle
            ZStack {
                Circle()
                    .fill(isCompleted ? Color("SalmonPink") : Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(stepNumber)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("CharcoalGray"))
                }
            }
            
            // Step title
            Text(stepTitle)
                .font(.body)
                .foregroundColor(isCompleted ? Color.gray : Color("CharcoalGray"))
                .strikethrough(isCompleted)
                .lineLimit(2)
            
            Spacer()
            
            // Completion toggle
            Button(action: onToggle) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isCompleted ? Color("SalmonPink") : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isCompleted {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color("SalmonPink"))
                            .frame(width: 22, height: 22)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#if DEBUG
struct RoutineStepView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            RoutineStepView(
                stepNumber: 1,
                stepTitle: "Wash face with cleanser",
                isCompleted: true,
                onToggle: {}
            )
            
            RoutineStepView(
                stepNumber: 2,
                stepTitle: "Apply moisturizer",
                isCompleted: false,
                onToggle: {}
            )
            
            RoutineStepView(
                stepNumber: 3,
                stepTitle: "Apply sunscreen (SPF 30+)",
                isCompleted: false,
                onToggle: {}
            )
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 