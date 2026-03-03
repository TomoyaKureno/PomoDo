//
//  Item.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import SwiftData
import Foundation

@Model
final class PomodoroSessionLog {
    var id: UUID
    var sessionTypeRaw: String            // "Focus" / "Break" (biar simpel)
    var startAt: Date
    var endAt: Date?
    var estimatedSeconds: Int
    
    // Derived values (disimpan biar gampang query/sort)
    var actualSeconds: Int?
    var differenceSeconds: Int?           // actual - estimated
    
    init(sessionTypeRaw: String, startAt: Date, estimatedSeconds: Int) {
        self.id = UUID()
        self.sessionTypeRaw = sessionTypeRaw
        self.startAt = startAt
        self.estimatedSeconds = estimatedSeconds
    }
}
