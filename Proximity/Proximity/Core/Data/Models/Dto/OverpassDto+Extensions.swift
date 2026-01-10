//
//  OverpassDto+Extensions.swift
//  Proximity
//
//  Extensions pour tous les nouveaux services
//

import Foundation
import CoreLocation

// MARK: - Helper Methods

extension OverpassElement {
    /// Construit une adresse à partir des tags
    private func buildAddress() -> String? {
        let street = tags?["addr:street"]
        let houseNumber = tags?["addr:housenumber"]
        
        if let street = street {
            return houseNumber != nil ? "\(houseNumber!) \(street)" : street
        }
        return nil
    }
    
    /// Extrait les coordonnées
    private func getCoordinate() -> CLLocationCoordinate2D? {
        guard let latitude = lat ?? center?.lat,
              let longitude = lon ?? center?.lon else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Calcule la distance
    private func calculateDistance(from userLocation: CLLocation, to coordinate: CLLocationCoordinate2D) -> Double {
        let elementLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: elementLocation)
    }
}

// MARK: - Restaurant

extension OverpassElement {
    func toRestaurantDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Restaurant"
        
        var additionalInfo: [String: String] = [:]
        if let cuisine = tags?["cuisine"] {
            additionalInfo["Cuisine"] = cuisine
        }
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let outdoor = tags?["outdoor_seating"] {
            additionalInfo["Terrasse"] = outdoor == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .restaurant,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Fast Food

extension OverpassElement {
    func toFastFoodDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Fast-food"
        
        var additionalInfo: [String: String] = [:]
        if let cuisine = tags?["cuisine"] {
            additionalInfo["Type"] = cuisine
        }
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let drive = tags?["drive_through"] {
            additionalInfo["Drive"] = drive == "yes" ? "Oui" : "Non"
        }
        if let takeaway = tags?["takeaway"] {
            additionalInfo["À emporter"] = takeaway == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .fastFood,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Bar

extension OverpassElement {
    func toBarDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Bar"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let outdoor = tags?["outdoor_seating"] {
            additionalInfo["Terrasse"] = outdoor == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .bar,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Hotel

extension OverpassElement {
    func toHotelDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Hôtel"
        
        var additionalInfo: [String: String] = [:]
        if let stars = tags?["stars"] {
            additionalInfo["Étoiles"] = stars
        }
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let website = tags?["website"] {
            additionalInfo["Site web"] = website
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let internet = tags?["internet_access"] {
            additionalInfo["WiFi"] = internet == "yes" || internet == "wlan" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .hotel,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Hospital

extension OverpassElement {
    func toHospitalDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Hôpital"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let emergency = tags?["emergency"] {
            additionalInfo["Urgences"] = emergency == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let operator_ = tags?["operator"] {
            additionalInfo["Opérateur"] = operator_
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .hospital,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Shopping Center

extension OverpassElement {
    func toShoppingCenterDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Centre commercial"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let website = tags?["website"] {
            additionalInfo["Site web"] = website
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .shoppingCenter,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Park

extension OverpassElement {
    func toParkDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Parc"
        
        var additionalInfo: [String: String] = [:]
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let dog = tags?["dog"] {
            additionalInfo["Chiens autorisés"] = dog == "yes" ? "Oui" : "Non"
        }
        if let playground = tags?["playground"] {
            additionalInfo["Aire de jeux"] = playground == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .park,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Gas Station

extension OverpassElement {
    func toGasStationDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? tags?["brand"] ?? "Station-service"
        
        var additionalInfo: [String: String] = [:]
        if let brand = tags?["brand"] {
            additionalInfo["Marque"] = brand
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        
        var fuels: [String] = []
        if tags?["fuel:diesel"] == "yes" { fuels.append("Diesel") }
        if tags?["fuel:octane_95"] == "yes" { fuels.append("SP95") }
        if tags?["fuel:octane_98"] == "yes" { fuels.append("SP98") }
        if tags?["fuel:e10"] == "yes" { fuels.append("E10") }
        if tags?["fuel:lpg"] == "yes" { fuels.append("GPL") }
        if !fuels.isEmpty {
            additionalInfo["Carburants"] = fuels.joined(separator: ", ")
        }
        
        if let selfService = tags?["self_service"] {
            additionalInfo["Libre-service"] = selfService == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .gasStation,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Car Wash

extension OverpassElement {
    func toCarWashDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Station de lavage"
        
        var additionalInfo: [String: String] = [:]
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let selfService = tags?["self_service"] {
            additionalInfo["Libre-service"] = selfService == "yes" ? "Oui" : "Non"
        }
        if let automated = tags?["automated"] {
            additionalInfo["Automatique"] = automated == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .carWash,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Library

extension OverpassElement {
    func toLibraryDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Bibliothèque"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let website = tags?["website"] {
            additionalInfo["Site web"] = website
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let internet = tags?["internet_access"] {
            additionalInfo["WiFi"] = internet == "yes" || internet == "wlan" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .library,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - ATM

extension OverpassElement {
    func toATMDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let operator_ = tags?["operator"] ?? "Distributeur"
        let name = "DAB \(operator_)"
        
        var additionalInfo: [String: String] = [:]
        if let operator_ = tags?["operator"] {
            additionalInfo["Banque"] = operator_
        }
        if let network = tags?["network"] {
            additionalInfo["Réseau"] = network
        }
        if let indoor = tags?["indoor"] {
            additionalInfo["Intérieur"] = indoor == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .atm,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Post Office

extension OverpassElement {
    func toPostOfficeDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Bureau de poste"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let atm = tags?["atm"] {
            additionalInfo["Distributeur"] = atm == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .postOffice,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Bakery

extension OverpassElement {
    func toBakeryDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Boulangerie"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let organic = tags?["organic"] {
            additionalInfo["Bio"] = organic == "yes" ? "Oui" : "Non"
        }
        if let craft = tags?["craft"] {
            additionalInfo["Artisanale"] = craft == "bakery" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .bakery,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Cinema

extension OverpassElement {
    func toCinemaDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Cinéma"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let website = tags?["website"] {
            additionalInfo["Site web"] = website
        }
        if let screens = tags?["screens"] {
            additionalInfo["Salles"] = screens
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let threeD = tags?["3d"] {
            additionalInfo["3D"] = threeD == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .cinema,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Gym

extension OverpassElement {
    func toGymDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Salle de sport"
        
        var additionalInfo: [String: String] = [:]
        if let phone = tags?["phone"] {
            additionalInfo["Téléphone"] = phone
        }
        if let website = tags?["website"] {
            additionalInfo["Site web"] = website
        }
        if let hours = tags?["opening_hours"] {
            additionalInfo["Horaires"] = hours
        }
        if let sport = tags?["sport"] {
            additionalInfo["Sports"] = sport
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .gym,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Bus Stop

extension OverpassElement {
    func toBusStopDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Arrêt de bus"
        
        var additionalInfo: [String: String] = [:]
        if let ref = tags?["ref"] {
            additionalInfo["Lignes"] = ref
        }
        if let network = tags?["network"] {
            additionalInfo["Réseau"] = network
        }
        if let operator_ = tags?["operator"] {
            additionalInfo["Opérateur"] = operator_
        }
        if let shelter = tags?["shelter"] {
            additionalInfo["Abribus"] = shelter == "yes" ? "Oui" : "Non"
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .busStop,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}

// MARK: - Metro Station

extension OverpassElement {
    func toMetroStationDomain(userLocation: CLLocation) -> ServicePoint? {
        guard let coordinate = getCoordinate() else { return nil }
        let distance = calculateDistance(from: userLocation, to: coordinate)
        let name = tags?["name"] ?? "Station de métro"
        
        var additionalInfo: [String: String] = [:]
        if let ref = tags?["ref"] {
            additionalInfo["Lignes"] = ref
        }
        if let network = tags?["network"] {
            additionalInfo["Réseau"] = network
        }
        if let operator_ = tags?["operator"] {
            additionalInfo["Opérateur"] = operator_
        }
        if let wheelchair = tags?["wheelchair"] {
            additionalInfo["Accessible PMR"] = wheelchair == "yes" ? "Oui" : "Non"
        }
        if let toilets = tags?["toilets"] {
            additionalInfo["Toilettes"] = toilets == "yes" ? "Oui" : "Non"
        }
        
        return ServicePoint(
            id: "\(id)",
            name: name,
            coordinate: coordinate,
            address: buildAddress(),
            serviceType: .metroStation,
            distance: distance,
            additionalInfo: additionalInfo
        )
    }
}
