//
//  Interactor.swift
//  Habitica
//
//  Created by Phillip Thelen on 06/03/2017.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import Foundation
import ReactiveSwift

class Interactor<Input, Output> {

    var reactive: Signal<Output, NSError>
    private let observer: Signal<Input, NSError>.Observer

    init() {
        let (reactive, observer) = Signal<Input, NSError>.pipe()
        self.observer = observer
        self.reactive = Signal<Output, NSError>.never
        self.reactive = configure(signal: reactive)
    }

    func configure(signal: Signal<Input, NSError>) -> Signal<Output, NSError> {
        fatalError("Subclasses need to implement the `configure(signal:)` method.")
    }

    func run(with: Input) {
        observer.send(value: with)
    }
}
