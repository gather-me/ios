import SwiftUI
import MapKit
import Combine

struct EventDetailView: View {
    let currentUserId: Int
    let eventId: Int
    let type: EventType = .musical
    @StateObject private var eventView = MusicalEventViewModel()
    
    var isEnrollmentFull: Bool {
        eventView.event.enrolled == eventView.event.capacity
    }
    
    var isEventEnded: Bool {
        formatDate(date: eventView.event.endDate) < Date()
    }
    
    var isEnrolled: Bool {
        eventView.participants?.contains { user in
            user.id == currentUserId
        } ?? false
    }
    
    var enrollmentButtonTitle: String {
        if isEnrollmentFull {
            return "Enrollment Full"
        } else if eventView.event.isPrivate {
            return "Request to Join"
        } else {
            return "Join"
        }
    }
    
    var body: some View {
        let price = eventView.event.price.map { $0 == 0 ? "Free" : "$\($0)" } ?? "Free"
        let capacity = eventView.event.capacity.map { $0 == 999 ? "No Limit" : "Capacity: \($0)" } ?? "No Limit"
        let startDate = formatDate(date: eventView.event.startDate)
        let endDate = formatDate(date: eventView.event.endDate)
        
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
                    Text(type.rawValue + " / " +  eventView.event.category.rawValue)
                        .foregroundColor(.gray)
                    Spacer()
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    Text(eventView.event.artist)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "person.crop.circle.fill")
                        .foregroundColor(.gray)
                    Text(eventView.event.creator.userName)
                        .foregroundColor(.gray)
                    
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
                    NavigationLink(destination: UserListView(title: "Participants", users: eventView.participants)) {
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
                
                Button(action: enrollmentButtonAction) {
                    Text(enrollmentButtonTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background((isEnrollmentFull || isEventEnded  || isEnrolled) ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .disabled(isEnrollmentFull || isEventEnded || isEnrolled)
            }
            .padding()
        }
        .navigationTitle(eventView.event.title)
        .onAppear {
            eventView.fetchEventById(eventId: eventId)
            eventView.fetchParticipantsById(eventId: eventId)
        }
    }
    
    private func enrollmentButtonAction() {
        if !isEnrollmentFull {
            eventView.enroll(userId: currentUserId)
        }
    }
}

struct MusicalEventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EventDetailView(currentUserId: 32, eventId: 232)
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
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.date(from: date) ?? Date.distantPast
}

struct MapView: UIViewRepresentable {
    let locationCoordinate: CLLocationCoordinate2D
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = locationCoordinate
        uiView.removeAnnotations(uiView.annotations)
        uiView.addAnnotation(annotation)
        uiView.showAnnotations([annotation], animated: true)
    }
}
