//
//  ChargingStationProvider.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Modèle pour les bornes de recharge électrique
struct ChargingStation: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .chargingStation
    var distance: Double?
    
    let operatorName: String?
    let power: String?
    let availablePlugs: String?
    let accessType: String?
    
    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        if let op = operatorName { info["Opérateur"] = op }
        if let pwr = power { info["Puissance"] = pwr }
        if let plugs = availablePlugs { info["Prises"] = plugs }
        if let access = accessType { info["Accès"] = access }
        return info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ChargingStation, rhs: ChargingStation) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - OpenDataSoft API Models
private struct ODSResponse: Codable {
    let records: [ODSRecord]
}

private struct ODSRecord: Codable {
    let recordid: String
    let fields: ODSFields
}

private struct ODSFields: Codable {
    let nomStation: String?
    let adresseStation: String?
    let coordonneesXY: [Double]?
    let nomOperateur: String?
    let puissanceNominale: Double?
    let typesPrise: String?
    let conditionAcces: String?
    
    enum CodingKeys: String, CodingKey {
        case nomStation = "n_station"
        case adresseStation = "ad_station"
        case coordonneesXY = "coordonneesxy"
        case nomOperateur = "n_operateur"
        case puissanceNominale = "puiss_max"
        case typesPrise = "type_prise"
        case conditionAcces = "acces_recharge"
    }
}

/// Fournisseur de bornes de recharge via OpenDataSoft
class ChargingStationProvider: ServiceProvider {
    let serviceType: ServiceType = .chargingStation
    var isEnabled: Bool = true
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // API OpenDataSoft ODRE - Bornes de recharge
        let baseURL = "https://odre.opendatasoft.com/api/records/1.0/search/"
        
        guard var components = URLComponents(string: baseURL) else {
            throw ServiceProviderError.invalidResponse
        }
        
        // Construction de la requête avec géolocalisation
        let geoFilter = "distance(\(location.latitude),\(location.longitude),\(radius * 1000)m)"
        
        components.queryItems = [
            URLQueryItem(name: "dataset", value: "bornes-irve"),
            URLQueryItem(name: "rows", value: "100"),
            URLQueryItem(name: "geofilter.distance", value: "\(location.latitude),\(location.longitude),\(Int(radius * 1000))")
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
            let odsResponse = try JSONDecoder().decode(ODSResponse.self, from: data)
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            let stations = odsResponse.records.compactMap { record -> ChargingStation? in
                guard let coords = record.fields.coordonneesXY,
                      coords.count >= 2 else { return nil }
                
                let stationLocation = CLLocation(latitude: coords[0], longitude: coords[1])
                let distance = userLocation.distance(from: stationLocation)
                
                let powerString = record.fields.puissanceNominale.map { "\(Int($0)) kW" }
                
                var station = ChargingStation(
                    id: record.recordid,
                    name: record.fields.nomStation ?? "Borne de recharge",
                    coordinate: CLLocationCoordinate2D(latitude: coords[0], longitude: coords[1]),
                    address: record.fields.adresseStation,
                    operatorName: record.fields.nomOperateur,
                    power: powerString,
                    availablePlugs: record.fields.typesPrise,
                    accessType: record.fields.conditionAcces
                )
                
                station.distance = distance
                return station
            }
            
            return stations.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
            
        } catch {
            throw ServiceProviderError.decodingError(error)
        }
    }
}
