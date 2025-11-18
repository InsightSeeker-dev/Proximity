//
//  MapView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import SwiftUI
import MapKit

struct MapView: View {
    let services: [any ServicePoint]
    let userLocation: CLLocation?
    @Binding var selectedService: (any ServicePoint)?
    
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
            ForEach(services.indices, id: \.self) { index in
                let service = services[index]
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
    let service: any ServicePoint
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: service.serviceType.iconName)
                .font(.title3)
                .foregroundStyle(.white)
                .padding(8)
                .background(
                    Circle()
                        .fill(colorForService(service.serviceType))
                        .shadow(radius: 3)
                )
            
            Image(systemName: "arrowtriangle.down.fill")
                .font(.caption)
                .foregroundStyle(colorForService(service.serviceType))
                .offset(y: -5)
        }
    }
    
    private func colorForService(_ type: ServiceType) -> Color {
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
