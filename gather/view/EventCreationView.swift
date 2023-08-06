import SwiftUI
import Combine
import MapKit

struct EventCreationView: View {
    @State private var showAlert = false
    @State private var success = false
    @State private var errorMessage: String = "Failed to create event."
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    
    @State private var eventType: EventType = EventType.musical
    @State private var musicalEventCategory: MusicalCategory = MusicalCategory.concert
    @State private var natureEventCategory: NatureCategory = NatureCategory.camp
    @State private var sportEventCategory: SportCategory = SportCategory.basketball
    @State private var stagePlayEventCategory: StagePlayCategory = StagePlayCategory.standUp
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var capacity: Int = 100
    @State private var showCapacity: Bool = false
    @State private var price: Double = 100
    @State private var showPrice: Bool = false
    @State private var isPrivate: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var artist: String = ""
    @State private var latitude: CLLocationDegrees = 41.015137
    @State private var longitude: CLLocationDegrees = 28.979530
    private var cancellables = Set<AnyCancellable>()
    
    private let eventClient = EventClient()
    
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            NavigationView {
                List {
                    Section(header: Text("Event Type")) {
                        Picker("Event Type", selection: $eventType) {
                            ForEach(EventType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    if eventType == .musical {
                        Section(header: Text("Musical Event Details")) {
                            Picker("Category", selection: $musicalEventCategory) {
                                ForEach(MusicalCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category.rawValue)
                                }
                            }
                        }
                        
                        Section {
                            TextField("Artist", text: $artist)
                                .onChange(of: artist) { newValue in
                                    // Handle artist value change
                                }
                        }
                    } else if eventType == .nature {
                        Section(header: Text("Nature Event Details")) {
                            Picker("Category", selection: $natureEventCategory) {
                                ForEach(NatureCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category.rawValue)
                                }
                            }
                        }
                    } else if eventType == .sport {
                        Section(header: Text("Sport Event Details")) {
                            Picker("Category", selection: $sportEventCategory) {
                                ForEach(SportCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category.rawValue)
                                }
                            }
                        }
                    } else if eventType == .stagePlay {
                        Section(header: Text("Stage Play Event Details")) {
                            Picker("Category", selection: $stagePlayEventCategory) {
                                ForEach(StagePlayCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category.rawValue)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Event Information")) {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description)
                        
                        Toggle("Private", isOn: $isPrivate)
                        
                        Toggle("Capacity", isOn: $showCapacity.animation())
                        
                        if showCapacity {
                            TextField("Capacity", value: $capacity, formatter: NumberFormatter())
                        }
                        
                        Toggle("Price", isOn: $showPrice.animation())
                        
                        if showPrice {
                            TextField("Price", value: $price, formatter: NumberFormatter())
                        }
                    }
                    
                    Section(header: Text("Event Dates")) {
                        DatePicker("Start Date", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("End Date", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                    }
                    
                    Section(header: Text("Location")) {
                        MapView2(latitude: $latitude, longitude: $longitude)
                            .frame(height: 200)
                    }
                    
                    Section {
                        Button("Create Event") {
                            sendRequest(currentUserId: currentUserId)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .navigationTitle("Create Event")
                .alert(isPresented: $showAlert) {
                    if success {
                        return Alert(
                            title: Text("Success"),
                            message: Text("Event created successfully"),
                            dismissButton: .default(Text("OK"), action: {
                                presentationMode.wrappedValue.dismiss()
                            })
                        )
                    } else {
                        return Alert(
                            title: Text("Failure"),
                            message: Text(errorMessage),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
            }
        }else{
            ProgressView()
                .onAppear {
                    isShowingAlert = true
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Session Expired"),
                        message: Text("Your session has expired. Please login again."),
                        primaryButton: .default(Text("OK")) {
                            navigateToAuthView()
                        },
                        secondaryButton: .cancel()
                    )
                }
        }
    }
    func sendRequest(currentUserId: Int) {
        let timeZone = TimeZone(identifier: "UTC")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = timeZone
        let event = EventCreationModel(
            eventType: eventType,
            title: title,
            description: description,
            capacity: showCapacity ? capacity : nil,
            price: showPrice ? price : nil,
            isPrivate: isPrivate,
            category: getCategory(),
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            locationModel: getLocation(),
            artist: artist
        )
        eventClient.createEvent(userId: currentUserId, body: event)
            .sink { completion in
                switch completion {
                case .finished:
                    showAlert = true
                    success = true
                case .failure(let error):
                    showAlert = true
                    success = false
                    errorMessage = error.localizedDescription
                }
            } receiveValue: { response in
            }
            .store(in: &eventClient.cancellables)
    }
    func getLocation() -> LocationModel{
        return LocationModel(latitude: latitude, longitude: longitude)
    }
    func getCategory() -> String {
        if eventType == .musical{
            return musicalEventCategory.rawValue
        } else if eventType == .sport{
            return sportEventCategory.rawValue
        } else if eventType == .nature{
            return natureEventCategory.rawValue
        } else if eventType == .stagePlay{
            return stagePlayEventCategory.rawValue
        }else{
            return ""
        }
    }
    
    func showSuccessNotification() -> some View {
        VStack {
            Text("Event Created")
                .font(.title)
                .padding()
            
            Text("The event has been successfully created.")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }
}

struct MapView2: UIViewRepresentable {
    @Binding var latitude: CLLocationDegrees
    @Binding var longitude: CLLocationDegrees
    
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        
        // Set initial region
        let initialCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        // Add gesture recognizer for placing pin
        let gestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        mapView.addGestureRecognizer(gestureRecognizer)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        if let coordinate = selectedCoordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            view.removeAnnotations(view.annotations)
            view.addAnnotation(annotation)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView2
        
        init(_ parent: MapView2) {
            self.parent = parent
        }
        
        @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            parent.latitude = coordinate.latitude
            parent.longitude = coordinate.longitude
            parent.selectedCoordinate = coordinate
        }
    }
}

struct EventCreationView_Previews: PreviewProvider {
    static var previews: some View {
        EventCreationView()
    }
}
