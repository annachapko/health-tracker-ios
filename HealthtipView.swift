import SwiftUI
import FSCalendar

// Global structs for MealItem and NutritionData
struct SavedItem: Codable {
    var name: String
    var calories: Double
    var mealType: String
}

struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let date: Date
    var mealType: String
    
    init(name: String, calories: Int, date: Date, mealType: String) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.date = date
        self.mealType = mealType
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case snack = "Snack"
    case dinner = "Dinner"
    case drink = "drink"
}

struct NutritionData {
    var nfCalories: Double
    var nfTotalFat: Double
    var nfProtein: Double
    var nfTotalCarbohydrate: Double
    var nfSugars: Double
    var servingWeightGrams: Double?
    var mealType: String
    
    enum MealType: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case snack = "Snack"
        case dinner = "Dinner"
    }
}

struct HealthTipView: View {
    @State private var isLoading = false
    @State private var selectedDate = Date()
    @State var savedDates: [Date] = []
    @State private var query = ""
    @State private var nutritionData: NutritionData? = nil
    @State private var isDataFetched: Bool = false
    @State private var errorMessage: String? = nil
    @State private var currentMonth = Date()
    @State private var savedItems: [Date: [(name: String, calories: Double, mealType: String)]] = [:]
    @ObservedObject var apiManager = NutritionAPIManager()
    @State private var selectedMealType: MealType = .breakfast // Use MealType directly
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Header
                Text("Health Tip Finder")
                    .font(.headline)
                    .fontWeight(.medium)
                
