//
//  ResponseObjectCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//
import UIKit
import FunkyNetwork
import ReactiveSwift
import Result

public class ResponseObjectCall<T: Any, C: Decodable>: HabiticaResponseCall<T, C> {
    public lazy var objectSignal: Signal<T?, NoError> = habiticaResponseSignal.skipNil().map { (habiticaResponse) in
        return habiticaResponse.data as? T
    }
    
    override func setupErrorHandler() {
        //Don't show errors to user
    }
}
