import XCTest
import ReactiveSwift

/**
 A `TestObserver` is a wrapper around an `Observer` that saves all events to an internal array so that
 assertions can be made on a signal's behavior. To use, just create an instance of `TestObserver` that
 matches the type of signal/producer you are testing, and observer/start your signal by feeding it the
 wrapped observer. For example,
 ```
 let test = TestObserver<Int, Never>()
 mySignal.observer(test.observer)
 // ... later ...
 test.assertValues([1, 2, 3])
 ```
 */
internal final class TestObserver <Value, E: Error> {
    
    internal private(set) var events: [Signal<Value, E>.Event] = []
    internal private(set) var observer: Signal<Value, E>.Observer!
    
    internal init() {
        self.observer = Signal<Value, E>.Observer(action)
    }
    
    private func action(event: Signal<Value, E>.Event) -> () {
        self.events.append(event)
    }
    
    /// Get all of the next values emitted by the signal.
    internal var values: [Value] {
        return self.events.filter { $0.isNext }.map { $0.value! }
    }
    
    /// Get the last value emitted by the signal.
    internal var lastValue: Value? {
        return self.values.last
    }
    
    /// `true` if at least one `.Next` value has been emitted.
    internal var didEmitValue: Bool {
        return self.values.isEmpty == false
    }
    
    /// The failed error if the signal has failed.
    internal var failedError: Error? {
        return self.events.filter { $0.isFailed }.map { $0.error! }.first
    }
    
    /// `true` if a `.Failed` event has been emitted.
    internal var didFail: Bool {
        return self.failedError != nil
    }
    
    /// `true` if a `.Completed` event has been emitted.
    internal var didComplete: Bool {
        return self.events.filter { $0.isCompleted }.isEmpty == false
    }
    
    /// `true` if a .Interrupt` event has been emitted.
    internal var didInterrupt: Bool {
        return self.events.filter { $0.isInterrupted }.isEmpty == false
    }
    
    internal func assertDidComplete(message: String = "Should have completed.",
                                    file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didComplete, message, file: file, line: line)
    }
    
    internal func assertDidFail(message: String = "Should have failed.",
                                file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didFail, message, file: file, line: line)
    }
    
    internal func assertDidNotFail(message: String = "Should not have failed.",
                                   file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didFail, message, file: file, line: line)
    }
    
    internal func assertDidInterrupt(message: String = "Should have failed.",
                                     file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didInterrupt, message, file: file, line: line)
    }
    
    internal func assertDidNotInterrupt(message: String = "Should not have failed.",
                                        file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didInterrupt, message, file: file, line: line)
    }
    
    internal func assertDidNotComplete(message: String = "Should not have completed",
                                       file: StaticString = #file, line: UInt = #line) {
        XCTAssertFalse(self.didComplete, message, file: file, line: line)
    }
    
    internal func assertDidEmitValue(message: String = "Should have emitted at least one value.",
                                     file: StaticString = #file, line: UInt = #line) {
        XCTAssert(self.values.isEmpty == false, message, file: file, line: line)
    }
    
    internal func assertDidNotEmitValue(message: String = "Should not have emitted any values.",
                                        file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(0, self.values.count, message, file: file, line: line)
    }
    
    internal func assertDidTerminate(
        message: String = "Should have terminated, i.e. completed/failed/interrupted.",
        file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(self.didFail || self.didComplete || self.didInterrupt, message, file: file, line: line)
    }
    
    internal func assertDidNotTerminate(
        message: String = "Should not have terminated, i.e. completed/failed/interrupted.",
        file: StaticString = #file, line: UInt = #line) {
        XCTAssertTrue(!self.didFail && !self.didComplete && !self.didInterrupt, message, file: file, line: line)
    }
    
    internal func assertValueCount(count: Int, _ message: String? = nil,
                                   file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(count, self.values.count, message ?? "Should have emitted \(count) values",
            file: file, line: line)
    }
}

extension TestObserver where Value: Equatable {
    internal func assertValue(value: Value, _ message: String? = nil,
                              file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
        XCTAssertEqual(value, self.lastValue, message ?? "A single value of \(value) should have been emitted",
            file: file, line: line)
    }
    
    internal func assertLastValue(value: Value, _ message: String? = nil,
                                  file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(value, self.lastValue, message ?? "Last emitted value is equal to \(value).",
            file: file, line: line)
    }
    
    internal func assertValues(values: [Value], _ message: String = "",
                               file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(values, self.values, message, file: file, line: line)
    }
}

extension TestObserver where Value: Sequence, Value.Iterator.Element: Equatable {
    
    internal func assertValue(value: Value, _ message: String? = nil,
                              file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(1, self.values.count, "A single item should have been emitted.", file: file, line: line)
        XCTAssertEqual(Array(value), self.lastValue.map(Array.init) ?? [],
                       message ?? "A single value of \(value) should have been emitted",
            file: file, line: line)
    }
    
    internal func assertLastValue(value: Value, _ message: String? = nil,
                                  file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(Array(value), self.lastValue.map(Array.init) ?? [],
                       message ?? "Last emitted value is equal to \(value).",
            file: file, line: line)
    }
    
}
