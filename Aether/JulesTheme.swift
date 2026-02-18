//
//  JulesTheme.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI
import Foundation

struct JulesTheme {
    struct Colors {
        // Primary Backgrounds
        static let deepspace = Color(hex: "1d0245") // Deep Midnight Purple
        static let orbit = Color(hex: "110133") // Darker, desaturated purple for cards/surfaces
        
        // Accents
        static let neonCyan = Color(hex: "22d3ee") // Tailwind Cyan-400
        static let electricPurple = Color(hex: "a855f7") // Tailwind Purple-500
        static let sunYellow = Color(hex: "facc15") // Neon Yellow for Sun
        
        // Text
        static let textLight = Color(hex: "ffffff") // Pure White
        static let textDim = Color(hex: "9ca3af") // Cool Grey
    }
    
    struct Fonts {
        static func title(size: CGFloat = 24) -> Font {
            return .system(size: size, weight: .bold, design: .monospaced)
        }
        
        static func body(size: CGFloat = 15) -> Font {
            return .system(size: size, weight: .regular, design: .monospaced)
        }
        
        // For the "code" look
        static func code(size: CGFloat = 13) -> Font {
            return .system(size: size, weight: .medium, design: .monospaced)
        }
    }
    
    // Glassmorphism Helper
    static func glassMaterial() -> some View {
        // "Liquid Glass"
        // Uses UltraThinMaterial with a tint + overlay border
        Rectangle()
            .fill(.ultraThinMaterial)
            .overlay(Rectangle().fill(Colors.deepspace.opacity(0.3))) // Darken
            .overlay(
                Rectangle()
                    .stroke(Colors.neonCyan.opacity(0.1), lineWidth: 1) // Subtle border
            )
            .shadow(color: Colors.electricPurple.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // Gradient Background (Deep Space with Glows)
    static func backgroundGradient() -> some View {
        ZStack {
            Colors.deepspace.ignoresSafeArea()
            
            // Subtle glowing orb (top left)
            RadialGradient(
                gradient: Gradient(colors: [Colors.electricPurple.opacity(0.3), Colors.deepspace]),
                center: .topLeading,
                startRadius: 50,
                endRadius: 600
            )
            .ignoresSafeArea()
            .blendMode(.screen)
            
            // Subtle glowing orb (bottom right)
            RadialGradient(
                gradient: Gradient(colors: [Colors.neonCyan.opacity(0.2), Colors.deepspace]),
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 500
            )
            .ignoresSafeArea()
            .blendMode(.screen)
        }
    }
}

// Helper for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
