//
//  ServiceListView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//  Refactored to use ServicePointUI
//

import SwiftUI

struct ServiceListView: View {
    let services: [ServicePointUI]
    let isLoading: Bool
    @Binding var selectedService: ServicePointUI?
    @State private var showingDetail = false
    @State private var detailService: ServicePointUI?
    
    var body: some View {
        VStack(spacing: 0) {
            // En-tête
            HStack {
                Text("Services à proximité")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(services.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.secondary.opacity(0.2))
                    )
            }
            .padding()
            .background(.ultraThinMaterial)
            
            if isLoading {
                VStack {
                    ProgressView()
                        .padding()
                    Text("Recherche en cours...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            } else if services.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "mappin.slash")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("Aucun service trouvé")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Text("Essayez d'augmenter le rayon de recherche")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.regularMaterial)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(services) { service in
                            ServiceRowView(service: service)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedService = service
                                    detailService = service
                                    showingDetail = true
                                }
                            
                            if service.id != services.last?.id {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                }
                .background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 10)
        .padding()
        .sheet(isPresented: $showingDetail) {
            if let service = detailService {
                ServiceDetailView(service: service)
            }
        }
    }
}

struct ServiceRowView: View {
    let service: ServicePointUI
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône du service
            Image(systemName: service.iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(service.color)
                )
            
            // Informations
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(service.displayAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // Informations supplémentaires
                if let firstInfo = service.firstAdditionalInfo {
                    Text(firstInfo)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Distance
            VStack(alignment: .trailing, spacing: 2) {
                Text(service.formattedDistance)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(service.serviceType.rawValue)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    @Previewable @State var selectedService: ServicePointUI? = nil
    
    ServiceListView(
        services: [],
        isLoading: false,
        selectedService: $selectedService
    )
}
