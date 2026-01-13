
import SwiftUI

struct ConfettiModifier: ViewModifier {
    @Binding var counter: Int
    @State private var isAnimating: Bool = false
    @State private var lastCounter: Int = 0
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            // Only show confetti during active animation
            if isAnimating {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiParticle(index: index, triggerId: counter)
                }
            }
        }
        .onChange(of: counter) { newValue in
            // Only trigger if counter actually increased (new save event)
            if newValue > lastCounter {
                lastCounter = newValue
                triggerAnimation()
            }
        }
    }
    
    private func triggerAnimation() {
        // Start animation
        isAnimating = true
        
        // Stop animation after 2 seconds (animation duration)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isAnimating = false
        }
    }
}

struct ConfettiParticle: View {
    let index: Int
    let triggerId: Int
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
            .fill(colors.randomElement() ?? .orange)
            .frame(width: 8, height: 8)
            .position(location)
            .opacity(opacity)
            .onAppear {
                // Reset and animate immediately when particle appears
                withAnimation(.none) {
                    reset()
                }
                animate()
            }
    }
    
    func reset() {
        // Start from center of screen
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
