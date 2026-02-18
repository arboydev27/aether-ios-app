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
    
    init(name: String, latitude: Double, longitude: Double, isCurrentLocation: Bool = false) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.isCurrentLocation = isCurrentLocation
        self.addedAt = Date()
    }
}
