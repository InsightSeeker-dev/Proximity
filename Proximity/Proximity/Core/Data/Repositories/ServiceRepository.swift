//
//  ServiceRepository.swift
//  Proximity
//
//  Repository Protocol - Interface unifiée pour l'accès aux données
//

import Foundation
import CoreLocation

/// Protocol définissant le contrat pour tous les repositories de services
protocol ServiceRepository {
    /// Type de service géré par ce repository
    var serviceType: ServiceType { get }
    
    /// Indique si le repository est activé
    var isEnabled: Bool { get set }
    
    /// Récupère les services à proximité d'une position
    /// - Parameters:
    ///   - location: Position centrale de la recherche
    ///   - radius: Rayon de recherche en kilomètres
    /// - Returns: Liste des points de service triés par distance
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [ServicePoint]
}
