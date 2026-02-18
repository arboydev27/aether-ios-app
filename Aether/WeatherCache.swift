//
//  WeatherCache.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

actor WeatherCache {
    static let shared = WeatherCache()
    
    // Cache structures
    private struct CachedWeather {
        let weather: Weather
        let timestamp: Date
    }
    
    // In-memory storage
    private var weatherCache: [String: CachedWeather] = [:] // Key: "lat,lon"
    private var coordinateCache: [String: [Geocoding]] = [:] // Key: "lowercase_city_query"
    
    // Configuration
    private let cacheValidityDuration: TimeInterval = 30 * 60 // 30 minutes
    
    private init() {}
    
    // MARK: - Weather Caching
    
    func getWeather(lat: Double, lon: Double) -> Weather? {
        let key = "\(lat),\(lon)"
        guard let cached = weatherCache[key] else { return nil }
        
        if Date().timeIntervalSince(cached.timestamp) < cacheValidityDuration {
            print("📦 Cache HIT for weather at \(key)")
            return cached.weather
        } else {
            print("⌛️ Cache EXPIRED for weather at \(key)")
            weatherCache.removeValue(forKey: key)
            return nil
        }
    }
    
    func saveWeather(_ weather: Weather, lat: Double, lon: Double) {
        let key = "\(lat),\(lon)"
        weatherCache[key] = CachedWeather(weather: weather, timestamp: Date())
        print("💾 Cache SAVED for weather at \(key)")
    }
    
    // MARK: - Geocoding Caching
    
    func getCoordinates(for city: String) -> [Geocoding]? {
        let key = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if let coords = coordinateCache[key] {
            print("📦 Cache HIT for coordinates: \(city)")
            return coords
        }
        return nil
    }
    
    func saveCoordinates(_ coords: [Geocoding], for city: String) {
        let key = city.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        coordinateCache[key] = coords
        print("💾 Cache SAVED for coordinates: \(city)")
    }
    
    // MARK: - Utilities
    
    func clearCache() {
        weatherCache.removeAll()
        coordinateCache.removeAll()
    }
}
