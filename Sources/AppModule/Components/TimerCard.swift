import SwiftUI

struct TimerCard: View {
    @Binding var currentSession: Session
    @Binding var timeRemaining: Int
    @Binding var timerAction: TimerAction
    
    private var progress: Double {
        1 - (Double(timeRemaining)/Double(currentSession.duration))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 14)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(currentSession.color, style: StrokeStyle(
                        lineWidth: 14,
                        lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: progress
                    )
                
                HStack(spacing: 0) {
                    Text(
                        formatMinuteSeconds(
                            minutes: calculateTime(timeRemaining).0,
                            seconds: calculateTime(timeRemaining).1
                        )
                    )
                    .font(
                        .system(
                            size: 42,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .foregroundStyle(.white)
                    
                    Text(
                        formatDesiSecond(desiSeconds: calculateTime(timeRemaining).2)
                    )
                    .font(
                        .system(
                            size: 26,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .baselineOffset(-6)
                    .foregroundStyle(.white.opacity(0.9))
                }
            }
            .frame(height: 250)
            
            HStack(alignment: .center, spacing: 16) {
                Button {
                    toggleTimer()  
                } label: {
                    Image(
                        systemName: timerAction == .play ? "pause.fill" : "play.fill"
                    )
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(
                    PrimaryButton(color: currentSession.color)
                )
                
                Button {
                    
                } label: {
                    Image(
                        systemName: "arrow.counterclockwise")
                    .font(.title3)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SecondaryButton())
            }
        }
        .padding()
        .background(
            .ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20)
        )
    }
    
    private func calculateTime(_ deciseconds: Int) -> (Int, Int, Int) {
        let totalSeconds = deciseconds / 10
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let desi = deciseconds % 10
        return (minutes, seconds, desi)
    }
    
    private func formatMinuteSeconds(minutes: Int, seconds: Int) -> String {
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func formatDesiSecond(desiSeconds: Int) -> String {
        return String(format: ".%01d", desiSeconds)
    }
    
    private func toggleTimer() {
        switch timerAction {
        case .initial, .pause:
            timerAction = .play
            addLog("Start")
        case .play:
            timerAction = .pause
            addLog("Pause")
        }
    }
    
    private func resetTimer() {
        timeRemaining = currentSession.duration
        timerAction = .initial
        addLog("Reset")
    }
    
    private func timerFinished() {
        timerAction = .initial
        addLog("Finished")
        timeRemaining = currentSession.duration
    }
    
    private func addLog(_ action: String) {
        _ = PomodoroLog(
            date: Date(),
            session: currentSession.title,
            action: action
        )
//        modelContext.insert(newLog)
    }
}

#Preview {
    
    @Previewable @State var currentSession: Session = .focus
    @Previewable @State var timeRemaining: Int = 20 * 60
    @Previewable @State var timerAction: TimerAction = .initial
    
    TimerCard(
        currentSession: $currentSession,
        timeRemaining: $timeRemaining,
        timerAction: $timerAction
    )
}
