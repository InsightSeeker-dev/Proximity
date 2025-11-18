//
//  ServicePoint.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import Foundation
import CoreLocation

/// Protocole de base pour tous les points de service
protocol ServicePoint: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var coordinate: CLLocationCoordinate2D { get }
    var address: String? { get }
    var serviceType: ServiceType { get }
    var distance: Double? { get set }
    var additionalInfo: [String: String] { get }
}

/// Types de services disponibles
enum ServiceType: String, CaseIterable {
    case velib = "Vélib'"
    case chargingStation = "Borne de recharge"
    case restaurant = "Restaurant"
    case toilet = "Toilettes"
    case pharmacy = "Pharmacie"
    case park = "Parc"
    case gasStation = "Station service"
    case carWash = "Station de lavage"
    case library = "Bibliothèque"
    
    var iconName: String {
        switch self {
        case .velib: return "bicycle"
        case .chargingStation: return "bolt.car"
        case .restaurant: return "fork.knife"
        case .toilet: return "toilet"
        case .pharmacy: return "cross.case"
        case .park: return "tree"
        case .gasStation: return "fuelpump"
        case .carWash: return "drop.triangle"
        case .library: return "book"
        }
    }
    
    var color: String {
        switch self {
        case .velib: return "green"
        case .chargingStation: return "blue"
        case .restaurant: return "orange"
        case .toilet: return "purple"
        case .pharmacy: return "red"
        case .park: return "green"
        case .gasStation: return "yellow"
        case .carWash: return "cyan"
        case .library: return "brown"
        }
    }
}
