import SwiftUI

struct CreateUserView: View {
    @Binding var isLoggedIn: Bool
    @State private var name: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var showThankYouMessage: Bool = false
    @State private var navigateToLogin: Bool = false

    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Input Fields
                Group {
                    TextField("Name", text: $name)
                    TextField("Username", text: $username)
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                // Error message for invalid date
                if isToday(date: dateOfBirth) {
                    Text("Date of birth cannot be today.")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, -20)
                }

                // Date Picker
                Text("Select Birthday")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top)

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.pink.opacity(0.7), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 50)

                    DatePicker("", selection: $dateOfBirth, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Create Account Button
                Button(action: createUser) {
                    Text("Create Account")
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()

                // Thank You Message
                if showThankYouMessage {
                    Text("Thank you for creating an account! Redirecting to login...")
                        .foregroundColor(.green)
                        .padding()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                resetFields()
                                navigateToLogin = true
                            }
                        }
                }

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Invalid Input"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView(isLoggedIn: $isLoggedIn, selectedTab: .constant(0))
                    .environmentObject(userData)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true) // Hides the default back button
    }

    private func createUser() {
        guard !name.isEmpty, !username.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }

        guard !isToday(date: dateOfBirth) else {
            alertMessage = "Please select a valid date of birth."
            showAlert = true
            return
        }

        userData.saveUser(username: username, password: password)
        showThankYouMessage = true
    }

    private func resetFields() {
        name = ""
        username = ""
        password = ""
        confirmPassword = ""
        dateOfBirth = Date()
        showThankYouMessage = false
    }

    private func isToday(date: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDateInToday(date)
    }
}

struct CreateUserView_Previews: PreviewProvider {
    @State static var isLoggedIn: Bool = false

    static var previews: some View {
        CreateUserView(isLoggedIn: $isLoggedIn)
            .environmentObject(UserData())
    }
}
