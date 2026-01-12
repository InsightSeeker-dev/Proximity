//
//  ProximityViewModel.swift
//  Proximity
//
//  ViewModel - Logique de présentation
//  Refactored to use Repository Pattern
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

/// ViewModel principal pour la gestion des services de proximité
@MainActor
class ProximityViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Liste des services à afficher
    @Published var services: [ServicePointUI] = []
    
    /// Types de services sélectionnés (activés)
    @Published var selectedServiceTypes: Set<ServiceType> = []
    
    /// Filtre par type de service spécifique (optionnel)
    /// Si nil, affiche tous les types activés
    /// Si défini, affiche uniquement ce type
    @Published var serviceTypeFilter: ServiceType? = nil
    
    /// Rayon de recherche en kilomètres (optimisé pour réduire les timeouts)
    @Published var searchRadius: Double = 1.5
    
    /// Indicateur de chargement
    @Published var isLoading: Bool = false
    
    /// Message d'erreur
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    
    private var repositories: [ServiceRepository] = []
    let locationManager = LocationManager()
    
    // MARK: - Initialization
    
    init() {
        setupRepositories()
    }
    
    /// Configure les repositories avec leurs data sources
    private func setupRepositories() {
        // Configuration des data sources
        let chargingDataSource = ChargingStationRemoteDataSource()
        let overpassDataSource = OverpassRemoteDataSource()
        
        // Création des repositories
        repositories = [
            // Services existants
            ChargingStationRepository(remoteDataSource: chargingDataSource),
            ToiletRepository(remoteDataSource: overpassDataSource),
            PharmacyRepository(remoteDataSource: overpassDataSource),
            
            // Nouveaux services essentiels
            RestaurantRepository(remoteDataSource: overpassDataSource),
            FastFoodRepository(remoteDataSource: overpassDataSource),
            BarRepository(remoteDataSource: overpassDataSource),
            HotelRepository(remoteDataSource: overpassDataSource),
            HospitalRepository(remoteDataSource: overpassDataSource),
            ShoppingCenterRepository(remoteDataSource: overpassDataSource),
            ParkRepository(remoteDataSource: overpassDataSource),
            GasStationRepository(remoteDataSource: overpassDataSource),
            CarWashRepository(remoteDataSource: overpassDataSource),
            LibraryRepository(remoteDataSource: overpassDataSource),
            
            // Nouveaux services complémentaires
            ATMRepository(remoteDataSource: overpassDataSource),
            PostOfficeRepository(remoteDataSource: overpassDataSource),
            BakeryRepository(remoteDataSource: overpassDataSource),
            CinemaRepository(remoteDataSource: overpassDataSource),
            GymRepository(remoteDataSource: overpassDataSource),
            BusStopRepository(remoteDataSource: overpassDataSource),
            MetroStationRepository(remoteDataSource: overpassDataSource)
        ]
        
        // Services activés par défaut (optimisés pour performance et fiabilité)
        selectedServiceTypes = [
            .restaurant,        // 2851 résultats à Paris, très fiable (1.0s)
            .chargingStation,   // 519 résultats, API différente (OpenDataSoft)
            .library            // 56 résultats, très rapide (0.61s)
        ]
    }
    
    // MARK: - Public Methods
    
    /// Toggle l'activation d'un type de service
    func toggleServiceType(_ type: ServiceType) {
        if selectedServiceTypes.contains(type) {
            selectedServiceTypes.remove(type)
        } else {
            selectedServiceTypes.insert(type)
        }
    }
    
    /// Récupère les services à proximité
    func fetchNearbyServices() async {
        guard let location = locationManager.location else {
            errorMessage = "Localisation non disponible"
            return
        }
        
        isLoading = true
        errorMessage = nil
        services = []
        
        let coordinate = location.coordinate
        
        // Déterminer quels types de services récupérer
        let typesToFetch: Set<ServiceType>
        if let filter = serviceTypeFilter {
            // Si un filtre est actif, récupérer uniquement ce type
            typesToFetch = [filter]
        } else {
            // Sinon, récupérer tous les types activés
            typesToFetch = selectedServiceTypes
        
        // Récupérer les services de tous les repositories concernés
        // Utilisation de requêtes séquentielles avec délai pour éviter le rate limiting
        var allServices: [ServicePoint] = []
        
        for repository in repositories where typesToFetch.contains(repository.serviceType) && repository.isEnabled {
            do {
                // Délai de 500ms entre chaque requête pour éviter le rate limiting (429)
                if !allServices.isEmpty {
                    try await Task.sleep(for: .milliseconds(500))
                }
                
                let results = try await repository.fetchNearbyServices(
                    around: coordinate,
                    radius: self.searchRadius
                )
                allServices.append(contentsOf: results)
            } catch {
                // En cas d'erreur, continuer avec les autres services
                print("⚠️ Erreur lors de la récupération de \(repository.serviceType.rawValue): \(error)")
            }
        }
        
        // Convertir en modèles UI et trier par distance
        services = allServices.map { ServicePointUI(from: $0) }
            .sorted { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
        
        // Limiter aux 10 services les plus proches
        // Si un filtre est actif, ce sont les 10 plus proches de CE type
        // Sinon, ce sont les 10 plus proches tous types confondus
        if services.count > 10 {
            services = Array(services.prefix(10))
        }
        
        isLoading = false
    }
    
    /// Active le filtre pour un type de service spécifique
    func filterByServiceType(_ type: ServiceType?) {
        serviceTypeFilter = type
    }
    
    /// Ajoute un repository personnalisé
    func addRepository(_ repository: ServiceRepository) {
        repositories.append(repository)
    }
    
    /// Retire un repository par type de service
    func removeRepository(ofType type: ServiceType) {
        repositories.removeAll { $0.serviceType == type }
    }
}
