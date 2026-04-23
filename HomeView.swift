import SwiftUI

struct HomeView: View {
    @Binding var isLoggedIn: Bool
    @Binding var selectedTab: Int

    init(isLoggedIn: Binding<Bool>, selectedTab: Binding<Int>) {
        self._isLoggedIn = isLoggedIn
        self._selectedTab = selectedTab
        
        // Customize navigation appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue // Bright background
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = .white // Brighter back button
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Spacer(minLength: 100) // Adds space above the text

                Text("Welcome! Let's get you feeling great! 🌟")
                    .font(.custom("Poppins", size: 36))
                    .fontWeight(.light)
                    .foregroundColor(.pink)
                    .padding()
                    .shadow(radius: 5)
                    .multilineTextAlignment(.center)

                Spacer()

                // Navigation to HealthTipView
                NavigationLink(
                    destination: HealthTipView(),
                    isActive: $isLoggedIn
                ) {
                    EmptyView()
                }
                .hidden() // Invisible link

                if isLoggedIn {
                    Text("Loading your Health Tips...") // Placeholder for logged-in users
                        .font(.custom("Poppins", size: 22))
                        .foregroundColor(.green)
                        .padding()
                } else {
                    // Buttons to log in and create user
                    VStack(spacing: 16) {
                        NavigationLink(destination: LoginView(isLoggedIn: $isLoggedIn, selectedTab: $selectedTab)) {
                            Text("Log in to start your journey! 🌱")
                                .font(.custom("Poppins", size: 22))
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                        }

                        NavigationLink(destination: CreateUserView(isLoggedIn: $isLoggedIn)) {
                            Text("Create a new account 💚")
                                .font(.custom("Poppins", size: 22))
                                .fontWeight(.medium)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .foregroundColor(.white)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer()
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.1), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
            )
            .cornerRadius(20)
            .shadow(radius: 15)
            .padding(.horizontal)
            .ignoresSafeArea()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    @State static var isLoggedIn = false
    @State static var selectedTab = 0

    static var previews: some View {
        HomeView(isLoggedIn: $isLoggedIn, selectedTab: $selectedTab)
    }
}
