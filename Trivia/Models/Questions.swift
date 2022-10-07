//
//  Questions.swift
//  Trivia
//
//  Created by Stephen Walton on 10/7/22.
//

import Foundation

struct Questions: Codable {
    var response_code: Int
    var results: [Question]
}
