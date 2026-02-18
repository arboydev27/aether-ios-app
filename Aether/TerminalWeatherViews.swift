//
//  TerminalWeatherViews.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct TerminalHeaderView: View {
    let city: String
    let lat: Double?
    let lon: Double?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // City Name with Blinking Cursor
            HStack(alignment: .bottom) {
                Text(city.uppercased())
                    .font(JulesTheme.Fonts.title(size: 40))
                    .foregroundColor(JulesTheme.Colors.textLight)
                    .shadow(color: JulesTheme.Colors.neonCyan.opacity(0.5), radius: 8)
                
                // Blinking underscore
                BlinkingCursor()
                    .padding(.bottom, 8)
            }
            
            // Lat/Lon
            if let lat = lat, let lon = lon {
                HStack(spacing: 15) {
                    Text("LAT: \(String(format: "%.4f", lat))° N")
                    Text("|")
                        .foregroundColor(JulesTheme.Colors.textDim.opacity(0.5))
                    Text("LON: \(String(format: "%.4f", lon))° W")
                }
                .font(JulesTheme.Fonts.code(size: 12))
                .foregroundColor(JulesTheme.Colors.textDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

struct BlinkingCursor: View {
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Text("_")
            .font(JulesTheme.Fonts.title(size: 40))
            .foregroundColor(JulesTheme.Colors.neonCyan)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                    opacity = 0.0
                }
            }
    }
}


struct TerminalMainStatusView: View {
    let weather: Weather
    
    var body: some View {
        TerminalBox(title: "CURRENT_CONDITION", borderColor: JulesTheme.Colors.neonCyan) {
            HStack(alignment: .top) {
                // Left Side: Weather Data
                VStack(alignment: .leading, spacing: 10) {
                    // Header: Icon + Label
                    HStack(spacing: 8) {
                        Image(systemName: WeatherCodeHelper.getIconName(for: weather.current.weather_code))
                            .font(.system(size: 16))
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                        
                        Text("STATUS: ONLINE") // Static for "feeling"
                            .font(JulesTheme.Fonts.code(size: 10))
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                    }
                    
                    // Temperature
                    Text(weather.temperatureString)
                        .font(JulesTheme.Fonts.title(size: 60))
                        .foregroundColor(JulesTheme.Colors.textLight)
                    
                    // Description
                    HStack(spacing: 4) {
                        Text(">>")
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                        Text(weather.description)
                            .foregroundColor(JulesTheme.Colors.textDim)
                    }
                    .font(JulesTheme.Fonts.code(size: 14))
                }
                
                Spacer()
                
                // Right Side: 8x8 Pixel Art Grid
                WeatherPixelGrid(code: weather.current.weather_code, isDay: weather.current.is_day == 1)
            }
            .padding(.vertical, 10)
        }
        .padding(.horizontal)
    }
}

struct WeatherPixelGrid: View {
    let code: Int
    let isDay: Bool
    
    var body: some View {
        let pattern = WeatherPixelArt.getPattern(for: code, isDay: isDay)
        let activeColor = WeatherPixelArt.getColor(for: code, isDay: isDay)
        
        VStack(spacing: 2) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 2) {
                    ForEach(0..<8, id: \.self) { col in
                        let isActive = pattern[row][col] == 1
                        Rectangle()
                            .fill(isActive ? activeColor : JulesTheme.Colors.orbit.opacity(0.3))
                            .frame(width: 6, height: 6) // Smaller for 8x8 fit
                    }
                }
            }
        }
        .padding(8)
        .background(JulesTheme.Colors.orbit.opacity(0.2))
        .overlay(
            Rectangle()
                .stroke(activeColor.opacity(0.3), lineWidth: 1)
        )
    }
}

struct TerminalMetricsGrid: View {
    let weather: Weather
    
