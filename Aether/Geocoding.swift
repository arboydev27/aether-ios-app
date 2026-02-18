//
//  Geocoding.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation

struct GeocodingResponse: Codable {
    let results: [Geocoding]?
}

struct Geocoding: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String? // State/Region
}
