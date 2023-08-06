import SwiftUI

struct PreviousEventsView: View {
    @State private var previousEvents: [BaseEventModel] = []
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
                VStack{
                    if !previousEvents.isEmpty{
                        ForEach(previousEvents,id: \.identifier) { event in
                            EventRow(event: event, userId: currentUserId, fetchUnratedPreviousEvents: fetchUnratedPreviousEvents)
                        }
                    }else{
                        Spacer()
                        Text("You do not have any previous event.")
                            .font(.headline)
                    }
                    if isFetching {
                        ProgressView()
                            .padding()
                    }
                    if showLoadMoreButton {
                        Button(action: {
                            fetchUnratedPreviousEvents(currentUserId: currentUserId)
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
            }.refreshable {
                fetchUnratedPreviousEvents(currentUserId: currentUserId, resetList: true)
            }
            .onAppear {
                Task {
                    fetchUnratedPreviousEvents(currentUserId: currentUserId, resetList: true)
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
    
    func fetchUnratedPreviousEvents(currentUserId: Int, resetList: Bool = false) {
        guard !isFetching else { return }
        if resetList {
            page = 0
            previousEvents.removeAll()
        }
        isFetching = true
        eventClient.getUnratedEvents(userId: currentUserId, page:page)
            .sink(receiveCompletion: { completion in
                isFetching = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { events in
                previousEvents.append(contentsOf: events)
                page += 1
                showLoadMoreButton = !events.isEmpty
            })
            .store(in: &cancellables.cancellables)
    }
}

struct EventRow: View {
    let event: BaseEventModel
    let userId: Int
    let fetchUnratedPreviousEvents: (Int, Bool)-> Void
    var body: some View {
        VStack{
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                
                VStack(alignment: .leading){
                    NavigationLink(destination: EventDetailView(eventId: event.id, type: event.eventType)){
                            Text(event.title)
                                .font(.headline)
                    }.foregroundColor(.black)
                }
            }
            RatingView(event: event, userId: userId, fetchUnratedPreviousEvents: fetchUnratedPreviousEvents)
            Divider()
        }
    }
}

struct PreviousEventsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviousEventsView()
    }
}

struct RatingView: View {
    let event: BaseEventModel
    let userId: Int
    let fetchUnratedPreviousEvents: (Int, Bool)-> Void
    
    @State private var selectedRating: Int = 0
    private let eventClient = EventClient()
    @StateObject private var rateCancellables = CancellablesHolder()

    var body: some View {
        VStack {
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= selectedRating ? "star.fill" : "star")
                        .foregroundColor(.black)
                        .imageScale(.large)
                        .onTapGesture {
                            selectedRating = index
                        }
                }
            }
            Spacer()
            Button(action: {
                rate(userId: userId, event: event, rate: selectedRating)
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(10)
            }
            .disabled(selectedRating == 0)
        }
        .padding()
    }
    func rate(userId: Int, event: BaseEventModel, rate: Int) {
        eventClient.rate(eventType: event.eventType, eventId: event.id, userId: userId, rate: rate)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    fetchUnratedPreviousEvents(userId, true)
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &rateCancellables.cancellables)
    }
}
