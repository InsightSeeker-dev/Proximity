//
//  PharmacyProvider.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Modèle pour les pharmacies
struct Pharmacy: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .pharmacy
    var distance: Double?
    
    let phone: String?
    let openingHours: String?
    let website: String?
    
    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        if let phone = phone {
            info["Téléphone"] = phone
        }
        if let hours = openingHours {
            info["Horaires"] = hours
        }
        if let website = website {
            info["Site web"] = website
        }
        return info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Pharmacy, rhs: Pharmacy) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Overpass API Models (réutilisation des structures)
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
    let phone: String?
    let openingHours: String?
    let website: String?
    let street: String?
    let housenumber: String?
    let city: String?
    let postcode: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case phone
        case openingHours = "opening_hours"
        case website
        case street = "addr:street"
        case housenumber = "addr:housenumber"
        case city = "addr:city"
        case postcode = "addr:postcode"
    }
}

/// Fournisseur de pharmacies via Overpass API (OpenStreetMap)
class PharmacyProvider: ServiceProvider {
    let serviceType: ServiceType = .pharmacy
    var isEnabled: Bool = false // Désactivé par défaut
    
    private let overpassURL = "https://overpass-api.de/api/interpreter"
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // Construire la requête Overpass QL
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:25];
        (
          node["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="pharmacy"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
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
            
            let pharmacies = overpassResponse.elements.compactMap { element -> Pharmacy? in
                // Obtenir les coordonnées (node ou center pour way)
                guard let lat = element.lat ?? element.center?.lat,
                      let lon = element.lon ?? element.center?.lon else {
                    return nil
                }
                
                let pharmacyLocation = CLLocation(latitude: lat, longitude: lon)
                let distance = userLocation.distance(from: pharmacyLocation)
                
                // Vérifier que c'est bien dans le rayon
                guard distance <= Double(radiusMeters) else { return nil }
                
                // Construire le nom
                let name = element.tags?.name ?? "Pharmacie"
                
                // Construire l'adresse complète
                var addressParts: [String] = []
                if let number = element.tags?.housenumber {
                    addressParts.append(number)
                }
                if let street = element.tags?.street {
                    addressParts.append(street)
                }
                if let postcode = element.tags?.postcode, let city = element.tags?.city {
                    addressParts.append("\(postcode) \(city)")
                } else if let city = element.tags?.city {
                    addressParts.append(city)
                }
                
                let address = addressParts.isEmpty ? nil : addressParts.joined(separator: ", ")
                
                var pharmacy = Pharmacy(
                    id: "\(element.id)",
                    name: name,
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    address: address,
                    phone: element.tags?.phone,
                    openingHours: element.tags?.openingHours,
                    website: element.tags?.website
                )
                
                pharmacy.distance = distance
                return pharmacy
            }
            
            return pharmacies.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
            
        } catch {
            print("Erreur décodage Overpass: \(error)")
            throw ServiceProviderError.decodingError(error)
        }
    }
}
