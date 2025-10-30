//
//  GenerableMapView.swift
//  AppleFoundationModels
//
//  Created by Učiteľ on 22/09/2025.

import SwiftUI
import MapKit
import FoundationModels

@Generable
struct LocationInfo: Equatable {
    var address: String
    var city: String
    var country: String
    var description: String
    var attractions: String
    var landmarks: String
    var transport: String
    var history: String
}

struct MapPin: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
}

struct MapGenerableView: View {
    @State private var userInput: String = ""
    @State private var partialLocation = LocationInfo(
        address: "", city: "", country: "", description: "",
        attractions: "", landmarks: "", transport: "", history: ""
    )
    @State private var isLoading: Bool = false
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 48.1486, longitude: 17.1077),
        span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
    )
    
    @State private var pins: [MapPin] = []
    @State private var session = LanguageModelSession()
    
    var body: some View {
        VStack {
            HStack {
                TextField("Enter address/city/country...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        Task {
                            await searchLocationGuided()
                        }
                    }

                Button("Search") {
                    Task {
                        await searchLocationGuided()
                    }
                }
                .padding(.trailing)
                .disabled(userInput.isEmpty || isLoading)
            }
            
            ZStack(alignment: .topTrailing) {
                Map(coordinateRegion: $region, annotationItems: pins) { pin in
                    MapMarker(coordinate: pin.coordinate, tint: .red)
                }
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Group {
                            if !partialLocation.address.isEmpty {
                                Text("🏷 Address")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.address)
                                    .transition(.opacity)
                            }
                            if !partialLocation.city.isEmpty {
                                Text("🌆 City")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.city)
                                    .transition(.opacity)
                            }
                            if !partialLocation.country.isEmpty {
                                Text("🌍 Country")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.country)
                                    .transition(.opacity)
                            }
                            if !partialLocation.description.isEmpty {
                                Text("💬 Description")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.description)
                                    .transition(.opacity)
                            }
                            if !partialLocation.attractions.isEmpty {
                                Text("🎡 Attractions")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.attractions)
                                    .transition(.opacity)
                            }
                            if !partialLocation.landmarks.isEmpty {
                                Text("🏛 Landmarks")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.landmarks)
                                    .transition(.opacity)
                            }
                            if !partialLocation.transport.isEmpty {
                                Text("🚌 Transport")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.transport)
                                    .transition(.opacity)
                            }
                            if !partialLocation.history.isEmpty {
                                Text("📜 History")
                                    .bold()
                                    .font(.title3)
                                    .transition(.opacity)
                                Text(partialLocation.history)
                                    .transition(.opacity)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .padding()
                    .frame(width: UIScreen.main.bounds.size.width * 0.35, alignment: .topLeading)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .padding()
                    .animation(.easeInOut(duration: 0.25), value: partialLocation)
                }
            }
        }
    }
    
    func searchLocationGuided() async {
        guard !userInput.isEmpty else { return }
        isLoading = true
        partialLocation = LocationInfo(
            address: "", city: "", country: "", description: "",
            attractions: "", landmarks: "", transport: "", history: ""
        )
        pins = []
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(userInput) { placemarks, error in
            if let coordinate = placemarks?.first?.location?.coordinate {
                let pin = MapPin(coordinate: coordinate, title: userInput)
                DispatchQueue.main.async {
                    region.center = coordinate
                    region.span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                    pins = [pin]
                }
            }
        }
        
        let prompt = """
        Generate structured information about the location "\(userInput)" including
        address, city, country, description, attractions, landmarks, transport, history.
        """
        
        do {
            let stream = session.streamResponse(to: prompt, generating: LocationInfo.self)
            
            for try await streamedContent in stream {
                await MainActor.run {
                    withAnimation {
                        let content = streamedContent.content
                        partialLocation.address = content.address ?? ""
                        partialLocation.city = content.city ?? ""
                        partialLocation.country = content.country ?? ""
                        partialLocation.description = content.description ?? ""
                        partialLocation.attractions = content.attractions ?? ""
                        partialLocation.landmarks = content.landmarks ?? ""
                        partialLocation.transport = content.transport ?? ""
                        partialLocation.history = content.history ?? ""
                    }
                }
            }
        } catch {
            print("❌ LLM error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}
