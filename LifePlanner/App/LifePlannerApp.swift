//
//  LifePlannerApp.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

@main
struct LifePlannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Goal.self,
            TodoItem.self,
            AIPersonality.self,
            UserProfile.self
        ])
    }
}
