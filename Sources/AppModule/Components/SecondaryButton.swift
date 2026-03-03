import SwiftUI

struct SecondaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                .white.opacity(0.15)
            )
            .foregroundStyle(.white)
            .clipShape(.capsule)
    }
}
