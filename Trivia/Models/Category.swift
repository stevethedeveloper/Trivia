//
//  Category.swift
//  Trivia
//
//  Created by Stephen Walton on 10/17/22.
//

import Foundation

struct Category: Codable, Equatable {
    var id: Int
    var name: String
    var image: String

    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
