//
//  ODSChargingStationDto.swift
//  Proximity
//
//  Data Transfer Object for OpenDataSoft API
//

import Foundation
import CoreLocation

// MARK: - OpenDataSoft API Response Models

/// Réponse de l'API OpenDataSoft ODRE
struct ODSResponse: Codable {
    let records: [ODSRecord]
}

struct ODSRecord: Codable {
    let recordid: String
    let fields: ODSFields
}

struct ODSFields: Codable {
    let nomStation: String?
    let adresseStation: String?
    let geoPointBorne: [Double]?  // Coordonnées [latitude, longitude]
    let nomOperateur: String?
    let puissanceNominale: Double?
    let typesPrise: String?
    let conditionAcces: String?
    
    enum CodingKeys: String, CodingKey {
        case nomStation = "n_station"
        case adresseStation = "ad_station"
        case geoPointBorne = "geo_point_borne"  // Nom correct du champ
        case nomOperateur = "n_operateur"
        case puissanceNominale = "puiss_max"
        case typesPrise = "type_prise"
        case conditionAcces = "acces_recharge"
    }
}

// MARK: - Conversion to Domain Model

extension ODSRecord {
    /// Convertit le DTO en modèle du domaine
    func toDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coords = fields.geoPointBorne,
              coords.count >= 2 else { return nil }
        
        // geo_point_borne contient [latitude, longitude]
        let coordinate = CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1])
        let stationLocation = CLLocation(latitude: coords[0], longitude: coords[1])
        let distance = userLocation.distance(from: stationLocation)
        
        var additionalInfo: [String: String] = [:]
        if let op = fields.nomOperateur {
            additionalInfo["Opérateur"] = op
        }
        if let power = fields.puissanceNominale {
            additionalInfo["Puissance"] = "\(Int(power)) kW"
        }
        if let plugs = fields.typesPrise {
            additionalInfo["Prises"] = plugs
        }
        if let access = fields.conditionAcces {
            additionalInfo["Accès"] = access
        }
        
        return ServicePoint(
            id: recordid,
            name: fields.nomStation ?? "Borne de recharge",
            coordinate: coordinate,
            address: fields.adresseStation,
            serviceType: .chargingStation,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}
