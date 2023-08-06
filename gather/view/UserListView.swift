import SwiftUI

struct UserListView: View {
    let title: String?
    let users: [UserModel]?
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack{
                List(users ?? []) { user in
                    UserRow(user: user, currentUserId: currentUserId)
                }
            }.navigationTitle(title ?? "Title")
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

struct UserRow: View {
    let user: UserModel
    let currentUserId: Int
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .cornerRadius(25)
            
            NavigationLink(destination: ProfileView(userId: user.id)){
                VStack(alignment: .leading) {
                    Text("@" + user.username)
                        .font(.headline)
                    
                    Text(user.firstName + " " + user.secondName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }.foregroundColor(.black)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView(title: "Followers",users: [UserModel(id: 3,firstName: "Özgür Deniz",secondName: "Türker",username: "odenizturker",emailAddress: "odenizturker@gmail.com")])
    }
}
