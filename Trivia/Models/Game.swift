//
//  Game.swift
//  Trivia
//
//  Created by Stephen Walton on 10/11/22.
//

import Foundation

struct Game: Codable {
    var score: Int
    var token: String
    var currentLevel: Int
    var categoriesCleared: [Category]
    var coins: Int
    var stars: Int
    var categories: [Category]
}

enum Levels: String {
    case easy
    case medium
    case hard
}
