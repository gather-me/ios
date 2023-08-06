import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var isCreatingEvent = false
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    var body: some View {
        NavigationView{
            if let currentUserId = accessTokenModel.currentUserId{
                VStack {
                    HStack {
                        Image("logo2")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
                        Spacer()
                        NavigationLink(destination: EventCreationView()) {
                            Image(systemName: "plus.square")
                                .font(.title)
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    TabView(selection: $selectedTab) {
                        HomeView()
                            .tabItem {
                                Image(systemName: "house")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            .tag(0)
                        
                        PreviousEventsView()
                            .tabItem {
                                Image(systemName: "clock.arrow.2.circlepath")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            .tag(1)
                        
                        RecommendationView()
                            .tabItem {
                                Image(systemName: "globe")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            .tag(2)
                        
                        NotificationView()
                            .tabItem {
                                Image(systemName: "bell")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            .tag(3)
                        
                        ProfileView(userId: currentUserId)
                            .tabItem {
                                Image(systemName: "person.crop.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(.black)
                            }
                            .tag(4)
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
    }
    
}

func navigateToAuthView() {
    let contentView = AuthView()
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
        
        window.rootViewController = UIHostingController(rootView: contentView)
        window.makeKeyAndVisible()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
