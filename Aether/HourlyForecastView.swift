//
//  HourlyForecastView.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct HourlyForecastView: View {
    let forecast: [Weather.HourlyForecastItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DATA_BUFFER // HOURLY_FORECAST")
                .font(JulesTheme.Fonts.code(size: 12))
                .foregroundColor(JulesTheme.Colors.neonCyan)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(forecast) { item in
                        VStack(spacing: 8) {
                            Text(item.formattedTime)
                                .font(JulesTheme.Fonts.code(size: 11))
                                .foregroundColor(JulesTheme.Colors.textDim)
                            
                            Image(systemName: item.icon)
                                .font(.system(size: 20))
                                .foregroundColor(JulesTheme.Colors.textLight)
                                .frame(height: 24)
                            
                            Text(String(format: "%.0f°", item.temp))
                                .font(JulesTheme.Fonts.code(size: 14))
                                .foregroundColor(JulesTheme.Colors.electricPurple)
                            
                            // Mini UV bar
                            VStack(spacing: 2) {
                                Text("UV:\(Int(item.uv))")
                                    .font(JulesTheme.Fonts.code(size: 8))
                                    .foregroundColor(JulesTheme.Colors.textDim)
                                
                                Rectangle()
                                    .fill(uvColor(item.uv))
                                    .frame(width: 20, height: 2)
                            }
                        }
                        .padding(12)
                        .background(JulesTheme.Colors.orbit.opacity(0.6))
                        .overlay(
                            Rectangle()
                                .stroke(JulesTheme.Colors.textDim.opacity(0.2), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func uvColor(_ index: Double) -> Color {
        switch index {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
}
