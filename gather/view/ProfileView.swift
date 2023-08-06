import SwiftUI
import Combine

struct ProfileView: View {
    let userId: Int
    @StateObject private var user = UserViewModel()
    @State private var selectedTab: Tab = .created
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false

    enum Tab {
        case created
        case past
    }
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack {
                if user.user != nil {
                    ScrollView{
                        HStack(alignment: .center) {
                            Spacer()
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .padding(.horizontal, 10)
                            
                            VStack(alignment: .leading) {
                                Text("\(user.user?.firstName ?? "") \(user.user?.secondName ?? "")")
                                    .font(.headline)
                                
                                Text("@\(user.user?.username ?? "")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                HStack {
                                    NavigationLink(destination: UserListView(title: "Followers", users: user.followers)) {
                                        VStack {
                                            Text("\(user.followerCount ?? -1)")
                                                .font(.headline)
                                            
                                            Text("Followers")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }.foregroundColor(.black)
                                    
                                    Spacer()
                                        .frame(width: 30)
                                    
                                    NavigationLink(destination: UserListView(title: "Followings", users: user.followings)) {
                                        VStack {
                                            Text("\(user.followingCount ?? -1)")
                                                .font(.headline)
                                            
                                            Text("Following")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }.foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                }
                                
                                if currentUserId != userId {
                                    Button(action: {
                                        user.follow(userId: currentUserId, followingUserId: userId)
                                    }) {
                                        Text(user.isFollowing ?? false ? "Unfollow" : "Follow")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.black)
                                            .cornerRadius(5)
                                    }
                                }
                            }
                            Spacer()
                            VStack{
                                Button(action: {
                                    accessTokenModel.currentUserId = nil
                                    accessTokenModel.accessToken = nil
                                }){
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .foregroundColor(.black)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        Divider()
                        VStack(alignment: .center){
                            Picker(selection: $selectedTab, label: Text("")){
                                Text("Created Events").tag(Tab.created)
                                Text("Past Events").tag(Tab.past)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .background(Color.white)
                            
                            switch selectedTab {
                            case .past:
                                PastEventsView(userId: userId, currentUserId: currentUserId)
                            case .created:
                                CreatedEventsView(userId: userId, currentUserId: currentUserId)
                            }
                        }
                        .padding()
                    }
                }else{
                    ProgressView()
                }
            }.refreshable{
                user.fetchUserById(userId: userId)
                user.fetchFollowers(userId: userId, currentUserId: currentUserId)
                user.fetchFollowerCount(userId: userId)
                user.fetchFollowings(userId: userId)
                user.fetchFollowingCount(userId: userId)
            }
            .onAppear {
                user.fetchUserById(userId: userId)
                user.fetchFollowers(userId: userId, currentUserId: currentUserId)
                user.fetchFollowerCount(userId: userId)
                user.fetchFollowings(userId: userId)
                user.fetchFollowingCount(userId: userId)
            }
            .navigationBarTitle("Profile")
            .padding()
        }else{
            ProgressView()
                .onAppear {
                    isShowingAlert = true
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Succesfully logout"),
                        message: Text("You successfully logout."),
                        primaryButton: .default(Text("OK")) {
                            navigateToAuthView()
                        },
                        secondaryButton: .cancel()
                    )
                }
        }
    }
}
struct PastEventsView: View{
    @StateObject private var user = UserViewModel()
    let userId: Int
    let currentUserId: Int
    var body: some View{
        ScrollView() {
            VStack{
                ForEach(user.previousEvents ?? [], id: \.identifier) { event in
                    eventLayer(event: event, currentUserId: currentUserId)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .clipped()
        }.refreshable{
            user.fetchPreviousEvents(userId: userId, page: 0)
        }
        .onAppear{
            user.fetchPreviousEvents(userId: userId, page: 0)
        }
    }
}

struct CreatedEventsView: View{
    @StateObject private var user = UserViewModel()
    let userId: Int
    let currentUserId: Int
    var body: some View{
        ScrollView() {
            VStack{
                ForEach(user.createdEvents ?? [], id: \.identifier) { event in
                    eventLayer(event: event, currentUserId: currentUserId)
                }
            }
            .frame(width: UIScreen.main.bounds.width)
            .clipped()
        }.refreshable{
            user.fetchCreatedEvents(userId: userId, page: 0)
        }
        .onAppear{
            user.fetchCreatedEvents(userId: userId, page: 0)
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(userId: 32)
    }
}
