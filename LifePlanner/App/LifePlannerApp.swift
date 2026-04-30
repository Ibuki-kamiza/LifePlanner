//
//  LifePlannerApp.swift
//  LifePlanner
//
import SwiftUI
import SwiftData

@main
struct LifePlannerApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .modelContainer(for: [
            Goal.self,
            TodoItem.self,
            AIPersonality.self,
            UserProfile.self
        ])
    }
}
