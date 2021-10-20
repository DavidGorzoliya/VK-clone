//
//  AuthVKViewController.swift
//  VKGeeKBrainsTest
//
//  Created by Давид Горзолия on 31.01.2021.
//

import UIKit
import WebKit
import FirebaseDatabase

final class AuthVKViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var session = Session.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthVK()
    }

    func loadAuthVK() {
        var urlConstructor = URLComponents()
        urlConstructor.scheme = "https"
        urlConstructor.host = "oauth.vk.com"
        urlConstructor.path = "/authorize"
        urlConstructor.queryItems = [
            URLQueryItem(name: "client_id", value: "7718521"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "friends,photos,groups"),
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.120")
        ]

        guard let url = urlConstructor.url  else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func removeCookie() {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        cookieStore.getAllCookies {
            cookies in
            for cookie in cookies {
                cookieStore.delete(cookie)
            }
        }
    }
}

extension AuthVKViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment  else {
            decisionHandler(.allow)
            return
        }

        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }

        if let token = params["access_token"], let userID = params["user_id"], let expiresIn = params["expires_in"] {
            self.session.token = token
            self.session.userId = Int(userID) ?? 0
            self.session.expiredDate = Date(timeIntervalSinceNow: TimeInterval(Int(expiresIn) ?? 0))

            decisionHandler(.cancel)

            writeUserToFirebase(userID)

            self.performSegue(withIdentifier: "AuthVKSuccessful", sender: nil)
        } else {
            decisionHandler(.allow)
            self.performSegue(withIdentifier: "AuthVKUnsuccessful", sender: nil)

        }
    }

    private func writeUserToFirebase(_ userID: String){
        let database = Database.database()
        let ref: DatabaseReference = database.reference(withPath: "All logged users")

        ref.observe(.value) { snapshot in
            let users = snapshot.children.compactMap { $0 as? DataSnapshot }
            let keys = users.compactMap { $0.key }

            guard keys.contains(userID) == false else {
                ref.removeAllObservers()
                
                let user = snapshot.childSnapshot(forPath: userID).value
                print("Текущий пользователь с ID \(userID) добавил следующие группы:\n\(user ?? "")")
                return
            }

            ref.child(userID).setValue("нет добавленных групп")
            print("В Firebase записан новый пользователь, ID: \(userID)")
        }
    }
}
