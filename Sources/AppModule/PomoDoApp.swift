//
//  PomoDoApp.swift
//  PomoDo
//
//  Created by Academy on 03/03/26.
//

import SwiftUI
import SwiftData

struct PomoDoApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//            PomodoroLog.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
//        .modelContainer(sharedModelContainer)
    }
}
