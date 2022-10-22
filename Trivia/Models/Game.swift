//
//  Game.swift
//  Trivia
//
//  Created by Stephen Walton on 10/11/22.
//

import Foundation

struct Game {
    var score: Int
    var token: String
    var currentLevel: Int
    var currentLevelDifficulty: String
    var currentRound: Int
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
