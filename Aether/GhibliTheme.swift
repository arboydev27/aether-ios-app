//
//  GhibliTheme.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct GhibliTheme {
    struct Colors {
        static let skyBlue = Color(red: 0.53, green: 0.81, blue: 0.92) // Soft sky
        static let grassGreen = Color(red: 0.34, green: 0.62, blue: 0.40) // Lush grass
        static let cloudWhite = Color(red: 0.96, green: 0.96, blue: 0.94) // Off-white clouds
        static let sunsetOrange = Color(red: 0.98, green: 0.69, blue: 0.45) // Warm sunset
        static let deepBlue = Color(red: 0.10, green: 0.20, blue: 0.35) // Night sky
        static let textDark = Color(red: 0.20, green: 0.20, blue: 0.20) // Soft black
    }
    
    struct Fonts {
        static func title(size: CGFloat = 34) -> Font {
            return .system(size: size, weight: .bold, design: .serif)
        }
        
        static func body(size: CGFloat = 17) -> Font {
            return .system(size: size, weight: .regular, design: .rounded)
        }
    }
    
    // Helper for gradients
    static func backgroundGradient(for isNight: Bool = false) -> LinearGradient {
        let colors = isNight 
            ? [Colors.deepBlue, Colors.skyBlue.opacity(0.3)] 
            : [Colors.skyBlue, Colors.cloudWhite]
        
        return LinearGradient(
            gradient: Gradient(colors: colors),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
