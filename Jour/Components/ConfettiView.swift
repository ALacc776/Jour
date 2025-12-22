
import SwiftUI

struct ConfettiModifier: ViewModifier {
    @Binding var counter: Int
    @State private var circleStart: Bool = false
    @State private var circleEnd: Bool = false
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if counter > 0 {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiParticle(index: index, counter: counter)
                }
            }
        }
    }
}

struct ConfettiParticle: View {
    let index: Int
    let counter: Int
    @State private var location: CGPoint = .zero
    @State private var opacity: Double = 0
    
    // Random colors including the new playful ones
    let colors: [Color] = [
        AppConstants.Colors.duoRed,
        AppConstants.Colors.duoBlue,
        AppConstants.Colors.duoGreen,
        AppConstants.Colors.duoYellow,
        AppConstants.Colors.duoPurple,
        .orange,
        .pink
    ]
    
    var body: some View {
        Circle()
            .fill(colors.randomElement()!)
            .frame(width: 8, height: 8)
            .position(location)
            .opacity(opacity)
            .onAppear {
                withAnimation(.none) {
                    reset()
                }
                animate()
            }
            .onChange(of: counter) { _ in
                reset()
                animate()
            }
    }
    
    func reset() {
        // Start from center-ish (or click location if we tracked it, but center is fine for general reward)
        let screenWidth = UIScreen.main.bounds.width
        let startX = screenWidth / 2
        let startY = UIScreen.main.bounds.height / 2
        
        location = CGPoint(x: startX, y: startY)
        opacity = 1
    }
    
    func animate() {
        withAnimation(
            .interpolatingSpring(stiffness: 50, damping: 5)
            .speed(Double.random(in: 0.8...1.5))
            .delay(Double.random(in: 0...0.1))
        ) {
            // Random explosion direction
            let angle = Double.random(in: 0...2 * .pi)
            let distance = Double.random(in: 100...300)
            
            let endX = location.x + cos(angle) * distance
            let endY = location.y + sin(angle) * distance + 200 // Add gravity
            
            location = CGPoint(x: endX, y: endY)
            opacity = 0
        }
    }
}

extension View {
    func confetti(counter: Binding<Int>) -> some View {
        self.modifier(ConfettiModifier(counter: counter))
    }
}
