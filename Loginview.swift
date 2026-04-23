import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userData: UserData
    @Binding var isLoggedIn: Bool
    @Binding var selectedTab: Int
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isNavigating: Bool = false // Flag to control navigation
    @State private var isPasswordVisible: Bool = false // Password visibility toggle
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6), Color.cyan.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack {
                    // Custom back button at the top-left
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 20, weight: .bold))
                                .padding(10)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding(.leading, 20)
                        Spacer()
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Logo
                    Image(systemName: "heart.text.square.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.pink)
                        .shadow(color: .pink.opacity(0.7), radius: 15, x: 0, y: 10)
                        .padding(.bottom, 40)
                    
                    // Input fields
                    VStack(spacing: 20) {
                        TextField("Enter your username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.purple, lineWidth: 1)
                            )
                            .shadow(color: .purple.opacity(0.5), radius: 5, x: 0, y: 5)
                        
                        HStack {
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 5)
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                    .shadow(color: .blue.opacity(0.5), radius: 5, x: 0, y: 5)
                            }
                            
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                    .padding(.horizontal, 40)
                    
                    // Login button
                    Button(action: login) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.pink, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(20)
                        .shadow(color: .pink.opacity(0.7), radius: 10, x: 0, y: 10)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                    
                    if showAlert {
                        Text(alertMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 15)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showAlert)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true) // Hide system back button
            .navigationBarItems(leading: EmptyView()) // Prevent the default back button
            
            // NavigationLink to the next view (HealthTipView), triggered by isNavigating
            NavigationLink(destination: HealthTipView(), isActive: $isNavigating) {
                EmptyView() // Invisible NavigationLink
            }
        }
        .onAppear {
            username = ""
            password = ""
        }
        .onTapGesture {
            hideKeyboard() // Dismiss keyboard when tapping outside
        }
    }
    
    private func login() {
        if let storedPassword = userData.userDatabase[username], storedPassword == password {
            // Update state variables
            isLoggedIn = true
            selectedTab = 0
            
            // Add delay before navigating to prevent double navigation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                isNavigating = true // Navigate to HealthTipView
            }
        } else {
            alertMessage = "Invalid username or password."
            showAlert = true
            
            // Clear error after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                showAlert = false
            }
        }
    }

    // Function to hide the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    @State static var isLoggedIn = false
    @State static var selectedTab = 0

    static var previews: some View {
        LoginView(isLoggedIn: $isLoggedIn, selectedTab: $selectedTab)
            .environmentObject(UserData())
    }
}