                // Query Input
                TextField("Enter food name", text: $query)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.blue, lineWidth: 0.8))
                    .padding(.horizontal, 8)
                    .onChange(of: query) { newValue in
                            // Clear nutrition facts if the query is modified or cleared
                            if newValue.isEmpty {
                                nutritionData = nil
                                isDataFetched = false
                                errorMessage = nil
                            } else {
                                fetchNutritionData()
                            }
                        }
                
                // Fetch Button
                Button(action: fetchNutritionData) {
                    Text("Fetch Nutrition Facts")
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(isLoading ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .padding(.horizontal, 8)
                .disabled(isLoading)
                
                // Nutrition Facts
                if let nutritionData = nutritionData {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Nutrition Facts for \(query):")
                        Text("Calories: \(nutritionData.nfCalories, specifier: "%.2f") kcal")
                        Text("Total Fat: \(nutritionData.nfTotalFat, specifier: "%.2f") g")
                        Text("Protein: \(nutritionData.nfProtein, specifier: "%.2f") g")
                        Text("Carbohydrates: \(nutritionData.nfTotalCarbohydrate, specifier: "%.2f") g")
                        Text("Sugars: \(nutritionData.nfSugars, specifier: "%.2f") g")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(6)
                    .padding(.horizontal, 8)
                }
                HStack {
                                Button(action: goToPreviousMonth) {
                                    Image(systemName: "chevron.left")
                                        .padding(4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(6)
                                        .frame(width: 30, height: 30) // Smaller button
                                }

                                Spacer()

                                Spacer()

                                Button(action: goToNextMonth) {
                                    Image(systemName: "chevron.right")
                                        .padding(4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(6)
                                        .frame(width: 30, height: 30) // Smaller button
                                }
                            }
                            .padding(.horizontal, 8)

                            // Calendar Section
                            CalendarView(
                                selectedDate: $selectedDate,
                                currentMonth: $currentMonth,
                                onDateChange: updateSavedItems,
                                savedDates: Set(savedDates)
                            )
                            .frame(height: 250)
                            .padding(.horizontal, 16)
                Text("Total Calories for \(formatDate(selectedDate)): \(totalCalories(), specifier: "%.2f") kcal")
                                    .font(.headline)
                                    .padding(.horizontal, 8)
                
                // Save Button
                Button(action: saveData) {
                    Text("Save")
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .padding(.horizontal, 8)
                
                if let items = savedItems[normalizeDate(selectedDate)] {
                    ForEach(items.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(items[index].name)
                                        .font(.headline)
                                    Text("Calories: \(items[index].calories, specifier: "%.2f") kcal")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            
                            // Picker for meal type
                            Picker("Meal Type", selection: Binding(
                                get: {
                                    items[index].mealType
                                },
                                set: { newValue in
                                    // Update meal type and persist changes
                                    savedItems[normalizeDate(selectedDate)]?[index].mealType = newValue
                                    saveToUserDefaults() // Save changes immediately
                                }
                            )) {
                                ForEach(MealType.allCases, id: \.self) { mealType in
                                    Text(mealType.rawValue).tag(mealType.rawValue)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(6)
                        .padding(.horizontal, 8)
                    }
                    
                    // Clear Button
                    Button(action: clearSavedItems) {
                        Text("Clear Saved Items")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(10)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }
                    .padding(.horizontal, 8)
                } else {
                    Text("No saved items for this date.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
        }
        .onAppear(perform: loadFromUserDefaults)
    }
    
    func totalCalories() -> Double {
            let normalizedDate = normalizeDate(selectedDate)
            return savedItems[normalizedDate]?.reduce(0) { $0 + $1.calories } ?? 0
        }
    
    // Date Formatter
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Navigate to the previous month
    func goToPreviousMonth() {
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previousMonth
        }
    }
    
    // Navigate to the next month
    func goToNextMonth() {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = nextMonth
        }
    }
    func getMonthYearString(from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    
    func fetchNutritionData() {
        guard !query.isEmpty else {
            return
        }
        
        // Reset previous data before fetching new data
        self.nutritionData = nil
        self.isDataFetched = false
        self.errorMessage = nil  // Clear any previous error message
        
        // Proceed with the actual data fetching using trailing closure
        self.apiManager.fetchNutritionData(for: self.query) { result in
                       
            switch result {
            case .success(let nutritionData):
                if !nutritionData.isEmpty {
                    
                    if let firstFood = nutritionData.first {
                        self.nutritionData = NutritionData(
                            nfCalories: firstFood.nfCalories,
                            nfTotalFat: firstFood.nfTotalFat,
                            nfProtein: firstFood.nfProtein,
                            nfTotalCarbohydrate: firstFood.nfTotalCarbohydrate,
                            nfSugars: firstFood.nfSugars,
                            servingWeightGrams: firstFood.servingWeightGrams,
                            mealType: self.selectedMealType.rawValue
                        )
                        self.isDataFetched = true
                    }
                } else {
                    self.nutritionData = nil
                    self.isDataFetched = false
                    self.errorMessage = "No data found for \(self.query)"  // Show error message
                }
                
            case .failure(let error):
                // Handle failure: print error
                self.nutritionData = nil
                self.isDataFetched = false
                self.errorMessage = "Failed to fetch nutrition data: \(error.localizedDescription)"  // Show error message
            }
        }
    }
    
    func saveData() {
        guard !query.isEmpty, let nutritionData = nutritionData else { return }
        
        let normalizedDate = normalizeDate(selectedDate)
        let entry = (name: query, calories: nutritionData.nfCalories, mealType: selectedMealType.rawValue)

        if savedItems[normalizedDate] == nil {
            savedItems[normalizedDate] = []
        }

        let foodEntry = FoodEntry(name: query, calories: Int(nutritionData.nfCalories), date: selectedDate, mealType: selectedMealType.rawValue)
                
        if !savedItems[normalizedDate]!.contains(where: { $0.name == entry.name }) {
            savedItems[normalizedDate]?.append(entry)
            saveToUserDefaults()
            clearData()
        }
    }
    func clearData() {
        nutritionData = nil
        query = ""
        isDataFetched = false
        errorMessage = nil // Clear any error message
    }
    
    
    
    
    
    
    func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for: date)
    }
    
    
    
    
    
    func updateSavedItems(newDate: Date) {
        selectedDate = newDate
        let normalizedDate = normalizeDate(newDate) // Normalize date
        
        if let items = savedItems[normalizedDate], !items.isEmpty {
            // Update the current saved items for the UI to show dynamically
            self.savedItems[normalizedDate] = items
        } else {
            // Handle case where no items are found
            self.savedItems[normalizedDate] = []
        }
    }
    
    // Save the savedItems to UserDefaults
    func saveToUserDefaults() {
        let encoder = JSONEncoder()
        let stringifiedItems = savedItems.reduce(into: [String: [SavedItem]]()) { result, item in
            let dateString = ISO8601DateFormatter().string(from: item.key)
            result[dateString] = item.value.map { entry in
                SavedItem(name: entry.name, calories: entry.calories, mealType: entry.mealType)
            }
        }
        if let encodedData = try? encoder.encode(stringifiedItems) {
            UserDefaults.standard.set(encodedData, forKey: "savedItems")
        }
    }
    
    func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: "savedItems") else { return }
        let decoder = JSONDecoder()
        if let decodedData = try? decoder.decode([String: [SavedItem]].self, from: data) {
            let reformattedItems = decodedData.reduce(into: [Date: [(name: String, calories: Double, mealType: String)]]()) { result, item in
                if let date = ISO8601DateFormatter().date(from: item.key) {
                    result[date] = item.value.map { entry in
                        (name: entry.name, calories: entry.calories, mealType: entry.mealType)
                    }
                }
            }
            self.savedItems = reformattedItems
        }
    }

    // Clear saved items for the selected date
    func clearSavedItems() {
        let normalizedDate = normalizeDate(selectedDate)
        savedItems[normalizedDate]?.removeAll()
        saveToUserDefaults() // Save the updated data back to UserDefaults
    }
}

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    var onDateChange: (Date) -> Void
    var savedDates: Set<Date> // Track dates with events

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scope = .month

        // Set the calendar's frame to a smaller size
        calendar.frame = CGRect(x: 0, y: 0, width: 250, height: 250) // Adjust as needed

        // Customize font sizes for month and day labels
        calendar.appearance.headerTitleFont = UIFont.systemFont(ofSize: 14)
        calendar.appearance.weekdayFont = UIFont.systemFont(ofSize: 12)
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 12)

        // Adjust overall appearance for events and selection
        calendar.appearance.eventDefaultColor = UIColor.blue
        calendar.appearance.eventSelectionColor = UIColor.red
        calendar.appearance.selectionColor = UIColor.lightGray

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate, scrollToDate: true)
        uiView.setCurrentPage(currentMonth, animated: false)
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        var parent: CalendarView

        init(_ parent: CalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.onDateChange(date)
        }

        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleFor date: Date) -> String? {
            let formatter = DateFormatter()
            formatter.dateFormat = "d"
            return formatter.string(from: date)
        }

        // Modify cell appearance to adjust size indirectly
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, configureCell cell: FSCalendarCell, for date: Date) {
            // Modify cell layout or style here as needed (e.g., font size, background color)
            cell.titleLabel?.font = UIFont.systemFont(ofSize: 12) // Adjust font size for day numbers
        }
    }
}
