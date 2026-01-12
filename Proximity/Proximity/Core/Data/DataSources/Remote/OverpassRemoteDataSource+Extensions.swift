//
//  OverpassRemoteDataSource+Extensions.swift
//  Proximity
//
//  Extensions pour tous les nouveaux services
//

import Foundation
import CoreLocation

// MARK: - Fetch Methods for New Services

extension OverpassRemoteDataSource {
    
    // MARK: - Restaurants
    func fetchRestaurants(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="restaurant"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="restaurant"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Fast Food
    func fetchFastFood(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="fast_food"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="fast_food"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Bars
    func fetchBars(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="bar"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="bar"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["amenity"="pub"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="pub"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Hotels
    func fetchHotels(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["tourism"="hotel"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["tourism"="hotel"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Hospitals
    func fetchHospitals(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="hospital"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="hospital"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["amenity"="clinic"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="clinic"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Shopping Centers
    func fetchShoppingCenters(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["shop"="mall"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["shop"="mall"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["shop"="department_store"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["shop"="department_store"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Parks
    func fetchParks(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["leisure"="park"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["leisure"="park"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Gas Stations
    func fetchGasStations(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="fuel"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="fuel"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Car Washes
    func fetchCarWashes(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="car_wash"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="car_wash"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Libraries
    func fetchLibraries(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="library"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="library"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - ATMs
    func fetchATMs(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="atm"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Post Offices
    func fetchPostOffices(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="post_office"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="post_office"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Bakeries
    func fetchBakeries(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["shop"="bakery"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["shop"="bakery"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Cinemas
    func fetchCinemas(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["amenity"="cinema"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["amenity"="cinema"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Gyms
    func fetchGyms(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["leisure"="fitness_centre"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["leisure"="fitness_centre"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["leisure"="sports_centre"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["leisure"="sports_centre"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Bus Stops
    func fetchBusStops(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["highway"="bus_stop"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["public_transport"="platform"]["bus"="yes"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
    
    // MARK: - Metro Stations
    func fetchMetroStations(around location: CLLocationCoordinate2D, radius: Double) async throws -> [OverpassElement] {
        let radiusMeters = Int(radius * 1000)
        let query = """
        [out:json][timeout:40];
        (
          node["railway"="station"]["station"="subway"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          way["railway"="station"]["station"="subway"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
          node["public_transport"="station"]["subway"="yes"](around:\(radiusMeters),\(location.latitude),\(location.longitude));
        );
        out center 50;
        """
        return try await executeQuery(query)
    }
}
