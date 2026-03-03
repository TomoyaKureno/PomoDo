import SwiftUI

enum Session: String, CaseIterable, Identifiable {
    case focus
    case breakSession
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .focus: return "Focus"
        case .breakSession: return "Break"
        }
    }
    
    var duration: Int {
        switch self {
        case .focus: return 25 * 60 * 10
        case .breakSession: return 5 * 60 * 10
        }
    }
    
    var color: Color {
        switch self {
        case .focus: return .red
        case .breakSession: return .blue
        }
    }
}
