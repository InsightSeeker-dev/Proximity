//
//  ServiceSelectorView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import SwiftUI

struct ServiceSelectorView: View {
    @ObservedObject var viewModel: ProximityViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(ServiceType.allCases, id: \.self) { type in
                        ServiceTypeRow(
                            serviceType: type,
                            isSelected: viewModel.selectedServiceTypes.contains(type)
                        ) {
                            viewModel.toggleServiceType(type)
                        }
                    }
                } header: {
                    Text("Types de services")
                } footer: {
                    Text("Sélectionnez les types de services que vous souhaitez afficher sur la carte.")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Rayon de recherche")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(String(format: "%.1f", viewModel.searchRadius)) km")
                                .foregroundStyle(.secondary)
                        }
                        
                        Slider(value: $viewModel.searchRadius, in: 0.5...10, step: 0.5)
                        
                        HStack {
                            Text("500 m")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Text("10 km")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Paramètres")
                }
                
                Section {
                    Button {
                        Task {
                            await viewModel.fetchNearbyServices()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text("Rechercher")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(viewModel.selectedServiceTypes.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Filtres")
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
}

struct ServiceTypeRow: View {
    let serviceType: ServiceType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icône
                Image(systemName: serviceType.iconName)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(colorForService(serviceType))
                    )
                
                // Nom
                Text(serviceType.rawValue)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(colorForService(serviceType))
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
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
    ServiceSelectorView(viewModel: ProximityViewModel())
}
