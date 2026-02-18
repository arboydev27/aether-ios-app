//
//  AetherApp.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI
import SwiftData

@main
struct AetherApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: City.self)
    }
}
