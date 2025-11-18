# Guide de contribution : Ajouter un nouveau service

Ce guide explique comment ajouter un nouveau type de service à l'application Proximity.

## 📋 Vue d'ensemble

Pour ajouter un nouveau service, vous devez :
1. Déclarer le nouveau type de service
2. Créer un modèle conforme au protocole `ServicePoint`
3. Implémenter un `ServiceProvider` pour récupérer les données
4. Enregistrer le provider dans le ViewModel
5. (Optionnel) Ajouter la clé API si nécessaire

## 🔧 Étape par étape

### 1. Ajouter le type de service

Ouvrez `Models/ServicePoint.swift` et ajoutez votre type dans l'enum `ServiceType` :

```swift
enum ServiceType: String, CaseIterable {
    // ... services existants
    case monNouveauService = "Mon Nouveau Service"
    
    var iconName: String {
        switch self {
        // ... cas existants
        case .monNouveauService: return "icon.sf.symbol"
        }
    }
    
    var color: String {
        switch self {
        // ... cas existants
        case .monNouveauService: return "blue"
        }
    }
}
```

**Icônes disponibles** : Consultez [SF Symbols](https://developer.apple.com/sf-symbols/) pour choisir une icône appropriée.

**Couleurs disponibles** : `"green"`, `"blue"`, `"orange"`, `"purple"`, `"red"`, `"yellow"`, `"cyan"`, `"brown"`, `"gray"`

### 2. Créer le modèle

Créez un nouveau fichier dans `Services/Providers/` (ex: `MonServiceProvider.swift`) :

```swift
import Foundation
import CoreLocation

struct MonService: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .monNouveauService
    var distance: Double?
    
    // Propriétés spécifiques à votre service
    let maProprietéSpécifique: String?
    
    var additionalInfo: [String: String] {
        var info: [String: String] = [:]
        if let prop = maProprietéSpécifique {
            info["Label affiché"] = prop
        }
        return info
    }
    
    // Conformité à Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MonService, rhs: MonService) -> Bool {
        lhs.id == rhs.id
    }
}
```

### 3. Créer les modèles de décodage API

Dans le même fichier, ajoutez les structures pour décoder la réponse de l'API :

```swift
// MARK: - API Response Models
private struct MonAPIResponse: Codable {
    let results: [MonAPIItem]
    // Adaptez selon votre API
}

private struct MonAPIItem: Codable {
    let id: String
    let nom: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case nom = "name" // Mapper les clés de l'API
        case latitude = "lat"
        case longitude = "lng"
    }
}
```

### 4. Implémenter le ServiceProvider

Toujours dans le même fichier :

```swift
class MonServiceProvider: ServiceProvider {
    let serviceType: ServiceType = .monNouveauService
    var isEnabled: Bool = true
    
    // Ajoutez les propriétés nécessaires
    private let apiKey: String?
    
    init(apiKey: String? = nil) {
        self.apiKey = apiKey
    }
    
    func fetchNearbyServices(
        around location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [any ServicePoint] {
        
        // 1. Construire l'URL
        let baseURL = "https://api.example.com/endpoint"
        guard var components = URLComponents(string: baseURL) else {
            throw ServiceProviderError.invalidResponse
        }
        
        // 2. Ajouter les paramètres
        components.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.latitude)"),
            URLQueryItem(name: "lng", value: "\(location.longitude)"),
            URLQueryItem(name: "radius", value: "\(Int(radius * 1000))"),
        ]
        
        if let key = apiKey {
            components.queryItems?.append(
                URLQueryItem(name: "api_key", value: key)
            )
        }
        
        guard let url = components.url else {
            throw ServiceProviderError.invalidResponse
        }
        
        // 3. Faire la requête
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ServiceProviderError.invalidResponse
        }
        
        // 4. Décoder la réponse
        do {
            let apiResponse = try JSONDecoder().decode(
                MonAPIResponse.self,
                from: data
            )
            
            let userLocation = CLLocation(
                latitude: location.latitude,
                longitude: location.longitude
            )
            
            // 5. Convertir en ServicePoint
            let services = apiResponse.results.compactMap { item -> MonService? in
                let serviceLocation = CLLocation(
                    latitude: item.latitude,
                    longitude: item.longitude
                )
                
                let distance = userLocation.distance(from: serviceLocation)
                
                // Filtrer selon le rayon
                guard distance <= radius * 1000 else { return nil }
                
                var service = MonService(
                    id: item.id,
                    name: item.nom,
                    coordinate: CLLocationCoordinate2D(
                        latitude: item.latitude,
                        longitude: item.longitude
                    ),
                    address: nil, // Ajoutez si disponible
                    maProprietéSpécifique: nil
                )
                
                service.distance = distance
                return service
            }
            
            // 6. Trier par distance
            return services.sorted {
                ($0.distance ?? .infinity) < ($1.distance ?? .infinity)
            }
            
        } catch {
            throw ServiceProviderError.decodingError(error)
        }
    }
}
```

### 5. Enregistrer le provider

Ouvrez `ViewModels/ProximityViewModel.swift` et ajoutez votre provider dans `setupProviders()` :

```swift
private func setupProviders() {
    providers = [
        // ... providers existants
        MonServiceProvider(apiKey: "MA_CLE_API")
    ]
    
    // Optionnel : activer par défaut
    selectedServiceTypes.insert(.monNouveauService)
}
```

### 6. (Optionnel) Ajouter la clé API

Si votre API nécessite une clé, ajoutez-la dans `Config/APIConfiguration.swift` :

```swift
struct APIConfiguration {
    // ... clés existantes
    static let monServiceAPIKey = "VOTRE_CLE_ICI"
}
```

Puis utilisez-la dans le ViewModel :

```swift
MonServiceProvider(apiKey: APIConfiguration.monServiceAPIKey)
```

## 📝 Exemples d'APIs recommandées

### APIs publiques sans clé
- **OpenStreetMap (Overpass API)** : Toilettes, pharmacies, parcs, etc.
  - URL : `https://overpass-api.de/api/interpreter`
  - Documentation : https://wiki.openstreetmap.org/wiki/Overpass_API
  
- **data.gouv.fr** : Données publiques françaises
  - URL : `https://www.data.gouv.fr/`
  - Exemple : Prix des carburants, équipements publics

### APIs avec clé gratuite
- **Google Places API** : Restaurants, commerces, etc.
  - Documentation : https://developers.google.com/maps/documentation/places/web-service
  
- **Yelp Fusion API** : Restaurants, bars, etc.
  - Documentation : https://www.yelp.com/developers/documentation/v3

### Requête Overpass (OpenStreetMap)

Exemple pour récupérer des toilettes publiques :

```swift
let query = """
[out:json][timeout:25];
(
  node["amenity"="toilets"](around:\(radiusMeters),\(lat),\(lng));
  way["amenity"="toilets"](around:\(radiusMeters),\(lat),\(lng));
);
out center;
"""

var request = URLRequest(url: URL(string: "https://overpass-api.de/api/interpreter")!)
request.httpMethod = "POST"
request.httpBody = query.data(using: .utf8)
request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
```

## ✅ Checklist finale

Avant de soumettre votre nouveau service :

- [ ] Le type est ajouté dans `ServiceType`
- [ ] L'icône SF Symbol est appropriée
- [ ] Le modèle implémente `ServicePoint`
- [ ] Le modèle est `Hashable` (hash + ==)
- [ ] Le provider implémente `ServiceProvider`
- [ ] Les erreurs sont gérées avec `ServiceProviderError`
- [ ] Les résultats sont filtrés par rayon
- [ ] Les résultats sont triés par distance
- [ ] Le provider est enregistré dans le ViewModel
- [ ] La clé API est sécurisée (si applicable)
- [ ] Le code compile sans erreur
- [ ] L'API a été testée manuellement

## 🧪 Tester votre service

1. Lancez l'application
2. Ouvrez le sélecteur de services (☰)
3. Activez votre nouveau service
4. Vérifiez que les résultats s'affichent sur la carte
5. Testez différents rayons de recherche
6. Vérifiez les détails en cliquant sur un service

## 🐛 Debugging

### Les services ne s'affichent pas

- Vérifiez que `isEnabled = true` dans le provider
- Ajoutez des `print()` pour débugger :
  ```swift
  print("URL de requête : \(url)")
  print("Nombre de résultats : \(services.count)")
  ```

### Erreur de décodage

- Utilisez un outil comme [quicktype.io](https://quicktype.io/) pour générer les structs
- Vérifiez les `CodingKeys` correspondent aux clés de l'API
- Testez l'API dans un outil comme Postman d'abord

### Problème de permissions

- Vérifiez que `Info.plist` contient `NSLocationWhenInUseUsageDescription`
- Testez sur un appareil réel si le simulateur pose problème

## 📚 Ressources

- [Apple MapKit Documentation](https://developer.apple.com/documentation/mapkit)
- [Core Location Documentation](https://developer.apple.com/documentation/corelocation)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [SF Symbols Browser](https://developer.apple.com/sf-symbols/)

## 💡 Besoin d'aide ?

Consultez les providers existants pour des exemples :
- `VelibServiceProvider.swift` - API REST avec clé
- `ChargingStationProvider.swift` - OpenDataSoft
- `PublicToiletProvider.swift` - Overpass API (OpenStreetMap)
- `PharmacyProvider.swift` - Overpass API avec plus de détails
