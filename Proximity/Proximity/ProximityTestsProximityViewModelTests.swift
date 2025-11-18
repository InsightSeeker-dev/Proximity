//
//  ProximityViewModelTests.swift
//  ProximityTests
//
//  Created by etudiant on 18/11/2025.
//

import Testing
import CoreLocation
@testable import Proximity

@Suite("Tests du ProximityViewModel")
@MainActor
struct ProximityViewModelTests {
    
    @Test("Le ViewModel s'initialise correctement")
    func testInitialization() async throws {
        let viewModel = ProximityViewModel()
        
        #expect(viewModel.services.isEmpty, "Les services devraient être vides au départ")
        #expect(!viewModel.isLoading, "Pas de chargement au départ")
        #expect(viewModel.errorMessage == nil, "Pas d'erreur au départ")
        #expect(!viewModel.selectedServiceTypes.isEmpty, "Des types de services devraient être sélectionnés par défaut")
        #expect(viewModel.searchRadius == 2.0, "Le rayon par défaut devrait être 2 km")
    }
    
    @Test("Toggle d'un type de service")
    func testToggleServiceType() async throws {
        let viewModel = ProximityViewModel()
        let initialCount = viewModel.selectedServiceTypes.count
        
        // Ajouter un service non sélectionné
        let newType = ServiceType.toilet
        if !viewModel.selectedServiceTypes.contains(newType) {
            viewModel.toggleServiceType(newType)
            #expect(viewModel.selectedServiceTypes.contains(newType), "Le service devrait être ajouté")
            #expect(viewModel.selectedServiceTypes.count == initialCount + 1, "Le compte devrait augmenter")
            
            // Retirer le service
            viewModel.toggleServiceType(newType)
            #expect(!viewModel.selectedServiceTypes.contains(newType), "Le service devrait être retiré")
            #expect(viewModel.selectedServiceTypes.count == initialCount, "Le compte devrait revenir à l'initial")
        }
    }
    
    @Test("Modification du rayon de recherche")
    func testSearchRadiusChange() async throws {
        let viewModel = ProximityViewModel()
        
        viewModel.searchRadius = 5.0
        #expect(viewModel.searchRadius == 5.0, "Le rayon devrait être mis à jour")
    }
}

@Suite("Tests des ServiceTypes")
struct ServiceTypeTests {
    
    @Test("Tous les types de services ont une icône")
    func testAllServicesHaveIcon() {
        for serviceType in ServiceType.allCases {
            #expect(!serviceType.iconName.isEmpty, "Le service \(serviceType.rawValue) devrait avoir une icône")
        }
    }
    
    @Test("Tous les types de services ont une couleur")
    func testAllServicesHaveColor() {
        for serviceType in ServiceType.allCases {
            #expect(!serviceType.color.isEmpty, "Le service \(serviceType.rawValue) devrait avoir une couleur")
        }
    }
    
    @Test("Les noms de services sont en français")
    func testServiceNamesInFrench() {
        let serviceNames = ServiceType.allCases.map { $0.rawValue }
        
        // Vérifier que certains noms attendus sont présents
        #expect(serviceNames.contains("Vélib'"), "Vélib' devrait être présent")
        #expect(serviceNames.contains("Borne de recharge"), "Les bornes de recharge devraient être présentes")
        #expect(serviceNames.contains("Pharmacie"), "Les pharmacies devraient être présentes")
    }
}

@Suite("Tests des modèles ServicePoint")
struct ServicePointTests {
    
    @Test("VelibStation respecte ServicePoint")
    func testVelibStationConformance() {
        let station = VelibStation(
            id: "test-1",
            name: "Test Station",
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            address: "Paris",
            availableBikes: 5,
            availableStands: 10,
            totalStands: 15,
            status: "OPEN"
        )
        
        #expect(station.id == "test-1")
        #expect(station.name == "Test Station")
        #expect(station.serviceType == .velib)
        #expect(station.availableBikes == 5)
        #expect(!station.additionalInfo.isEmpty, "Les infos additionnelles devraient être présentes")
    }
    
    @Test("ChargingStation respecte ServicePoint")
    func testChargingStationConformance() {
        let station = ChargingStation(
            id: "charge-1",
            name: "Borne Test",
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            address: "Paris",
            operatorName: "TestOp",
            power: "22 kW",
            availablePlugs: "Type 2",
            accessType: "Public"
        )
        
        #expect(station.id == "charge-1")
        #expect(station.serviceType == .chargingStation)
        #expect(station.operatorName == "TestOp")
        #expect(station.power == "22 kW")
    }
    
    @Test("Les ServicePoints sont Hashable")
    func testServicePointHashable() {
        let station1 = VelibStation(
            id: "1",
            name: "Station 1",
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            address: nil,
            availableBikes: 0,
            availableStands: 0,
            totalStands: 0,
            status: "OPEN"
        )
        
        let station2 = VelibStation(
            id: "1",
            name: "Station 1",
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            address: nil,
            availableBikes: 0,
            availableStands: 0,
            totalStands: 0,
            status: "OPEN"
        )
        
        #expect(station1 == station2, "Deux stations avec le même ID devraient être égales")
    }
}

@Suite("Tests utilitaires de distance")
struct DistanceTests {
    
    @Test("Calcul de distance entre deux points")
    func testDistanceCalculation() {
        // Paris - Tour Eiffel
        let eiffelTower = CLLocation(latitude: 48.8584, longitude: 2.2945)
        
        // Paris - Notre-Dame
        let notreDame = CLLocation(latitude: 48.8530, longitude: 2.3499)
        
        let distance = eiffelTower.distance(from: notreDame)
        
        // La distance devrait être d'environ 4 km
        #expect(distance > 3000 && distance < 5000, "La distance devrait être d'environ 4 km")
    }
}
