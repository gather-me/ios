import SwiftUI

struct GroupRecommendationView: View {
    @State private var selectedUsers: Set<UserModel> = []
    @StateObject private var event = EventViewModel()
    @StateObject private var user = UserViewModel()
    private let eventClient = EventClient()
    @StateObject private var cancellables = CancellablesHolder()
    @State private var eventType: EventType = EventType.musical
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack {
                if(user.followings != nil){
                    Text("Select users to get event recommendation according to your common taste.\nYou can select maximum 2 user.")
                        .font(.caption)
                        .frame(width: 300)
                        .multilineTextAlignment(.center)
                    
                    List(user.followings ?? [], id: \.id) { user in
                        SelectUserRow(user: user, isSelected: selectedUsers.contains(user)) {
                            if self.selectedUsers.contains(user) {
                                self.selectedUsers.remove(user)
                            } else if self.selectedUsers.count < 2 {
                                self.selectedUsers.insert(user)
                            }
                        }
                    }.id(user.followings)
                    Section {
                        Picker("Event Type", selection: $eventType) {
                            ForEach(EventType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    NavigationLink(destination: RecommendationResultView(selectedUsers: selectedUsers, eventType: eventType)) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(selectedUsers.count > 2 ? Color.gray : (selectedUsers.isEmpty ? Color.gray : Color.black))
                            .cornerRadius(8)
                    }.disabled(selectedUsers.isEmpty || selectedUsers.count > 2)
                }else{
                    ProgressView()
                }
            }.refreshable {
                user.fetchFollowings(userId: currentUserId)
            }
            .onAppear {
                user.fetchFollowings(userId: currentUserId)
            }
            .navigationTitle("Group Recommendation")
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


struct GroupRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        GroupRecommendationView()
    }
}
