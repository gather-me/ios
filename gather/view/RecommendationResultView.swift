import SwiftUI

struct RecommendationResultView: View {
    let selectedUsers: Set<UserModel>
    let eventType: EventType
    @StateObject private var user = UserViewModel()
    private let eventClient = EventClient()
    @StateObject private var cancellables = CancellablesHolder()
    @State private var recommendation: [BaseEventModel] = []
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            ScrollView(showsIndicators: false){
                if recommendation.isEmpty{
                    VStack{
                        Text("It can take a while.")
                        ProgressView()
                    }
                } else{
                    Text("\(eventType.rawValue) Events you might like with your friend(s) \(selectedUsers.map { "@" + $0.username }.joined(separator: ", "))")
                        .font(.headline)
                        .frame(width: 300)
                    ForEach(recommendation, id: \.identifier) { event in
                        eventLayer(event: event, currentUserId: currentUserId)
                    }
                }
            }.refreshable{
                user.getGroupRecommendation(userId: currentUserId, userIds: selectedUsers.map { $0.id }, eventType: eventType){ eventIds in
                    eventClient.getEvents(eventIds: eventIds, eventType: eventType)
                        .sink(receiveCompletion: {completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(_):
                                break
                            }
                        }, receiveValue: {events in
                            recommendation = events
                        })
                        .store(in: &cancellables.cancellables)
                }
            }.onAppear{
                user.getGroupRecommendation(userId: currentUserId, userIds: selectedUsers.map { $0.id }, eventType: eventType){ eventIds in
                    eventClient.getEvents(eventIds: eventIds, eventType: eventType)
                        .sink(receiveCompletion: {completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(_):
                                break
                            }
                        }, receiveValue: {events in
                            recommendation = events
                        })
                        .store(in: &cancellables.cancellables)
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

struct RecommendationResultView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationResultView(selectedUsers: [UserModel(id: 231, firstName: "Kathy", secondName: "Knight", username: "kathyknight", emailAddress: "kathyknight@gmail.com")], eventType: .musical)
    }
}
