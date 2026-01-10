//
//  ChargingStationRepository.swift
//  Proximity
//
//  Repository for Charging Stations
//

import Foundation
import CoreLocation

/// Repository pour les bornes de recharge
class ChargingStationRepository: ServiceRepository {
    let serviceType: ServiceType = .chargingStation
    var isEnabled: Bool = true
    
    private let remoteDataSource: ChargingStationRemoteDataSource
    
    init(remoteDataSource: ChargingStationRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint] {
        // 1. Récupérer les données depuis l'API (déjà filtrées par rayon)
        let recordsDto = try await remoteDataSource.fetchStations(around: location, radius: radius)
        
        // 2. Convertir en modèles du domaine
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = recordsDto.compactMap { dto -> ServicePoint? in
            dto.toDomain(userLocation: userLocation)
        }
        
        // 3. Trier par distance
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
