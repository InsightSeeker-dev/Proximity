//
//  BarRepository.swift
//  Proximity
//
//  Repository for Bar services
//

import Foundation
import CoreLocation

class BarRepository: ServiceRepository {
    let serviceType: ServiceType = .bar
    var isEnabled: Bool = true
    
    private let remoteDataSource: OverpassRemoteDataSource
    
    init(remoteDataSource: OverpassRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint] {
        let elementsDto = try await remoteDataSource.fetchBars(around: location, radius: radius)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = elementsDto.compactMap { dto -> ServicePoint? in
            dto.toBarDomain(userLocation: userLocation)
        }
        
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
