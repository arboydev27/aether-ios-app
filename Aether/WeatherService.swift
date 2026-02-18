//
//  WeatherService.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

class WeatherService {
    // Open-Meteo (Free, No Key)
    private let weatherUrl = "https://api.open-meteo.com/v1/forecast"
    
    // Open-Meteo Geocoding (Free, No Key)
    private let geocodingUrl = "https://geocoding-api.open-meteo.com/v1/search"
    
    // ...
    
    func fetchWeather(for city: String) async throws -> Weather {
        // Step 1: Get coordinates for the city (Check Cache First)
        let coordinates: [Geocoding]
        if let cachedCoords = await WeatherCache.shared.getCoordinates(for: city) {
            coordinates = cachedCoords
        } else {
            coordinates = try await fetchCoordinates(for: city)
            await WeatherCache.shared.saveCoordinates(coordinates, for: city)
        }
        
        guard let location = coordinates.first else {
            throw WeatherError.cityNotFound
        }
        
        // Step 2: Get weather for coordinates (Check Cache First)
        return try await fetchWeather(lat: location.latitude, lon: location.longitude)
    }

    func fetchCoordinates(for city: String) async throws -> [Geocoding] {
        var components = URLComponents(string: geocodingUrl)
        var queryItems = [
            URLQueryItem(name: "name", value: city),
            URLQueryItem(name: "count", value: "5"),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "format", value: "json")
        ]
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        let request = URLRequest(url: url)
        // No API Key needed for Open-Meteo Geocoding
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.networkError(statusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
        }
        
        let decoder = JSONDecoder()
        let responseObj = try decoder.decode(GeocodingResponse.self, from: data)
        return responseObj.results ?? []
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        // Check Cache
        if let cachedWeather = await WeatherCache.shared.getWeather(lat: lat, lon: lon) {
            return cachedWeather
        }
        
        // Construct Open-Meteo URL
        // https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,cloud_cover,wind_speed_10m&hourly=temperature_2m,weather_code,uv_index&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max&timezone=auto
        
        var components = URLComponents(string: weatherUrl)
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(format: "%.6f", lat)),
            URLQueryItem(name: "longitude", value: String(format: "%.6f", lon)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,cloud_cover,wind_speed_10m"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code,uv_index"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset,uv_index_max"),
            URLQueryItem(name: "timezone", value: "auto")
        ]
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        // No API Key needed for Open-Meteo
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError(statusCode: 0)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Open-Meteo Error: \(errorString) URL: \(url.absoluteString)")
            }
            throw WeatherError.networkError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(Weather.self, from: data)
            // Save to Cache
            await WeatherCache.shared.saveWeather(weather, lat: lat, lon: lon)
            return weather
        } catch {
            print("Decoding Error: \(error)")
            throw WeatherError.decodingError
        }
    }
}

enum WeatherError: Error, LocalizedError {
    case missingApiKey
    case invalidURL
    case networkError(statusCode: Int)
    case decodingError
    case cityNotFound
    
    var errorDescription: String? {
        switch self {
        case .missingApiKey:
            return "API Key is missing for Geocoding. Please check your .env file."
        case .invalidURL:
            return "Invalid URL constructed."
        case .networkError(let statusCode):
            return "Network error occurred with status code: \(statusCode)"
        case .decodingError:
            return "Failed to decode weather data."
        case .cityNotFound:
            return "City not found. Please try another location."
        }
    }
}
