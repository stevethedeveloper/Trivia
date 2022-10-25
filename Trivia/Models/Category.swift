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
// remove
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decodeWrapper(key: .id, defaultValue: -1)
//        self.name = try container.decodeWrapper(key: .name, defaultValue: "")
//        self.image = try container.decodeWrapper(key: .image, defaultValue: "")
//        self.completed = try container.decodeWrapper(key: .completed, defaultValue: false)
//        self.locked = try container.decodeWrapper(key: .locked, defaultValue: false)
//    }
}
