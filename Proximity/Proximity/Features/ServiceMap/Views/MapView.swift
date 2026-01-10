//
//  MapView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//  Refactored to use ServicePointUI
//

import SwiftUI
import MapKit

struct MapView: View {
    let services: [ServicePointUI]
    let userLocation: CLLocation?
    @Binding var selectedService: ServicePointUI?
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition, selection: $selectedService) {
            // Position de l'utilisateur
            if let location = userLocation {
                Annotation("Ma position", coordinate: location.coordinate) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.3))
                            .frame(width: 32, height: 32)
                        Circle()
                            .fill(.blue)
                            .frame(width: 16, height: 16)
                    }
                }
                .tag("user" as String?)
            }
            
            // Points de service
            ForEach(services) { service in
                Annotation(service.name, coordinate: service.coordinate) {
                    ServiceAnnotationView(service: service)
                }
                .tag(service.id)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onChange(of: userLocation) { oldValue, newValue in
            if let location = newValue {
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: location.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
            }
        }
        .onChange(of: selectedService) { oldValue, newValue in
            if let service = newValue {
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: service.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    )
                }
            }
        }
    }
}

struct ServiceAnnotationView: View {
    let service: ServicePointUI
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: service.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(service.color)
                        .shadow(radius: 3)
                )
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundStyle(service.color)
                .offset(y: -5)
        }
    }
}
