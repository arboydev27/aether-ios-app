//
//  City.swift
//  Aether
//
//  Created by Arboy Magomba on 2/17/26.
//

import Foundation
import SwiftData

@Model
class City {
    var name: String
    var latitude: Double
    var longitude: Double
    var isCurrentLocation: Bool
    var addedAt: Date
    var admin1: String? // State/Region
    var country: String? // Name
    var countryCode: String? // "US", "JP"
    
    init(name: String, latitude: Double, longitude: Double, admin1: String? = nil, country: String? = nil, countryCode: String? = nil, isCurrentLocation: Bool = false) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.admin1 = admin1
        self.country = country
        self.countryCode = countryCode
        self.isCurrentLocation = isCurrentLocation
        self.addedAt = Date()
    }
}
