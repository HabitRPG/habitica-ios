// https://github.com/kickstarter/Kickstarter-ReactiveExtensions/blob/master/ReactiveExtensionsTests/TestHelpers/Event-Extensions.swift

import ReactiveSwift

internal extension Signal.Event {
    internal var isNext: Bool {
        if case .value = self {
            return true
        }
        return false
    }

    internal var isFailed: Bool {
        if case .failed = self {
            return true
        }
        return false
    }

    internal var isInterrupted: Bool {
        if case .interrupted = self {
            return true
        }
        return false
    }
}
