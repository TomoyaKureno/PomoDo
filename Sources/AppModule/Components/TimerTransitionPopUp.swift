import SwiftUI

struct TimerTransitionPopup: View {
    let title: String
    let subtitle: String
    let canContinue: Bool
    var buttonLabel: String = "Continue"
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            
            Button {
                onContinue()
            } label: {
                Text(buttonLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButton(color: .white.opacity(0.25)))
            .disabled(!canContinue)
            .opacity(canContinue ? 1 : 0.55)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 12)
        .padding(.horizontal, 24)
    }
}
