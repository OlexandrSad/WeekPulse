//
//  TownModel.swift
//  WeekPulse
//
//  Created by Олександр on 21.01.2024.
//

import Foundation

// MARK: - TownModelElement
struct TownModelElement: Codable {
    let name: String?
    let localNames: LocalNames?
    let lat, lon: Double?
    let country, state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat, lon, country, state
    }
}

// MARK: - LocalNames
struct LocalNames: Codable {
    let ru, uk, en: String?
}

typealias TownModel = [TownModelElement]
