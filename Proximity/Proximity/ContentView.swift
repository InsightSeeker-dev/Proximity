//
//  ContentView.swift
//  Proximity
//
//  Created by etudiant on 18/11/2025.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ProximityViewModel()
    @State private var showServiceSelector = false
    @State private var selectedService: (any ServicePoint)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Carte en arrière-plan
                MapView(
                    services: viewModel.services,
                    userLocation: viewModel.locationManager.location,
                    selectedService: $selectedService
                )
                .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    // Liste des services
                    ServiceListView(
                        services: viewModel.services,
                        isLoading: viewModel.isLoading,
                        selectedService: $selectedService
                    )
                    .frame(maxHeight: 300)
                }
            }
            .navigationTitle("Proximity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showServiceSelector.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.fetchNearbyServices()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .sheet(isPresented: $showServiceSelector) {
                ServiceSelectorView(viewModel: viewModel)
            }
            .task {
                viewModel.locationManager.requestPermission()
                viewModel.locationManager.startUpdatingLocation()
                
                // Attendre un peu pour obtenir la localisation
                try? await Task.sleep(for: .seconds(2))
                await viewModel.fetchNearbyServices()
            }
            .alert("Erreur", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
