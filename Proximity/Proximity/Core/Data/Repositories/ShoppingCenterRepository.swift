//
//  ShoppingCenterRepository.swift
//  Proximity
//
//  Repository for Shopping Center services
//

import Foundation
import CoreLocation

class ShoppingCenterRepository: ServiceRepository {
    let serviceType: ServiceType = .shoppingCenter
    var isEnabled: Bool = true
    
    private let remoteDataSource: OverpassRemoteDataSource
    
    init(remoteDataSource: OverpassRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint] {
        let elementsDto = try await remoteDataSource.fetchShoppingCenters(around: location, radius: radius)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = elementsDto.compactMap { dto -> ServicePoint? in
            dto.toShoppingCenterDomain(userLocation: userLocation)
        }
        
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
