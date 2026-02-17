# Aether Weather App: Reimagined

This document outlines a comprehensive plan to transform the current "Aether" Weather App from a simple prototype into a full-features, professional-grade application. The goal is to retain the charming "Ghibli-inspired" aesthetic while delivering precise, useful, and extensive weather data.

## Product Vision
To create a delightful weather companion that combines the serenity of Studio Ghibli visuals with the precision of a professional meteorological tool. It's not just about knowing if it will rain; it's about enjoying the check.

---

## 1. Core Feature Expansion
The current app only shows *current* weather for a searched city. A "full-blown" app needs much more context.

### 1.1 Forecasting (The Missing Piece)
*   **Hourly Forecast (Next 24-48 Hours)**:
    *   Horizontal scroll view showing temperature, precipitation chance, and wind speed hour-by-hour.
    *   *Visuals*: Small icons that change based on time of day (sun/moon) and condition.
*   **7-Day / 10-Day Forecast**:
    *   Vertical list view.
    *   High/Low temperatures bar visualization (like iOS Weather).
    *   Daily summary text (e.g., "Rain expected on Tuesday").

### 1.2 Location Services (CoreLocation)
*   **Current Location**: Automatically detect the user's location on launch.
*   **Permission Handling**: Graceful request for "While In Use" location permissions.
*   **"My Location" Tab**: Always the first item in the page controller or list.

### 1.3 Dynamic City Management (Persistence)
*   replace hardcoded "Saved Cities" chips with a robust management system.
*   **Add/Remove Cities**: Search allowing users to add reliable locations.
*   **Reorder List**: Drag-and-drop ordering.
*   **Storage**: Use `SwiftData` or `CoreData` to persist favorite cities across app launches.

---

## 2. Advanced Weather Data
Professional apps go beyond temperature and condition.

*   **Air Quality Index (AQI)**: Critical for many users. Color-coded bar (Green to Purple).
*   **UV Index**: detailed graph showing peak times (essential for skin protection).
*   **Precipitation Maps/Radar**:
    *   Integrate a Map view (MapKit) with a precipitation overlay.
    *   *Stretch Goal*: Animated radar future cast.
*   **Astro Data**: Sunrise, Sunset, Moon Phase, and Moonrise/set times.
*   **Wind & Pressure**: Compass view for wind direction; barometric pressure trends (rising/falling).
*   **Allergy/Pollen Info**: (If API supports it) High value for specific user segments.

---

## 3. User Experience & Aesthetics ("The Ghibli Touch")
The current `GhibliTheme` is a great start. We will double down on this.

### 3.1 Dynamic Backgrounds
*   **Animated Atmospheric Effects**:
    *   Rain: Subtle Swift particle system (SpriteKit or SwiftUI Canvas) for rain drops.
    *   Clouds: Parallax moving clouds.
    *   Night: Twinkling stars.
*   **Condition-Matching Art**:
    *   Clear Day: Green grassy hill (like *Totoro*).
    *   Rain: Bus stop scene.
    *   Night: Lanterns or fireflies.

### 3.2 Smart Interaction
*   **Haptic Feedback**: Subtle vibration when scrolling through hourly forecast or refreshing data.
*   **Pull-to-Refresh**: Custom animation (maybe a soot sprite spinning?).
*   **Interactive Charts**: Tap and hold on the hourly graph to see specific values.

---

## 4. System Integration & Widgets
A useful app lives outside its main window.

### 4.1 WidgetKit Support
*   **Home Screen Widgets**:
    *   *Small*: Current temp + Icon.
    *   *Medium*: Current + Next 6 hours forecast.
    *   *Lock Screen*: Circular widgets for quick glance (temp, rain chance).
*   **Live Activities**: Real-time precipitation countdown ("Rain starting in 5 min").

### 4.2 Accessibility & Localization
*   **Dynamic Type**: Ensure all text scales with system settings.
*   **VoiceOver**: Detailed descriptions ("Current temperature 72 degrees, partly cloudy").
*   **Localization**: Support for multiple languages and unit formats (Imperial/Metric auto-detection).

---

## 5. Technical Architecture Refactor

### 5.1 API Strategy
*   *Current*: API Ninjas (Limited).
*   *Recommendation*: **Apple WeatherKit** (Best for iOS apps).
    *   *Pros*: built-in to Swift, generous free tier (500k calls/month), extremely detailed data (minute-by-minute precip).
    *   *Cons*: Requires Apple Developer Program membership ($99/year).
    *   *Alternative*: OpenMeteo (Free, detailed, no key needed for basic usage).

### 5.2 MVVM + Repository Pattern
*   Refactor `WeatherService` into a repository that can cache data (offline support).
*   Use `Observation` framework (iOS 17+) for cleaner state management.

### 5.3 Modularization
*   Separate UI components (`ForecastRow`, `CurrentConditionCard`, `AstroView`) into their own files.
*   Create a `WeatherKitManager` (if switching) or enhanced `NetworkManager`.

---

## 6. Implementation Roadmap

### Phase 1: Foundation Clean-up
*   [ ] Refactor folder structure (Views, Models, ViewModels, Services).
*   [ ] Implement `SwiftData` for saving cities.
*   [ ] Add "Current Location" support.

### Phase 2: The Data Deep Dive
*   [ ] Switch API (recommend OpenMeteo or WeatherKit) for forecast data.
*   [ ] Build Hourly and Daily forecast views.
*   [ ] Add detailed grid items (UV, Pressure, AQI).

### Phase 3: The "Wow" Factor
*   [ ] Implement animated backgrounds.
*   [ ] Add Home Screen Widgets.
*   [ ] Polish UI (transitions, fonts, custom icons).

### Phase 4: Pro Features
*   [ ] Radar Map View.
*   [ ] Notifications.
*   [ ] WatchOS companion app.
