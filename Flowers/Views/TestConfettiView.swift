import SwiftUI

struct TestConfettiView: View {
    @State private var showConfetti = false
    
    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("Physics-Based Flower Confetti")
                    .font(.system(size: 28, weight: .light, design: .serif))
                    .foregroundColor(.flowerTextPrimary)
                
                Text("Using your custom flower SVG in different colors")
                    .font(.system(size: 16))
                    .foregroundColor(.flowerTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    showConfetti = true
                }) {
                    Text("Celebrate! 🎉")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.flowerPrimary, Color.flowerSecondary],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(28)
                        .shadow(color: .flowerPrimary.opacity(0.3), radius: 10, y: 5)
                }
                
                Spacer()
            }
            .padding(.top, 100)
        }
        .flowerConfetti(isActive: $showConfetti)
    }
}

struct TestConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        TestConfettiView()
    }
} 