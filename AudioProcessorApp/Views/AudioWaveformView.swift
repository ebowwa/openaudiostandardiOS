import SwiftUI

struct AudioWaveformView: View {
    let isPlaying: Bool
    let duration: TimeInterval
    let progress: Double
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<30) { index in
                Capsule()
                    .fill(Color.blue.opacity(0.8))
                    .frame(width: 3, height: getHeight(for: index))
                    .animation(.easeInOut(duration: 0.2), value: isPlaying)
            }
        }
        .frame(height: 40)
    }
    
    private func getHeight(for index: Int) -> CGFloat {
        if isPlaying {
            // Create a wave-like effect when playing
            let phase = Double(index) / 30.0 * 2 * .pi
            let amplitude: Double = 20
            let baseline: Double = 25
            return baseline + amplitude * sin(phase + progress * 10)
        } else {
            // Static random heights when not playing
            return CGFloat(10 + (index % 3) * 10)
        }
    }
}
