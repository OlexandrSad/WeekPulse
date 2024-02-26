//
//  ParserTownData.swift
//  WeekPulse
//
//  Created by Олександр on 21.01.2024.
//

import Foundation


final class ParserTownData {
    
    func createTownsArray(townModel: TownModel) -> [String:[String]] {
        var towns = [String:[String]]()
        for element in townModel {
            var fullString = "\(element.name ?? ""), \(element.state ?? ""), \(element.country ?? "")"
            
            if element.state == nil {
                fullString = "\(element.name ?? ""), \(element.country ?? "")"
            }
            
            if let lat = element.lat, let lon = element.lon {
                let lat = String(lat)
                let lon = String(lon)
                towns[fullString] = [lat, lon]
            }
        }
        return towns
    }
    
}
