import SwiftUI
import AuthenticationServices

class PresentationContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            return window
        }
        
        fatalError("No key window found")
    }
}

let authEndpoint = "http://164.90.185.210:9000/"

struct AuthView: View {
    @State private var accessToken: String? = nil
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView{
                    Spacer()
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    Spacer()
                    SignupView()
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                    Button(action: {
                        startWebAuthSession()
                    }) {
                        Text("Already have an account? Login")
                    }
                    Spacer()
                }
            }.onAppear {
                if accessToken != nil {
                    navigateToContentView()
                }
            }
        }
    }
    
    func navigateToContentView() {
        let contentView = ContentView()
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            
            window.rootViewController = UIHostingController(rootView: contentView)
            window.makeKeyAndVisible()
        }
    }

    
    func startWebAuthSession() {
        let callbackUrlScheme = "myapp"
        let encodedCallbackUrlScheme = callbackUrlScheme.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
        let authUrl = "\(authEndpoint)oauth2/authorize?response_type=code&client_id=my-client-id&redirect_uri=\(encodedCallbackUrlScheme)://oauth/callback"
        let authSession = ASWebAuthenticationSession(url: URL(string: authUrl)!, callbackURLScheme: callbackUrlScheme) { callbackUrl, error in
            guard error == nil, let callbackUrl = callbackUrl else {
                print("An error occurred: \(error.debugDescription)")
                return
            }
            
            let queryItems = URLComponents(string: callbackUrl.absoluteString)?.queryItems
            if let authCode = queryItems?.filter({ $0.name == "code" }).first?.value {
                getAccessToken(with: authCode)
            }
        }
        
        let presentationContextProvider = PresentationContextProvider()
        authSession.presentationContextProvider = presentationContextProvider
        
        authSession.prefersEphemeralWebBrowserSession = true
        authSession.start()
    }
    
    func getAccessToken(with authCode: String) {
        let tokenUrl = "\(authEndpoint)oauth2/token"
        let redirectUri = "myapp://oauth/callback"
        
        var urlComponents = URLComponents(string: tokenUrl)!
        urlComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: authCode),
            URLQueryItem(name: "redirect_uri", value: redirectUri),
            URLQueryItem(name: "client_id", value: "my-client-id")
        ]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        let credentials = "my-client-id:my-client-secret"
        let encodedCredentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    if let accessToken = json?["access_token"] as? String {
                        DispatchQueue.main.async {
                            print(accessToken)
                            AccessTokenModel.shared.accessToken = accessToken
                            introspectUser(with: accessToken)
                            navigateToContentView()
                        }
                    } else {
                        print("Access token not found in response")
                    }
                } catch {
                    print("Failed to parse response data: \(error)")
                }
            }
        }.resume()
    }
    
    func introspectUser(with accessToken: String) {
        let url = "\(authEndpoint)oauth2/introspect"
        
        let urlComponents = URLComponents(string: url)!
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "POST"
        
        let credentials = "my-client-id:my-client-secret"
        let encodedCredentials = Data(credentials.utf8).base64EncodedString()
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        
        let requestBody = "token=\(accessToken)"
        
        request.httpBody = requestBody.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let currentUserIdString = json["sub"] as? String {
                            if let currentUserId = Int(currentUserIdString) {
                                DispatchQueue.main.async {
                                    AccessTokenModel.shared.currentUserId = currentUserId
                                }
                            }
                        } else {
                            print("Sub not found")
                        }
                    } else {
                        print("Failed to parse JSON response")
                    }
                } catch {
                    print("Failed to introspect user: \(error)")
                }
            }
        }.resume()
    }
    
    
    
    
    
    
    
    
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
}
