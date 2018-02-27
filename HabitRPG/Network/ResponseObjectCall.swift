//
//  ResponseObjectCall.swift
//  Habitica
//
//  Created by Elliot Schrock on 9/30/17.
//  Copyright © 2017 HabitRPG Inc. All rights reserved.
//

import UIKit
import FunkyNetwork
import Eson
import ReactiveSwift
import Result

class ResponseObjectCall<T: NSObject>: AuthenticatedCall {
    public lazy var objectSignal: Signal<T?, NoError> = jsonSignal.map(ResponseObjectCall.parse)
    
    static func parse(_ json: Any) -> T? {
        if let jsonObject = json as? [String: AnyObject], let data = jsonObject["data"] {
            if data is [String: AnyObject] {
                let responseObject = Eson().fromJsonDictionary(json as? [String : AnyObject], clazz: ResponseObject<T>.self)
                return responseObject?.dataObject()
            }
        }
        return nil
    }
}
