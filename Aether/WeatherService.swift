//
//  WeatherService.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

class WeatherService {
    private let weatherUrl = "https://api.api-ninjas.com/v1/weather"
    private let geocodingUrl = "https://api.api-ninjas.com/v1/geocoding"
    
    func fetchWeather(for city: String) async throws -> Weather {
        // Step 1: Get coordinates for the city
        let coordinates = try await fetchCoordinates(for: city)
        guard let location = coordinates.first else {
            throw WeatherError.cityNotFound
        }
        
        // Step 2: Get weather for coordinates
        return try await fetchWeather(lat: location.latitude, lon: location.longitude)
    }
    
    private func fetchCoordinates(for city: String) async throws -> [Geocoding] {
        guard let apiKey = Optional(Configuration.apiKey), !apiKey.isEmpty else {
            throw WeatherError.missingApiKey
        }
        
        var components = URLComponents(string: geocodingUrl)
        var queryItems = [URLQueryItem]()
        
        // Check for "City, State" format
        if city.contains(",") {
            let parts = city.split(separator: ",")
            if parts.count >= 2 {
                let cityName = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let stateName = String(parts[1]).trimmingCharacters(in: .whitespaces)
                queryItems.append(URLQueryItem(name: "city", value: cityName))
                queryItems.append(URLQueryItem(name: "state", value: stateName))
                queryItems.append(URLQueryItem(name: "country", value: "US")) // Usually implies US if state is used
            } else {
                queryItems.append(URLQueryItem(name: "city", value: city))
            }
        } else {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode([Geocoding].self, from: data)
    }
    
    private func fetchWeather(lat: Double, lon: Double) async throws -> Weather {
        guard let apiKey = Optional(Configuration.apiKey), !apiKey.isEmpty else {
            throw WeatherError.missingApiKey
        }
        
        var components = URLComponents(string: weatherUrl)
        components?.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)")
        ]
        
        guard let url = components?.url else {
            throw WeatherError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.networkError(statusCode: 0)
        }
            
        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherError.networkError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let weather = try decoder.decode(Weather.self, from: data)
            return weather
        } catch {
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
            return "API Key is missing. Please check your .env file."
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
