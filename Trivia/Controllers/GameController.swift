//
//  GameController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/11/22.
//

import Foundation

final class GameController {
    // game holds the entire game state and is injected into every view that needs it using dependency injection
    var game = Game(
        score: 0,
        token: "",
        currentLevel: 1,
        categoriesCleared: [Category](),
        coins: 0,
        stars: 0,
        categories: [Category]()
    )
    
    let starsText = [
        0: "☆ ☆ ☆ ☆ ☆",
        1: "⭐️ ☆ ☆ ☆ ☆",
        2: "⭐️ ⭐️ ☆ ☆ ☆",
        3: "⭐️ ⭐️ ⭐️ ☆ ☆",
        4: "⭐️ ⭐️ ⭐️ ⭐️ ☆",
        5: "⭐️ ⭐️ ⭐️ ⭐️ ⭐️"
    ]
    
    init() {
        // Take care of first setup.  Get token, load the game state, and list of categories
        loadGameState()
        getToken()
    }
    
    // Load game state from user defaults
    func loadGameState() {
        if let data = UserDefaults.standard.object(forKey: "game") as? Data,
           let game = try? JSONDecoder().decode(Game.self, from: data) {
            self.game = game
            self.game.stars = self.game.categoriesCleared.count
        } else {
            let allCategories = loadCategoriesFromJSON() ?? []
            game.categories = Array(allCategories.prefix(8)).shuffled()
        }
    }

    // Save game state to user defaults
    func saveGameState() {
        if let encoded = try? JSONEncoder().encode(game) {
            UserDefaults.standard.set(encoded, forKey: "game")
        }
    }
    
    // This is called on init, but also can be called elsewhere if a new token is needed
    func getToken() {
        // get new token
        let urlString: String
        urlString = "https://opentdb.com/api_token.php?command=request"
        
        let queue = DispatchQueue(label: "com.app.queue")
        queue.sync {
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    let object = try? JSONSerialization.jsonObject(
                        with: data,
                        options: []
                    )

                    if let dict = object as? [AnyHashable:Any] {
                        if let newToken = dict["token"] as? String {
                            self.game.token = newToken
                        } else {
                            self.game.token = ""
                        }
                    }
                }
            }
            
        }
    }
    
    func getCurrentLevelDifficulty() -> String {
        switch game.currentLevel {
        case 1...5:
            return "easy"
        case 6...15:
            return "medium"
        default:
            return "hard"
        }
    }

    // Load categories from JSON file
    func loadCategoriesFromJSON() -> [Category]? {
        if let url = Bundle.main.url(forResource: "categories", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(Categories.self, from: data)
                return jsonData.categories
            } catch {
                print("error:\(error)")
            }
        }
        return nil
    }
    
}
