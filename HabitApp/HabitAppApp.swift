//
//  HabitAppApp.swift
//  HabitApp
//
//  Created by huangrenbin on 2025/3/4.
//

import SwiftUI

@main
struct HabitAppApp: App {
    @StateObject private var habitViewModel = HabitViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}