//
//  HospitalRepository.swift
//  Proximity
//
//  Repository for Hospital services
//

import Foundation
import CoreLocation

class HospitalRepository: ServiceRepository {
    let serviceType: ServiceType = .hospital
    var isEnabled: Bool = true
    
    private let remoteDataSource: OverpassRemoteDataSource
    
    init(remoteDataSource: OverpassRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint] {
        let elementsDto = try await remoteDataSource.fetchHospitals(around: location, radius: radius)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let services = elementsDto.compactMap { dto -> ServicePoint? in
            dto.toHospitalDomain(userLocation: userLocation)
        }
        
        return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
