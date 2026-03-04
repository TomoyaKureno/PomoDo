import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    
    @State private var totalSession: Int = 4
    @State private var isSheetPresent: Bool = false
    
    @State private var focusSeconds: Int = 25 * 60
    @State private var breakSeconds: Int = 5 * 60
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.blue, .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack {
                    Text("PomoDo")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Focus. Breath. Achieve")
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Target Sessions")
                        .font(.headline.bold())
                        .foregroundStyle(.white)
                    
                    VStack(spacing: 16) {
                        HStack {
                            CircleIconButton(systemName: "minus") {
                                guard totalSession > 1 else { return }
                                totalSession -= 1
                            }
                            
                            Spacer()
                            
                            Text("\(totalSession)")
                                .font(.system(size: 46, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            CircleIconButton(systemName: "plus") { totalSession += 1 }
                        }
                        .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.text.magnifyingglass")
                                Text("\(formatDuration(focusSeconds)) Focus")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            
                            HStack(spacing: 8) {
                                Image(systemName: "cup.and.saucer.fill")
                                Text("\(formatDuration(breakSeconds)) Break")
                            }
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Button { isSheetPresent = true } label: {
                                Text("Customize")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(.white.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            }
                        }
                    }
                    
                    Button {
                        let config = PomodoroConfig(
                            totalSessions: totalSession,
                            focusSeconds: focusSeconds,
                            breakSeconds: breakSeconds
                        )
                        coordinator.push(.timer(config))
                    } label: {
                        Text("Start Pomodoro")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity)
                            .background(.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
            }
            .padding()
        }
        .sheet(isPresented: $isSheetPresent) {
            TimePickerSheet(
                focusSeconds: $focusSeconds,
                breakSeconds: $breakSeconds,
                onCancel: { isSheetPresent = false },
                onSave: { isSheetPresent = false }
            )
            .presentationDetents([.height(320)])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        if m > 0 && s > 0 { return "\(m)m \(s)s" }
        if m > 0 { return "\(m)m" }
        return "\(s)s"
    }
}
