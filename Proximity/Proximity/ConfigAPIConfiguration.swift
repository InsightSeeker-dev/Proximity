//
//  APIConfiguration.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation

/// Configuration centralisée des clés API
/// ⚠️ Dans un projet réel, ces clés devraient être stockées de manière sécurisée
/// (Keychain, fichier de configuration non versionné, ou service de gestion de secrets)
struct APIConfiguration {
    /// Clé API JCDecaux pour les vélib
    /// Obtenez votre clé sur: https://developer.jcdecaux.com/
    static let jcdecauxAPIKey = "a8aa42f6c7525093bffb39f799de03d24d773eea"
    
    /// Nom du contrat JCDecaux (ville)
    /// Exemples: "Paris", "Lyon", "Marseille", etc.
    static let jcdecauxContract = "Paris"
    
    // TODO: Ajouter d'autres clés API au fur et à mesure
    // static let overpassAPIURL = "https://overpass-api.de/api/interpreter"
}
