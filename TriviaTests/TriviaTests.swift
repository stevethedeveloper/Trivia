//
//  TriviaTests.swift
//  TriviaTests
//
//  Created by Stephen Walton on 10/7/22.
//

import XCTest
@testable import Trivia

class TriviaTests: XCTestCase {

    func testAllCategoriesLoaded() {
        let gameController = GameController()
        let allCategories = gameController.loadCategoriesFromJSON()
        XCTAssertEqual(allCategories?.count, 12)
    }

    func testGameControllerCategoriesLoaded() {
        let gameController = GameController()
        XCTAssertEqual(gameController.game.categories.count, 8)
    }

    func testGetToken() {
        let gameController = GameController()
        XCTAssertGreaterThan(gameController.game.token.count, 10)
    }
    
    func testCheckAnswer() {
        let vc = QuestionViewController()
        var submittedAnswer = "testing 123"
        let expectedAnswer = "testing 123"
        
        XCTAssertEqual(vc.checkAnswer(submittedAnswer: submittedAnswer, expectedAnswer: expectedAnswer), true)
        
        submittedAnswer = "testing 321"
        
        XCTAssertEqual(vc.checkAnswer(submittedAnswer: submittedAnswer, expectedAnswer: expectedAnswer), false)
    }
    
//    override func setUpWithError() throws {
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//    }
//
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
