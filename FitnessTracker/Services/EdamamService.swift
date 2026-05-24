import Foundation
import Combine

struct EdamamFood {
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fats: Double
}

class EdamamService: ObservableObject {
    @Published var searchResults: [EdamamFood] = []

    // calls the edamam nutrition api
    func searchFood(query: String, completion: @escaping ([EdamamFood]) -> Void) {
        guard !query.isEmpty else {
            completion([])
            return
        }

        let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.edamam.com/api/food-database/v2/parser?ingr=\(encoded)&app_id=\(Constants.edamamAppId)&app_key=\(Constants.edamamAppKey)"

        guard let url = URL(string: urlString) else {
            print("bad url")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("api error: \(error)")
                completion([])
                return
            }

            guard let data = data else {
                completion([])
                return
            }

            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let hints = json["hints"] as? [[String: Any]] else {
                    completion([])
                    return
                }

                var foods: [EdamamFood] = []
                for hint in hints.prefix(10) { // only show first 10
                    guard let food = hint["food"] as? [String: Any],
                          let label = food["label"] as? String,
                          let nutrients = food["nutrients"] as? [String: Any] else {
                        continue
                    }

                    let cal = Int(nutrients["ENERC_KCAL"] as? Double ?? 0)
                    let prot = nutrients["PROCNT"] as? Double ?? 0
                    let carb = nutrients["CHOCDF"] as? Double ?? 0
                    let fat = nutrients["FAT"] as? Double ?? 0

                    foods.append(EdamamFood(
                        name: label,
                        calories: cal,
                        protein: round(prot * 10) / 10,
                        carbs: round(carb * 10) / 10,
                        fats: round(fat * 10) / 10
                    ))
                }

                // remove duplicates by name
                var seen = Set<String>()
                let unique = foods.filter { seen.insert($0.name).inserted }

                completion(unique)
            } catch {
                print("parse error: \(error)")
                completion([])
            }
        }.resume()
    }
}
