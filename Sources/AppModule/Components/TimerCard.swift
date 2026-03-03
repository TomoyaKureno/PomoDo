import SwiftUI

struct TimerCard: View {
    @Binding var currentSession: Session
    @Binding var timeRemaining: Int        // deciseconds
    @Binding var timerAction: TimerAction
    
    let onToggle: () -> Void               // start/pause/resume
    let onReset: () -> Void                // focus=reset, break=skip (handled in TimerView)
    
    private var progress: Double {
        let total = Double(max(1, currentSession.durationDeciseconds))
        return 1 - (Double(timeRemaining) / total)
    }
    
    private var secondaryIcon: String {
        currentSession == .breakSession ? "forward.end.fill" : "arrow.counterclockwise"
    }
    
    private var secondaryLabel: String {
        currentSession == .breakSession ? "Skip Break" : "Reset"
    }
    
    private var primaryIcon: String {
        timerAction == .play ? "pause.fill" : "play.fill"
    }
    
    private var primaryLabel: String {
        timerAction == .play ? "Pause" : "Start"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 14)
                
                Circle()
                    .trim(from: 0, to: max(0, min(1, progress)))
                    .stroke(currentSession.color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.2), value: progress)
                
                HStack(spacing: 0) {
                    Text(formatMinuteSeconds(
                        minutes: calculateTime(timeRemaining).0,
                        seconds: calculateTime(timeRemaining).1
                    ))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    
                    Text(formatDesiSecond(desiSeconds: calculateTime(timeRemaining).2))
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .baselineOffset(-6)
                        .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(height: 250)
            
            HStack(alignment: .center, spacing: 16) {
                // Primary (Start/Pause)
                Button {
                    onToggle()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: primaryIcon)
                            .font(.title3)
                        Text(primaryLabel)
                            .font(.caption.weight(.semibold))
                            .opacity(0.9)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButton(color: currentSession.color))
                
                // Secondary (Reset / Skip Break)
                Button {
                    onReset()
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: secondaryIcon)
                            .font(.title3)
                        Text(secondaryLabel)
                            .font(.caption.weight(.semibold))
                            .opacity(0.9)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButton())
                .accessibilityLabel(secondaryLabel)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }
    
    private func calculateTime(_ deciseconds: Int) -> (Int, Int, Int) {
        let ds = max(0, deciseconds)
        let totalSeconds = ds / 10
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let desi = ds % 10
        return (minutes, seconds, desi)
    }
    
    private func formatMinuteSeconds(minutes: Int, seconds: Int) -> String {
        String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatDesiSecond(desiSeconds: Int) -> String {
        String(format: ".%01d", desiSeconds)
    }
}
