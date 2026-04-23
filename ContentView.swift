import SwiftUI

struct ContentView: View {
    @StateObject private var nutritionAPIManager = NutritionAPIManager()
    @State private var foodQuery = ""  // Query text
    @State private var showingErrorAlert = false

    var body: some View {
        NavigationView {
            VStack {
                // TextField to input the food name
                TextField("Enter food name", text: $foodQuery)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(nutritionAPIManager.isLoading)  // Disable text field while loading

                // Button to fetch data
                Button("Fetch Nutrition Info") {
                    if !foodQuery.isEmpty {
                        nutritionAPIManager.fetchNutritionData(for: foodQuery) { result in
                            switch result {
                            case .success(let data):
                                print("Successfully fetched data: \(data)")
                            case .failure(let error):
                                print("Error fetching data: \(error.localizedDescription)")
                                showingErrorAlert = true
                            }
                        }
                    }
                }
                .padding()
                .disabled(foodQuery.isEmpty || nutritionAPIManager.isLoading)  // Disable while loading

                // Loading spinner
                if nutritionAPIManager.isLoading {
                    ProgressView("Loading...")
                        .padding()
                }

                // Error message display
                if let errorMessage = nutritionAPIManager.errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundColor(.red)
                        .padding()
                }

                // List of nutrition data
                if !nutritionAPIManager.nutritionData.isEmpty {
                    List(nutritionAPIManager.nutritionData) { food in
                        VStack(alignment: .leading) {
                            Text(food.foodName)
                                .font(.headline)
                            Text("Calories: \(food.nfCalories, specifier: "%.0f")")
                            Text("Fat: \(food.nfTotalFat, specifier: "%.1f") g")
                            Text("Protein: \(food.nfProtein, specifier: "%.1f") g")
                            Text("Carbs: \(food.nfTotalCarbohydrate, specifier: "%.1f") g")
                            Text("Sugar: \(food.nfSugars, specifier: "%.1f") g")

                            if !food.fullNutrients.isEmpty {
                                Text("Nutrient Breakdown:")
                                    .font(.subheadline)
                                ForEach(food.fullNutrients, id: \.attrID) { nutrient in
                                    Text("\(nutrient.attrID): \(nutrient.value, specifier: "%.1f")")
                                        .italic()
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Nutrition Info")
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text("Error"), message: Text("Failed to fetch nutrition data. Please try again."), dismissButton: .default(Text("OK")))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
