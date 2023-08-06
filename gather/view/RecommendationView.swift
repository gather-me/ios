//
//  RecommendationView.swift
//  gather
//
//  Created by Ozgur on 15.05.2023.
//

import SwiftUI

struct RecommendationView: View {
    @State private var upcomingEvents: [BaseEventModel] = []
    @State private var sportRecommendation: [BaseEventModel] = []
    @State private var musicalRecommendation: [BaseEventModel] = []
    @State private var natureRecommendation: [BaseEventModel] = []
    @State private var stagePlayRecommendation: [BaseEventModel] = []
    @StateObject private var user = UserViewModel()
    @StateObject private var sportRecommendationCancellables = CancellablesHolder()
    @StateObject private var musicalRecommendationCancellables = CancellablesHolder()
    @StateObject private var natureRecommendationCancellables = CancellablesHolder()
    @StateObject private var stagePlayRecommendationCancellables = CancellablesHolder()
    @StateObject private var upcomingCancellables = CancellablesHolder()
    @ObservedObject private var accessTokenModel = AccessTokenModel.shared
    @State private var isShowingAlert = false
    
    private let eventClient = EventClient()
    var body: some View {
        if let currentUserId = accessTokenModel.currentUserId{
            VStack{
                ScrollView(showsIndicators: false){
                    VStack(alignment: .center) {
                        NavigationLink(destination: GroupRecommendationView()) {
                            Text("Get Group Recommendation")
                                .font(.subheadline)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.medium)
                                .frame(width: 150)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 60)
                                .background(Color.black)
                                .cornerRadius(5)
                        }.padding()
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Upcoming Events")
                                .font(.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.black)
                                .frame(width: 300)
                            
                            HStack{
                                ScrollView(.horizontal ,showsIndicators: false){
                                    HStack(alignment: .top){
                                        ForEach(upcomingEvents, id: \.identifier) { event in
                                            recommendationLayer(event: event, currentUserId: currentUserId)
                                        }
                                    }
                                }
                            }
                        }
                        Divider()
                        VStack(alignment: .leading) {
                            Text("Sport Events You Might Like")
                                .font(.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.black)
                                .frame(width: 300)
                            if sportRecommendation.isEmpty {
                                ProgressView()
                            }
                            else{
                                recommendation(recommendation: sportRecommendation, currentUserId: currentUserId)
                            }
                            Divider()
                        }
                        VStack(alignment: .leading) {
                            Text("Musical Events You Might Like")
                                .font(.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.black)
                                .frame(width: 300)
                            if musicalRecommendation.isEmpty {
                                ProgressView()
                            }
                            else{
                                recommendation(recommendation: musicalRecommendation, currentUserId: currentUserId)
                            }
                            Divider()
                        }
                        VStack(alignment: .leading) {
                            Text("Nature Events You Might Like")
                                .font(.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.black)
                                .frame(width: 300)
                            if natureRecommendation.isEmpty {
                                ProgressView()
                            }
                            else{
                                recommendation(recommendation: natureRecommendation, currentUserId: currentUserId)
                            }
                            Divider()
                        }
                        VStack(alignment: .leading) {
                            Text("Stage Play Events You Might Like")
                                .font(.title)
                                .fixedSize(horizontal: false, vertical: true)
                                .fontWeight(.black)
                                .frame(width: 300)
                            if stagePlayRecommendation.isEmpty {
                                ProgressView()
                            }
                            else{
                                recommendation(recommendation: stagePlayRecommendation, currentUserId: currentUserId)
                            }
                        }
                        
                    }
                }.refreshable {
                    fetchSportRecommendations(currentUserId: currentUserId)
                    fetchMusicalRecommendations(currentUserId: currentUserId)
                    fetchNatureRecommendations(currentUserId: currentUserId)
                    fetchStagePlayRecommendations(currentUserId: currentUserId)
                    fetchUpcomingEvents()
                }
                .onAppear {
                    Task {
                        fetchUpcomingEvents()
                        fetchSportRecommendations(currentUserId: currentUserId)
                        fetchMusicalRecommendations(currentUserId: currentUserId)
                        fetchNatureRecommendations(currentUserId: currentUserId)
                        fetchStagePlayRecommendations(currentUserId: currentUserId)
                    }
                }
            }}else{
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
    private func fetchUpcomingEvents() {
        eventClient.getUpcomingEvents(page: 0)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    print("Request failed with error: \(error)")
                }
            }, receiveValue: { events in
                upcomingEvents = events
            })
            .store(in: &upcomingCancellables.cancellables)
    }
    
    private func fetchSportRecommendations(currentUserId: Int) {
        user.getRecommendation(userId: currentUserId, eventType: .sport){ eventIds in
            eventClient.getEvents(eventIds: eventIds, eventType: .sport)
                .sink(receiveCompletion: {completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                }, receiveValue: {events in
                    sportRecommendation = events
                })
                .store(in: &sportRecommendationCancellables.cancellables)
        }
    }
    
    private func fetchMusicalRecommendations(currentUserId: Int) {
        user.getRecommendation(userId: currentUserId, eventType: .musical){ eventIds in
            eventClient.getEvents(eventIds: eventIds, eventType: .musical)
                .sink(receiveCompletion: {completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                }, receiveValue: {events in
                    musicalRecommendation = events
                })
                .store(in: &musicalRecommendationCancellables.cancellables)
        }
    }
    
    private func fetchNatureRecommendations(currentUserId: Int) {
        user.getRecommendation(userId: currentUserId, eventType: .nature){ eventIds in
            eventClient.getEvents(eventIds: eventIds, eventType: .nature)
                .sink(receiveCompletion: {completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                }, receiveValue: {events in
                    natureRecommendation = events
                })
                .store(in: &natureRecommendationCancellables.cancellables)
        }
    }
    
    private func fetchStagePlayRecommendations(currentUserId: Int) {
        user.getRecommendation(userId: currentUserId, eventType: .stagePlay){ eventIds in
            eventClient.getEvents(eventIds: eventIds, eventType: .stagePlay)
                .sink(receiveCompletion: {completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        break
                    }
                }, receiveValue: {events in
                    stagePlayRecommendation = events
                })
                .store(in: &stagePlayRecommendationCancellables.cancellables)
        }
    }
    
    
    @ViewBuilder
    func recommendation(recommendation: [BaseEventModel], currentUserId: Int) -> some View{
        HStack{
            ScrollView(.horizontal ,showsIndicators: false){
                HStack(alignment: .top){
                    ForEach(recommendation, id: \.identifier) { event in
                        recommendationLayer(event: event, currentUserId: currentUserId)
                    }
                }
            }
        }
        Spacer(minLength: 100)
    }
}


@ViewBuilder
func recommendationLayer(event: BaseEventModel, currentUserId: Int) -> some View {
    VStack{
        Button(action: {}) {
            NavigationLink(destination: EventDetailView(eventId: event.id, type: event.eventType)) {
                Image("concert")
                    .resizable()
                    .frame(width: 300, height: 300)
            }
        }
        Text(event.title)
            .bold()
            .fixedSize(horizontal: false, vertical: true)
            .multilineTextAlignment(.center)
            .frame(width: 300)
        HStack{
            Image(systemName: "tag.fill")
                .foregroundColor(.gray)
            Text("\(event.eventType.rawValue)")
                .foregroundColor(.gray)
        }
    }
}

struct RecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendationView()
    }
}
