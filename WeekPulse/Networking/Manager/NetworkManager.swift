//
//  NetworkManager.swift
//  WeekPulse
//
//  Created by Олександр on 14.01.2024.
//

import Foundation

final class NetworkManager {

    static var shared = NetworkManager()
    private init(){}
    
    private func createWeatherUrl(lat: String, lon: String) -> URL? {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "api.openweathermap.org"
        urlComponent.path = "/data/2.5/forecast"
        urlComponent.queryItems = [
            URLQueryItem(name: "lat", value: lat),
            URLQueryItem(name: "lon", value: lon),
            URLQueryItem(name: "cnt", value: "40"),
            URLQueryItem(name: "appid", value: "Private key"),
            URLQueryItem(name: "units", value: "metric")
        ]
        let url = urlComponent.url
        return url
    }
    
    private func createTownUrl(town: String) -> URL? {
        var urlComponent = URLComponents()
        urlComponent.scheme = "https"
        urlComponent.host = "api.openweathermap.org"
        urlComponent.path = "/geo/1.0/direct"
        urlComponent.queryItems = [
            URLQueryItem(name: "q", value: town),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: "Private key")
        ]
        let url = urlComponent.url
        return url
    }
    
    func fetchWeatherData(lat: String, lon: String, complition: @escaping (Result<WeatherData, Error>) -> Void) {
        let url = createWeatherUrl(lat: lat, lon: lon)
        
        guard let safeUrl = url else { complition(.failure(NetworkingError.invalidWeatherUrl))
            return
        }
        URLSession.shared.dataTask(with: safeUrl) { (data, response, error) in
            guard error == nil else {
                complition(.failure(NetworkingError.noInternet))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        complition(.failure(NetworkingError.invalidWeatherResponse))
                        return
                    }

            if let safeData = data {
                do {
                    let weatherData = try JSONDecoder().decode(WeatherData.self, from: safeData)
                    DispatchQueue.main.async {
                        complition(.success(weatherData))
                    }
                } catch {
                    complition(.failure(NetworkingError.invalidWeatherJson))
                }
            } else {
                complition(.failure(NetworkingError.invalidWeatherData))
            }
        }.resume()
    }
    
    func fetchTownData(town: String, complition: @escaping (Result<TownModel, Error>) -> Void) {
        let url = createTownUrl(town: town)
        
        guard let safeUrl = url else { complition(.failure(NetworkingError.invalidTownUrl))
            return
        }
        URLSession.shared.dataTask(with: safeUrl) { (data, response, error) in
            guard error == nil else { 
                complition(.failure(NetworkingError.noInternet))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                        complition(.failure(NetworkingError.invalidTownResponse))
                        return
                    }
            
                if let safeData = data {
                do {
                    let townData = try JSONDecoder().decode(TownModel.self, from: safeData)
                    DispatchQueue.main.async {
                        complition(.success(townData))
                    }
                } catch {
                    complition(.failure(NetworkingError.invalidTownJson))
                }
            } else {
                complition(.failure(NetworkingError.invalidTownData))
            }
        }.resume()
    }
}


enum NetworkingError: Error {
    case invalidWeatherUrl, invalidWeatherData, invalidWeatherResponse, invalidWeatherJson, noInternet
    case invalidTownUrl, invalidTownData, invalidTownResponse, invalidTownJson
}
