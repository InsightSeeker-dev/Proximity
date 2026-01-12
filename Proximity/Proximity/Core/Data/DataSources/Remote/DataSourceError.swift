//
//  DataSourceError.swift
//  Proximity
//
//  Error types for Remote Data Sources
//

import Foundation

/// Erreurs possibles lors de l'accès aux sources de données distantes
enum DataSourceError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
}

extension DataSourceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "L'URL de la requête est invalide"
        case .invalidResponse:
            return "La réponse du serveur est invalide"
        case .httpError(let statusCode):
            return "Erreur HTTP: \(statusCode)"
        case .decodingError(let error):
            return "Erreur de décodage: \(error.localizedDescription)"
        case .networkError(let error):
            return "Erreur réseau: \(error.localizedDescription)"
        }
    }
}
