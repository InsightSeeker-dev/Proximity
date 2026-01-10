//
//  ToiletRepository.swift
//  Proximity
//
//  Repository for Public Toilets
//

import Foundation
import CoreLocation

/// Repository pour les toilettes publiques
class ToiletRepository: ServiceRepository {
    let serviceType: ServiceType = .toilet
    var isEnabled: Bool = true
    
    private let remoteDataSource: OverpassRemoteDataSource
    
    init(remoteDataSource: OverpassRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint] {
        // 1. Récupérer les données depuis Overpass
        let elementsDto = try await remoteDataSource.fetchToilets(around: location, radius: radius)
        
        // 2. Convertir en modèles du domaine
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = elementsDto.compactMap { dto -> ServicePoint? in
            dto.toToiletDomain(userLocation: userLocation)
        }
        
        // 3. Trier par distance
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
