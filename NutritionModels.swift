import Foundation

struct NutritionResponse: Codable {
    let foods: [Food]
}

struct Food: Codable, Identifiable {
    var id: String { foodName }
    let foodName: String
    let nfCalories: Double
    let nfTotalFat: Double
    let nfProtein: Double
    let nfTotalCarbohydrate: Double
    let nfSugars: Double
    let dietLabels: [String]?
    let fullNutrients: [FullNutrient]
    let servingWeightGrams: Double?

    enum CodingKeys: String, CodingKey {
        case foodName = "food_name"
        case nfCalories = "nf_calories"
        case nfTotalFat = "nf_total_fat"
        case nfProtein = "nf_protein"
        case nfTotalCarbohydrate = "nf_total_carbohydrate"
        case nfSugars = "nf_sugars"
        case dietLabels = "diet_labels"
        case fullNutrients = "full_nutrients"
        case servingWeightGrams = "serving_weight_grams"
    }
}

struct FullNutrient: Codable {
    let attrID: Int
    let value: Double
    
    enum CodingKeys: String, CodingKey {
        case attrID = "attr_id"
        case value
    }
}

