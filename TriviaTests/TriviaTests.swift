//
//  TriviaTests.swift
//  TriviaTests
//
//  Created by Stephen Walton on 10/7/22.
//

import XCTest
@testable import Trivia

class TriviaTests: XCTestCase {

    func testGameControllerCategoriesLoaded() {
        // Init calls the function to load categories, which is private.  This should cover it.
        let gameController = GameController()
        XCTAssertEqual(gameController.game.categories.count, 8)
    }

    func testGetToken() {
        let gameController = GameController()
        XCTAssertGreaterThan(gameController.game.token.count, 10)
    }
    
    func testGetCurrentDifficultyLevel() {
        let gameController = GameController()
        // Force easy difficulty level
        gameController.game.currentLevel = 1
        let difficultyLevel = gameController.getCurrentLevelDifficulty()
        XCTAssertEqual(difficultyLevel, "easy")
    }
    
    func testLoadNewLevel() {
        let gameController = GameController()
        
        let previousLevel = gameController.game.currentLevel
        
        gameController.loadNewLevel()
        
        XCTAssertEqual(gameController.game.currentLevel, previousLevel + 1)
        XCTAssertEqual(gameController.game.stars, 0)
        XCTAssertEqual(gameController.game.categoriesCleared.count, 0)
        XCTAssertEqual(gameController.game.categories.count, 8)
    }
}
