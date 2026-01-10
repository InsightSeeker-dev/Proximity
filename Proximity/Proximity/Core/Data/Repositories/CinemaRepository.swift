//
//  CinemaRepository.swift
//  Proximity
//

import Foundation
import CoreLocation

class CinemaRepository: ServiceRepository {
    let serviceType: ServiceType = .cinema
    var isEnabled: Bool = true
    private let remoteDataSource: OverpassRemoteDataSource
    
    init(remoteDataSource: OverpassRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [ServicePoint] {
        let elementsDto = try await remoteDataSource.fetchCinemas(around: location, radius: radius)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return elementsDto.compactMap { $0.toCinemaDomain(userLocation: userLocation) }
            .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
    }
}
