//
//  ResponseArrayCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import UIKit
import FunkyNetwork
import ReactiveSwift
import Result

public class ResponseArrayCall<T: Any, C: Codable>: HabiticaResponseCall<[T], [C]> {
    public lazy var arraySignal: Signal<[T]?, NoError> = habiticaResponseSignal.skipNil().map { (habiticaResponse) in
        return habiticaResponse.data as? [T]
    }
}
