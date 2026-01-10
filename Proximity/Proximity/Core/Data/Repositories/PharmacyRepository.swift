//
//  PharmacyRepository.swift
//  Proximity
//
//  Repository for Pharmacies
//

import Foundation
import CoreLocation

/// Repository pour les pharmacies
class PharmacyRepository: ServiceRepository {
    let serviceType: ServiceType = .pharmacy
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
        let elementsDto = try await remoteDataSource.fetchPharmacies(around: location, radius: radius)
        
        // 2. Convertir en modèles du domaine
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = elementsDto.compactMap { dto -> ServicePoint? in
            dto.toPharmacyDomain(userLocation: userLocation)
        }
        
        // 3. Trier par distance
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
