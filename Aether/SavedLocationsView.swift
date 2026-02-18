
import SwiftUI
import SwiftData

struct SavedLocationsView: View {
    @Query private var savedCities: [City]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // Callback to select a city
    var onSelectCity: (City) -> Void
    
    @State private var newCityName: String = ""
    @State private var isAddingCity: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    
    private let weatherService = WeatherService()
    
    var body: some View {
        ZStack {
            // Liquid Glass Background
            Rectangle()
                .fill(.regularMaterial) // Fallback or base
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header / Handle
                VStack(spacing: 8) {
                    Capsule()
                        .fill(JulesTheme.Colors.textDim.opacity(0.3))
                        .frame(width: 40, height: 4)
                        .padding(.top, 10)
                    
                    Text("SAVED_LOCATIONS // DATABASE")
                        .font(JulesTheme.Fonts.code(size: 14))
                        .foregroundColor(JulesTheme.Colors.neonCyan)
                        .padding(.bottom, 10)
                }
                
                // List of Cities
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(savedCities) { city in
                            SavedCityRow(
                                city: city,
                                onSelect: {
                                    onSelectCity(city)
                                    dismiss()
                                },
                                onDelete: {
                                    modelContext.delete(city)
                                    try? modelContext.save()
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                Spacer()
                
                // Add City Input (Bottom Liquid Glass)
                HStack {
                    TextField("ADD_NEW_TARGET...", text: $newCityName)
                        .font(JulesTheme.Fonts.code(size: 12)) // Slightly smaller font
                        .foregroundColor(JulesTheme.Colors.textLight)
                        .tint(JulesTheme.Colors.neonCyan)
                        .submitLabel(.done)
                        .onSubmit {
                            Task { await addCity() }
                        }
                    
                    Button(action: {
                        Task { await addCity() }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6) // Thinner button
                            .background(JulesTheme.Colors.electricPurple)
                            .clipShape(Circle())
                    }
                    .disabled(newCityName.isEmpty || isLoading)
                }
                .padding(.vertical, 8) // Thinner vertical padding
                .padding(.horizontal, 16)
                .glassEffect(in: Capsule()) // Apple's Liquid Glass
                .overlay(
                    Capsule().stroke(.white.opacity(0.1), lineWidth: 0.5)
                )
                .padding(.horizontal)
                .padding(.bottom, 10) // Bottom margin
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.clear) // Important for custom glass background
    }
    
    private func addCity() async {
        guard !newCityName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let locations = try await weatherService.fetchCoordinates(for: newCityName)
            guard let location = locations.first else {
                errorMessage = "TARGET NOT FOUND"
                isLoading = false
                return
            }
            
            let newCity = City(
                name: location.name,
                latitude: location.latitude,
                longitude: location.longitude,
                admin1: location.admin1,
                country: location.country,
                countryCode: location.country_code
            )
            
            // Explicitly run on MainActor to ensure UI updates
            await MainActor.run {
                modelContext.insert(newCity)
                try? modelContext.save()
            }
            
            newCityName = ""
        } catch {
            errorMessage = "TARGET NOT FOUND"
        }
        isLoading = false
    }
}

// Subview for individual rows to handle async weather fetching independently
struct SavedCityRow: View {
    let city: City
    var onSelect: () -> Void
    var onDelete: () -> Void
    
    @State private var weather: Weather?
    @State private var isLoading: Bool = true
    private let weatherService = WeatherService()
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Top Section: Icon + Name + Temp
                HStack(alignment: .top) {
                    // Square Indicator
                    Rectangle()
                        .fill(city.isCurrentLocation ? JulesTheme.Colors.electricPurple : JulesTheme.Colors.neonCyan)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(city.name.uppercased())
                            .font(JulesTheme.Fonts.title(size: 20)) // Larger Title
                            .foregroundColor(JulesTheme.Colors.textLight)
                            .tracking(1.0)
                        
                        // Location Info: "CC • Lat° N, Lon° E"
                        let cc = city.countryCode ?? city.country ?? "??"
                        let latDir = city.latitude >= 0 ? "N" : "S"
                        let lonDir = city.longitude >= 0 ? "E" : "W"
                         
                        Text("\(cc.uppercased()) • \(String(format: "%.4f", abs(city.latitude)))° \(latDir), \(String(format: "%.4f", abs(city.longitude)))° \(lonDir)")
                            .font(JulesTheme.Fonts.code(size: 10))
                            .foregroundColor(JulesTheme.Colors.textDim)
                    }
                    
                    Spacer()
                    
                    // Temp
                    if let current = weather?.current {
                        Text("\(Int(current.temperature_2m))°")
                            .font(JulesTheme.Fonts.title(size: 28))
                            .foregroundColor(JulesTheme.Colors.textLight)
                    } else {
                        Text("--°")
                            .font(JulesTheme.Fonts.title(size: 28))
                            .foregroundColor(JulesTheme.Colors.textDim.opacity(0.3))
                    }
                }
                .padding(16)
                
                // ASCII Dashed Line
                Text("------------------------------------------------------------")
                    .font(JulesTheme.Fonts.code(size: 10))
                    .foregroundColor(JulesTheme.Colors.textDim.opacity(0.3))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .padding(.horizontal, 4)
                
                // Bottom Section: Stats
                HStack(alignment: .bottom) {
                    HStack(spacing: 12) {
                        if let daily = weather?.daily {
                             Text("H:\(Int(daily.temperature_2m_max.first ?? 0))°")
                             Text("L:\(Int(daily.temperature_2m_min.first ?? 0))°")
                        } else {
                            Text("H:--°")
                            Text("L:--°")
                        }
                        
                        if let current = weather?.current {
                             Text("Wind: \(Int(current.wind_speed_10m))km/h")
                                .foregroundColor(city.isCurrentLocation ? JulesTheme.Colors.electricPurple : JulesTheme.Colors.neonCyan)
                        }
                    }
                    .font(JulesTheme.Fonts.code(size: 11))
                    .foregroundColor(JulesTheme.Colors.textDim)
                    
                    Spacer()
                    
                    // Weather Icon
                    if let code = weather?.current.weather_code {
                        Image(systemName: WeatherCodeHelper.getIconName(for: code))
                            .symbolRenderingMode(.multicolor)
                            .font(.system(size: 32)) 
                            .shadow(color: (city.isCurrentLocation ? JulesTheme.Colors.electricPurple : JulesTheme.Colors.neonCyan).opacity(0.6), radius: 6)
                    } else {
                        // Loading/Fallback
                        Image(systemName: "hourglass")
                            .font(.system(size: 24))
                            .foregroundColor(JulesTheme.Colors.textDim.opacity(0.3))
                    }
                }
                .padding(16)
            }
            // Neo-Retro Terminal Card Container
            .background(JulesTheme.Colors.orbit.opacity(0.9)) // Dark opaque background
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(JulesTheme.Colors.textDim.opacity(0.3), lineWidth: 1)
                    
                    if city.isCurrentLocation {
                        // "CURRENT" Badge
                        HStack {
                            Spacer()
                            VStack {
                                Text("CURRENT")
                                    .font(JulesTheme.Fonts.code(size: 9))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(JulesTheme.Colors.electricPurple)
                                    .rotationEffect(.degrees(0))
                                    .offset(x: 4, y: -10)
                                Spacer()
                            }
                        }
                    }
                }
            )
            // Retro Hard Shadow
            .shadow(color: JulesTheme.Colors.neonCyan.opacity(0.15), radius: 0, x: 4, y: 4)
            .padding(.horizontal, 4) // Spacing for shadow
            .padding(.bottom, 8)
            
            // Delete Action
            .contextMenu {
                Button("DELETE_TARGET", role: .destructive) {
                    onDelete()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .task {
            // Fetch weather for this row
            do {
                self.weather = try await weatherService.fetchWeather(lat: city.latitude, lon: city.longitude)
                self.isLoading = false
            } catch {
                print("Error fetching weather for list item: \(error)")
            }
        }
    }
}
