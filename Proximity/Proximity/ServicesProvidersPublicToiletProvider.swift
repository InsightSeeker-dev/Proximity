//
//  PublicToiletProvider.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Modèle pour les toilettes publiques
struct PublicToilet: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .toilet
    var distance: Double?
    
    let fee: String?
    let wheelchairAccessible: String?
    let openingHours: String?
    
    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        if let fee = fee {
            info["Accès"] = fee == "yes" ? "Payant" : "Gratuit"
        }
        if let wheelchair = wheelchairAccessible {
            info["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let hours = openingHours {
            info["Horaires"] = hours
        }
        return info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PublicToilet, rhs: PublicToilet) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Overpass API Models
private struct OverpassResponse: Codable {
    let elements: [OverpassElement]
}

private struct OverpassElement: Codable {
    let type: String
    let id: Int
    let lat: Double?
    let lon: Double?
    let tags: OverpassTags?
    let center: OverpassCenter?
}

private struct OverpassCenter: Codable {
    let lat: Double
    let lon: Double
}

private struct OverpassTags: Codable {
    let name: String?
    let fee: String?
    let wheelchair: String?
    let openingHours: String?
    let street: String?
    let housenumber: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case fee
        case wheelchair
        case openingHours = "opening_hours"
        case street = "addr:street"
        case housenumber = "addr:housenumber"
    }
}

/// Fournisseur de toilettes publiques via Overpass API (OpenStreetMap)
class PublicToiletProvider: ServiceProvider {
    let serviceType: ServiceType = .toilet
    var isEnabled: Bool = false // Désactivé par défaut
    
    private let overpassURL = "https://overpass-api.de/api/interpreter"
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // Construire la requête Overpass QL
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="toilets"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center;
        """
        
        guard let url = URL(string: overpassURL) else {
            throw ServiceProviderError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = query.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceProviderError.invalidResponse
        }
        
        do {
            let overpassResponse = try JSONDecoder().decode(OverpassResponse.self, from: data)
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let toilets = overpassResponse.elements.compactMap { element -> PublicToilet? in
                // Obtenir les coordonnées (node ou center pour way)
                guard let lat = element.lat ?? element.center?.lat,
                      let lon = element.lon ?? element.center?.lon else {
                    return nil
                }
                
                let toiletLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = userLocation.distance(from: toiletLocation)
                
                // Vérifier que c'est bien dans le rayon
                guard distance <= Double(radiusMeters) else { return nil }
                
                // Construire le nom
                let name = element.tags?.name ?? "Toilettes publiques"
                
                // Construire l'adresse si disponible
                var address: String?
                if let street = element.tags?.street,
                   let number = element.tags?.housenumber {
                    address = "\(number) \(street)"
                } else if let street = element.tags?.street {
                    address = street
                }
                
                var toilet = PublicToilet(
                    id: "\(element.id)",
                    name: name,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    address: address,
                    fee: element.tags?.fee,
                    wheelchairAccessible: element.tags?.wheelchair,
                    openingHours: element.tags?.openingHours
                )
                
                toilet.distance = distance
                return toilet
            }
            
            return toilets.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
            
        } catch {
            print("Erreur décodage Overpass: \(error)")
            throw ServiceProviderError.decodingError(error)
        }
    }
}
