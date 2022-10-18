//
//  GameController.swift
//  Trivia
//
//  Created by Stephen Walton on 10/11/22.
//

import Foundation

class GameController {
    var game = Game(
        score: 0,
        token: ""
    )
    
    init() {
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
            
            // load previous score
            let defaults = UserDefaults.standard
            let score = defaults.integer(forKey: "score")
            self.game.score = score
        }
    }
}
