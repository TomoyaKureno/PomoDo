//
//  Item.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import Foundation
import SwiftData

@Model
final class PomodoroLog {
    var date: Date
    var session: String
    var action: String
    
    init(date: Date, session: String, action: String) {
        self.date = date
        self.session = session
        self.action = action
    }
}
