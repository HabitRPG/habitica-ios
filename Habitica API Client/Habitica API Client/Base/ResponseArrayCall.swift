//
//  ResponseArrayCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import Foundation
import ReactiveSwift

public class ResponseArrayCall<T: Any, C: Decodable>: HabiticaResponseCall<[T], [C]> {
    public lazy var arraySignal: Signal<[T]?, Never> = habiticaResponseSignal.skipNil().map { (habiticaResponse) in
        return habiticaResponse.data as? [T]
    }
}
