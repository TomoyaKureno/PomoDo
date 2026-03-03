import Foundation

struct RecapSummary: Hashable {
    let totalCycles: Int
    let totalFocusDuration: Int
    let totalBreakDuration: Int
    let totalDuration: Int
    let completedAt: Date
    let isCompleted: Bool
}
