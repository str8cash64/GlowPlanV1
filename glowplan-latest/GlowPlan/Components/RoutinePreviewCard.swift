import SwiftUI

struct RoutinePreviewCard: View {
    let routineName: String
    let timeOfDay: String
    let stepCount: Int
    let isActive: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(routineName)
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text("\(timeOfDay) • \(stepCount) steps")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Circle()
                    .fill(isActive ? Color("SalmonPink") : Color.gray.opacity(0.3))
                    .frame(width: 20, height: 20)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .opacity(isActive ? 1.0 : 0.0)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
struct RoutinePreviewCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            RoutinePreviewCard(
                routineName: "Morning Routine",
                timeOfDay: "Morning",
                stepCount: 5,
                isActive: true,
                onTap: {}
            )
            
            RoutinePreviewCard(
                routineName: "Evening Routine",
                timeOfDay: "Evening",
                stepCount: 4,
                isActive: false,
                onTap: {}
            )
        }
        .padding()
        .background(Color("SoftWhite"))
    }
}
#endif 