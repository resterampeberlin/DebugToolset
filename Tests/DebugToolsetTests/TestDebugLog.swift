//
//  testDebugLog.swift
//  StayAtHomeTests
//
//  Created by Markus Nickels on 12.04.20.
//  Copyright © 2020 Resterampe Berlin. All rights reserved.
//

import XCTest
@testable import DebugToolset

/// use this as the standard logging functionality
var std = DebugLog()

class TestDebugLog: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    
    // MARK: - test: DebugLog
    func testDebugLog() throws {
        
        func subTestCase1() {
            XCTAssertEqual(std.indent, 1)

            std.end(self)
            
            XCTAssertEqual(std.indent, 1)
        }

        func subTestCase2() {
            func subTestCase22() {
                std.begin(self)
            }
            XCTAssertEqual(std.indent, 1)

            std.begin(self)
            
            XCTAssertEqual(std.indent, 2)
            
            subTestCase22()
            
            XCTAssertEqual(std.indent, 3)
        }

        struct TestType {
            var someValue: Int = 0
        }
        
        // we can not use any "XTC" Macros for all functions since the output goes to the console. Look at the console instead
        
        // MARK: - test case: initialization
        XCTAssertEqual(std.warnings, 0)
        XCTAssertEqual(std.errors, 0)

        print()
        
        // MARK: - test case: log something at object level
        std.log(self, message: "Object level message")
        std.log(self, message: "Object level message", highlight: .information)
        std.log(self, message: "Object level message", highlight: .warning)
        std.log(self, message: "Object level message", highlight: .error)
   
        XCTAssertEqual(std.warnings, 1)
        XCTAssertEqual(std.errors, 1)

        print()
    
        // MARK: - test case: log something without an object
        std.info("Information")
        std.warn("Warning")
        std.error("Test")
        
        XCTAssertEqual(std.warnings, 2)
        XCTAssertEqual(std.errors, 2)
        
        print()

        // MARK: - test case: add/flush
        std.add("part 1", separator: ",")
        std.add("part 2")
        std.flush()
        
        XCTAssertEqual(std.warnings, 2)
        XCTAssertEqual(std.errors, 2)
        
        print()

        // MARK: - test case: normal begin/end handling
        XCTAssertEqual(std.indent, 0)
 
        std.begin(self)

        XCTAssertEqual(std.indent, 1)
        
        std.end(self)

        XCTAssertEqual(std.indent, 0)
        
        print()

        // MARK: - test case: wrong begin/end handling at base level
        std.end(self)
        
        XCTAssertEqual(std.indent, 0)
        XCTAssertEqual(std.warnings, 3)
        
        print()

        // MARK: - test case: wrong begin/end handling at nested func level, begin missing
        std.begin(self)
        subTestCase1()
        
        XCTAssertEqual(std.indent, 1)
        
        std.end(self)
        
        XCTAssertEqual(std.indent, 0)
        XCTAssertEqual(std.warnings, 4)
        
        print()

        // MARK: - test case: wrong begin/end handling at nested func level, mutliple end missing
        std.begin(self)
        subTestCase2()
        
        XCTAssertEqual(std.indent, 3)

        std.end(self)
        
        XCTAssertEqual(std.warnings, 5)
        XCTAssertEqual(std.indent, 0)
        
        print()
        
        // MARK: - test case: variadic supported parameters in .info
        std.info("a string", 1, 2.0, true, highlight: .none)
        
        XCTAssertEqual(std.warnings, 5)
        XCTAssertEqual(std.indent, 0)
        
        print()

        // MARK: - test case: variadic suppoerted parameters in .info
        std.info("a string", TestType(), highlight: .none)
        
        XCTAssertEqual(std.warnings, 6)
        XCTAssertEqual(std.indent, 0)
        
        print()

        std.log(self)
    }

    func testPerformance() throws {
        // This is an example of a performance test case.
        self.measure {
            std.begin(self)
            std.log(self)
            std.end(self)
        }
    }
}
