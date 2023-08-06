import Foundation
import Combine
import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack(spacing: 0) {
            Image("logo")
                .resizable()
                .frame(width: 150, height: 150)
                .padding(.top, 30)
            Spacer()
            SignupView()
            Spacer()
        }.padding(.bottom, 100)
        .padding(.top, 50)
    }
}

struct User: Codable {
    var firstName: String = ""
    var secondName: String = ""
    var emailAddress: String = ""
    var username: String = ""
    var password: String = ""
}

struct SignupView: View {
    @State private var user = User()
    private let userClient = UserClient()
    private var registerCancellables = CancellablesHolder()
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            TextField("First Name", text: $user.firstName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Second Name", text: $user.secondName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Email Address", text: $user.emailAddress)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            TextField("Username", text: $user.username)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            SecureField("Password", text: $user.password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Button(action: {
                registerUser()
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Registration Successful"), message: Text("Your account has been successfully registered."), dismissButton: .default(Text("OK")))
            }
        }
    }
    func registerUser(){
        userClient.register(user: user)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    showAlert = true
                    user = User()
                    break
                case .failure(let error):
                    print(error)
                }
            }, receiveValue: { _ in
            })
            .store(in: &registerCancellables.cancellables)
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
