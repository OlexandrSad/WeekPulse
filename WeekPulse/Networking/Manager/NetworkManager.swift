//
//  NetworkManager.swift
//  WeekPulse
//
//  Created by Олександр on 14.01.2024.
//

import Foundation

class NetworkManager {

    static var shared = NetworkManager()
    private init(){}
    
    private func createUrl(lat: String, lon: String) -> URL? {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "api.openweathermap.org"
        urlComponent.path = "/data/2.5/forecast"
        urlComponent.queryItems = [
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "cnt", value: "40"),
            URLQueryItem(name: "appid", value: "58eac063205faa2ef3a468d1bd4d6c0a"),
            URLQueryItem(name: "units", value: "metric")
        ]
        let url = urlComponent.url
        return url
    }
    
    
    func fetchWeatherData(lat: String, lon: String, complition: @escaping (Result<WeatherData, Error>) -> Void) {
        let url = createUrl(lat: lat, lon: lon)
        
        guard let safeUrl = url else { print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: safeUrl) { (data, response, error) in
            var result: Result<WeatherData, Error>
            defer {
                DispatchQueue.main.async {
                    complition(result)
                }
            }

            if error == nil, let data = data {
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: data)
                    result = .success(weatherData)
                } catch {
                    print("Error decoding JSON: \(error)")
                    result = .failure(error)
                }
            } else {
                print("Error request or in received data: \(error!)")
                result = .failure(error!)
            }
        }.resume()
    }
    
}
