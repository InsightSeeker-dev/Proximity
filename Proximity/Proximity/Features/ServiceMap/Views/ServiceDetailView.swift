//
//  ServiceDetailView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//  Refactored to use ServicePointUI
//

import SwiftUI
import MapKit

struct ServiceDetailView: View {
    let service: ServicePointUI
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête avec icône et type
                    ServiceHeaderView(service: service)
                    
                    // Carte miniature
                    Map(position: .constant(.region(
                        MKCoordinateRegion(
                            center: service.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ))) {
                        Annotation(service.name, coordinate: service.coordinate) {
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
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(radius: 4)
                    .padding(.horizontal)
                    
                    // Informations principales
                    VStack(spacing: 12) {
                        // Nom
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.red)
                            Text(service.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                        }
                        
                        // Adresse
                        HStack(alignment: .top) {
                            Image(systemName: "location.fill")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(service.displayAddress)
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        
                        // Distance
                        HStack {
                            Image(systemName: "ruler")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text(service.formattedDistance)
                                .font(.body)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    // Informations supplémentaires
                    if !service.additionalInfo.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Informations supplémentaires")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            VStack(spacing: 8) {
                                ForEach(Array(service.additionalInfo.keys.sorted()), id: \.self) { key in
                                    if let value = service.additionalInfo[key] {
                                        HStack {
                                            Text(key)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                            Text(value)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                        }
                                        .padding(.horizontal)
                                        
                                        if key != service.additionalInfo.keys.sorted().last {
                                            Divider()
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                            .background(.regularMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal)
                        }
                    }
                    
                    // Actions
                    VStack(spacing: 12) {
                        // Ouvrir dans Plans
                        Button {
                            openInMaps()
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Ouvrir dans Plans")
                                Spacer()
                                Image(systemName: "arrow.up.right")
                            }
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Partager
                        ShareLink(
                            item: shareText,
                            subject: Text(service.name),
                            message: Text("J'ai trouvé ce service intéressant")
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Partager")
                                Spacer()
                            }
                            .padding()
                            .background(.gray.opacity(0.2))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Détails")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var shareText: String {
        var text = "\(service.name)\n"
        if let address = service.address {
            text += "\(address)\n"
        }
        text += "Type: \(service.serviceType.rawValue)\n"
        text += "Distance: \(service.formattedDistance)\n"
        text += "Coordonnées: \(service.coordinate.latitude), \(service.coordinate.longitude)"
        return text
    }
    
    private func openInMaps() {
        let placemark = MKPlacemark(coordinate: service.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = service.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

struct ServiceHeaderView: View {
    let service: ServicePointUI
    
    var body: some View {
        VStack(spacing: 12) {
            // Grande icône
            Image(systemName: service.iconName)
                .font(.system(size: 60))
                .foregroundStyle(.white)
                .frame(width: 120, height: 120)
                .background(
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    service.color,
                                    service.color.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing)
                        )
                        .shadow(radius: 10)
                )
            
            // Type de service
            Text(service.serviceType.rawValue)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
