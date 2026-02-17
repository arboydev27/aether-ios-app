//
//  ContentView.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI

struct ContentView: View {
    @State private var city: String = "London"
    @State private var weather: Weather?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    // Simulate terminal typing effect
    @State private var displayedCity: String = ""
    
    private let weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            // New "Deep Space" Background with Glows
            JulesTheme.backgroundGradient()
                // .ignoresSafeArea() is handled inside the theme helper, but good to be safe
            
            VStack(spacing: 24) {
                // Header / Search Section
                HStack(spacing: 12) {
                    // Search Field - "Terminal Input" Style
                    HStack {
                        Text(">")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                        
                        TextField("Enter city...", text: $city)
                            .font(JulesTheme.Fonts.body())
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .tint(JulesTheme.Colors.neonCyan) // Cursor color
                            .onSubmit {
                                Task { await fetchWeather() }
                            }
                    }
                    .padding(12)
                    .background(JulesTheme.Colors.orbit.opacity(0.8))
                    .overlay(
                        Rectangle() // Sharp borders
                            .stroke(
                                city.isEmpty ? JulesTheme.Colors.textDim.opacity(0.3) : JulesTheme.Colors.neonCyan,
                                lineWidth: 1
                            )
                    )
                    
                    // Search Button - Sharp & Solid Purple
                    Button(action: {
                        Task { await fetchWeather() }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .padding(12)
                            .background(JulesTheme.Colors.electricPurple)
                            .clipShape(Rectangle()) // Sharp corners
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Saved Cities "Tabs"
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["London", "Norman, OK", "New York", "Mountain View, CA", "Tokyo", "Paris"], id: \.self) { savedCity in
                            Button(action: {
                                city = savedCity
                                Task { await fetchWeather() }
                            }) {
                                Text(savedCity)
                                    .font(JulesTheme.Fonts.code(size: 12))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(city == savedCity ? JulesTheme.Colors.neonCyan.opacity(0.1) : Color.clear)
                                    .overlay(
                                        Rectangle()
                                            .stroke(
                                                city == savedCity ? JulesTheme.Colors.neonCyan : JulesTheme.Colors.textDim.opacity(0.5),
                                                lineWidth: 1
                                            )
                                    )
                                    .foregroundColor(city == savedCity ? JulesTheme.Colors.neonCyan : JulesTheme.Colors.textDim)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if isLoading {
                    // Loading State - Minimal terminal loader
                    VStack(spacing: 15) {
                        ProgressView()
                            .tint(JulesTheme.Colors.neonCyan)
                            .scaleEffect(1.2)
                        Text("EXECUTING REQUEST...")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if let error = errorMessage {
                    // Error State
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(JulesTheme.Colors.electricPurple)
                        Text("ERROR: \(error.uppercased())")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if let weather = weather {
                    // Weather Display
                    ScrollView {
                        VStack(spacing: 30) {
                            
                            // Main Stats
                            VStack(spacing: 5) {
                                Text(city.uppercased())
                                    .font(JulesTheme.Fonts.code(size: 16))
                                    .foregroundColor(JulesTheme.Colors.neonCyan)
                                    .kerning(2)
                                
                                Text(weather.temperatureString)
                                    .font(JulesTheme.Fonts.title(size: 90))
                                    .foregroundColor(JulesTheme.Colors.textLight)
                                    // Make it look like a digital readout
                                    .shadow(color: JulesTheme.Colors.electricPurple.opacity(0.5), radius: 10, x: 0, y: 0)
                                
                                Text(weather.description.uppercased())
                                    .font(JulesTheme.Fonts.code())
                                    .foregroundColor(JulesTheme.Colors.textDim)
                                    .padding(.top, -10)
                            }
                            .padding(.top, 20)
                            
                            // Data Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                                WeatherDetailView(icon: "thermometer.medium", label: "Feels Like", value: weather.feelsLikeString)
                                WeatherDetailView(icon: "humidity", label: "Humidity", value: weather.humidityString)
                                WeatherDetailView(icon: "wind", label: "Wind", value: weather.windSpeedString)
                                WeatherDetailView(icon: "cloud.fill", label: "Clouds", value: "\(weather.cloud_pct)%")
                                WeatherDetailView(icon: "sunrise.fill", label: "Sunrise", value: weather.sunriseString)
                                WeatherDetailView(icon: "sunset.fill", label: "Sunset", value: weather.sunsetString)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 50)
                    }
                    
                } else {
                    // Empty State / Welcome
                    VStack {
                        Spacer()
                        Text("AETHER_TERMINAL_V1")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.textDim.opacity(0.3))
                        Spacer()
                    }
                }
            }
        }
        .task {
            // Load initial weather
            await fetchWeather()
        }
        .preferredColorScheme(.dark) // Force dark mode for status bar
    }
    
    private func fetchWeather() async {
        isLoading = true
        errorMessage = nil
        do {
            weather = try await weatherService.fetchWeather(for: city)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// Updated Detail View - "Card" Style
struct WeatherDetailView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(JulesTheme.Colors.neonCyan)
                Text(label.uppercased())
                    .font(JulesTheme.Fonts.code(size: 10))
                    .foregroundColor(JulesTheme.Colors.textDim)
                Spacer()
            }
            
            Text(value)
                .font(JulesTheme.Fonts.title(size: 20))
                .foregroundColor(JulesTheme.Colors.textLight)
        }
        .padding(16)
        .background(JulesTheme.Colors.orbit)
        .cornerRadius(12) // Slightly rounded for cards, as per Jules design
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(JulesTheme.Colors.textDim.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ContentView()
}
