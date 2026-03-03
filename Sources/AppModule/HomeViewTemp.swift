import SwiftUI
import SwiftData
import Combine

struct HomeViewTemp : View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PomodoroLog.date, order: .reverse)
    private let logs: [PomodoroLog]
    
    private let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @State private var currentSession: Session = .focus
    @State private var timeRemaining: Int = Session.focus.duration
    @State private var timerAction: TimerAction = .initial
    
    private var progress: Double {
        1 - Double(timeRemaining) / Double(currentSession.duration)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        currentSession.color.opacity(0.6),
                        .black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: Session Picker
                        Picker("Session", selection: $currentSession) {
                            ForEach(Session.allCases) { session in
                                Text(session.title)
                                    .foregroundStyle(.white)
                                    .tag(session)
                            }
                        }
                        .pickerStyle(.segmented)
                        .disabled(timerAction == .play)
                        
                        // MARK: Timer Card
                        TimerCard(
                            currentSession: $currentSession,
                            timeRemaining: $timeRemaining,
                            timerAction: $timerAction
                        )
                        
                        // MARK: Logs
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HStack {
                                Text("Logs")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                Spacer()
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            if logs.isEmpty {
                                Text("Belum ada activity")
                                    .foregroundStyle(.white.opacity(0.7))
                            } else {
                                ForEach(logs.prefix(20)) { log in
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(log.session) • \(log.action)")
                                                .foregroundStyle(.white)
                                            Text(log.date,
                                                 style: .time)
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.6))
                                        }
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(.white.opacity(0.08),
                                                in: RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding()
                        .background(
                            .ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("PomoDo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal){
                    Text("PomoDo")
                        .foregroundStyle(.white)
                        .font(.title.bold())
                }
            }
            .onReceive(timer) { _ in
                guard timerAction == .play else { return }
                
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
//                    timerFinished()
                }
            }
            .onChange(of: currentSession) { _, newValue in
                timeRemaining = newValue.duration
                timerAction = .initial
            }
        }
    }
}

#Preview {
    HomeViewTemp()
        .modelContainer(
            for: PomodoroLog.self,
            inMemory: true
        )
}
