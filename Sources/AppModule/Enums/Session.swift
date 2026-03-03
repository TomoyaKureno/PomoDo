import SwiftUI

enum Session: String, CaseIterable, Identifiable {
    case focus
    case breakSession
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .focus: return "Focus Time"
        case .breakSession: return "Break"
        }
    }
    
    var color: Color {
        switch self {
        case .focus: return .red
        case .breakSession: return .blue
        }
    }
    
    /// durasi session dalam deciseconds (0.1s). Di-set oleh TimerView.
    var durationDeciseconds: Int {
        get { _durationDeciseconds[self] ?? 1 }
        set { _durationDeciseconds[self] = max(1, newValue) }
    }
}

// storage sederhana untuk durasi runtime
private var _durationDeciseconds: [Session: Int] = [:]
