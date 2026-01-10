//
//  OverpassDto.swift
//  Proximity
//
//  Data Transfer Object for Overpass API (OpenStreetMap)
//

import Foundation
import CoreLocation

// MARK: - Overpass API Response Models

/// Réponse de l'API Overpass
struct OverpassResponse: Codable {
    let version: Double
    let generator: String
    let elements: [OverpassElement]
}

struct OverpassElement: Codable {
    let type: String
    let id: Int
    let lat: Double?
    let lon: Double?
    let tags: [String: String]?
    let center: OverpassCenter?
    
    struct OverpassCenter: Codable {
        let lat: Double
        let lon: Double
    }
}

// MARK: - Conversion to Domain Model

extension OverpassElement {
    /// Convertit un élément Overpass en ServicePoint pour les toilettes
    func toToiletDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let latitude = lat ?? center?.lat,
              let longitude = lon ?? center?.lon else { return nil }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let elementLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = userLocation.distance(from: elementLocation)
        
        let name = tags?["name"] ?? "Toilettes publiques"
        let street = tags?["addr:street"]
        let houseNumber = tags?["addr:housenumber"]
        
        var address: String?
        if let street = street {
            address = houseNumber != nil ? "\(houseNumber!) \(street)" : street
        }
        
        var additionalInfo: [String: String] = [:]
        if let fee = tags?["fee"] {
            additionalInfo["Payant"] = fee == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let access = tags?["access"] {
            additionalInfo["Accès"] = access
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: address,
            serviceType: .toilet,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
    
    /// Convertit un élément Overpass en ServicePoint pour les pharmacies
    func toPharmacyDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let latitude = lat ?? center?.lat,
              let longitude = lon ?? center?.lon else { return nil }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let elementLocation = CLLocation(latitude: latitude, longitude: longitude)
        let distance = userLocation.distance(from: elementLocation)
        
        let name = tags?["name"] ?? "Pharmacie"
        let street = tags?["addr:street"]
        let houseNumber = tags?["addr:housenumber"]
        
        var address: String?
        if let street = street {
            address = houseNumber != nil ? "\(houseNumber!) \(street)" : street
        }
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let openingHours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = openingHours
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let dispensing = tags?["dispensing"] {
            additionalInfo["Délivrance"] = dispensing == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: address,
            serviceType: .pharmacy,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}
