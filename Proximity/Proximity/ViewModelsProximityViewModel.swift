//
//  ProximityViewModel.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation
import SwiftUI

@MainActor
class ProximityViewModel: ObservableObject {
    @Published var services: [any ServicePoint] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedServiceTypes: Set<ServiceType> = []
    @Published var searchRadius: Double = 2.0 // km
    
    private var providers: [ServiceProvider] = []
    let locationManager = LocationManager()
    
    init() {
        setupProviders()
    }
    
    private func setupProviders() {
        providers = [
            VelibServiceProvider(
                apiKey: APIConfiguration.jcdecauxAPIKey,
                contractName: APIConfiguration.jcdecauxContract
            ),
            ChargingStationProvider(),
            PublicToiletProvider(),
            PharmacyProvider()
        ]
        
        // Activer Velib et Charging par défaut
        selectedServiceTypes = [.velib, .chargingStation]
    }
    
    func toggleServiceType(_ type: ServiceType) {
        if selectedServiceTypes.contains(type) {
            selectedServiceTypes.remove(type)
        } else {
            selectedServiceTypes.insert(type)
        }
    }
    
    func fetchNearbyServices() async {
        guard let location = locationManager.location else {
            errorMessage = "Localisation non disponible"
            return
        }
        
        isLoading = true
        errorMessage = nil
        services = []
        
        let coordinate = location.coordinate
        
        // Récupérer les services de tous les providers activés
        await withTaskGroup(of: Result<[any ServicePoint], Error>.self) { group in
            for provider in providers where selectedServiceTypes.contains(provider.serviceType) && provider.isEnabled {
                group.addTask {
                    do {
                        let results = try await provider.fetchNearbyServices(
                            around: coordinate,
                            radius: self.searchRadius
                        )
                        return .success(results)
                    } catch {
                        return .failure(error)
                    }
                }
            }
            
            for await result in group {
                switch result {
                case .success(let servicePoints):
                    services.append(contentsOf: servicePoints)
                case .failure(let error):
                    print("Erreur lors de la récupération des services: \(error)")
                }
            }
        }
        
        // Trier par distance
        services.sort { ($0.distance ?? .infinity) < ($1.distance ?? .infinity) }
        
        isLoading = false
    }
    
    func addProvider(_ provider: ServiceProvider) {
        providers.append(provider)
    }
    
    func removeProvider(ofType type: ServiceType) {
        providers.removeAll { $0.serviceType == type }
    }
}
