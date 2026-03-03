import SwiftUI

struct BreakContinueSheet: View {
    let focusMinutes: Int
    let breakMinutes: Int
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Time for a Break!")
                .font(.title2.bold())
            
            Text("Take \(breakMinutes) minute\(breakMinutes > 1 ? "s" : "") to recharge")
                .foregroundStyle(.secondary)
            
            Button("Continue") {
                onContinue()
            }
            .foregroundStyle(.white)
            .background(.orange)
        }
        .padding()
    }
}
