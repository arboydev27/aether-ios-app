//
//  TerminalComponents.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct TerminalBox<Content: View>: View {
    let title: String?
    let borderColor: Color
    let content: Content
    
    init(title: String? = nil, borderColor: Color = JulesTheme.Colors.neonCyan, @ViewBuilder content: () -> Content) {
        self.title = title
        self.borderColor = borderColor
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background
            JulesTheme.Colors.orbit.opacity(0.3)
                .background(.ultraThinMaterial)
            
            // Content
            content
                .padding()
                .padding(.top, title != nil ? 20 : 0) // Extra padding for title
            
            // Border & Title Overlay
            VStack(spacing: 0) {
                HStack(alignment: .top, spacing: 0) {
                    // Top Left Corner
                    Corner(color: borderColor, location: .topLeft)
                    
                    // Title Area
                    if let title = title {
                        Text(" \(title) ")
                            .font(JulesTheme.Fonts.code(size: 10))
                            .foregroundColor(borderColor)
                            .background(JulesTheme.Colors.deepspace)
                            .offset(y: -7) // Move up to straddle border
                    }
                    
                    // Top Line
                    Rectangle()
                        .fill(borderColor.opacity(0.5))
                        .frame(height: 1)
                        .padding(.top, 0)
                    
                    // Top Right Corner
                    Corner(color: borderColor, location: .topRight)
                }
                
                HStack {
                    // Left Line
                    Rectangle()
                        .fill(borderColor.opacity(0.5))
                        .frame(width: 1)
                    
                    Spacer()
                    
                    // Right Line
                    Rectangle()
                        .fill(borderColor.opacity(0.5))
                        .frame(width: 1)
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    // Bottom Left Corner
                    Corner(color: borderColor, location: .bottomLeft)
                    
                    // Bottom Line
                    Rectangle()
                        .fill(borderColor.opacity(0.5))
                        .frame(height: 1)
                    
                    // Bottom Right Corner
                    Corner(color: borderColor, location: .bottomRight)
                }
            }
        }
    }
    
    struct Corner: View {
        let color: Color
        let location: Location
        
        enum Location {
            case topLeft, topRight, bottomLeft, bottomRight
        }
        
        var body: some View {
            ZStack(alignment: alignment) {
                Rectangle().fill(Color.clear).frame(width: 8, height: 8)
                
                // Horizontal part
                Rectangle()
                    .fill(color)
                    .frame(width: 8, height: 2)
                
                // Vertical part
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: 8)
            }
        }
        
        var alignment: Alignment {
            switch location {
            case .topLeft: return .topLeading
            case .topRight: return .topTrailing
            case .bottomLeft: return .bottomLeading
            case .bottomRight: return .bottomTrailing
            }
        }
    }
}

// A simple pixel-style progress bar
struct PixelProgressBar: View {
    let value: Double // 0.0 to 1.0
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background Track
                Rectangle()
                    .fill(JulesTheme.Colors.textDim.opacity(0.2))
                    .frame(height: 10)
                
                // Fill
                HStack(spacing: 2) {
                    ForEach(0..<Int(geometry.size.width / 6), id: \.self) { index in
                        if Double(index) / Double(geometry.size.width / 6) < value {
                            Rectangle()
                                .fill(color)
                                .frame(width: 4, height: 8)
                        }
                    }
                }
                .padding(.leading, 1)
            }
        }
        .frame(height: 10)
    }
}

// Tech Label equivalent
struct TechLabel: View {
    let text: String
    let color: Color
    
    init(_ text: String, color: Color = JulesTheme.Colors.textDim) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text("[\(text.uppercased())]")
            .font(JulesTheme.Fonts.code(size: 10))
            .foregroundColor(color)
    }
}

// Blinking Cursor Text
struct TypingText: View {
    let text: String
    @State private var showCursor = true
    
    var body: some View {
        HStack(spacing: 0) {
            Text(text)
            Text("_")
                .opacity(showCursor ? 1 : 0)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                        showCursor.toggle()
                    }
                }
        }
        .font(JulesTheme.Fonts.title(size: 32)) // Large title
        .foregroundColor(JulesTheme.Colors.textLight)
    }
}
