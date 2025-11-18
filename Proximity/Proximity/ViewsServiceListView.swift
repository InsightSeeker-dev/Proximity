//
//  ServiceListView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import SwiftUI

struct ServiceListView: View {
    let services: [any ServicePoint]
    let isLoading: Bool
    @Binding var selectedService: (any ServicePoint)?
    @State private var showingDetail = false
    @State private var detailService: (any ServicePoint)?
    
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
                        ForEach(services.indices, id: \.self) { index in
                            ServiceRowView(service: services[index])
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedService = services[index]
                                    detailService = services[index]
                                    showingDetail = true
                                }
                            
                            if index < services.count - 1 {
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
    let service: any ServicePoint
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône du service
            Image(systemName: service.serviceType.iconName)
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(colorForService(service.serviceType))
                )
            
            // Informations
            VStack(alignment: .leading, spacing: 4) {
                Text(service.name)
                    .font(.headline)
                    .lineLimit(1)
                
                if let address = service.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                // Informations supplémentaires
                if let firstInfo = service.additionalInfo.first {
                    Text("\(firstInfo.key): \(firstInfo.value)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Distance
            if let distance = service.distance {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatDistance(distance))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(service.serviceType.rawValue)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func formatDistance(_ distance: Double) -> String {
        if distance < 1000 {
            return "\(Int(distance)) m"
        } else {
            return String(format: "%.1f km", distance / 1000)
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

#Preview {
    @Previewable @State var selectedService: (any ServicePoint)? = nil
    
    ServiceListView(
        services: [],
        isLoading: false,
        selectedService: $selectedService
    )
}
