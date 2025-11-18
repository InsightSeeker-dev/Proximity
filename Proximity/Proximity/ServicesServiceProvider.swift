//
//  ServiceProvider.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Protocole pour tous les fournisseurs de services
protocol ServiceProvider {
    var serviceType: ServiceType { get }
    var isEnabled: Bool { get set }
    
    /// Récupère les points de service à proximité
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint]
}

/// Erreurs possibles lors de la récupération des services
enum ServiceProviderError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case locationUnavailable
    case apiKeyMissing
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        case .invalidResponse:
            return "Réponse invalide du serveur"
        case .decodingError(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .locationUnavailable:
            return "Localisation non disponible"
        case .apiKeyMissing:
            return "Clé API manquante"
        }
    }
}
