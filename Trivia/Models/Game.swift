//
//  Game.swift
//  Trivia
//
//  Created by Stephen Walton on 10/11/22.
//

import Foundation
import UIKit

struct Game: Codable {
    var score: Int
    var token: String
    var currentLevel: Int
    var categoriesCleared: [Category]
    var coins: Int
    var stars: Int
    var categories: [Category]
    var response_code: Int
    var has_connection: Bool
}

enum Levels: String {
    case easy
    case medium
    case hard
}

enum StarsText: String, CaseIterable {
    case zero, one, two, three, four, five

    var asString : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .zero: return "☆ ☆ ☆ ☆ ☆"
      case .one: return "⭐️ ☆ ☆ ☆ ☆"
      case .two: return "⭐️ ⭐️ ☆ ☆ ☆"
      case .three: return "⭐️ ⭐️ ⭐️ ☆ ☆"
      case .four: return "⭐️ ⭐️ ⭐️ ⭐️ ☆"
      case .five: return "⭐️ ⭐️ ⭐️ ⭐️ ⭐️"

      }
    }
}
