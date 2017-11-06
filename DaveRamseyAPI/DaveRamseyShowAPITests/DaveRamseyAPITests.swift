//
//  DaveRamseyAPITests.swift
//  DaveRamseyAPITests
//
//  Created by Porter Hoskins on 11/5/17.
//  Copyright © 2017 Porter Hoskins. All rights reserved.
//

import XCTest
@testable import DaveRamseyShowAPI

class DaveRamseyAPITests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEpisodes() {
        let episodeExpectation = expectation(description: "episodes")
        
        DaveRamseyShowAPI.fetchEpisodes { episodes in
            XCTAssert(episodes.count != 0, "The API should always return episodes!")
            episodeExpectation.fulfill()
        }

        wait(for: [episodeExpectation], timeout: 30)
    }
    
    func testLiveShow() {
        let isLiveExpectation = expectation(description: "isLive")
        
        DaveRamseyShowAPI.fetchLiveShow { isLive, secondsUntilNextShow in
            defer {
                isLiveExpectation.fulfill()
            }
            
            guard isLive else {
                XCTAssertNotNil(secondsUntilNextShow)
                return
            }
        }
        
        wait(for: [isLiveExpectation], timeout: 30)
    }
    
}
