//
//  ContentView.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI
import SwiftData
import CoreLocation

struct ContentView: View {
    @State private var city: String = "Loading..."
    @State private var weather: Weather?
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var showSavedLocations: Bool = false
    
    // Simulate terminal typing effect
    @State private var displayedCity: String = ""
    
    @StateObject private var locationManager = LocationManager()
    @Environment(\.modelContext) private var modelContext
    @Query private var savedCities: [City]
    
    private let weatherService = WeatherService()
    
    // Computes overall loading state
    private var isBusy: Bool {
        isLoading || locationManager.isLoading
    }
    
    var body: some View {
        ZStack {
            // New "Deep Space" Background with Glows
            JulesTheme.backgroundGradient()
            
            if let weather = weather {
                WeatherEffectsView(
                    weatherCode: weather.current.weather_code,
                    isDay: weather.current.is_day == 1
                )
            }
            
            VStack(spacing: 24) {
                // Header / Search Section
                HStack(spacing: 12) {
                    // Search Field - "Terminal Input" Style
                    HStack {
                        Text(">")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                        
                        TextField("Enter city... or 'add [city]'", text: $city)
                            .font(JulesTheme.Fonts.body())
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .tint(JulesTheme.Colors.neonCyan) // Cursor color
                            .onSubmit {
                                handleInput()
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
                    
                    // Location Button
                    Button(action: {
                        locationManager.requestLocation()
                    }) {
                        Image(systemName: "location.fill")
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .padding(12)
                            .background(JulesTheme.Colors.electricPurple.opacity(0.8))
                            .clipShape(Rectangle())
                    }
                    
                    // Search Button - Sharp & Solid Purple
                    Button(action: {
                        handleInput()
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
                
                // Saved Cities "Tabs" - REMOVED (Replaced by FAB Sheet)
                
                if isBusy {
                    // Loading State - Minimal terminal loader
                    VStack(spacing: 15) {
                        ProgressView()
                            .tint(JulesTheme.Colors.neonCyan)
                            .scaleEffect(1.2)
                        Text("ACQUIRING TARGET...")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.neonCyan)
                        
                        // Fallback button if stuck
                        Button("Override: Load London") {
                            locationManager.stopUpdating() // Stop trying
                            self.city = "London"
                            Task { await fetchWeather() }
                        }
                        .font(JulesTheme.Fonts.code(size: 10))
                        .foregroundColor(JulesTheme.Colors.textDim)
                        .padding(.top, 20)
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
                            
                            // Terminal Header (City + Lat/Lon)
                            TerminalHeaderView(city: city, lat: weather.latitude, lon: weather.longitude)
                                .padding(.top, 10)
                            
                            // Main Terminal Status Box
                            TerminalMainStatusView(weather: weather)
                            
                            // Restore Forecast Views
                            HourlyForecastView(forecast: weather.hourlyForecast)
                            DailyForecastView(forecast: weather.dailyForecast)
                            
                            // Metrics Grid
                            TerminalMetricsGrid(weather: weather)
                            
                            // System Log Visualization
                            TerminalSystemLog()
                                .padding(.top, 20)
                            
                    }


                }
                    
                } else {
                    // Empty State / Welcome
                    VStack {
                        Spacer()
                        Text("AETHER_TERMINAL_V1")
                            .font(JulesTheme.Fonts.code())
                            .foregroundColor(JulesTheme.Colors.textDim.opacity(0.3))
                        Text("WAITING FOR TARGET ACQUISITION...")
                            .font(JulesTheme.Fonts.code(size: 10))
                            .foregroundColor(JulesTheme.Colors.neonCyan.opacity(0.5))
                            .padding(.top, 10)
                        Spacer()
                    }
                }
            }
            
            // FAB for Saved Locations
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        showSavedLocations = true
                    }) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(18)
                            .glassEffect(in: Circle()) // Apple's Liquid Glass
                            .overlay(
                                Circle().stroke(.white.opacity(0.1), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(25)
                }
            }
        }
        .sheet(isPresented: $showSavedLocations) {
            SavedLocationsView(onSelectCity: { selectedCity in
                self.city = selectedCity.name
                Task {
                    await fetchWeather(lat: selectedCity.latitude, lon: selectedCity.longitude)
                }
            })
        }
        .task {
            // Request location immediately on launch
            locationManager.requestLocation()
            
            // Timeout after 5 seconds if no location found
            try? await Task.sleep(nanoseconds: 5 * 1_000_000_000)
            if city == "Loading..." || city == "Acquiring Target..." {
                print("Location timeout. Defaulting to Norman, OK.")
                locationManager.stopUpdating()
                // Default to Norman, OK
                self.city = "Norman"
                await fetchWeather(lat: 35.2226, lon: -97.4395)
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            guard let location = newLocation else { return }
            // Only update if we haven't set a manual city yet (or are still loading)
            if city == "Loading..." || city == "Acquiring Target..." {
                 Task {
                    // Reverse geocode for UI
                    if let cityName = await locationManager.getCityName(from: location) {
                        self.city = cityName
                    } else {
                        self.city = "Current Location"
                    }
                    // Fetch weather by coords
                    await fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
                }
            }
        }
        .onChange(of: locationManager.permissionError) { hasError in
             if hasError {
                 errorMessage = "Location permission denied. Please enable it in settings."
             }
        }
        .preferredColorScheme(.dark) // Force dark mode for status bar
    }
    
    private func handleInput() {
        let input = city.trimmingCharacters(in: .whitespacesAndNewlines)
        if input.lowercased().starts(with: "add ") {
            let cityName = String(input.dropFirst(4)).trimmingCharacters(in: .whitespaces)
            Task {
                 await addCity(name: cityName)
            }
        } else {
            Task { await fetchWeather() }
        }
    }
    
    private func addCity(name: String) async {
        isLoading = true
        // 1. Fetch coords to verify city exists
        // We can reuse WeatherService private method if exposed or just use fetchWeather to get coords then save
        // A better way is to add a public geocode method to service
        // For now, I'll allow "saving" after a successful fetch, OR implement a standalone add:
        
        do {
            // I'll assume WeatherService processes it. 
            // Better behavior: user searches, sees weather, then clicks "Save"?
            // User requested "command line style input (> add city Tokyo)".
            // So we blindly try to add it.
            
            // We need coordinates to save.
            // I will use fetchWeather to get the weather object which contains lat/lon, then save.
            let weather = try await weatherService.fetchWeather(for: name)
            
            // Save to SwiftData
            let newCity = City(name: name, latitude: weather.latitude, longitude: weather.longitude)
            modelContext.insert(newCity)
            
            self.city = name
            self.weather = weather // Show it
        } catch {
            errorMessage = "Could not find city: \(name)"
        }
        isLoading = false
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
    
    private func fetchWeather(lat: Double, lon: Double) async {
        isLoading = true
        errorMessage = nil
        do {
            weather = try await weatherService.fetchWeather(lat: lat, lon: lon)
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
