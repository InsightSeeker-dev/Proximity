//
//  OverpassRemoteDataSource.swift
//  Proximity
//
//  Remote Data Source for Overpass API (OpenStreetMap)
//

import Foundation
import CoreLocation

/// Source de données distante pour l'API Overpass (OpenStreetMap)
class OverpassRemoteDataSource {
    
    private let baseURL = "https://overpass-api.de/api/interpreter"
    private let urlSession: URLSession
    
    init() {
        // Configuration URLSession optimisée
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 45 // Timeout pour la requête
        config.timeoutIntervalForResource = 60 // Timeout pour la ressource complète
        config.requestCachePolicy = .returnCacheDataElseLoad // Utiliser le cache si disponible
        config.urlCache = URLCache(memoryCapacity: 10 * 1024 * 1024, diskCapacity: 50 * 1024 * 1024) // 10MB RAM, 50MB disque
        
        self.urlSession = URLSession(configuration: config)
    }
    
    /// Récupère les toilettes publiques depuis Overpass
    func fetchToilets(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        
        return try await executeQuery(query)
    }
    
    /// Récupère les pharmacies depuis Overpass
    func fetchPharmacies(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        
        return try await executeQuery(query)
    }
    
    /// Exécute une requête Overpass
    func executeQuery(_ query: String) async throws -> [OverpassElement] {
        guard let url = URL(string: baseURL) else {
            throw DataSourceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataSourceError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw DataSourceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let overpassResponse = try JSONDecoder().decode(OverpassResponse.self, from: data)
            return overpassResponse.elements
        } catch {
            throw DataSourceError.decodingError(error)
        }
    }
}
