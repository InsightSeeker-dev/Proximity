//
//  ChargingStationRemoteDataSource.swift
//  Proximity
//
//  Remote Data Source for OpenDataSoft API (Charging Stations)
//

import Foundation
import CoreLocation

/// Source de données distante pour les bornes de recharge via OpenDataSoft
class ChargingStationRemoteDataSource {
    
    private let urlSession: URLSession
    
    init() {
        // Configuration URLSession optimisée
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 45
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(memoryCapacity: 5 * 1024 * 1024, diskCapacity: 20 * 1024 * 1024)
        
        self.urlSession = URLSession(configuration: config)
    }
    
    /// Récupère les bornes de recharge depuis l'API OpenDataSoft
    /// - Parameters:
    ///   - location: Position centrale de la recherche
    ///   - radius: Rayon de recherche en kilomètres
    func fetchStations(around location: CLLocationCoordinate2D, radius: Double) async throws -> [ODSRecord] {
        let baseURL = "https://odre.opendatasoft.com/api/records/1.0/search/"
        
        guard var components = URLComponents(string: baseURL) else {
            throw DataSourceError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "dataset", value: "bornes-irve"),
            URLQueryItem(name: "rows", value: "100"),
            URLQueryItem(name: "geofilter.distance", value: "\(location.latitude),\(location.longitude),\(Int(radius * 1000))")
        ]
        
        guard let url = components.url else {
            throw DataSourceError.invalidURL
        }
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataSourceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DataSourceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let odsResponse = try JSONDecoder().decode(ODSResponse.self, from: data)
            return odsResponse.records
        } catch {
            throw DataSourceError.decodingError(error)
        }
    }
}
