# Proximity

Une application iOS permettant de trouver les points de services les plus proches de votre position.

## 🎯 Fonctionnalités

L'application permet de localiser différents types de services à proximité :

### Services implémentés
- ✅ **Vélib'** (via API JCDecaux)
- ✅ **Bornes de recharge électrique** (via OpenDataSoft ODRE)

### Services à venir
- ⏳ Restaurants / Fast-food
- ⏳ Toilettes publiques
- ⏳ Pharmacies
- ⏳ Parcs
- ⏳ Stations service
- ⏳ Stations de lavage
- ⏳ Bibliothèques

## 🏗️ Architecture

Le projet est conçu avec une architecture modulaire permettant d'ajouter facilement de nouveaux types de services.

### Structure du projet

```
Proximity/
├── Models/
│   └── ServicePoint.swift         # Protocole de base pour tous les services
├── Services/
│   ├── ServiceProvider.swift      # Protocole pour les fournisseurs de données
│   ├── LocationManager.swift      # Gestion de la localisation
│   └── Providers/
│       ├── VelibServiceProvider.swift
│       └── ChargingStationProvider.swift
├── ViewModels/
│   └── ProximityViewModel.swift   # ViewModel principal
├── Views/
│   ├── ContentView.swift          # Vue principale
│   ├── MapView.swift              # Carte interactive
│   ├── ServiceListView.swift     # Liste des services
│   └── ServiceSelectorView.swift  # Sélection des services
└── Config/
    └── APIConfiguration.swift     # Configuration des clés API
```

### Principes d'architecture

1. **Protocol-Oriented Programming** : Tous les services implémentent le protocole `ServicePoint`
2. **Provider Pattern** : Chaque source de données implémente `ServiceProvider`
3. **MVVM** : Séparation claire entre logique métier et interface
4. **SwiftUI + Async/Await** : Interface moderne et gestion asynchrone native
5. **Modulabilité** : Ajout facile de nouveaux services

## 🔧 Configuration

### Prérequis
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### Clés API nécessaires

#### JCDecaux (Vélib')
1. Créez un compte sur [JCDecaux Developer Portal](https://developer.jcdecaux.com/)
2. Obtenez votre clé API
3. Ajoutez-la dans `Config/APIConfiguration.swift` :

```swift
static let jcdecauxAPIKey = "VOTRE_CLE_ICI"
```

#### OpenDataSoft (Bornes de recharge)
Aucune clé API requise - API publique

### Permissions

L'application nécessite l'accès à la localisation. Assurez-vous que `Info.plist` contient :
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Proximity a besoin de votre position pour trouver les services à proximité.</string>
```

## 📱 Utilisation

1. Lancez l'application
2. Autorisez l'accès à la localisation
3. Les services proches s'affichent automatiquement
4. Utilisez le bouton filtre (☰) pour sélectionner les types de services
5. Ajustez le rayon de recherche selon vos besoins
6. Appuyez sur un service pour le voir sur la carte

## 🔌 Ajouter un nouveau service

Pour ajouter un nouveau type de service :

### 1. Ajouter le type dans `ServiceType`

```swift
enum ServiceType: String, CaseIterable {
    case nouveauService = "Nouveau Service"
    
    var iconName: String {
        case .nouveauService: return "icon.system.name"
    }
    
    var color: String {
        case .nouveauService: return "blue"
    }
}
```

### 2. Créer un modèle conforme à `ServicePoint`

```swift
struct MonService: ServicePoint {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType = .nouveauService
    var distance: Double?
    
    var additionalInfo: [String: String] {
        // Informations spécifiques au service
    }
}
```

### 3. Créer un Provider conforme à `ServiceProvider`

```swift
class MonServiceProvider: ServiceProvider {
    let serviceType: ServiceType = .nouveauService
    var isEnabled: Bool = true
    
    func fetchNearbyServices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [any ServicePoint] {
        // Implémentation de la récupération des données
    }
}
```

### 4. Enregistrer le provider dans le ViewModel

```swift
// Dans ProximityViewModel.setupProviders()
providers.append(MonServiceProvider())
```

## 🌐 APIs utilisées

### JCDecaux API v3
- **Documentation** : https://developer.jcdecaux.com/
- **Endpoint** : `https://api.jcdecaux.com/vls/v3/stations`
- **Usage** : Vélib' et autres systèmes de vélos partagés

### OpenDataSoft ODRE
- **Documentation** : https://odre.opendatasoft.com/
- **Endpoint** : `https://odre.opendatasoft.com/api/records/1.0/search/`
- **Dataset** : `bornes-irve`
- **Usage** : Bornes de recharge pour véhicules électriques

## 📝 TODO

- [ ] Implémenter les autres services (restaurants, pharmacies, etc.)
- [ ] Ajouter un système de cache pour réduire les appels API
- [ ] Implémenter la navigation vers les services
- [ ] Ajouter des favoris
- [ ] Mode hors-ligne avec données en cache
- [ ] Filtres avancés (horaires, disponibilité, etc.)
- [ ] Support du mode sombre
- [ ] Tests unitaires et UI

## 📄 Licence

Ce projet est un exercice éducatif.

## 👥 Crédits

Données fournies par :
- JCDecaux pour les stations Vélib'
- OpenDataSoft ODRE pour les bornes de recharge
