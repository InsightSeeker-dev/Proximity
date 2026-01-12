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
    
    /// Récupère les toilettes publiques depuis Overpass
    func fetchToilets(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center;
        """
        
        return try await executeQuery(query)
    }
    
    /// Récupère les pharmacies depuis Overpass
    func fetchPharmacies(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center;
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
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
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
