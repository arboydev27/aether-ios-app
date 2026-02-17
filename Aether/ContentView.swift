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
    
    private let weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            // Background
            GhibliTheme.backgroundGradient()
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search Bar
                HStack {
                    TextField("Enter city", text: $city)
                        .padding(10)
                        .background(GhibliTheme.Colors.cloudWhite.opacity(0.8))
                        .cornerRadius(20)
                        .foregroundColor(GhibliTheme.Colors.textDark)
                        .font(GhibliTheme.Fonts.body())
                        .onSubmit {
                            Task {
                                await fetchWeather()
                            }
                        }
                    
                    Button(action: {
                        Task {
                            await fetchWeather()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(GhibliTheme.Colors.textDark)
                            .padding(10)
                            .background(GhibliTheme.Colors.cloudWhite.opacity(0.8))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 40)
                
                // Saved Cities Chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(["London", "Norman, OK", "New York", "Mountain View, CA", "Tokyo", "Paris"], id: \.self) { savedCity in
                            Button(action: {
                                city = savedCity
                                Task {
                                    await fetchWeather()
                                }
                            }) {
                                Text(savedCity)
                                    .font(GhibliTheme.Fonts.body(size: 14))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(city == savedCity ? GhibliTheme.Colors.sunsetOrange : GhibliTheme.Colors.cloudWhite.opacity(0.8))
                                    .foregroundColor(city == savedCity ? .white : GhibliTheme.Colors.textDark)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(GhibliTheme.Colors.textDark)
                        .padding(.top, 50)
                    Spacer()
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "cloud.rain.fill") // Placeholder for a sad soot sprite maybe?
                            .font(.system(size: 60))
                            .foregroundColor(GhibliTheme.Colors.textDark)
                            .padding()
                        Text(error)
                            .font(GhibliTheme.Fonts.body())
                            .foregroundColor(GhibliTheme.Colors.textDark)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .padding(.top, 50)
                    Spacer()
                } else if let weather = weather {
                    // Weather Display
                    VStack(spacing: 15) {
                        Text(city.capitalized)
                            .font(GhibliTheme.Fonts.title())
                            .foregroundColor(GhibliTheme.Colors.textDark)
                        
                        Text(weather.temperatureString)
                            .font(GhibliTheme.Fonts.title(size: 80))
                            .foregroundColor(GhibliTheme.Colors.textDark)
                        
                        // Grid for details
                        // Grid for details
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            WeatherDetailView(icon: "thermometer.medium", label: "Feels Like", value: weather.feelsLikeString)
                            WeatherDetailView(icon: "humidity", label: "Humidity", value: weather.humidityString)
                            WeatherDetailView(icon: "wind", label: "Wind", value: weather.windSpeedString)
                            WeatherDetailView(icon: "cloud.fill", label: "Clouds", value: "\(weather.cloud_pct)%")
                            WeatherDetailView(icon: "sunrise.fill", label: "Sunrise", value: weather.sunriseString)
                            WeatherDetailView(icon: "sunset.fill", label: "Sunset", value: weather.sunsetString)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Footer or cute scenic element
                    // Could be an image of a Totoro or field if we had assets
                    // For now, let's use a shape to represent a hill
                    GeometryReader { geometry in
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                            path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height - 100))
                            path.addQuadCurve(to: CGPoint(x: 0, y: geometry.size.height - 50), control: CGPoint(x: geometry.size.width / 2, y: geometry.size.height - 150))
                            path.closeSubpath()
                        }
                        .fill(GhibliTheme.Colors.grassGreen)
                    }
                    .frame(height: 150)
                } else {
                    Spacer()
                }
            }
        }
        .task {
            // Load initial weather
            await fetchWeather()
        }
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

struct WeatherDetailView: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundColor(GhibliTheme.Colors.textDark.opacity(0.7))
                Text(label.uppercased())
                    .font(GhibliTheme.Fonts.body(size: 12))
                    .foregroundColor(GhibliTheme.Colors.textDark.opacity(0.7))
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(GhibliTheme.Fonts.body(size: 20))
                    .fontWeight(.semibold)
                    .foregroundColor(GhibliTheme.Colors.textDark)
                Spacer()
            }
        }
        .padding()
        .background(GhibliTheme.Colors.cloudWhite.opacity(0.6))
        .cornerRadius(15)
    }
}

#Preview {
    ContentView()
}
