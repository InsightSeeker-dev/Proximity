//
//  ServicePoint.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//  Refactored: Domain Model (ModelData)
//

import Foundation
import CoreLocation

// MARK: - Domain Models

/// Modèle du domaine représentant un point de service
/// Ce modèle est agnostique de la source de données (API, DB, etc.)
struct ServicePoint: Identifiable, Hashable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType
    var distance: Double?
    let additionalInfo: [String: String]
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ServicePoint, rhs: ServicePoint) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Service Types

/// Types de services disponibles dans l'application
enum ServiceType: String, CaseIterable, Codable {
    // Services existants
    case chargingStation = "Borne de recharge"
    case toilet = "Toilettes"
    case pharmacy = "Pharmacie"
    
    // Services essentiels
    case restaurant = "Restaurant"
    case fastFood = "Fast-food"
    case bar = "Bar"
    case hotel = "Hôtel"
    case hospital = "Hôpital"
    case shoppingCenter = "Centre commercial"
    case park = "Parc"
    case gasStation = "Station service"
    case carWash = "Station de lavage"
    case library = "Bibliothèque"
    
    // Services complémentaires
    case atm = "Distributeur"
    case postOffice = "Bureau de poste"
    case bakery = "Boulangerie"
    case cinema = "Cinéma"
    case gym = "Salle de sport"
    case busStop = "Arrêt de bus"
    case metroStation = "Station de métro"
    
    var iconName: String {
        switch self {
        case .chargingStation: return "bolt.car"
        case .restaurant: return "fork.knife"
        case .fastFood: return "cart.fill"
        case .bar: return "wineglass.fill"
        case .hotel: return "bed.double.fill"
        case .hospital: return "cross.case.fill"
        case .shoppingCenter: return "bag.fill"
        case .toilet: return "toilet"
        case .pharmacy: return "cross.case"
        case .park: return "tree.fill"
        case .gasStation: return "fuelpump.fill"
        case .carWash: return "drop.triangle.fill"
        case .library: return "book.fill"
        case .atm: return "banknote.fill"
        case .postOffice: return "envelope.fill"
        case .bakery: return "birthday.cake.fill"
        case .cinema: return "film.fill"
        case .gym: return "figure.run"
        case .busStop: return "bus.fill"
        case .metroStation: return "tram.fill"
        }
    }
    
    var color: String {
        switch self {
        case .chargingStation: return "blue"
        case .restaurant: return "orange"
        case .fastFood: return "yellow"
        case .bar: return "indigo"
        case .hotel: return "purple"
        case .hospital: return "red"
        case .shoppingCenter: return "pink"
        case .toilet: return "purple"
        case .pharmacy: return "red"
        case .park: return "green"
        case .gasStation: return "yellow"
        case .carWash: return "cyan"
        case .library: return "brown"
        case .atm: return "green"
        case .postOffice: return "yellow"
        case .bakery: return "brown"
        case .cinema: return "purple"
        case .gym: return "orange"
        case .busStop: return "blue"
        case .metroStation: return "blue"
        }
    }
}

// MARK: - CLLocationCoordinate2D Hashable Extension

extension CLLocationCoordinate2D: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
