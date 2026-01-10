//
//  ServicePointUI.swift
//  Proximity
//
//  UI Model - Modèle spécifique à l'interface utilisateur
//

import Foundation
import SwiftUI
import CoreLocation

/// Modèle UI pour l'affichage des points de service
/// Contient des propriétés calculées pour faciliter l'affichage dans SwiftUI
struct ServicePointUI: Identifiable, Hashable {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    let serviceType: ServiceType
    let distance: Double?
    let additionalInfo: [String: String]
    
    // MARK: - UI Properties
    
    /// Icône SF Symbol pour ce service
    var iconName: String {
        serviceType.iconName
    }
    
    /// Couleur associée au type de service
    var color: Color {
        colorForServiceType(serviceType)
    }
    
    /// Distance formatée pour l'affichage
    var formattedDistance: String {
        guard let distance = distance else { return "—" }
        
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
        }
    }
    
    /// Adresse formatée ou message par défaut
    var displayAddress: String {
        address ?? "Adresse non disponible"
    }
    
    /// Première information additionnelle (pour affichage compact)
    var firstAdditionalInfo: String? {
        guard let first = additionalInfo.first else { return nil }
        return "\(first.key): \(first.value)"
    }
    
    // MARK: - Initializers
    
    /// Initialise depuis un modèle du domaine
    init(from servicePoint: ServicePoint) {
        self.id = servicePoint.id
        self.name = servicePoint.name
        self.coordinate = servicePoint.coordinate
        self.address = servicePoint.address
        self.serviceType = servicePoint.serviceType
        self.distance = servicePoint.distance
        self.additionalInfo = servicePoint.additionalInfo
    }
    
    // MARK: - Hashable
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ServicePointUI, rhs: ServicePointUI) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Helper Methods
    
    private func colorForServiceType(_ type: ServiceType) -> Color {
        switch type.color {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "brown": return .brown
        default: return .gray
        }
    }
}
