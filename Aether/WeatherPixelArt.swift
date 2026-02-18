//
//  WeatherPixelArt.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct WeatherPixelArt {
    
    // MARK: - Patterns (8x8 Grid)
    
    static let sun: [[Int]] = [
        [0, 0, 1, 0, 0, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [1, 0, 1, 1, 1, 1, 0, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 0, 1, 1, 1, 1, 0, 1],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 1, 0, 0, 1, 0, 0]
    ]
    
    static let moon: [[Int]] = [
        [0, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [0, 1, 1, 1, 0, 0, 0, 0],
        [0, 1, 1, 1, 0, 0, 0, 0],
        [0, 1, 1, 1, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0]
    ]
    
    static let cloud: [[Int]] = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 1, 1, 1, 1, 1, 0],
        [0, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0]
    ]
    
    static let rain: [[Int]] = [
        [0, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 1, 1, 1, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 1, 0, 1, 0, 1, 0],
        [0, 0, 1, 0, 1, 0, 1, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [1, 0, 1, 0, 1, 0, 0, 0]
    ]
    
    static let snow: [[Int]] = [
        [1, 0, 0, 1, 0, 0, 1, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [0, 1, 0, 1, 0, 1, 0, 0],
        [1, 0, 0, 1, 0, 0, 1, 0],
        [0, 0, 0, 0, 0, 0, 0, 0]
    ]
    
    static let thunder: [[Int]] = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 0, 1, 1, 1, 0, 0],
        [0, 0, 1, 1, 1, 0, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 0, 0, 0]
    ]
    
    static let fog: [[Int]] = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0]
    ]
    
    // MARK: - Helpers
    
    static func getPattern(for code: Int, isDay: Bool) -> [[Int]] {
        switch code {
        case 0, 1: // Clear / Mainly Clear
            return isDay ? sun : moon
        case 2, 3: // Partly Cloudy / Overcast
            return cloud
        case 45, 48: // Fog
            return fog
        case 51...67, 80...82: // Drizzle / Rain / Showers
            return rain
        case 71...77, 85, 86: // Snow
            return snow
        case 95...99: // Thunderstorm
            return thunder
        default:
            return cloud
        }
    }
    
    static func getColor(for code: Int, isDay: Bool) -> Color {
        // Only the Sun (Clear Day) gets Yellow.
        if (code == 0 || code == 1) && isDay {
            return JulesTheme.Colors.sunYellow
        }
        // Everything else is Neon Cyan
        return JulesTheme.Colors.neonCyan
    }
}
