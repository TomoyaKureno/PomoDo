//
//  PomoDoApp.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import SwiftUI
import SwiftData

struct PomoDoApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: PomodoroSessionLog.self)
    }
}
