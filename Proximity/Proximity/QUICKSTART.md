# 🚀 Guide de démarrage rapide - Proximity

## Installation

### 1. Prérequis
- macOS 14.0+ (Sonoma)
- Xcode 15.0+
- iOS 17.0+ (pour le simulateur/appareil)
- Compte développeur JCDecaux (gratuit)

### 2. Cloner le projet
```bash
git clone [URL_DU_REPO]
cd Proximity
```

### 3. Configuration des clés API

#### JCDecaux API (Vélib')
1. Créez un compte sur https://developer.jcdecaux.com/
2. Créez une nouvelle application
3. Copiez votre clé API
4. Ouvrez `Config/APIConfiguration.swift`
5. Remplacez `"VOTRE_CLE_API_JCDECAUX"` par votre clé

```swift
static let jcdecauxAPIKey = "votre_vraie_clé_ici"
```

#### OpenDataSoft (Bornes de recharge)
✅ Aucune clé nécessaire - API publique

#### Overpass API (Toilettes, Pharmacies)
✅ Aucune clé nécessaire - API publique

### 4. Permissions de localisation

Le fichier `Info.plist` doit contenir :

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Proximity a besoin de votre position pour trouver les services à proximité.</string>
```

Ceci est normalement déjà configuré dans le projet.

### 5. Lancer l'application

1. Ouvrez `Proximity.xcodeproj` dans Xcode
2. Sélectionnez un simulateur iOS 17+ ou votre appareil
3. Appuyez sur `Cmd + R` pour compiler et lancer

⚠️ **Note pour le simulateur** : 
- Allez dans `Features > Location > Custom Location...`
- Entrez des coordonnées (ex: Paris = 48.8566, 2.3522)

## 📱 Utilisation

### Premier lancement

1. **Autoriser la localisation** : Appuyez sur "Autoriser" quand l'app le demande
2. **Attendez le chargement** : Les services proches s'affichent automatiquement
3. **Explorez la carte** : Pincer pour zoomer, glisser pour déplacer

### Filtrer les services

1. Appuyez sur l'icône **☰** en haut à gauche
2. Sélectionnez/désélectionnez les types de services
3. Ajustez le rayon de recherche (0.5 à 10 km)
4. Appuyez sur **"Rechercher"**

### Services disponibles

| Service | Status | API |
|---------|--------|-----|
| 🚲 Vélib' | ✅ Actif | JCDecaux |
| ⚡ Bornes de recharge | ✅ Actif | OpenDataSoft |
| 🚽 Toilettes publiques | ⏳ Disponible | Overpass |
| 💊 Pharmacies | ⏳ Disponible | Overpass |
| 🍔 Restaurants | 🔜 À venir | - |
| 🌳 Parcs | 🔜 À venir | - |
| ⛽ Stations service | 🔜 À venir | - |
| 🚿 Stations de lavage | 🔜 À venir | - |
| 📚 Bibliothèques | 🔜 À venir | - |

### Activer des services supplémentaires

Pour activer les toilettes publiques ou pharmacies :

1. Ouvrez `ViewModels/ProximityViewModel.swift`
2. Dans la méthode `setupProviders()`, les providers sont déjà créés
3. Pour les activer par défaut, ajoutez-les dans `selectedServiceTypes` :

```swift
selectedServiceTypes = [.velib, .chargingStation, .toilet, .pharmacy]
```

Ou activez-les depuis l'interface en appuyant sur ☰.

### Voir les détails d'un service

1. Dans la liste en bas de l'écran, appuyez sur un service
2. Consultez les informations détaillées
3. Actions disponibles :
   - **Ouvrir dans Plans** : Navigation avec Apple Plans
   - **Partager** : Partager les informations

### Rafraîchir les données

Appuyez sur l'icône **🔄** en haut à droite pour recharger les services.

## 🧪 Tests

### Lancer les tests

```bash
# Depuis Xcode
Cmd + U

# Ou en ligne de commande
xcodebuild test -scheme Proximity -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Tests disponibles

