//
//  NetworkModel.swift
//  WeekPulse
//
//  Created by Олександр on 14.01.2024.
//

import Foundation

// MARK: - WeatherData
struct WeatherData: Codable {
    let cnt: Int?
    let list: [List]?
    let city: City?
}

// MARK: - City
struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord?
    let country: String?
}

// MARK: - Coord
struct Coord: Codable {
    let lat: Double?
    let lon: Double?
}

// MARK: - List
struct List: Codable {
    let main: Main?
    let weather: [Weather]?
    let wind: Wind?
    let date: String?

    enum CodingKeys: String, CodingKey {
        case main, weather, wind
        case date = "dt_txt"
    }
}

// MARK: - Main
struct Main: Codable {
    let temp: Double?
}

// MARK: - Weather
struct Weather: Codable {
    let main, description, icon: String?
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double?
}
