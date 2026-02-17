//
//  Weather.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

struct Weather: Codable {
    let temp: Double
    let humidity: Int
    let wind_speed: Double
    let wind_degrees: Int
    let cloud_pct: Int
    let feels_like: Double
    let min_temp: Double
    let max_temp: Double
    let sunrise: Int
    let sunset: Int
    
    // Computed properties for display
    var temperatureString: String {
        return String(format: "%.1f°C", temp)
    }
    
    var humidityString: String {
        return "\(humidity)%"
    }
    
    var windSpeedString: String {
        return String(format: "%.1f m/s", wind_speed)
    }
    
    var feelsLikeString: String {
        return String(format: "%.1f°C", feels_like)
    }
    
    var sunriseString: String {
        return formatTime(timestamp: TimeInterval(sunrise))
    }
    
    var sunsetString: String {
        return formatTime(timestamp: TimeInterval(sunset))
    }
    
    // synthesized description since API doesn't provide one
    var description: String {
        if wind_speed > 10 { return "Windy" }
        if cloud_pct < 30 { return "Clear Sky" }
        if cloud_pct < 70 { return "Partly Cloudy" }
        return "Cloudy"
    }
    
    private func formatTime(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
