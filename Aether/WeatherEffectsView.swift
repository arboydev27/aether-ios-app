//
//  WeatherEffectsView.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import SwiftUI
import Combine

struct WeatherEffectsView: View {
    let weatherCode: Int
    let isDay: Bool // 1 = day, 0 = night in Open-Meteo, so convert Int to Bool in usage
    
    var body: some View {
        ZStack {
            if isRain(code: weatherCode) {
                RainView()
            } else if isSnow(code: weatherCode) {
                SnowView()
            } else if isClear(code: weatherCode) && !isDay {
                StarFieldView()
            }
        }
        .allowsHitTesting(false) // Pass touches through
    }
    
    private func isRain(code: Int) -> Bool {
        // Drizzle (51,53,55), Rain (61,63,65), Showers (80,81,82), Thunderstorm (95+)
        return [51, 53, 55, 61, 63, 65, 80, 81, 82, 95, 96, 99].contains(code)
    }
    
    private func isSnow(code: Int) -> Bool {
        // Snow (71,73,75), Flurries (77), Snow Showers (85,86)
        return [71, 73, 75, 77, 85, 86].contains(code)
    }
    
    private func isClear(code: Int) -> Bool {
        return code == 0 || code == 1
    }
}

// MARK: - Effects

struct RainView: View {
    @State private var drops: [RainDrop] = []
    
    var body: some View {
        GeometryReader { proxy in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for drop in drops {
                        let rect = CGRect(x: drop.x * size.width, y: drop.y * size.height, width: 2, height: 15)
                        context.fill(Path(rect), with: .color(JulesTheme.Colors.neonCyan.opacity(drop.opacity)))
                    }
                }
            }
            .onAppear {
                // Initialize drops
                for _ in 0..<100 {
                    drops.append(RainDrop())
                }
            }
            .onReceive(Timer.publish(every: 0.02, on: .main, in: .common).autoconnect()) { _ in
                updateDrops()
            }
        }
    }
    
    private func updateDrops() {
        for i in 0..<drops.count {
            drops[i].y += drops[i].speed
            if drops[i].y > 1.0 {
                drops[i].y = -0.1
                drops[i].x = Double.random(in: 0...1)
            }
        }
    }
    
    struct RainDrop {
        var x: Double = Double.random(in: 0...1)
        var y: Double = Double.random(in: 0...1)
        var speed: Double = Double.random(in: 0.01...0.03)
        var opacity: Double = Double.random(in: 0.3...0.8)
    }
}

struct SnowView: View {
    @State private var flakes: [SnowFlake] = []
    
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                for flake in flakes {
                    let rect = CGRect(x: flake.x * size.width, y: flake.y * size.height, width: flake.size, height: flake.size)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(flake.opacity)))
                }
            }
            .onAppear {
                for _ in 0..<50 {
                    flakes.append(SnowFlake())
                }
            }
            .onReceive(Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()) { _ in
               updateFlakes()
            }
        }
    }
    
    private func updateFlakes() {
        for i in 0..<flakes.count {
            flakes[i].y += flakes[i].speed
            flakes[i].x += sin(Date().timeIntervalSince1970 + Double(i)) * 0.001 // Drift
            if flakes[i].y > 1.0 {
                flakes[i].y = -0.1
                flakes[i].x = Double.random(in: 0...1)
            }
        }
    }
    
    struct SnowFlake {
        var x: Double = Double.random(in: 0...1)
        var y: Double = Double.random(in: 0...1)
        var speed: Double = Double.random(in: 0.002...0.008)
        var size: Double = Double.random(in: 2...5)
        var opacity: Double = Double.random(in: 0.4...0.9)
    }
}

struct StarFieldView: View {
    var body: some View {
        GeometryReader { proxy in
            Canvas { context, size in
                for _ in 0..<100 {
                    let x = Double.random(in: 0...size.width)
                    let y = Double.random(in: 0...size.height)
                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(rect), with: .color(.white.opacity(Double.random(in: 0.2...0.8))))
                }
            }
        }
        // Static for now, or could twinkle with timeline
    }
}
