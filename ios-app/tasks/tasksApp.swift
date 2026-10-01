//
//  tasksApp.swift
//  tasks
//
//  Created by Haris Dar on 08/01/2026.
//

import SwiftUI

@main
struct tasksApp: App {
    init() {
        NotificationManager.shared.requestAuthorization()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
