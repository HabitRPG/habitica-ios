//
//  ResponseArrayCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/20/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift
import Result

public class ResponseArrayCall<T: NSObject>: AuthenticatedCall {
    public lazy var arraySignal: Signal<[T]?, NoError> = jsonSignal.map(ResponseArrayCall.parse)
    
    static func parse(_ json: Any) -> [T]? {
        if let jsonObject = json as? [String: AnyObject], let data = jsonObject["data"] {
            if data is [[String: AnyObject]] {
                let responseArray = Eson().fromJsonDictionary(json as? [String : AnyObject], clazz: ResponseArray<T>.self)
                return responseArray?.dataArray()
            }
        }
        return nil
    }

}
