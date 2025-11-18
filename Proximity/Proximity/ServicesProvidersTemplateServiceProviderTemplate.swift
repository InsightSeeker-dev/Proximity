//
//  ServiceProviderTemplate.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//
//  📝 Template pour créer un nouveau provider de services
//  Copiez ce fichier et remplacez "Template" par le nom de votre service

import Foundation
import CoreLocation

// MARK: - Model

/// Modèle pour [NOM DU SERVICE]
struct TemplateService: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .restaurant // TODO: Changer selon le service
    var distance: Double?
    
    // Propriétés spécifiques au service
    // let customProperty: String?
    
    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        // Ajoutez les informations spécifiques à afficher
        // if let prop = customProperty { info["Clé"] = prop }
        return info
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: TemplateService, rhs: TemplateService) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - API Response Models

/// Structures pour décoder la réponse de l'API
private struct TemplateAPIResponse: Codable {
    let results: [TemplateAPIItem]
    
    // Adaptez selon la structure de votre API
}

private struct TemplateAPIItem: Codable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let address: String?
    
    // Ajoutez les champs de votre API
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case latitude = "lat" // Adapter selon l'API
        case longitude = "lng"
        case address
    }
}

// MARK: - Provider

/// Fournisseur de [NOM DU SERVICE] via [NOM DE L'API]
class TemplateServiceProvider: ServiceProvider {
    let serviceType: ServiceType = .restaurant // TODO: Changer selon le service
    var isEnabled: Bool = true
    
    // Ajoutez les paramètres nécessaires (clé API, configuration, etc.)
    // private let apiKey: String?
    
    init(/* paramètres si nécessaires */) {
        // Initialisation
    }
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // TODO: Construire l'URL de l'API
        let baseURL = "https://api.example.com/endpoint"
        
        guard var components = URLComponents(string: baseURL) else {
            throw ServiceProviderError.invalidResponse
        }
        
        // TODO: Ajouter les query parameters
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lng", value: "\(location.longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radius * 1000))"),
            // URLQueryItem(name: "apiKey", value: apiKey)
        ]
        
        guard let url = components.url else {
            throw ServiceProviderError.invalidResponse
        }
        
        // TODO: Faire la requête
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceProviderError.invalidResponse
        }
        
        do {
            // TODO: Décoder la réponse
            let apiResponse = try JSONDecoder().decode(TemplateAPIResponse.self, from: data)
            
            let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            
            // TODO: Convertir les résultats en ServicePoint
            let services = apiResponse.results.compactMap { item -> TemplateService? in
                let serviceLocation = CLLocation(
                    latitude: item.latitude,
                    longitude: item.longitude
                )
                
                let distance = userLocation.distance(from: serviceLocation)
                
                // Filtrer selon le rayon
                guard distance <= radius * 1000 else { return nil }
                
                var service = TemplateService(
                    id: item.id,
                    name: item.name,
                    coordinate: CLLocationCoordinate2D(
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
                    address: item.address
                    // Ajoutez les propriétés spécifiques
                )
                
                service.distance = distance
                return service
            }
            
            // Trier par distance
            return services.sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
            
        } catch {
            throw ServiceProviderError.decodingError(error)
        }
    }
}

/*
 CHECKLIST pour implémenter un nouveau service :
 
 1. □ Ajouter le ServiceType dans ServiceType.swift
 2. □ Créer le modèle conforme à ServicePoint
 3. □ Créer les structures pour décoder l'API
 4. □ Implémenter le ServiceProvider
 5. □ Ajouter la clé API si nécessaire dans APIConfiguration.swift
 6. □ Enregistrer le provider dans ProximityViewModel.setupProviders()
 7. □ Tester avec quelques données
 8. □ Documenter l'API dans le README
 
 APIs suggérées :
 - Restaurants : Overpass API (OpenStreetMap), Yelp API, Google Places API
 - Toilettes : OpenStreetMap via Overpass API
 - Pharmacies : API Santé.fr, OpenStreetMap
 - Parcs : OpenStreetMap, data.gouv.fr
 - Stations service : prix-carburants.gouv.fr
 - Bibliothèques : data.gouv.fr, API Culture
 */
