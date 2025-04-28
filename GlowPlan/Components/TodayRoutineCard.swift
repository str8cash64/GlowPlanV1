import SwiftUI

struct TodayRoutineCard: View {
    let routineName: String
    let time: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(routineName)
                        .font(.headline)
                        .foregroundColor(Color("CharcoalGray"))
                    
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    // Start action
                } label: {
                    Text("Start")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color("SalmonPink"))
                        .cornerRadius(20)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                ForEach(steps.indices, id: \.self) { index in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color("SalmonPink").opacity(0.3))
                            .frame(width: 28, height: 28)
                            .overlay(
                                Text("\(index + 1)")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color("SalmonPink"))
                            )
                        
                        Text(steps[index])
                            .font(.subheadline)
                            .foregroundColor(Color("CharcoalGray"))
                        
                        Spacer()
                    }
                }
            }
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
struct TodayRoutineCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TodayRoutineCard(
                routineName: "Evening Routine",
                time: "8:00 PM",
                steps: ["Cleanse", "Tone", "Serum", "Moisturize"]
            )
            .padding()
        }
        .background(Color("SoftWhite"))
    }
}
#endif 