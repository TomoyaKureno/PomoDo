import SwiftUI
import SwiftData
import Combine

struct TimerView: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    
    @Query(sort: \PomodoroSessionLog.startAt, order: .reverse)
    private var sessionLogs: [PomodoroSessionLog]
    
    private let ticker = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    let config: PomodoroConfig
    
    @State private var currentSession: Session = .focus
    @State private var completedFocus: Int = 0
    
    @State private var timerAction: TimerAction = .initial
    @State private var endDate: Date?
    @State private var timeRemaining: Int = 0 // deciseconds
    
    // transition popup 3 detik sebelum habis
    @State private var showTransitionPopup: Bool = false
    @State private var transitionTarget: Session? = nil
    @State private var popupShownForThisSession: Bool = false
    @State private var finishedAll: Bool = false
    
    // logging current session
    @State private var currentSessionLogId: UUID? = nil
    
    @State private var showSkipBreakConfirm: Bool = false
    @State private var showStopSessionConfirm: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [currentSession.color.opacity(0.6), .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 18) {
                    header
                    
                    TimerCard(
                        currentSession: $currentSession,
                        timeRemaining: $timeRemaining,
                        timerAction: $timerAction,
                        onToggle: { toggle() },
                        onReset: { secondaryButtonTapped() }
                    )
                    .disabled(showTransitionPopup && timeRemaining <= 0)
                    
                    logsSection
                    
                    Button("Stop Session") { 
                        showStopSessionConfirm = true
                    }
                    .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 4)
                }
                .padding()
            }
            
            if showTransitionPopup {
                Color.black.opacity(0.35).ignoresSafeArea()
                
                TimerTransitionPopup(
                    title: popupTitle(),
                    subtitle: popupSubtitle(),
                    canContinue: timeRemaining <= 0 && timerAction != .play,
                    onContinue: { continueAfterFinish() }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("PomoDo")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            startSession(.focus, autoStart: true)
        }
        .onReceive(ticker) { _ in
            tick()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            refreshRemainingFromEndDate()
            if timeRemaining <= 0, timerAction == .play {
                handleFinishIfNeeded()
            }
        }
        // ✅ Confirm popup
        .alert("Skip Break?", isPresented: $showSkipBreakConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Skip", role: .destructive) {
                skipBreakConfirmed()
            }
        } message: {
            Text("This will end the current break and start the next focus session.")
        }
        .alert("Stop Pomodoro Session?", isPresented: $showStopSessionConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Stop", role: .destructive) {
                coordinator.pop()
            }
        } message: {
            Text("Your progress will be saved in the summary.")
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(spacing: 4) {
            Text(currentSession.title)
                .font(.title.bold())
                .foregroundStyle(.white)
            
            let currentIndex = min(completedFocus + (currentSession == .focus ? 1 : 0), config.totalSessions)
            Text("Session \(currentIndex)/\(config.totalSessions)")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
    }
    
    // MARK: - Logs UI
    
    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Session Logs")
                .font(.headline)
                .foregroundStyle(.white)
            
            Divider().background(.white.opacity(0.2))
            
            if sessionLogs.isEmpty {
                Text("Belum ada session log")
                    .foregroundStyle(.white.opacity(0.7))
            } else {
                ForEach(sessionLogs.prefix(12)) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(log.sessionTypeRaw)
                            .foregroundStyle(.white)
                            .font(.headline)
                        
                        HStack(spacing: 10) {
                            Text("Start \(log.startAt.formatted(date: .omitted, time: .shortened))")
                            if let endAt = log.endAt {
                                Text("End \(endAt.formatted(date: .omitted, time: .shortened))")
                            } else {
                                Text("Running…")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        
                        HStack(spacing: 10) {
                            Text("Est \(formatMMSS(log.estimatedSeconds))")
                            if let actual = log.actualSeconds,
                               let diff = log.differenceSeconds,
                               log.endAt != nil {
                                Text("Act \(formatMMSS(actual))")
                                Text("Δ \(formatSignedDiff(diff))")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))
                    }
                    .padding(10)
                    .background(.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
        .navigationBarBackButtonHidden(true)
        .interactiveDismissDisabled(true)    
    }
    
    // MARK: - Timer core
    
    private func startSession(_ session: Session, autoStart: Bool) {
        currentSession = session
        
        popupShownForThisSession = false
        showTransitionPopup = false
        transitionTarget = nil
        finishedAll = false
        
        let estimatedSeconds = (session == .focus ? config.focusSeconds : config.breakSeconds)
        let durationDs = max(1, estimatedSeconds * 10)
        
        currentSession.durationDeciseconds = durationDs
        timeRemaining = durationDs
        endDate = Date().addingTimeInterval(TimeInterval(estimatedSeconds))
        timerAction = autoStart ? .play : .pause
        
        beginSessionLog(session: session, estimatedSeconds: estimatedSeconds)
    }
    
    private func tick() {
        guard timerAction == .play else { return }
        guard let endDate else { return }
        
        let remainingSeconds = endDate.timeIntervalSinceNow
        let remainingDs = Int((remainingSeconds * 10).rounded(.down))
        timeRemaining = max(0, remainingDs)
        
        // popup 3 detik sebelum habis
        if !popupShownForThisSession, timeRemaining <= 5, timeRemaining > 0 {
            popupShownForThisSession = true
            showTransitionPopup = true
            transitionTarget = nextSessionTargetPreview()
        }
        
        if timeRemaining <= 0 {
            handleFinishIfNeeded()
        }
    }
    
    private func handleFinishIfNeeded() {
        timerAction = .pause
        endDate = nil
        timeRemaining = 0
        
        if transitionTarget == nil {
            transitionTarget = nextSessionTargetAfterFinish()
        }
        showTransitionPopup = true
    }
    
    private func refreshRemainingFromEndDate() {
        guard timerAction == .play, let endDate else { return }
        let remainingSeconds = endDate.timeIntervalSinceNow
        let remainingDs = Int((remainingSeconds * 10).rounded(.down))
        timeRemaining = max(0, remainingDs)
    }
    
    // MARK: - Popup logic
    
    private func nextSessionTargetPreview() -> Session {
        currentSession == .focus ? .breakSession : .focus
    }
    
    private func nextSessionTargetAfterFinish() -> Session? {
        if currentSession == .focus {
            if completedFocus + 1 >= config.totalSessions { return nil }
            return .breakSession
        } else {
            return .focus
        }
    }
    
    private func continueAfterFinish() {
        // finalize log session ini (endAt = saat user menekan continue)
        finalizeCurrentSessionLog()
        
        showTransitionPopup = false
        
        if currentSession == .focus {
            completedFocus += 1
            
            if completedFocus >= config.totalSessions {
                finishedAll = true
                transitionTarget = nil
                showTransitionPopup = true
                return
            }
            
            startSession(.breakSession, autoStart: true)
        } else {
            startSession(.focus, autoStart: true)
        }
    }
    
    private func popupTitle() -> String {
        if finishedAll || transitionTarget == nil {
            return "All sessions completed 🎉"
        }
        switch currentSession {
        case .focus: return "Focus ending"
        case .breakSession: return "Break ending"
        }
    }
    
    private func popupSubtitle() -> String {
        if finishedAll || transitionTarget == nil {
            return "Great job! You're done."
        }
        switch currentSession {
        case .focus: return "Next: Break"
        case .breakSession: return "Next: Focus"
        }
    }
    
    // MARK: - TimerCard controls
    
    private func toggle() {
        switch timerAction {
        case .initial, .pause:
            let remainingSeconds = Double(timeRemaining) / 10.0
            endDate = Date().addingTimeInterval(remainingSeconds)
            timerAction = .play
        case .play:
            timerAction = .pause
            endDate = nil
        }
    }

    private func secondaryButtonTapped() {
        if currentSession == .breakSession {
            showSkipBreakConfirm = true
        } else {
            resetCurrent()
        }
    }
    
    private func resetCurrent() {
        popupShownForThisSession = false
        showTransitionPopup = false
        transitionTarget = nil
        finishedAll = false
        
        let estimatedSeconds = (currentSession == .focus ? config.focusSeconds : config.breakSeconds)
        let durationDs = max(1, estimatedSeconds * 10)
        
        timeRemaining = durationDs
        endDate = nil
        timerAction = .initial
        
        finalizeCurrentSessionLog(markAsReset: true)
        currentSessionLogId = nil
    }
    
    // MARK: - Skip Break Flow
    
    private func skipBreakConfirmed() {
        // hanya valid kalau lagi break
        guard currentSession == .breakSession else { return }
        
        // stop timer, close any transition popup
        timerAction = .pause
        endDate = nil
        
        // finalize log break (anggap endAt = sekarang)
        finalizeCurrentSessionLog(markAsSkipped: true)
        
        // lanjut focus berikutnya auto start
        startSession(.focus, autoStart: true)
    }
    
    // MARK: - Logging (per session)
    
    private func beginSessionLog(session: Session, estimatedSeconds: Int) {
        let log = PomodoroSessionLog(
            sessionTypeRaw: session.title,
            startAt: Date(),
            estimatedSeconds: estimatedSeconds
        )
        modelContext.insert(log)
        currentSessionLogId = log.id
    }
    
    private func finalizeCurrentSessionLog(
        endAt: Date = Date(),
        markAsReset: Bool = false,
        markAsSkipped: Bool = false
    ) {
        guard let id = currentSessionLogId else { return }
        guard let log = sessionLogs.first(where: { $0.id == id }) else { return }
        
        log.endAt = endAt
        let actual = Int(endAt.timeIntervalSince(log.startAt).rounded(.down))
        log.actualSeconds = max(0, actual)
        log.differenceSeconds = (log.actualSeconds ?? 0) - log.estimatedSeconds
        
        if markAsReset {
            log.sessionTypeRaw = "\(log.sessionTypeRaw) (Reset)"
        }
        if markAsSkipped {
            log.sessionTypeRaw = "\(log.sessionTypeRaw) (Skipped)"
        }
        
        currentSessionLogId = nil
    }
    
    // MARK: - Formatting
    
    private func formatMMSS(_ totalSeconds: Int) -> String {
        let m = max(0, totalSeconds) / 60
        let s = max(0, totalSeconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
    
    private func formatSignedDiff(_ diffSeconds: Int) -> String {
        let sign = diffSeconds >= 0 ? "+" : "-"
        return "\(sign)\(formatMMSS(abs(diffSeconds)))"
    }
}