- `ProximityViewModelTests` : Tests du ViewModel
- `ServiceTypeTests` : Validation des types de services
- `ServicePointTests` : Tests des modèles de données
- `DistanceTests` : Tests des calculs de distance

## 🐛 Problèmes courants

### Les services ne s'affichent pas

**Problème** : La carte est vide après le chargement

**Solutions** :
1. Vérifiez votre connexion internet
2. Vérifiez que la localisation est autorisée
3. Sur simulateur : Définissez une position personnalisée
4. Vérifiez la clé API JCDecaux dans la console Xcode
5. Augmentez le rayon de recherche

### Erreur "API key missing"

**Problème** : Message d'erreur concernant la clé API

**Solution** : Vérifiez que vous avez bien configuré la clé dans `APIConfiguration.swift`

### La localisation ne fonctionne pas

**Problème** : L'app demande mais n'obtient pas la position

**Solutions** :
1. Sur appareil réel : Vérifiez les réglages iOS → Confidentialité → Localisation
2. Sur simulateur : Features → Location → Custom Location
3. Vérifiez `Info.plist` contient `NSLocationWhenInUseUsageDescription`

### Erreur de compilation

**Problème** : Le projet ne compile pas

**Solutions** :
1. Nettoyez le build : `Cmd + Shift + K`
2. Supprimez DerivedData : `Cmd + Shift + Alt + K`
3. Vérifiez la version d'Xcode (15.0+ requis)
4. Vérifiez le deployment target (iOS 17.0+)

## 📚 Structure du projet

```
Proximity/
├── ProximityApp.swift          # Point d'entrée
├── ContentView.swift            # Vue principale
├── Models/
│   └── ServicePoint.swift       # Protocole et types
├── Services/
│   ├── ServiceProvider.swift   # Protocole provider
│   ├── LocationManager.swift   # Gestion localisation
│   └── Providers/              # Implémentations
├── ViewModels/
│   └── ProximityViewModel.swift # Logique métier
├── Views/
│   ├── MapView.swift           # Carte interactive
│   ├── ServiceListView.swift  # Liste des services
│   ├── ServiceSelectorView.swift # Filtres
│   └── ServiceDetailView.swift # Détails
└── Config/
    └── APIConfiguration.swift   # Clés API
```

## 🔧 Configuration avancée

### Changer la ville (Vélib')

Dans `APIConfiguration.swift` :

```swift
static let jcdecauxContract = "Lyon" // ou "Marseille", "Toulouse", etc.
```

Villes disponibles : https://developer.jcdecaux.com/#/opendata/vls?page=dynamic

### Ajuster la précision de localisation

Dans `LocationManager.swift` :

```swift
locationManager.desiredAccuracy = kCLLocationAccuracyBest // Précision maximale
// ou
locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // Moins précis
```

### Modifier le rayon par défaut

Dans `ProximityViewModel.swift` :

```swift
@Published var searchRadius: Double = 5.0 // 5 km au lieu de 2 km
```

## 📝 Contribuer

Consultez [CONTRIBUTING.md](CONTRIBUTING.md) pour ajouter de nouveaux services.

## 📄 Licence

Ce projet est à but éducatif.

## 🆘 Besoin d'aide ?

1. Consultez le [README.md](README.md) principal
2. Lisez le [CONTRIBUTING.md](CONTRIBUTING.md)
3. Vérifiez les issues existantes
4. Créez une nouvelle issue avec :
   - Description du problème
   - Étapes pour reproduire
   - Version d'iOS et Xcode
   - Logs de la console Xcode

## ✅ Prochaines étapes

Après avoir l'app fonctionnelle :

1. [ ] Activer d'autres types de services (toilettes, pharmacies)
2. [ ] Ajouter des nouveaux providers (restaurants, parcs)
3. [ ] Implémenter un système de cache
4. [ ] Ajouter des favoris
5. [ ] Support du mode sombre
6. [ ] Localisation en plusieurs langues

Bon développement ! 🚀
