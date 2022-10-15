//
//  Question.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import Foundation

struct Question: Codable {
    var category: String
    var type: String
    var difficulty: String
    var question: String
    var correct_answer: String
    var incorrect_answers: [String]
}

enum DifficultyPoints: String {
    case easy, medium, hard

    var pointsValue: Int {
        switch self {
        case .easy:
            return 100000
        case .medium:
            return 250000
        case .hard:
            return 500000
        }
    }
}
