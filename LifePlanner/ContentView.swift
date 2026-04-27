//
//  ContentView.swift
//  LifePlanner
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
            
            GoalView()
                .tabItem {
                    Label("目標", systemImage: "target")
                }
            
            TodoView()
                .tabItem {
                    Label("Todo", systemImage: "checkmark.circle.fill")
                }
            
            ReportView()
                .tabItem {
                    Label("レポート", systemImage: "chart.bar.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
