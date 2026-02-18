//
//  DailyForecastView.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct DailyForecastView: View {
    let forecast: [Weather.DailyForecastItem]
    
    // Calculate global min/max for the bar chart scaling
    var minTempGlobal: Double {
        forecast.map { $0.minTemp }.min() ?? 0
    }
    
    var maxTempGlobal: Double {
        forecast.map { $0.maxTemp }.max() ?? 30
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7_DAY_FORECAST")
                .font(JulesTheme.Fonts.code(size: 12))
                .foregroundColor(JulesTheme.Colors.neonCyan)
                .padding(.horizontal)
            
            VStack(spacing: 4) {
                ForEach(forecast) { item in
                    HStack {
                        // Day Name
                        Text(item.dayName.prefix(3).uppercased())
                            .font(JulesTheme.Fonts.code(size: 12))
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .frame(width: 40, alignment: .leading)
                        
                        // Icon
                        Image(systemName: item.icon)
                            .font(.system(size: 12))
                            .foregroundColor(JulesTheme.Colors.textDim)
                            .frame(width: 20)
                        
                        // Temp Bar Visualization
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Background track
                                Rectangle()
                                    .fill(JulesTheme.Colors.textDim.opacity(0.1))
                                    .frame(height: 4)
                                
                                // Range bar
                                let range = maxTempGlobal - minTempGlobal
                                let width = (item.maxTemp - item.minTemp) / (range == 0 ? 1 : range) * geo.size.width
                                let offset = (item.minTemp - minTempGlobal) / (range == 0 ? 1 : range) * geo.size.width
                                
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [JulesTheme.Colors.neonCyan, JulesTheme.Colors.electricPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(width, 2), height: 4)
                                    .offset(x: offset)
                            }
                            .frame(height: 4)
                            .offset(y: 8) // Center vertically roughly
                        }
                        .frame(height: 20)
                        
                        // Min / Max Text
                        HStack(spacing: 6) {
                            Text(String(format: "%.0f", item.minTemp))
                                .foregroundColor(JulesTheme.Colors.neonCyan)
                            Text(String(format: "%.0f", item.maxTemp))
                                .foregroundColor(JulesTheme.Colors.electricPurple)
                        }
                        .font(JulesTheme.Fonts.code(size: 12))
                        .frame(width: 60, alignment: .trailing)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(JulesTheme.Colors.orbit.opacity(0.3))
                }
            }
            .padding(.horizontal)
        }
    }
}
