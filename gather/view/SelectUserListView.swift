import SwiftUI

struct SelectUserListView: View {
    let title: String?
    let eventId: Int
    let eventType: EventType
    @State private var selectedUsers: Set<UserModel> = []
    @StateObject private var event = EventViewModel()
    private let eventClient = EventClient()
    @StateObject private var cancellables = CancellablesHolder()
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack {
                if(event.invitingUsers != nil){
                    List(event.invitingUsers ?? [], id: \.id) { user in
                        SelectUserRow(user: user, isSelected: selectedUsers.contains(user)) {
                            if self.selectedUsers.contains(user) {
                                self.selectedUsers.remove(user)
                            } else {
                                self.selectedUsers.insert(user)
                            }
                        }
                    }.id(event.invitingUsers)
                    Button(action: {submitSelectedUsers(currentUserId: currentUserId)}) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(selectedUsers.isEmpty ? Color.gray : Color.black)
                            .cornerRadius(8)
                    }
                    .padding()
                    .disabled(selectedUsers.isEmpty)
                }else{
                    ProgressView()
                }
            }.refreshable {
                event.fetchInvitingUsers(eventId: eventId, eventType: eventType, page: 0)
            }
            .onAppear {
                event.fetchInvitingUsers(eventId: eventId, eventType: eventType, page: 0)
            }
            .navigationTitle(title ?? "Title")
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
    private func submitSelectedUsers(currentUserId: Int) {
        for user in selectedUsers {
            invite(currUserId: currentUserId, userId: user.id)
        }
    }
    
    func invite(currUserId: Int, userId: Int) {
        eventClient.invite(currUserId: currUserId, eventType: eventType, eventId: eventId, userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    event.fetchInvitingUsers(eventId: eventId, eventType: eventType, page: 0)
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables.cancellables)
    }
}

struct SelectUserRow: View {
    let user: UserModel
    let isSelected: Bool
    let toggleSelection: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(25)
            
            VStack(alignment: .leading) {
                Text("@" + user.username)
                    .font(.headline)
                
                Text(user.firstName + " " + user.secondName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .foregroundColor(.black)
            
            Spacer()
            
            Button(action: toggleSelection) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 24, height: 24)
        }
        .padding(.vertical, 8)
    }
}

struct SelectUserListView_Previews: PreviewProvider {
    static var previews: some View {
        SelectUserListView(title: "Followers", eventId: 7568, eventType: .nature)
    }
}
