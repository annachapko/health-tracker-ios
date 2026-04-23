import Foundation

// Define NutritionAPIError to handle different error cases.
enum NutritionAPIError: Error {
    case invalidQuery
    case networkError
    case noData
    case invalidURL
    case jsonDecodingError
}

// API Manager to fetch and handle food data from the Nutritionix API.
class NutritionAPIManager: ObservableObject {
    @Published var nutritionData: [Food] = []  // Holds the list of food data.
    @Published var isLoading: Bool = false      // Tracks loading state.
    @Published var errorMessage: String? = nil  // Holds any error messages.
    
    private let apiUrl = "https://trackapi.nutritionix.com/v2/natural/nutrients"  // API URL for Nutritionix.
    private let appID = "ec8c0c2f"  // Your Nutritionix app ID.
    private let appKey = "f72493238a2da481214df0d8f27cdcbd"  // Your Nutritionix app key.
    
    // Fetch food data from the Nutritionix API based on a query.
    func fetchNutritionData(for query: String, completion: @escaping (Result<[Food], Error>) -> Void) {
        // Check if the query is not empty.
        guard !query.isEmpty else {
            print("Query is empty.")
            completion(.failure(NutritionAPIError.invalidQuery))
            return
        }
        
        // Prevent multiple fetch requests while one is already in progress.
        guard !isLoading else {
            print("Already fetching data, please wait.")
            return
        }
        
        // Clear previous data and set loading state.
        DispatchQueue.main.async {
            self.nutritionData = []  // Clear old data.
            self.isLoading = true     // Set loading state to true.
            self.errorMessage = nil   // Reset the error message.
        }
        
        // Ensure the URL is valid.
        guard let url = URL(string: apiUrl) else {
            print("Invalid URL.")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid API URL."  // Update error message.
            }
            completion(.failure(NutritionAPIError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appID, forHTTPHeaderField: "x-app-id")
        request.setValue(appKey, forHTTPHeaderField: "x-app-key")
        
        // Create JSON request body.
        let body = ["query": query]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error creating JSON body: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to create request body."  // Update error message.
            }
            completion(.failure(NutritionAPIError.jsonDecodingError))
            return
        }
        
        // Perform the network request.
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false  // Reset loading state.
                
                // Handle network errors.
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription  // Update error message.
                    completion(.failure(NutritionAPIError.networkError))
                    return
                }
                
                // Handle no data error.
                guard let data = data else {
                    print("No data received from API.")
                    self.errorMessage = "No data received. Please try again."  // Update error message.
                    completion(.failure(NutritionAPIError.noData))
                    return
                }
                
                // Attempt to decode the JSON response.
                do {
                    let decodedResponse = try JSONDecoder().decode(NutritionResponse.self, from: data)
                    // Check if there is any food data.
                    if decodedResponse.foods.isEmpty {
                        self.errorMessage = "No food data found. Please check the spelling of the food item."  // Update error message.
                        completion(.failure(NutritionAPIError.noData))
                    } else {
                        self.nutritionData = decodedResponse.foods
                        completion(.success(decodedResponse.foods))  // Return success with food data.
                    }
                } catch {
                    print("Failed to decode JSON: \(error.localizedDescription)")
                    self.errorMessage = "Failed to decode the response. Please try again."  // Update error message.
                    completion(.failure(NutritionAPIError.jsonDecodingError))
                }
            }
        }
        
        task.resume()  // Start the network request.
    }
}