    var body: some View {
        // Divider
        HStack {
            Rectangle().frame(height: 1).foregroundColor(JulesTheme.Colors.neonCyan.opacity(0.5))
            Text("[METRICS_DUMP]")
                .font(JulesTheme.Fonts.code(size: 10))
                .foregroundColor(JulesTheme.Colors.neonCyan)
            Rectangle().frame(height: 1).foregroundColor(JulesTheme.Colors.neonCyan.opacity(0.5))
        }
        .padding(.horizontal).padding(.vertical, 10)
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            // Humidity
            MetricPanel(label: "HUMIDITY", value: weather.humidityString, icon: "humidity", color: JulesTheme.Colors.neonCyan) {
                // Progress Bar
                PixelProgressBar(value: Double(weather.current.relative_humidity_2m) / 100.0, color: JulesTheme.Colors.neonCyan)
            }
            
            // UV Index (Using max for daily as current might not be available in hourly accurately without logic)
            // But Weather struct has hourly UV. Let's use first hourly UV for now or map.
            // Wait, Weather has hourly.uv_index. Let's use current hour approximation or daily max.
            // Let's use Cloud Cover as "Coverage" if UV is tricky, or just hardcode a placeholder logic if needed.
            // Actually, let's use Wind Speed.
            MetricPanel(label: "WIND_VEL", value: weather.windSpeedString, icon: "wind", color: JulesTheme.Colors.electricPurple) {
                HStack {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(i < 3 ? JulesTheme.Colors.electricPurple : JulesTheme.Colors.electricPurple.opacity(0.2))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            
            // Cloud Cover
            MetricPanel(label: "CLOUD_COV", value: weather.cloudCoverString, icon: "cloud.fill", color: JulesTheme.Colors.textDim) {
                PixelProgressBar(value: Double(weather.current.cloud_cover) / 100.0, color: JulesTheme.Colors.textDim)
            }
            
            // Feels Like
            MetricPanel(label: "FEELS_LIKE", value: weather.feelsLikeString, icon: "thermometer", color: JulesTheme.Colors.neonCyan)
            
            // Sunrise/Sunset - Full Width? No, let's keep grid.
            MetricPanel(label: "SUN_CYCLE", value: weather.sunriseString, icon: "sunrise.fill", color: .orange)
            
            MetricPanel(label: "MOON_PHASE", value: String(format: "%.2f", weather.daily.moon_phase?.first ?? 0), icon: "moon.stars.fill", color: .purple)
        }
        .padding(.horizontal)
    }
}


struct MetricPanel: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    let extraContent: AnyView?
    
    init<Content: View>(label: String, value: String, icon: String, color: Color, @ViewBuilder extraContent: () -> Content) {
        self.label = label
        self.value = value
        self.icon = icon
        self.color = color
        self.extraContent = AnyView(extraContent())
    }
    
    init(label: String, value: String, icon: String, color: Color) {
        self.label = label
        self.value = value
        self.icon = icon
        self.color = color
        self.extraContent = nil
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("[\(label)]")
                    .font(JulesTheme.Fonts.code(size: 10))
                    .foregroundColor(JulesTheme.Colors.textDim)
                Spacer()
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(JulesTheme.Fonts.title(size: 20))
                .foregroundColor(JulesTheme.Colors.textLight)
            
            if let extraContent = extraContent {
                extraContent
            }
        }
        .padding(12)
        .background(JulesTheme.Colors.orbit.opacity(0.4))
        //.cornerRadius(8) // Sharp corners preferred for terminal
        .overlay(
            Rectangle()
                .stroke(JulesTheme.Colors.textDim.opacity(0.2), lineWidth: 1)
        )
    }
}

struct TerminalSystemLog: View {
    var body: some View {
        VStack(spacing: 5) {
            Divider().background(JulesTheme.Colors.textDim.opacity(0.3))
            
            // ASCII Art
            Text("""
              _  _    ___    ___ 
             | || |  / _ \\  / _ \\
             | || | | (_) || (_) |
              \\__/   \\___/  \\___/ 
            """)
            .font(JulesTheme.Fonts.code(size: 10))
            .foregroundColor(JulesTheme.Colors.textDim)
            .multilineTextAlignment(.center)
            
            Text("SYSTEM STATUS: ONLINE")
                .font(JulesTheme.Fonts.code(size: 10))
                .foregroundColor(JulesTheme.Colors.neonCyan)
            
            VStack(alignment: .leading, spacing: 2) {
                LogLine(time: "14:02:22", msg: "Fetching local sensor data...", color: .gray)
                LogLine(time: "14:02:23", msg: "Data packet received [OK]", color: JulesTheme.Colors.neonCyan)
                LogLine(time: "14:02:24", msg: "Analyzing cloud density...", color: JulesTheme.Colors.electricPurple)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(JulesTheme.Colors.deepspace.opacity(0.8))
    }
    
    struct LogLine: View {
        let time: String
        let msg: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 5) {
                Text(time)
                    .foregroundColor(.gray)
                Text(">>")
                    .foregroundColor(color)
                Text(msg)
                    .foregroundColor(.gray)
            }
            .font(JulesTheme.Fonts.code(size: 10))
        }
    }
}
