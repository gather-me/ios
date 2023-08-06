import SwiftUI
import MapKit
import Combine

struct EventDetailView: View {
    let eventId: Int
    let type: EventType
    @StateObject private var eventView = EventViewModel()
    @StateObject private var user = UserViewModel()
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    @State private var  price: String = "Free"
    @State private var  capacity: String = "No Limit"
    @State private var  startDate = Date.distantPast
    @State private var  endDate = Date.distantPast
    
    @State private var  isParticipant: Bool = true
    
    @State private var  isRequester: Bool = true
    
    @State private var  invitation: InvitationModel? = nil
    @State private var  isFull = true
    @State private var  isEnded = true
    
    @State private var  enrollmentButtonSetting: (String, Bool) = ("", true)
    
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image("concert")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    Text(eventView.event.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(eventView.event.description ?? "")
                        .font(.body)
                        .lineLimit(nil)
                        .multilineTextAlignment(.leading)
                    HStack {
                        Image(systemName: "waveform")
                            .foregroundColor(.gray)
                        Text(type.rawValue + " / " +  eventView.event.category)
                            .foregroundColor(.gray)
                        Spacer()
                        if(eventView.event.eventType == .musical){
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                            Text(eventView.event.artist!)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        NavigationLink(destination: ProfileView(userId: eventView.event.creator.id)) {
                            Image(systemName: "person.crop.circle.fill")
                                .foregroundColor(.gray)
                            Text(eventView.event.creator.username)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        Image(systemName: "person.3")
                            .foregroundColor(.gray)
                        Text(capacity)
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.gray)
                        Text(price)
                            .foregroundColor(.gray)
                        Spacer()
                        NavigationLink(destination: UserListView(title:"Participants", users: eventView.participants)) {
                            Image(systemName: "person.3.fill")
                                .foregroundColor(.gray)
                            Text("\(eventView.event.enrolled) Enrolled")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Image(systemName: eventView.event.isPrivate ? "lock.fill" : "globe")
                            .foregroundColor(.gray)
                        Text(eventView.event.isPrivate ? "Private" : "Public")
                            .foregroundColor(.gray)
                        
                        Spacer()
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text("\(shortDateFormatter.string(from: startDate))\n\(shortDateFormatter.string(from: endDate))")
                            .foregroundColor(.gray)
                    }
                    
                    MapView(locationCoordinate: CLLocationCoordinate2D(latitude: eventView.event.locationModel.latitude, longitude: eventView.event.locationModel.longitude))
                        .frame(height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    Spacer()
                    
                    if (currentUserId == eventView.event.creator.id){
                        NavigationLink(destination: SelectUserListView(title: "Invite", eventId: eventId, eventType: type)) {
                            Text("Invite")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        
                    } else if(invitation != nil){
                        VStack(alignment: .center){
                            Text("\(invitation?.event.creator.username ?? "") is invited you.")
                                .font(.headline)
                            HStack(alignment: .center){
                                Button(action: {responseInvitation(currentUserId: currentUserId, respond: true)}){
                                    Text("Accept")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.black)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: .infinity)
                                }
                                Button(action: {responseInvitation(currentUserId: currentUserId, respond: false)}){
                                    Text("Deny")
                                        .font(.headline)
                                        .padding()
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .frame(maxWidth: .infinity)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }else{
                        Button(action: {enrollmentButtonAction(currentUserId: currentUserId)}) {
                            Text(enrollmentButtonSetting.0)
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background((!enrollmentButtonSetting.1) ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(!enrollmentButtonSetting.1)
                    }
                }
                .onChange(of: eventView.event) { _ in
                    setValues(currentUserId: currentUserId)
                }
                .onChange(of: eventView.participants) { _ in
                    setValues(currentUserId: currentUserId)
                }
                .onChange(of: eventView.requesters) { _ in
                    setValues(currentUserId: currentUserId)
                }
                .onChange(of: user.invitations) { _ in
                    setValues(currentUserId: currentUserId)
                }
                .onAppear {
                    fetchEventAndParticipants(currentUserId: currentUserId)
                }
                .padding()
            }
            .navigationTitle(eventView.event.title)
            .refreshable {
                fetchEventAndParticipants(currentUserId: currentUserId)
            }
            .onAppear {
                fetchEventAndParticipants(currentUserId: currentUserId)
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
    
    private func fetchEventAndParticipants(currentUserId: Int){
        eventView.fetchEventByIdAndType(eventId: eventId, eventType: type)
        eventView.fetchParticipants(eventId: eventId, eventType: type, currUserId: currentUserId)
        user.fetchInvitations(userId: currentUserId)
        setValues(currentUserId: currentUserId)
        enrollmentButtonSetting = setEnrollmentButtonSetting()
    }
    private func setValues(currentUserId: Int){
        price = eventView.event.price.map { $0 == 0 ? "Free" : "$\($0)" } ?? "Free"
        capacity = eventView.event.capacity.map { $0 == 999 ? "No Limit" : "Capacity: \($0)" } ?? "No Limit"
        startDate = formatDate(date: eventView.event.startDate)
        endDate = formatDate(date: eventView.event.endDate)
        
        isParticipant = eventView.participants?.contains{usr in usr.id == currentUserId} ?? true
        
        isRequester = eventView.requesters?.contains{usr in usr.id == currentUserId} ?? true
        
        invitation = user.invitations?.first{inv in inv.event.id == eventView.event.id && inv.event.eventType == eventView.event.eventType}
        isFull = (eventView.event.enrolled == eventView.event.capacity)
        isEnded = endDate < Date()
        enrollmentButtonSetting = setEnrollmentButtonSetting()
    }
    
    func enrollmentButtonAction(currentUserId: Int) {
        if enrollmentButtonSetting.1 {
            eventView.enroll(eventId: eventId, eventType: type, userId: currentUserId)
            fetchEventAndParticipants(currentUserId: currentUserId)
        }
    }
    
    func responseInvitation(currentUserId: Int, respond: Bool) {
        if invitation != nil {
            eventView.respond(eventId: eventId, invitationId: invitation?.id ?? -1, eventType: type, userId: currentUserId, response: respond){
                user.fetchInvitations(userId: currentUserId)
                invitation = user.invitations?.first{inv in inv.event.id == eventView.event.id && inv.event.eventType == eventView.event.eventType}
            }
            enrollmentButtonSetting = setEnrollmentButtonSetting()
        }
    }
    
    func setEnrollmentButtonSetting() -> (String, Bool) {
        if isParticipant {
            return ("Already Joined", false)
        } else if isFull {
            return ("Enrollment Full", false)
        } else if isEnded {
            return ("Event Ended", false)
        } else if isRequester {
            return ("Request Sent", false)
        } else if eventView.event.isPrivate {
            return ("Request to Join", true)
        } else{
            return ("Join", true)
        }
        
    }
    
    
}

let shortDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

func formatDate(date: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    if let parsedDate = dateFormatter.date(from: date) {
        return parsedDate
    }
    
    let isoFormatter = ISO8601DateFormatter()
    if let parsedDate = isoFormatter.date(from: date) {
        return parsedDate
    }
    return Date.distantPast
}

struct MapView: UIViewRepresentable {
    let locationCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        mapView.addAnnotation(annotation)
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let annotation = uiView.annotations.first as? MKPointAnnotation else {
            return
        }
        
        annotation.coordinate = locationCoordinate
        
        let zoomMeters: CLLocationDistance = 1000
        let region = MKCoordinateRegion(center: locationCoordinate, latitudinalMeters: zoomMeters, longitudinalMeters: zoomMeters)
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard annotation is MKPointAnnotation else {
                return nil
            }
            
            let markerAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "MarkerAnnotation") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MarkerAnnotation")
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.isDraggable = false
            return markerAnnotationView
        }
    }
}


struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(eventId: 38, type: .nature)
        }
    }
}

