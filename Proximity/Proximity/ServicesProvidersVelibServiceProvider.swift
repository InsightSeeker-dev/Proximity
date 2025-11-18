//
//  VelibServiceProvider.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Modèle pour les stations Vélib (JCDecaux API)
struct VelibStation: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .velib
    var distance: Double?
    
    let availableBikes: Int
    let availableStands: Int
    let totalStands: Int
    let status: String
    
    var additionalInfo: [String: String] {
        [
            "Vélos disponibles": "\(availableBikes)",
            "Places disponibles": "\(availableStands)",
            "Capacité totale": "\(totalStands)",
            "Statut": status == "OPEN" ? "Ouvert" : "Fermé"
        ]
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: VelibStation, rhs: VelibStation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - JCDecaux API Models
private struct JCDecauxStation: Codable {
    let number: Int
    let contractName: String
    let name: String
    let address: String
    let position: Position
    let banking: Bool
    let bonus: Bool
    let status: String
    let totalStands: StandInfo
    let mainStands: StandInfo
    let overflowStands: StandInfo?
    
    struct Position: Codable {
        let latitude: Double
        let longitude: Double
        
        enum CodingKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "lng"
        }
    }
    
    struct StandInfo: Codable {
        let availabilities: Availabilities
        let capacity: Int
    }
    
    struct Availabilities: Codable {
        let bikes: Int
        let stands: Int
        let mechanicalBikes: Int
        let electricalBikes: Int
    }
}

/// Fournisseur de services Vélib utilisant l'API JCDecaux
class VelibServiceProvider: ServiceProvider {
    let serviceType: ServiceType = .velib
    var isEnabled: Bool = true
    
    private let apiKey: String
    private let contractName: String // ex: "Paris", "Lyon", etc.
    
    init(apiKey: String, contractName: String = "Paris") {
        self.apiKey = apiKey
        self.contractName = contractName
    }
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // API JCDecaux v3
        let urlString = "https://api.jcdecaux.com/vls/v3/stations"
        guard var components = URLComponents(string: urlString) else {
            throw ServiceProviderError.invalidResponse
        }
        
        components.queryItems = [
            URLQueryItem(name: "contract", value: contractName),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw ServiceProviderError.invalidResponse
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceProviderError.invalidResponse
        }
        
        do {
            let stations = try JSONDecoder().decode([JCDecauxStation].self, from: data)
            
            // Filtrer les stations dans le rayon spécifié
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let nearbyStations = stations.compactMap { station -> VelibStation? in
                let stationLocation = CLLocation(
                    latitude: station.position.latitude,
                    longitude: station.position.longitude
                )
                
                let distance = userLocation.distance(from: stationLocation)
                
                // Convertir le rayon en mètres si nécessaire
                guard distance <= radius * 1000 else { return nil }
                
                var velibStation = VelibStation(
                    id: "\(station.number)",
                    name: station.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: station.position.latitude,
                        longitude: station.position.longitude
                    ),
                    address: station.address,
                    availableBikes: station.mainStands.availabilities.bikes,
                    availableStands: station.mainStands.availabilities.stands,
                    totalStands: station.mainStands.capacity,
                    status: station.status
                )
                
                velibStation.distance = distance
                return velibStation
            }
            
            return nearbyStations.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
            
        } catch {
            throw ServiceProviderError.decodingError(error)
        }
    }
}
