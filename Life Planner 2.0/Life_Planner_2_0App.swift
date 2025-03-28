//
//  Life_Planner_2_0App.swift
//  Life Planner 2.0
//
//  Created by 許銘聰 on 2025/3/20.
//

import SwiftUI

@main
struct Life_Planner_2_0App: App {
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
        }
    }
}
