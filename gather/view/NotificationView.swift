import SwiftUI
import Foundation
import Combine

struct NotificationView: View {
    @State private var selectedTab: Tab = .requests
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false

    enum Tab {
        case requests
        case invitations
    }
    
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack(alignment: .center){
                Picker(selection: $selectedTab, label: Text("")){
                    Text("Requests").tag(Tab.requests)
                    Text("Invitations").tag(Tab.invitations)
                }
                .pickerStyle(SegmentedPickerStyle())
                .background(Color.white)
                
                switch selectedTab {
                case .requests:
                    RequestView(currentUserId: currentUserId)
                case .invitations:
                    InvitationView(currentUserId: currentUserId)
                }
                Spacer()
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
}

struct RequestView: View {
    let currentUserId: Int
    @StateObject private var user = UserViewModel()
    var body: some View {
        VStack{
            Text("Requests")
                .font(.title)
                .fontWeight(.heavy)
            Divider()
            ForEach(user.requests ?? []){request in
                RequestRow(currentUserId: currentUserId, request: request){
                    user.fetchRequests(userId: currentUserId)
                }
            }
        }.refreshable {
            user.fetchRequests(userId: currentUserId)
        }
        .onAppear {
            user.fetchRequests(userId: currentUserId)
        }
    }
}
struct RequestRow: View {
    let currentUserId: Int
    let request: EnrollmentRequestModel
    let action : () -> Void
    
    var body: some View {
        VStack {
            Text(request.event.title)
                .font(.headline)
                .fontWeight(.heavy)
            
            ForEach(request.users, id: \.id) { user in
                RequestUserRow(currentUserId: currentUserId, user: user, event: request.event, action: action)
                Divider()
            }
        }
    }
}

struct RequestUserRow: View {
    let currentUserId: Int
    let user: UserModel
    let event: BaseEventModel
    let action : () -> Void
    let eventClient = EventClient()
    @State private var respondCancellables = Set<AnyCancellable>()
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(25)
            
            VStack(alignment: .leading) {
                Text("Username: \(user.username)")
                    .font(.headline)
                
                HStack {
                    Button(action: {
                        respond(response: true)
                    }) {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        respond(response: false)
                    }) {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
    
    func respond(response: Bool) {
        eventClient.respondEnrollmentRequest(creatorId: currentUserId, eventId: event.id, userId: user.id, eventType: event.eventType, response: response)
            .sink(receiveCompletion: {completion in
                switch completion {
                case .finished:
                    action()
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: {_ in })
            .store(in: &respondCancellables)
    }
}


struct InvitationView: View{
    let currentUserId: Int
    @StateObject private var user = UserViewModel()
    
    var body: some View {
        VStack{
            Text("Invitations")
                .font(.title)
                .fontWeight(.heavy)
            List(user.invitations ?? []) { invitation in
                InvitationRow(invitation: invitation, currentUserId: currentUserId)
            }
        }.refreshable {
            user.fetchInvitations(userId: currentUserId)
        }
        .onAppear {
            user.fetchInvitations(userId: currentUserId)
        }
    }
}

struct InvitationRow: View {
    let invitation: InvitationModel
    let currentUserId: Int
    var body: some View {
        VStack{
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                
                VStack(alignment: .leading){
                    NavigationLink(destination: EventDetailView(eventId: invitation.event.id, type: invitation.event.eventType)){
                        Text(invitation.event.title)
                            .font(.headline)
                    }.foregroundColor(.black)
                }
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
