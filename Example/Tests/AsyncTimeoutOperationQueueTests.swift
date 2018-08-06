//
//  AsyncTimeoutOperationQueueTests.swift
//
//  Created by severehed on 7/20/18.
//  Copyright © 2018 severehed. All rights reserved.
//

import XCTest
import AsyncTimeoutOperationQueue

class AsyncTimeoutOperationQueueTests: XCTestCase {

    private func randomUInt(_ range: ClosedRange<UInt32>) -> UInt32 {
        #if swift(>=4.2)
        return UInt32.random(in: range)
        #else
        return arc4random_uniform(range.upperBound - range.lowerBound) + range.lowerBound;
        #endif
    }
    
    private func randomDouble(_ range: ClosedRange<Double>) -> Double {
        #if swift(>=4.2)
        return Double.random(in: range)
        #else
        let random = Double(arc4random_uniform(UInt32(range.upperBound - range.lowerBound) * 1000)) / 1000.0
        return random + range.lowerBound
        #endif
    }
    
    func testAsyncTimeoutOperationQueue() {
        let queue = AsyncTimeoutOperationQueue()
        var array: [Int] = []
        let iterations = Int(randomUInt(5...10))
        queue.maxConcurrentOperationCount = 1
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        var totalTime: Double = 0
        let validationArray: [Int] = (0..<iterations).map { $0 }
        for i in (0..<iterations) {
            let time = randomDouble(1...5)
            totalTime += time
            queue.addAsyncOperation { (completion) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + time, execute: {
                    array.append(i)
                    completion?()
                    exp.fulfill()
                })
            }
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.1) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
    
    func testAsyncTimeoutOperationQueueWithTimeout() {
        let queue = AsyncTimeoutOperationQueue()
        var array: [Int] = []
        
        let iterations = Int(randomUInt(5...10))
        queue.maxConcurrentOperationCount = 1
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        var totalTime: Double = 0
        let validationArray: [Int] = (0..<iterations).map { $0 }
        for i in (0..<iterations) {
            let time = randomDouble(1...3)
            totalTime += time
            queue.addAsyncOperation({ (completion) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.distantFuture, execute: {
                    completion?()
                })
            }).onTimeout {
                array.append(i)
                exp.fulfill()
                }.timeout(time)
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.2) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
    
    func testAsyncTimeoutOperationQueueWithTimeoutRevertedParameters() {
        let queue = AsyncTimeoutOperationQueue()
        var array: [Int] = []
        
        let iterations = Int(randomUInt(5...10))
        queue.maxConcurrentOperationCount = 1
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        var totalTime: Double = 0
        let validationArray: [Int] = (0..<iterations).map { $0 }
        for i in (0..<iterations) {
            let time = randomDouble(1...3)
            totalTime += time
            queue.addAsyncOperation({ (completion) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.distantFuture, execute: {
                    completion?()
                })
            })
                .timeout(time)
                .onTimeout {
                    array.append(i)
                    exp.fulfill()
            }
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.2) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
    
    func testAsyncTimeoutOperationQueueWithDefaultTimeout() {
        let queue = AsyncTimeoutOperationQueue()
        queue.maxConcurrentOperationCount = 1
        queue.defaultTimeout = 2
        var array: [Int] = []
        
        let iterations = Int(randomUInt(5...10))
        var totalTime: Double = Double(iterations) * queue.defaultTimeout!
        
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        
        let validationArray: [Int] = (0..<iterations).map { $0 }
        
        for i in (0..<iterations) {
            let time = randomDouble(1...3)
            totalTime += time
            queue.addAsyncOperation({ (completion) in
                DispatchQueue.global().asyncAfter(deadline: DispatchTime.distantFuture, execute: {
                    completion?()
                })
            }).onTimeout {
                array.append(i)
                exp.fulfill()
            }
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.2) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
    
    func testAsyncTimeoutOperationQueueWithCompletion() {
        let queue = AsyncTimeoutOperationQueue()
        var array: [Int] = []
        
        let iterations = Int(randomUInt(5...10))
        queue.maxConcurrentOperationCount = 1
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        var totalTime: Double = 0
        let validationArray: [Int] = (0..<iterations).map { $0 }
        for i in (0..<iterations) {
            let time = randomDouble(1...5)
            totalTime += time
            queue
                .addAsyncOperation { (completion) in
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + time, execute: {
                        
                        completion?()
                        
                    })
                }
                .onCompletionOrTimeout {
                    array.append(i)
                    exp.fulfill()
            }
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.1) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
    
    func testAsyncTimeoutOperationQueueWithCompletionAndTimeout() {
        let queue = AsyncTimeoutOperationQueue()
        var array: [Int] = []
        
        let iterations = Int(randomUInt(5...10))
        queue.maxConcurrentOperationCount = 1
        let exp = expectation(description: #function)
        exp.expectedFulfillmentCount = iterations
        exp.assertForOverFulfill = true
        var totalTime: Double = 0
        let validationArray: [Int] = (0..<iterations).map { $0 }
        for i in (0..<iterations) {
            let time = randomDouble(1...3)
            totalTime += time
            queue
                .addAsyncOperation({ (completion) in
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.distantFuture, execute: {
                        completion?()
                    })
                })
                .onTimeout {
                    
                }
                .timeout(time)
                .onCompletionOrTimeout {
                    array.append(i)
                    exp.fulfill()
            }
        }
        print(#function + " expected time: \(totalTime)")
        let timeStart = Date().timeIntervalSince1970
        waitForExpectations(timeout: totalTime * 1.2) { (error) in
            XCTAssert(error == nil)
            XCTAssert(array == validationArray)
            print(#function + " actual time: \(Date().timeIntervalSince1970 - timeStart)")
        }
    }
}
