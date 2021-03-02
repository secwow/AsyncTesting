//
//  AsyncTestingTests.swift
//  AsyncTestingTests
//
//  Created by AndAdmin on 02.03.2021.
//

import XCTest
@testable import AsyncTesting

class SpyLoader: SomeLoader {
    var loadCount: Int = 0

    func load() {
        loadCount += 1
    }
}

protocol SomeLoader {
    func load()
}

class SomeAsync {
    private var loader: SomeLoader

    init(with loader: SomeLoader) {
        self.loader = loader
    }

    func load() {
        DispatchQueue.performImmediateWhenOnMainQueue { [weak self] in
            self?.loader.load()
        }
    }
}

class AsyncTestingTests: XCTestCase {
    func testExampleOnMain() throws {
        let spy = SpyLoader()
        let someAsync = SomeAsync(with: spy)

        for _ in 0..<100 {
            someAsync.load()
        }

        XCTAssertEqual(spy.loadCount, 100)
    }

    func testExampleOnBackground() throws {
        let spy = SpyLoader()
        let someAsync = SomeAsync(with: spy)

        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            for _ in 0..<100 {
                someAsync.load()
            }
        }

        XCTAssertNotEqual(spy.loadCount, 100)
    }
}
