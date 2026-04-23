import SwiftUI
import Combine

class UserData: ObservableObject {
    @Published var userDatabase: [String: String] = [:]

    init() {
        loadUserData() // Load user data on initialization
    }

    func saveUser(username: String, password: String) {
        userDatabase[username] = password
        UserDefaults.standard.set(username, forKey: "savedUsername") // Save username
        UserDefaults.standard.set(password, forKey: "savedPassword") // Save password
    }

    private func loadUserData() {
        if let savedUsername = UserDefaults.standard.string(forKey: "savedUsername"),
           let savedPassword = UserDefaults.standard.string(forKey: "savedPassword") {
            userDatabase[savedUsername] = savedPassword // Load saved user
        }
    }
}
