//
//  Weather.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

// MARK: - Main Response
public struct Weather: Codable {
    let latitude: Double
    let longitude: Double
    let timezone: String
    let current: CurrentWeather
    let hourly: HourlyWeather
    let daily: DailyWeather
}

// MARK: - Current Weather
struct CurrentWeather: Codable {
    let time: String
    let temperature_2m: Double
    let relative_humidity_2m: Int
    let apparent_temperature: Double
    let is_day: Int
    let weather_code: Int
    let cloud_cover: Int
    let wind_speed_10m: Double
}

// MARK: - Hourly Weather
struct HourlyWeather: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let weather_code: [Int]
    let uv_index: [Double]
}

// MARK: - Daily Weather
struct DailyWeather: Codable {
    let time: [String]
    let weather_code: [Int]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let sunrise: [String]
    let sunset: [String]
    let uv_index_max: [Double]
    let moon_phase: [Double]? // Optional as I'm adding it now
}

// MARK: - Air Quality Response (Separate Call or Merged)
// Implementation Note: Open-Meteo allows merging, or we can use separate struct if calling separate endpoint.
// For now, let's keep it simple. If we merge requests, we might need a combined struct.
// But Open-Meteo limits constraints differently. Let's assume we might fetch AQI separately or add to this generic if we use the "customer" endpoint features, but usually AQI is a separate domain (air-quality-api.open-meteo.com).
// Let's create a separate struct for AQI and manage it in the Service.

struct AirQualityResponse: Codable {
    let current: CurrentAQI
}

struct CurrentAQI: Codable {
    let us_aqi: Int?
    let european_aqi: Int?
}

// MARK: - Convenience / Display Extensions

extension Weather {
    // Helper to get formatted current temp
    var currentTempString: String {
        return String(format: "%.1f°C", current.temperature_2m)
    }
    
    var temperatureString: String {
        return currentTempString
    }
    
    var feelsLikeString: String {
        return String(format: "%.1f°C", current.apparent_temperature)
    }
    
    var windSpeedString: String {
        return String(format: "%.1f km/h", current.wind_speed_10m)
    }
    
    var humidityString: String {
        return "\(current.relative_humidity_2m)%"
    }
    
    // Determine description from WMO Weather Code
    var description: String {
        return WeatherCodeHelper.getDescription(for: current.weather_code)
    }
    
    var cloudCoverString: String {
        return "\(current.cloud_cover)%"
    }
    
    // Compatibility
    var cloud_pct: Int {
        return current.cloud_cover
    }
    
    var sunriseString: String {
        guard let time = daily.sunrise.first else { return "--:--" }
        return WeatherDateHelper.formatTime(isoString: time)
    }
    
    var sunsetString: String {
        guard let time = daily.sunset.first else { return "--:--" }
        return WeatherDateHelper.formatTime(isoString: time)
    }

    // MARK: - Forecast Helpers
    
    struct HourlyForecastItem: Identifiable {
        let id = UUID()
        let time: String
        let temp: Double
        let code: Int
        let uv: Double
        
        var formattedTime: String {
            return WeatherDateHelper.formatTimeHourOnly(isoString: time)
        }
        
        var icon: String {
            // Simple mapping for now
            return WeatherCodeHelper.getIconName(for: code)
        }
    }
    
    var hourlyForecast: [HourlyForecastItem] {
        var items: [HourlyForecastItem] = []
        // Limit to next 24 hours
        let count = min(hourly.time.count, 24)
        for i in 0..<count {
            items.append(HourlyForecastItem(
                time: hourly.time[i],
                temp: hourly.temperature_2m[i],
                code: hourly.weather_code[i],
                uv: hourly.uv_index[i]
            ))
        }
        return items
    }
    
    struct DailyForecastItem: Identifiable {
        let id = UUID()
        let time: String
        let code: Int
        let maxTemp: Double
        let minTemp: Double
        
        var dayName: String {
            return WeatherDateHelper.getDayName(isoString: time)
        }
         var icon: String {
            // Simple mapping for now
            return WeatherCodeHelper.getIconName(for: code)
        }
    }
    
    var dailyForecast: [DailyForecastItem] {
        var items: [DailyForecastItem] = []
        let count = min(daily.time.count, 7)
        for i in 0..<count {
            items.append(DailyForecastItem(
                time: daily.time[i],
                code: daily.weather_code[i],
                maxTemp: daily.temperature_2m_max[i],
                minTemp: daily.temperature_2m_min[i]
            ))
        }
        return items
    }
}

class WeatherDateHelper {
    static func formatTime(isoString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime] // OpenMeteo uses ISO8601 but without Z if timezone is not UTC? 
        // actually OpenMeteo returns "2023-01-01T00:00" without offset usually if requested that way.
        // Let's use specific format
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        if let date = simpleFormatter.date(from: isoString) {
            let output = DateFormatter()
            output.timeStyle = .short
            return output.string(from: date)
        }
        return isoString
    }
    
    static func formatTimeHourOnly(isoString: String) -> String {
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        
        if let date = simpleFormatter.date(from: isoString) {
            let output = DateFormatter()
            output.dateFormat = "HH:mm"
            return output.string(from: date)
        }
        return "--"
    }
    
    static func getDayName(isoString: String) -> String {
        let simpleFormatter = DateFormatter()
        simpleFormatter.dateFormat = "yyyy-MM-dd" // Daily time is YYYY-MM-DD
        
        if let date = simpleFormatter.date(from: isoString) {
            let output = DateFormatter()
            output.dateFormat = "EEEE"
            return output.string(from: date)
        }
        return isoString
    }
}

class WeatherCodeHelper {
    static func getIconName(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2, 3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51, 53, 55, 61, 63, 65, 80, 81, 82: return "cloud.rain.fill"
        case 71, 73, 75, 85, 86: return "cloud.snow.fill"
        case 95, 96, 99: return "cloud.bolt.fill"
        default: return "questionmark.circle"
        }
    }
    
    static func getDescription(for code: Int) -> String {
        switch code {
        case 0: return "Clear Sky"
        case 1, 2, 3: return "Partly Cloudy"
        case 45, 48: return "Fog"
        case 51, 53, 55: return "Drizzle"
        case 61, 63, 65: return "Rain"
        case 71, 73, 75: return "Snow"
        case 80, 81, 82: return "Rain Showers"
        case 95, 96, 99: return "Thunderstorm"
        default: return "Unknown"
        }
    }
}
