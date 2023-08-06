import SwiftUI
import Combine

struct HomeView: View {
    @State private var followingEvents: [BaseEventModel] = []
    private let eventClient = EventClient()
    @StateObject private var cancellables = CancellablesHolder()
    @State private var page = 0
    @State private var isFetching = false
    @State private var showLoadMoreButton = false
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false

    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        if !followingEvents.isEmpty{
                            ForEach(followingEvents, id: \.identifier) { event in
                                eventLayer(event: event, currentUserId: currentUserId)
                                Divider()
                            }
                        }else{
                            Text("Nothing new to see.")
                                .font(.headline)
                                .padding()
                        }
                        if isFetching {
                            ProgressView()
                                .padding()
                        }
                        if showLoadMoreButton {
                            Button(action: {
                                fetchFollowingEvents(currentUserId: currentUserId)
                            }) {
                                Text("Load More")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                    }
                    .padding(.top, 16)
                }
                .background(Color(.white).edgesIgnoringSafeArea(.all))
                .refreshable {
                    fetchFollowingEvents(currentUserId: currentUserId, resetList: true)
                }
                .onAppear {
                    Task {
                        fetchFollowingEvents(currentUserId: currentUserId,resetList: true)
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
    
    private func fetchFollowingEvents(currentUserId: Int, resetList: Bool = false) {
        guard !isFetching else { return }
        if resetList {
            page = 0
            followingEvents.removeAll()
        }
        isFetching = true
        eventClient.getFollowingEvents(userId: currentUserId, page: page)
            .sink(receiveCompletion: { completion in
                isFetching = false
                switch completion {
                case .finished: break
                case .failure(_): break
                }
            }, receiveValue: { events in
                followingEvents.append(contentsOf: events)
                page += 1
                showLoadMoreButton = !events.isEmpty
            })
            .store(in: &cancellables.cancellables)
    }
}


struct eventLayer: View{
    let event: BaseEventModel
    let currentUserId: Int
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50)
                
                VStack(alignment: .leading) {
                    Text(event.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    HStack {
                        Image(systemName: event.isPrivate ? "lock.fill" : "globe")
                            .foregroundColor(.gray)
                        Text(event.isPrivate ? "Private" : "Public")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 8)
            Spacer()
            Image("concert")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                .clipped()
            
            HStack(spacing: 16) {
                HStack {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.gray)
                    Text("\(event.enrolled)")
                        .foregroundColor(.gray)
                }
                Spacer()
                NavigationLink(destination: EventDetailView(eventId: event.id, type: event.eventType)) {
                    Text("Event Details")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 30)
                        .background(Color.black)
                        .cornerRadius(5)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(event.description ?? "")
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(8)
        .padding(8)
        Divider()
    }
}

class CancellablesHolder: ObservableObject {
    var cancellables = Set<AnyCancellable>()
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
